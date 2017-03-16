(*
Notes: 
Ver. 2.11
Created by macmadness86 on 29.12.2013

Author of TeX Tutorials on YouTube
http://www.youtube.com/user/XeTeXTutorials?feature=watch

StackExchange User
http://stackoverflow.com/users/1236128/macmadness86

Instructions for use:
Have Microsoft Word document open. The frontmost document will be processed. The script creates a replica before processing, in order to avoid losing data. This document remains open when the script is finished and its contents can be copied to a tex editor e.g. TeXShop and compiled.

Version Notes:
26.12.2013 version 2.0 improved the table support. Now tables are coded as centered tabu tables.
29.12.2013 version 2.1 added list support using standard bullet or simple numbering buttons on the Word GUI. Supports only 1 embedded list.

Issues:
This script depends on a paragraph before a table. Therefore, a table must not be located at paragraph 1. There is a glitch in MS Word, preventing a script from adding a paragraph before a table (as far as I know).
*)

set myDup to my duplicateDoc()
--set outputPathAL to (path to desktop folder as string) & "Temporary Saved Doc for Latex Conversion.doc"
--my saveWordDoc(outputPathAL)


tell application "Microsoft Word"
	if (count of documents) is greater than or equal to 1 then
		
		tell document 1
			-- Edit sectionTags and inlineTags for 
			set sectionTags to {{"Title", "title"}, {"Heading 1", "section"}, {"Heading 2", "subsection"}, {"Heading 3", "subsubsection"}}
			set inlineTags to {{"Paragraph", "paragraph"}}
			global stylesList
			set stylesList to (get name local of Word styles)
			-- Automated List 
			set sectionStyles to {}
			repeat with itemStep from 1 to count of sectionTags
				set end of sectionStyles to item 1 of item itemStep of sectionTags
			end repeat
			
			set {xpath, xname, xext, xbodytext, paraCount, wordCount} to {(get default file path file path type documents path), name, (get name extension), (get contents of text object), get count of paragraphs, get count of words}
			--set allStyles to Word styles
			-- Takes care of Section Tags
			repeat with paraStep from 1 to paraCount
				set paraStyle to (get style of paragraph paraStep)
				set paraContent to (get content of text object of paragraph paraStep)
				
				repeat with itemStep from 1 to (count of sectionTags)
					if (paraContent as string) does not contain "{" then
						set {wordTag, texTag} to {item 1 of item itemStep of sectionTags, item 2 of item itemStep of sectionTags}
						try -- 
							--return paraStyle
							if Word style paraStyle is Word style wordTag then
								my texifyHeading(paraContent, wordTag, texTag, paraStep)
							end if
						end try
					end if
				end repeat
			end repeat
			
			
			-- Handle Bold and Italics 
			
			
		end tell
	end if
end tell


my texifyBoldItalicsQuotes()
my findReplace("&", "\\&")
my findReplace("$", "\\$")
my findReplace("_", "\\_")
my findReplace("%", "\\%")
my texifyLists()
my texifyTables()
set preBody to "
\\documentclass[10pt]{article}
\\usepackage{fontspec}
\\usepackage{tabu}
\\begin{document}
"
set postBody to "
\\end{document}"

addTextToFrontOfDoc(preBody)
addTextToEndOfDoc(postBody)
--my openInTeXShop()
--my closeWordDocByName(myDup, false)

on texifyHeading(para_Content, word_style, tex_style, para_num)
	tell application "Microsoft Word"
		tell active document
			--set content of text object of paragraph paraNUM to "poop"
			--select text object of paragraph paraNUM
			--set orig_text to content of text object of paragraph paraNUM
			set sedFix to do shell script "echo " & para_Content & "| sed \"s/$(printf '
')\\$//\""
			try
				if last character of (para_Content as string) is (ASCII character 13) then
					set returnText to "\\" & tex_style & "{" & sedFix & "}" & "
"
				else
					set returnText to "\\" & tex_style & "{" & para_Content & "}"
				end if
				set content of text object of paragraph para_num to returnText
				set style of paragraph para_num to word_style
				--end if
			end try
			
		end tell
	end tell
end texifyHeading

on texifyWord(word_content, tex_style, word_num)
	tell application "Microsoft Word"
		try
			set bold_Style to make new Word style at active document with properties ¬
				{name local:"Bold Tagged", style type:style type character}
			set bold of font object of bold_Style to true
		end try
		tell active document
			set wordRange to word word_num
			--ASCII character 32 is space
			if last character of (word_content as string) is (ASCII character 32) then
				set wordOnly to set range wordRange start ((start of content of wordRange)) ¬
					end ((end of content of wordRange) - 1)
				set word_content to content of wordOnly
			end if
			
			set newContent to "\\" & tex_style & "{" & word_content & "}"
			set style of word word_num to "Bold Tagged"
			
			set content of word word_num to newContent --("\\" & tex_style & "{" & word_content & "}")
			
			--set style of word word_num to 
		end tell
	end tell
end texifyWord


on texifyBoldItalicsQuotes()
	tell application "Microsoft Word"
		if (count of documents) is greater than or equal to 1 then
			set stylesList to (get name local of Word styles of active document)
			
			if stylesList does not contain "Bold Tagged" then
				set bold_Style to make new Word style at active document with properties ¬
					{name local:"Bold Tagged", style type:style type character}
				set bold of font object of bold_Style to true
			end if
			if stylesList does not contain "Italic Tagged" then
				set italic_Style to make new Word style at active document with properties ¬
					{name local:"Italic Tagged", style type:style type character}
				set italic of font object of italic_Style to true
			end if
			--save as active document file name "Temp.doc"
			
			set curly to false -- change to true if curly quotes desired
			set wasSmartQuotes to auto format as you type replace quotes of settings
			set auto format as you type replace quotes of settings to curly
			set myFind to find object of selection
			
			tell myFind
				clear formatting myFind
				execute find find text "&" replace with "\\&" replace replace all
				execute find find text "_" replace with "\\_" replace replace all
			end tell
			
			-- mark up italics and take out of italics
			clear formatting of myFind
			set forward of myFind to true
			set wrap of myFind to find continue
			set style of myFind to "Normal"
			set italic of font object of myFind to true
			set content of myFind to ""
			clear formatting replacement of myFind
			set content of replacement of myFind to "\\emph{^&}"
			set italic of font object of replacement of myFind to false
			set style of replacement of myFind to "Italic Tagged"
			execute find myFind replace replace all
			
			-- mark up bold and take out of bold
			clear formatting of myFind
			set forward of myFind to true
			set wrap of myFind to find continue
			set bold of font object of myFind to true
			set style of myFind to "Normal"
			set content of myFind to ""
			clear formatting replacement of myFind
			set content of replacement of myFind to "\\textbf{^&}"
			set bold of font object of replacement of myFind to false
			set style of replacement of myFind to "Bold Tagged"
			execute find myFind replace replace all
			
			clear formatting of myFind
			set forward of myFind to true
			set wrap of myFind to find continue
			set style of myFind to "quotation"
			set content of myFind to ""
			clear formatting replacement of myFind
			set content of replacement of myFind to "\\begin{quotation}^&\\end{quotation}"
			--set style of replacement of myFind to "normal"
			execute find myFind replace replace all
			
			set auto format as you type replace quotes of settings to wasSmartQuotes
		end if
	end tell
end texifyBoldItalicsQuotes

on findReplace(textToFind, replacementText)
	tell application "Microsoft Word"
		if (count of documents) is greater than or equal to 1 then
			-- mark up italics and take out of italics
			set myFind to find object of selection
			clear formatting of myFind
			set forward of myFind to true
			set wrap of myFind to find continue
			--set style of myFind to "Normal"
			--set italic of font object of myFind to true
			set content of myFind to textToFind
			clear formatting replacement of myFind
			set content of replacement of myFind to replacementText --\\emph{^&}
			set italic of font object of replacement of myFind to false
			execute find myFind replace replace all
		end if
	end tell
end findReplace

on texifyLists()
	tell application "Microsoft Word"
		--tell active document
		--end tell
		--set listFormatProps to properties of list format of text object of selection
		--set paraStep to GetParagraph() of me
		
		set paraCompensator to 0
		repeat with paraStep from 1 to count of paragraphs of active document
			set paraStep to paraStep + paraCompensator
			set listFormatProps to properties of list format of text object of paragraph paraStep of active document
			set styleName to name local of style of text object of paragraph paraStep of active document
			
			if styleName is "List paragraph" then
				get list type of listFormatProps
				-- ## Setup Itemize Environment
				if list type of listFormatProps is list bullet then
					-- ## Prefix List Items with \item
					if content of text object of paragraph paraStep of active document does not contain "\\item" then
						insert text "\\item " at first word of paragraph paraStep of active document
					end if
					
					if list type of list format of text object of paragraph (paraStep - 1) of active document is list no numbering then
						insert text return & "\\begin{itemize}" at the last word of paragraph (paraStep - 1) of active document
						set paraCompensator to paraCompensator + 1
						set paraStep to paraStep + 1
					end if
					
					-- ## Look for start of embedded list (Level 2 Indent)
					if list type of list format of text object of paragraph (paraStep + 1) of active document is list bullet then
						if list level number of list format of text object of paragraph (paraStep + 1) of active document is 2 then
							insert text return & "\\begin{itemize}" at last word of paragraph (paraStep) of active document
							set paraCompensator to paraCompensator + 1
							set paraStep to paraStep + 1
						end if
					end if
					-- ## Look for end of embedded list (Level 2 Indent) 
					if list type of list format of text object of paragraph (paraStep + 1) of active document is list bullet then
						if list level number of list format of text object of paragraph (paraStep) of active document is 2 then
							if list level number of list format of text object of paragraph (paraStep + 1) of active document is 1 then
								insert text "\\end{itemize}" & return at first word of paragraph (paraStep + 1) of active document
								set paraCompensator to paraCompensator + 1
								set paraStep to paraStep + 1
							end if
						end if
					end if
					
					-- ## Detect end of list (Level 1 Indent) and tag with \end{itemize}
					try
						if list type of list format of text object of paragraph (paraStep + 1) of active document is list no numbering then
							insert text "\\end{itemize}" & return at first word of paragraph (paraStep + 1) of active document
							set paraCompensator to paraCompensator + 1
						end if
					on error
						set lastItem to true
						insert text return & "\\end{itemize}" at last word of paragraph (paraStep) of active document
						log "Reached end of document checking for list at paragraph nr. " & paraStep
					end try
				end if
			end if
			
			-- ## Setup Enumerate Environment
			if list type of listFormatProps is list simple numbering then
				-- ## Prefix List Items with \item
				if content of text object of paragraph paraStep of active document does not contain "\\item" then
					insert text "\\item " at first word of paragraph paraStep of active document
				end if
				
				if list type of list format of text object of paragraph (paraStep - 1) of active document is list no numbering then
					insert text return & "\\begin{enumerate}" at the last word of paragraph (paraStep - 1) of active document
					set paraCompensator to paraCompensator + 1
					set paraStep to paraStep + 1
				end if
				
				-- ## Look for start of embedded list (Level 1 Indent)
				if list type of list format of text object of paragraph (paraStep + 1) of active document is list simple numbering then
					if list level number of list format of text object of paragraph (paraStep + 1) of active document is 2 then
						insert text "\\begin{enumerate}" & return at first word of paragraph (paraStep + 1) of active document
						set paraCompensator to paraCompensator + 1
						set paraStep to paraStep + 1
					end if
				end if
				-- ## Look for end of embedded list (Level 1 Indent)
				if list type of list format of text object of paragraph (paraStep + 1) of active document is list simple numbering then
					if list level number of list format of text object of paragraph (paraStep + 1) of active document is 1 then
						insert text return & "\\end{enumerate}" at last word of paragraph (paraStep) of active document
						set paraCompensator to paraCompensator + 1
						set paraStep to paraStep + 1
					end if
				end if
				
				-- ## Detect end of list and tag with \end{itemize}
				
				try
					if list type of list format of text object of paragraph (paraStep + 1) of active document is list no numbering then
						set myInsert to insert text "\\end{enumerate}" & return at first word of paragraph (paraStep + 1) of active document
						set paraCompensator to paraCompensator + 1
					end if
				on error
					set lastItem to true
					insert text return & "\\end{enumerate}" at last word of paragraph (paraStep) of active document
					log "Reached end of document checking for list at paragraph nr. " & paraStep
				end try
			end if
			
			
			log "Paragraph: " & paraStep
		end repeat
		
		repeat with paraStep from 1 to count of paragraphs of active document
			set listFormatProps to properties of list format of text object of paragraph paraStep of active document
			set styleName to name local of style of text object of paragraph paraStep of active document
			set paraContent to content of text object of paragraph paraStep of active document
			if styleName is "List Paragraph" then
				set myStyle to Word style "Normal" of active document -- replace "Normal" with name of your style in quotations
				set content of text object of paragraph paraStep of active document to tab & paraContent
				
				select text object of paragraph paraStep of active document
				set style of paragraph format of selection to myStyle
			end if
		end repeat
	end tell
	
end texifyLists

on texifyTables()
	tell application "Microsoft Word"
		set tableCount to (count of tables of active document)
		if tableCount is greater than or equal to 1 then
			repeat with tableNum from 1 to tableCount
				set thisTable to table tableNum of active document
				set cellCount to (count of cells of text object of thisTable)
				set rowCount to (count of rows of text object of thisTable)
				--set columnCount to (count of columns of text object of thisTable) --DOES NOT WORK, RESULTS IN 0
				set rowCount to number of rows of thisTable
				set columnCount to number of columns of thisTable
				repeat with rowIncr from 1 to rowCount
					repeat with columnIncr from 1 to columnCount
						--set myRange to create range active document start (start of content of text object of cell) end ((end of content of text object of cell columnIncr))
					end repeat
				end repeat
				
				set rowList to {}
				repeat with rowIncr from 1 to rowCount
					--set columnIncr to 1
					repeat with columnIncr from 1 to columnCount --(get cells of row rowIncr of thisTable)
						--set myRange to create range active document start (start of content of text object of column columnIncr of thisTable) end ((end of content of text object of column columnIncr of thisTable) - 1)
						set cellContent to (get content of text object of (get cell from table thisTable row rowIncr column columnIncr))
						
						-- Remove "end-of-cell marker" AKA remove ASCII character 13 from end of cell content
						set cellcontentList to {}
						set orig_delims to AppleScript's text item delimiters
						set AppleScript's text item delimiters to ASCII character 13 -- (a carriage return)
						set cellcontentList to text items of cellContent
						set cellItems to items of cellcontentList
						set AppleScript's text item delimiters to orig_delims
						set cellContent to item 1 of cellcontentList
						
						-- Enable Script to be re-run without adding extra "&" or "\\" to tables
						if (count of characters of cellContent) is greater than 0 then
							if last character of (cellContent) is not "&" then
								if columnIncr = columnCount then
									if last character of (cellContent) is not "\\" then
										set content of text object of (get cell from table thisTable row rowIncr column columnIncr) to cellContent & " \\\\"
									end if
								else
									set content of text object of (get cell from table thisTable row rowIncr column columnIncr) to cellContent & " &"
								end if
								set columnIncr to columnIncr + 1
							end if
						else
							if columnIncr = columnCount then
								--if last character of (cellContent) is not "\\" then
								set content of text object of (get cell from table thisTable row rowIncr column columnIncr) to cellContent & " \\\\"
								
							else
								set content of text object of (get cell from table thisTable row rowIncr column columnIncr) to cellContent & " &"
							end if
							set columnIncr to columnIncr + 1
						end if
					end repeat
				end repeat
			end repeat -- table loop
			
			-- ## loop for pre and post table code
			tell active document
				set selPara to GetParagraph() of me
				get content of text object of paragraph selPara
			end tell
			if (count of tables of active document) is greater than 0 then
				repeat with tableStep from 1 to count of tables of active document
					--tell active document
					set thisTable to table tableStep of active document
					set cellCount to (count of cells of text object of thisTable)
					set rowCount to (count of rows of text object of thisTable)
					--set columnCount to (count of columns of text object of thisTable) --DOES NOT WORK, RESULTS IN 0					
					set rowCount to number of rows of thisTable
					set columnCount to number of columns of thisTable
					set colList to {}
					repeat (columnCount) times
						if (count of colList) is less than 1 then
							set end of colList to "X[l]"
						else
							set end of colList to "X[m]"
						end if
					end repeat
					set colString to colList as string
					-- ## Deal with Pre-Table Code		
					select text object of (get cell from table thisTable row 1 column 1)
					set preParaNum to (GetParagraph() of me)
					
					set myRange to create range active document start (start of content of content of text object of paragraph preParaNum of active document) end ((end of content of content of text object of paragraph preParaNum of active document) - 1)
					select myRange
					set origContent to content of myRange
					set preTableContent to "
\\begin{table}
\\centering
{\\extrarowsep=1mm
\\begin{tabu}{" & colString & "}
\\tabucline[.4mm,black]1"
					set content of myRange to origContent & return & preTableContent
					
					-- ## Deal with Post-Table Code
					select text object of (get cell from table thisTable row rowCount column columnCount)
					set postParaNum to (GetParagraph() of me) + 1 + 1 + 1
					set myRange to create range active document start (start of content of content of text object of paragraph postParaNum of active document) end ((end of content of content of text object of paragraph postParaNum of active document))
					select myRange
					set origContent to content of myRange
					--return origContent					
					set postTableContent to "\\tabucline[.4mm,black]1
\\end{tabu}}
\\end{table}"
					set content of myRange to postTableContent & return & origContent
					-- Add Line After Top Row (Heading Row)			
					select text object of (get cell from table thisTable row (2) column 1)
					insert rows selection position above number of rows 1
					select text object of (get cell from table thisTable row (2) column 1)
					set content of selection to "\\tabucline[.1mm,black]1"
					
					--end tell --doc
				end repeat --table loop
			end if --tables exist
			--end tell --doc
		end if -- if table
		
		
		(*
	set myTable to table 1 of the active document
	set aRange to convert row to text (row 1 of myTable) ¬
		separator separate by tabs
	set style of aRange to "normal"
	set rowContent to content of aRange
	set rowItems to {}
	set orig_delims to AppleScript's text item delimiters
	set AppleScript's text item delimiters to ASCII character 13 -- (a carriage return)
	set rowContent_items to text items of rowContent
	set rowItems to items of rowContent_items
	set AppleScript's text item delimiters to orig_delims
	repeat with thisItem in rowItems
		set item thisItem to item thisItem & "&"
	end repeat
	set content of aRange to (rowItems as string)
	*)
	end tell
end texifyTables

on GetParagraph()
	-- NOTE: If you select a paragraph including the first character of the first word, it will count up to the previous paragraph only!
	tell application "Microsoft Word"
		set myDoc to active document
		set myRange to create range myDoc start 0 end (start of content of text object of selection)
		set paragraphNum to (count paragraphs in myRange)
		return paragraphNum
	end tell
end GetParagraph

on openInTeXShop()
	tell application "Microsoft Word"
		get properties of settings
		get RTF in clipboard of settings
		tell active document
			set paraCount to count of paragraphs
			set myRange to create range start (start of content of text object of paragraph 1) end (end of content of text object of paragraph paraCount)
			select myRange
		end tell
		if selection type of selection is selection normal then
			copy object selection
		end if
	end tell
	
	tell application "TeXShop"
		make new document
		activate
		set thisDoc to the front document
		(*
		set preBody to "
\\documentclass[10pt]{article}
\\usepackage{fontspec}
\\begin{document}
"
		set postBody to "
\\end{document}"
*)
		set content of selection of thisDoc to (the clipboard)
	end tell
end openInTeXShop

on saveWordDoc(inputPathAL)
	tell application "Microsoft Word"
		save as active document file name inputPathAL
	end tell
end saveWordDoc

on duplicateDoc()
	tell application "Microsoft Word"
		tell active document
			set paraCount to count of paragraphs
			set myRange to create range start (start of content of text object of paragraph 1) end (end of content of text object of paragraph paraCount)
			select myRange
		end tell
		if selection type of selection is selection normal then
			copy object selection
			make new document
			paste object selection
			return name of active document
		end if
	end tell
end duplicateDoc

--my closeWordDocByName(myDup, false)
on closeWordDocByName(docName, savingBOOL)
	if savingBOOL is true then
		tell application "Microsoft Word"
			close document docName saving yes
		end tell
	else
		tell application "Microsoft Word"
			close document docName saving no
		end tell
	end if
end closeWordDocByName


on addTextToFrontOfDoc(preBody)
	tell application "Microsoft Word"
		tell active document
			insert text preBody & return at beginning of text object of active document
		end tell -- doc
	end tell --prog
end addTextToFrontOfDoc


on addTextToEndOfDoc(postBody)
	tell application "Microsoft Word"
		tell active document
			insert text postBody at end of text object of active document
		end tell -- doc
	end tell --prog
end addTextToEndOfDoc