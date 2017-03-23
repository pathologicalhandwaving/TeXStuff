-- Numbers to LaTeX converter
-- this small AppleScript takes the first table in the first sheet of the first
-- Numbers document and turns it into a LaTeX table (well, sort of).
-- It will be copied to the clipboard.

-- This is a 5-minute quick hack and mostly unsupported, but if you like it or
-- if you have any enhancements (not feature request :-)), plese send them to
-- gundlach <at> speedata.de

tell application "Numbers"
	tell document 1
		set current_table to table 1 of sheet 1
		set current_table_string to ""
		tell current_table
			repeat with current_row from 1 to row count
				set current_row_string to ""
				repeat with current_column from 1 to column count
					set current_cell to cell current_column of row current_row
					-- log name of current_cell as text
					-- log format of range "A1" as text
					
					try
						set this_value to value of current_cell as integer
					on error
						set this_value to value of current_cell as text
					end try
					
					if current_column < 2 then
						set current_row_string to this_value as text
					else
						set current_row_string to current_row_string & " & " & this_value as text
					end if
					set current_column to (current_column + 1)
				end repeat
				set current_table_string to current_table_string & current_row_string & " \\\\
"
				set current_row to (current_row + 1)
			end repeat
		end tell
		set the clipboard to current_table_string
		display dialog "Copied table to clipboard"
	end tell
end tell
