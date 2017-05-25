#!/usr/bin/env bash

# This is free and unencumbered software released into the public domain.

# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# For more information, please refer to <http://unlicense.org>

# Some code adapted from:
# - http://stackoverflow.com/a/34676160
# - http://unix.stackexchange.com/a/84980

# Usage:
#   ./diff_with_version.sh <ref> <main_tex_file.tex>
#
# N.B. This script must be called from the same directory as the main tex file.

# create a temporary directory
CUR_DIR=`pwd`
TMP_DIR=`mktemp -d 2>/dev/null || mktemp -d -t 'old_tex'`

# ensure temp dir gets cleaned up
function cleanup {
  rm -rf "$TMP_DIR"
  echo "Deleted temp working directory $TMP_DIR"
}
trap cleanup EXIT

# clone and checkout the requested version into the temp dir
git clone $CUR_DIR $TMP_DIR \
    && cd $TMP_DIR \
    && git reset --hard $1 \
    && cd $CUR_DIR \
    || { echo "Failed to clone and checkout requested version."; exit -1; }

# do the diff
latexdiff --flatten $TMP_DIR/$2 $2 > diff.tex

# compile and cleanup
latexmk -pdf -interaction=nonstopmode -outdir=diff diff.tex \
    && mv diff/diff.pdf . \
    && rm -r diff diff.tex \
    || { echo "Failed to produce diff."; exit -1; }

echo '** Created diff.pdf **'