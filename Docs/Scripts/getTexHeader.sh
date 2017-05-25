#!/usr/bin/env sh
filename=$1
grep -B9999 'begin{document}' $filename && echo ' ' && echo '\end{document}'
