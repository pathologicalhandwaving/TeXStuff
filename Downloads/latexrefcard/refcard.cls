\NeedsTeXFormat{LaTeX2e}

\ProvidesClass{rcarcard}[2015/09/25 My RefCard Clas]

\LoadClass{article}

\RequirePackage{tikz}

% page geometry
\RequirePackage[a4paper,	
	top=10mm,
	bottom=20mm,
	left=20mm,
	right=10mm
	]{geometry}
\RequirePackage{graphicx,xcolor}

\RequirePackage{tcolorbox}
\tcbuselibrary{listings,breakable,skins}

% commands
\newcommand{\reftitle}[1]{\def\@reftitle{#1}}
\newcommand{\refauthor}[1]{\def\@refauthor{#1}}
\newcommand{\refabstract}[1]{\def\@refabstract{#1}}
\newcommand{\refemail}[1]{\def\@refemail{#1}}
%----------------------------------------------------



% maketitle -----------------------------------------
\renewcommand{\@maketitle}{
\thispagestyle{empty}%
\twocolumn[{

%\fcolorbox{white}{orange!70}{
\begin{tcolorbox}[opacityframe=0.5,colframe=blue, breakable, 
	rightrule=0mm,toprule=0mm, bottomrule=0.2mm, leftrule=5mm]
	\parbox{\textwidth\fboxsep\fboxrule}{\centering
	\colorbox{black!5}{
		\parbox{0.98\textwidth\fboxsep\fboxrule}{\centering
			{\Huge\bfseries\color{blue}\@reftitle\par}
		}
	}

	{\raggedleft\bfseries\@refauthor\\\par}
	\vskip2pt
	{\raggedleft\tiny\@refemail\par}	
	\vskip5pt

}% end of parbox
\end{tcolorbox}
%}%end fcolorbox
\vskip20pt

}]

}
% ---------------------------------------------


%page color -----------------------------------

\RequirePackage[pagecolor=orange!10]{pagecolor}


% ---------------------------------------------


% for multi columns
\RequirePackage{multicol}
\columnseprule1pt
\columnsep10mm

\RequirePackage{tcolorbox}
\tcbuselibrary{breakable}


% SECTION COMMANDS -----------------------------------------------

\RequirePackage[explicit]{titlesec}
\renewcommand\thesection{}
\titleformat{\section}[block]%              
    {\Large\bfseries\color{white}%
     \tikz[overlay, rounded corners] \shade[left color=blue!85,right color=blue!85,] (0,-1ex) rectangle (235pt,0.8em);}%    
    {\thesection}%                   
    {1em}%
    {\hspace{-10pt}#1}



% important things

% figure
% code
% concepts
% definitions
% table
