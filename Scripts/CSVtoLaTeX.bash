# Convert a CSV like the following:
# a,b,c,d,e,f,g
# To the LaTeX table format like the following:
# {a} & {b} & {c} & {d} & {e} & {f} & {g} \\\hline

sed 's/,/} \& {/g' Table1.csv | sed 's/^/{/' | sed 's/$/} \\\\\\hline/' > Table1Format.txt