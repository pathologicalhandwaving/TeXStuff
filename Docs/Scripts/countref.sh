# assumes latex -output-directory is ./tmp
# will assist in spotting broken and unused citations
grep 'cite{' tmp/$1.aux| sed s/'[{}]'/' '/g |awk '{print $2}'>tmp/USED.TXT
grep ^@ MyLibrary.bib |sed s/'[{,]'/' '/g |awk '{print $2}'|grep -v -x -f tmp/IGNORE.TXT>tmp/LIB.TXT
echo '#number used'
cat tmp/USED.TXT|wc -l
echo '#number non-existant'
grep -v tmp/USED.TXT -x -f tmp/LIB.TXT|wc -l
echo '#first 5 non-existant'
grep -v tmp/USED.TXT -x -f tmp/LIB.TXT|sort|head -n 5
echo '---------'
echo '#number not used'
grep -f tmp/USED.TXT -v tmp/LIB.TXT|wc -l
echo '#first 5 not used'
grep -f tmp/USED.TXT -v tmp/LIB.TXT|sort|head -n 5
echo '#random 5 not used'
grep -f tmp/USED.TXT -v tmp/LIB.TXT|shuf|head -n 5