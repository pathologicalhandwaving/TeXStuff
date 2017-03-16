#!/bin/sh

# A simple script that builds the specified latex file when any *.tex
# file changes.
#
# Dependencies:
# - inotify-tools
# - pdflatex

if [ $# -eq 1 ]
then
  while true; do inotifywait -e modify *.tex; pdflatex $1 ; done
else
  echo "Usage: autolatex.sh TEX_FILE_TO_BUILD"
fi