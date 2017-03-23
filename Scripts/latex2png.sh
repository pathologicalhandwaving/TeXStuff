#!/bin/bash
# converts latex to .png. It doesn't do this directly, there are temporary files saved in $dir
# To make a LaTeX-Document suitable for this, you should include

# \pagestyle{empty}

# or there will be loads of whitespace around the thing you actually want.
# Usage:
# latex2png file [density]
# file: latex file
# density: the resolution of the resulting image depends on this. 100 is rather small, 200 rather big, in my opinion. Defaults to 150.
set -e

dir=~/tmp
mkdir -p $dir
file=${1##*/}
fileWithoutExt=${file%.*}
pathWithoutExt=${1%.*}
if test ! -z $2; then
        density=$2
else
        density=150
fi
if test -z $1; then
        cat "$0"
        exit 1
fi
latex -output-directory $dir $1
dvips -E -o $dir/$fileWithoutExt.ps $dir/$fileWithoutExt.dvi
convert -density ${density}x$density $dir/$fileWithoutExt.ps $pathWithoutExt.png
rm -v $dir/$fileWithoutExt.ps $dir/$fileWithoutExt.dvi $dir/$fileWithoutExt.log $dir/$fileWithoutExt.aux && rmdir --ignore-fail-on-non-empty $dir