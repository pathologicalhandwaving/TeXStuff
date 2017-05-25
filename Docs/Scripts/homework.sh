#!/bin/bash

# Get user full name
user_full_name=$(getent passwd $USER | cut -d ':' -f 5 | sed 's/[,].*$//')
conf_dir=$HOME/.config/homework_setup
build_dir=Output
inc_dir=inc
res_dir=res
src_dir=src
latexmkrc_file=latexmkrc
main_file=main.tex
preamble_file="$inc_dir/preamble.tex"
tikz_file=$inc_dir/tikz.tex
problem_file=$src_dir/problem.tex
solution_file=$src_dir/solution.tex

hr () {
    printf "%% " >> $1
    for j in `seq 1 77`;
    do
        printf "-" >> $1
    done
    printf "\n" >> $1
}
space () {
    printf "%% " >> $1
    for j in `seq 1 31`;
    do
        printf " " >> $1
    done
}


# -----------------------------------------------------------------------------
#                            Choose dir for root_dir
# -----------------------------------------------------------------------------
if [ -f $conf_dir/last_folder ]; then
   last_dir="$(cat $conf_dir/last_folder)"
else
   last_dir="$HOME"
fi
DIR=$(zenity --file-selection --directory --filename="$last_dir" --title="Velg en mappe")

case $? in
    0)
        notify-send  "$DIR valgt"
        mkdir -p "$conf_dir"
        echo $DIR > "$conf_dir/last_folder"
        ;;
    1)
        exit 0
        ;;
    -1)
        notify-send "En uventet feil har oppstått"
        exit 1
        ;;
esac
cd "$DIR"
# -----------------------------------------------------------------------------
#       Get numbers of assigments and such
# -----------------------------------------------------------------------------
if [ -f $conf_dir/last_class ]; then
   last_class="$(cat $conf_dir/last_class)"
fi
root_dir=$(zenity --entry --text="Navn på Øvingen")
case $? in 1) exit 0;; esac
class=$(zenity --entry --entry-text="$last_class" --text="Hvilket fag?")
case $? in 1) exit 0;; esac
echo $class > $conf_dir/last_class
duedate=$(zenity --calendar --title="Frist for innlvering")
case $? in 1) exit 0;; esac
nr=$(zenity --entry --text="Hvor mange oppgaver?")
case $? in 1) exit 0;; esac
# -----------------------------------------------------------------------------
#                       Sett up root enviroment
# -----------------------------------------------------------------------------

# ---------------------- Testing if dir exsist --------------------------------
if [ ! -d "$root_dir" ]; then
    # Control will enter here if $DIRECTORY doesn't exsist.
    mkdir "$root_dir"
    notify-send  "Setter opp prosjekt i $root_dir"
else
    # Continue if dir exsist
    if zenity --question --text="Mappe finnes allerede.\n Fortsette?"; then
        notify-send  "Setter opp prosjekt i $root_dir"
    else
        # Kill
        zenity --error --text="Avsluttet"
        exit 0
    fi
fi
cd "$root_dir"
# -----------------------------------------------------------------------------
mkdir -p "$build_dir"

mkdir -p $inc_dir

mkdir -p $src_dir
mkdir -p $src_dir/tikz

mkdir -p $res_dir
mkdir -p $res_dir/pictures

# -----------------------------------------------------------------------------
#                   Making files
# -----------------------------------------------------------------------------
cd inc
if [ ! -f homework.cls ]; then
    wget https://gist.github.com/davidKristiansen/8984179/raw/5bf39b29c91cc325d57364a7899eb833d9758c05/homework.cls
fi
cd ..
# -----------------------------------------------------------------------------
#                       Preamble
# -----------------------------------------------------------------------------
## Setting up default files
if [ ! -f $preamble_file ]; then
    printf "\\" > $preamble_file
    printf "documentclass{inc/homework}\n\n" >> $preamble_file
    printf "\\" >> $preamble_file
    printf "input{tikz.tex}\n\n" >> $preamble_file
    printf "\\" >> $preamble_file
    printf "graphicspath{{%s/pictures}}\n\n" "$res_dir">> $preamble_file
        printf "\\" >> $preamble_file
    printf "name{%s}\n" "$user_full_name" >> $preamble_file
        printf "\\" >> $preamble_file
    printf "class{%s}\n" "$class">> $preamble_file
        printf "\\" >> $preamble_file
    printf "assignment{%s}\n" "$root_dir" >> $preamble_file
        printf "\\" >> $preamble_file
    printf "duedate{%s}" "$duedate">> $preamble_file
fi
# -----------------------------------------------------------------------------
#                       Tikz.tex
# -----------------------------------------------------------------------------
#if [ ! -f $tikz_file ]; then
#    printf "\\" > $tikz_file
#    printf "usepackage{tikz}\n" >> $tikz_file
#fi
# -----------------------------------------------------------------------------
#                       main File
# -----------------------------------------------------------------------------
if [ ! -f $main_file ]; then
    printf "\\" > $main_file
    printf "input{%s}\n\n" "$preamble_file" >> $main_file
    printf "\\" >> $main_file
    printf "usepackage{catchfilebetweentags}\n\n" >> $main_file
    printf "\\" >> $main_file
    printf "begin{document}\n\n" >> $main_file

    for i in `seq 1 $nr`;
    do
        printf "\\" >> $main_file
        printf "section*{Oppgave %s}\n" "$i">> $main_file
        printf "\\" >> $main_file
        printf "begin{problem}\n" >> $main_file
        printf "\t\\" >> $main_file
        printf "ExecuteMetaData[%s" "$problem_file" >> $main_file
        printf "]{prob%s}\n" "$i" >> $main_file
        printf "\\" >> $main_file
        printf "end{problem}\n" >> $main_file
        printf "\\" >> $main_file
        printf "begin{solution}\n" >> $main_file
        printf "\t\\" >> $main_file
        printf "ExecuteMetaData[%s" "$solution_file" >> $main_file
        printf "]{sol%s}\n" "$i" >> $main_file
        printf "\\" >> $main_file
        printf "end{solution}\n\n" >> $main_file
    done

    printf "\\" >> $main_file
    printf "end{document}" >> $main_file
fi
# -----------------------------------------------------------------------------
#                       Problem File
# -----------------------------------------------------------------------------
if [ ! -f $problem_file ]; then

    for i in `seq 1 $nr`;
    do
        hr $problem_file
        space $problem_file
        printf "Oppgave %s\n" " $i" >> $problem_file
        hr $problem_file
        printf "%%" >> $problem_file
        printf "<*prob%s>\n\n" "$i">> $problem_file
        printf "%%" >> $problem_file
        printf "</prob%s>\n" "$i">> $problem_file
    done
fi
# -----------------------------------------------------------------------------
#                       Solution File
# -----------------------------------------------------------------------------
if [ ! -f $solution_file ]; then

    for i in `seq 1 $nr`;
    do
        hr $solution_file
        space $solution_file
        printf "Oppgave %s\n" " $i" >> $solution_file
        hr $solution_file
        printf "%%" >> $solution_file
        printf "<*sol%s>\n\n" "$i">> $solution_file
        printf "%%" >> $solution_file
        printf "</sol%s>\n" "$i">> $solution_file
    done
fi
# -----------------------------------------------------------------------------
#                       latexmkrc file
# -----------------------------------------------------------------------------
if [ ! -f $latexmkrc_file ]; then
    printf 'my $motor = "xelatex";\n' > $latexmkrc_file
    printf 'my $build_dir = "%s";\n\n' "$build_dir" >> $latexmkrc_file
    printf '$pdf_mode = 1;\n' >> $latexmkrc_file
    printf '$postscript_mode = 0;\n' >> $latexmkrc_file
    printf '$dvi_mode = 0;\n' >> $latexmkrc_file
    printf '$pdf_previewer = "evince";\n' >> $latexmkrc_file
    printf '$clean_ext = "paux lox pdfsync out";\n' >> $latexmkrc_file
    printf '$pdflatex="$motor -interaction=nonstopmode";\n' >> $latexmkrc_file
    printf '$out_dir = $build_dir;\n' >> $latexmkrc_file
    printf '$aux_dir = $build_dir;\n' >> $latexmkrc_file
fi
# -----------------------------------------------------------------------------
latexmk -pdf -pv $main_file

notify-send  "All done!"

evince $build_dir/*.pdf

exit 0
