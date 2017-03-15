\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{testform}[2017/03/13 v1.0.0 A Test Form]
\LoadClass[12pt,a4paper]{article}

\RequirePackage{wasysm}

\pagestyle{empty}

% Fonts
\newcommand*{\@fillinfont}{\rmfamily}
\newcommand*{\@formfont}{\sffamily}

% Checked and Unchecked Boxes
\newcommand*{\@unchecked}{\Square}
\newcommand*{\@checked}{\XBox}

% User Input Commands
\newcommand*{\@forenames}{}
\newcommand*{\forenames}[1]{\renewcommand*{\@forenames}{#1}}
\newcommand*{\@surname}{}
\newcommand*{\surname}[1]{\renewcommand*{\@surname}{#1}}
\newcommand*{\@address}{\rule{0pt}{1in}}
\newcommand*{\address}[1]{\renewcommand*{\@address}{#1}}
\newcommand*{\@comments}{\rule{0pt}{1in}}
\newcommand*{\comments}[1]{\renewcommand*{\@comments}{#1}}


\newcommand*{\reset@fimative}{%
    \def\firmative@yes{\@unchecked}%
    \def\firmative@no{\@unchecked}%
}
\reset@firmative

\newcommand{\firmative}[1]{%
    \itundefined{firmative@#1}%
    {%
       \ClassError{testform}{Unknown firmative `#1'}%
       {Firmative can either be `Yes' or `No' but not both}%
     }%
     {%
       \reset@firmative
       \@namedef{firmative@#1}{\@checked}%
     }%
}

\newcommand*{\@validageranges}{%
    {<18}{\textless18},%
    {18-30}{18--30},%
    {31-40}{31--40},%
    {41-60}{41--60},%
    {>60}{\textgreater60}%
}

\newcommand*{\get@agerange}{%
    \def\@agerange@label{#1}%
    \def\@agerange@text{#2}%
}

    