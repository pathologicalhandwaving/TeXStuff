packagedata               = packagedata or { }
packagedata.beegradients  = { }
local beegradients        = packagedata.beegradients

local processorid         = "beegradients" --- name of callback

local err, warn, info
if luatexbase then
  err, warn, info = luatexbase.provides_module {
    name          = "beegradients",
    version       = 42,
    date          = "2013-09-07 17:03:42+0200",
    descriptions  = "http://tex.stackexchange.com/q/131883/14066",
    author        = "Philipp Gesang",
    copyright     = "Philipp Gesang",
    license       = "BSD 2 clause",
  }
end

local lpeg                = require "lpeg"
local C, Cf, Cg, Ct       = lpeg.C, lpeg.Cf, lpeg.Cg, lpeg.Ct
local P, R, S             = lpeg.P, lpeg.R, lpeg.S
local lpegmatch           = lpeg.match

local unpack              = unpack or table.unpack

local stringformat        = string.format
local stringis_empty      = string.is_empty
local tableswapped        = table.swapped

local nodes               = nodes
local nodecodes           = nodes.nodecodes or tableswapped (node.types ())
local hlist_t             = nodecodes.hlist
local vlist_t             = nodecodes.vlist
local glyph_t             = nodecodes.glyph
local disc_t              = nodecodes.disc
local whatsit_t           = nodecodes.whatsit
local pdf_literal_t       = 8

local traversenodes       = node.traverse
local traversenodetype    = node.traverse_id
local countnodes          = node.count
local newnode             = node.new
local copynode            = node.copy
local insertnodebefore    = node.insert_before
local insertnodeafter     = node.insert_after

require "lualibs" --- requires extended set including util-prs.lua

local settingstoarray     = utilities and utilities.parsers.settings_to_array

if not settingstoarray then --- old Lualibs

  local comma      = P","
  local spacechar  = S" \f\n\r\t\v"
  local separator  = comma * spacechar^0
  local item       = C((1 - comma - spacechar)^1)
  local p_settings = spacechar^0
                   * item
                   * (separator * item)^0
                   * (separator + spacechar^0)

  settingstoarray = function (settings)
    return lpegmatch (Ct (p_settings), settings)
  end

end

local practically_zero = 0.003921568627451
local practically_one  = 0.99607843137255

local parse_gradient do

  local tonumber16 = function (n) return tonumber (n, 16) end

  local digit       = R"09"
  local hexdigit    = R("09", "af", "AF")
  local dash        = P"-"
  local colon       = P":"
  local asterisk    = P"*"
  --- values:
  --- hexcolor    -> 0xf00ba7         (triplet of hex octets, r->g->b)
  --- deccolor    -> 123*44*111       (triplet of decimal octets: r->g->b)
  --- speccolor   -> r:210*g:32*b:145 (prefixed octets, any order)
  local hexcolor    = Ct (P"0x" * Cg (hexdigit * hexdigit / tonumber16, "r")
                                * Cg (hexdigit * hexdigit / tonumber16, "g")
                                * Cg (hexdigit * hexdigit / tonumber16, "b"))
  local decexp      = digit * digit^-1 * digit^-1
  local deccolor    = Ct (Cg (decexp / tonumber, "r") * asterisk
                        * Cg (decexp / tonumber, "g") * asterisk
                        * Cg (decexp / tonumber, "b"))
  local specexp     = C(S"rgb") * colon * (C(decexp) / tonumber)
  local speccolor   = Cf (Ct ""
                        * Cg (specexp) * asterisk
                        * Cg (specexp) * asterisk
                        * Cg (specexp),
                        rawset)
  local colexp      = hexcolor + deccolor + speccolor

  local zero        = { 0, 0, 0 } --- fallback

  --- string -> float * float * float

  parse_color = function (raw)
    local color = lpegmatch (colexp, raw)

    local r = color.r / 255
    local g = color.g / 255
    local b = color.b / 255

    if r < practically_zero then r = 0 end
    if r > practically_one  then r = 1 end

    if g < practically_zero then g = 0 end
    if g > practically_one  then g = 1 end

    if b < practically_zero then b = 0 end
    if b > practically_one  then b = 1 end

    return { r, g, b }
  end

end



local gradients = { } --- (float * float * float) list

--- string -> unit

local definegradients = function (groupid, raw)

  local group         = gradients [groupid]
  if group then
    warn (stringformat ("Gradient group %q already defined, redefining.",
                        groupid))
  else
    group = { }
  end

  local definitions   = settingstoarray (raw)

  if #definitions < 1 then
    warn (stringformat ("Need at least one definition in gradient group %q, skipping.",
                        groupid))
    return nil
  end

  for i = 1, #definitions do
    local definition = definitions [i]
    if definition and not stringis_empty (definition) then
      group [#group + 1] = parse_color (definition)
    end
  end

  gradients [groupid] = group
end

beegradients.define = definegradients



local pdf_literal = newnode(whatsit_t, pdf_literal_t)

local get_colornode = function (r, g, b)
  local push, pop = copynode (pdf_literal), copynode (pdf_literal)
  local pushcolor = stringformat ("%.3g %.3g %.3g rg", r, g, b)
  local popcolor  = "0 g"
  push.mode, push.data = 1, pushcolor
  pop.mode,  pop.data  = 1, popcolor
  return push, pop
end

--- more accurate, recursive glyph counter than node.count;
--- this includes, for instance, the lowered -Y´E¡ in \TeX
--- node_t -> int? -> int

local countglyphs countglyphs = function (hd, cnt)
  cnt = cnt or 0
  for n in traversenodes (hd) do
    local nid = n.id
    if nid == glyph_t or nid == disc_t then
      cnt = cnt + 1
    elseif nid == hlist_t or nid == vlist_t then
      cnt = countglyphs (n.list, cnt)
    end
  end

  return cnt
end

--- node_t -> float -> float -> float ->
--         -> float -> float -> float -> node_t

local colorize_glyphs colorize_glyphs = function (hd, done,
                                                  r, g, b,
                                                  rstep, gstep, bstep)

  local cur = hd

  while cur do
    local id = cur.id

    if id == glyph_t or id == disc_t then

      local before, after       = get_colornode (r, g, b)
      local curprev, curnext    = cur.prev, cur.next

      before.next, cur.prev     = cur, before
      after.prev, cur.next      = cur, after

      if not curprev then --- first
        hd = before
      else
        before.prev, curprev.next = curprev, before
      end

      if curnext then
        after.next, curnext.prev  = curnext, after
      end -- else last node
      
      done = done + 1
      cur  = curnext

      if cur then
        r = r + rstep
        g = g + gstep
        b = b + bstep

        --- safeguard against rounding

        if r < practically_zero then r = 0 end
        if r > practically_one  then r = 1 end

        if g < practically_zero then g = 0 end
        if g > practically_one  then g = 1 end

        if b < practically_zero then b = 0 end
        if b > practically_one  then b = 1 end
      end

    elseif id == hlist_t or id == vlist_t then

      local list = cur.list
      if list then
        cur.list, done = colorize_glyphs (cur.list, done,
                                          r, g, b,
                                          rstep, gstep, bstep)
      end

      cur   = cur.next

    else

      cur   = cur.next

    end

  end

  --print (stringformat ("final>  %.3f %.3f %.3f -A× %d", r, g, b, done))

  return hd, done
end

local lineprocessor = function (hd, from, to)

  local list    = hd.list
  local nglyphs = countglyphs (list)
  local nsteps  = nglyphs - 1

  local rstart, gstart, bstart = unpack (from)

  local rstep = (to [1] - rstart) / nsteps
  local gstep = (to [2] - gstart) / nsteps
  local bstep = (to [3] - bstart) / nsteps

  --print (stringformat ("from>   %.3f %.3f %.3f", rstart, gstart, bstart))
  --print (stringformat ("to>     %.3f %.3f %.3f", to [1], to [2], to [3]))
  --print (stringformat ("step>   %.3f %.3f %.3f × %d", rstep,  gstep,  bstep, nglyphs))
  --print (">>", nglyphs, countnodes (glyph_t, list), from, to)

  local glyphs_done
  hd.list, glyphs_done = colorize_glyphs  (list, 0,
                                           rstart, gstart, bstart,
                                           rstep,  gstep,  bstep)
  --print (">>", nglyphs, glyphs_done, from, to)
end

local currentgroup
local currentgradient = 1

local processor = function (hd)
  local group       = gradients [currentgroup]
  local ngradients  = #group

  if not group then
    warn (stringformat ("No such gradient group: %q, bailing out.",
                        currentgroup))
    return hd
  end

  for line in traversenodetype (hlist_t, hd) do

    local fromcolor = group [currentgradient]

    currentgradient = currentgradient + 1
    if currentgradient > ngradients then
      currentgradient = 1
    end

    local tocolor   = group [currentgradient]

    lineprocessor (line, fromcolor, tocolor)

  end

  return hd
end

local active = false

local enable = function (groupid)

  if not stringis_empty (groupid) then
    if currentgroup ~= groupid then -- reset gradient pointer
      currentgradient = 1
    end
    currentgroup = groupid
  end

  if currentgroup == nil then
    warn "Cannot inject node processor: no gradient group defined."
    return
  end

  if active == false then

    info (stringformat ("Injecting node processor, active group %q.",
                        currentgroup))
    luatexbase.add_to_callback ("post_linebreak_filter",
                                processor,
                                processorid)
    active = true
  end

end

local disable = function ()

  if active == true then
    info "Removing node processor."
    luatexbase.remove_from_callback ("post_linebreak_filter",
                                     processorid)
    active = false
  end

end

beegradients.enable     = enable
beegradients.disable    = disable

