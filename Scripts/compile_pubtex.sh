#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games

DIRS=$(ls -d /var/www/pubtex/*/)
LOG="<!DOCTYPE html>
<html>
<body>"


PAGE='<!DOCTYPE html>
<html>
        <head>
        <title>BlokX5 PubTeX</title>

        <style>
                body{
                        background-color: #0033EE;
                        color: #FFFFFF;
                        font-family: Monospace, Consolas, Arial, Helvetica;
                	line-height: 2em;
		}

		a {
			color: #FFFFFF;
			text-decoration: none;
		}

		a.visited {
			color #FFFFFF;
		}

        </style>
        </head>
<body>
<h1 style="font-size: 32pt;">BlokX5 PubTeX</h1>

<table>
'



for DIR in $DIRS
do
	cd $DIR
	
	BNAME=$(basename $DIR)

	
	# RECOMPILE

	OUT="$(git pull)"


	if [[ $OUT == *"Already"* ]]
	then
		echo $DIR" already up-to-date"
		LOG=$LOG$'\n'$DIR" already up-to-date<br>" 
	
	else

		/usr/bin/time -f "%e" make latex > /dev/null 2> /tmp/zeit
		TIME=$(</tmp/zeit)


	        echo "Updated "$DIR" (took "$TIME")"
			servernotify "PubTeX: Updated "$DIR" (took "$TIME")"
        	LOG=$LOG$'\nUpdated '$DIR' (took '$TIME')<br>'
	fi

	
	# FIND PDFs and build page

        PDFS=$(find . -type f -name \*.pdf | grep -v "img/" | sed 's/\.\///')
        PAGE=$PAGE'<tr><td style="width: 250px; font-weight: bold;"><a href="'$BNAME'">'$BNAME'</a></td>'

        for PDF in $PDFS
        do

                PAGE=$PAGE'<td style="padding-left: 75px;"><a href="'$BNAME'/'$PDF'">'$(basename $PDF)'</a></td>'
        done

        PAGE=$PAGE'</tr>'


	cd ../..

done


LOG=$LOG'<br><br>'$(echo 'Letzte Aktualisierung: '$(date))'</body></html>'
echo $LOG > pubtex/last_update.html


PAGE=$PAGE'</table><br><br><a href="last_update.html">'
MSG=$(cowsay "Zuletzt aktualisiert: "$(date) | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\<br\>/g' | sed 's/ /\&nbsp\;/g')
PAGE=$PAGE$MSG
PAGE=$PAGE'</a>'


PAGE=$PAGE"<br></body></html>"
echo $PAGE > pubtex/index.html

