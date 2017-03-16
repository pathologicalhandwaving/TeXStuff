#!/bin/sh

while read line; do
    echo '\hline'
    echo $line"\\\\" | sed 's/°/\\degree/' |
    awk '
    BEGIN{OFS=" & "}
    {
        print $1,$2,$3,$4$5$6$7$8,$9
    }
    ' |
    sed 's/-/ - /g'
done < "$1"
echo '\hline'
