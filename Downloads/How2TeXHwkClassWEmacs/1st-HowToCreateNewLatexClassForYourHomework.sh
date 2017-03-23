#!/bin/bash
# find your latex load path
# i.e., where should you put your *.cls/*.sty files
texpath=kpsewhich --var-value=TEXMFHOME
echo "Tex home diretory: $texpath"
# my output is $HOME/Library/texmf

# if the directory hasn't been created, create it
[[ -d "$texpath" ]] || mkdir -p "$texpath"
# following the convention of texmf directory structure
# you should put your class file into /somewhere/texmf/latex/commonstuff/
[[ -d "$texpath/tex/latex/commonstuff" ]] || mkdir -p "$texpath/tex/latex/commonstuff"