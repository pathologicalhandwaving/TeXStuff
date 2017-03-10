%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Custom Class
% LaTeX Class
% Version 1.0 (28/2/15)
%
% This template has been downloaded from:
% http://www.LaTeXTemplates.com
%
% Original author:
% Vel (vel@latextemplates.com)
%
% License:
% CC BY-NC-SA 3.0 (http://creativecommons.org/licenses/by-nc-sa/3.0/)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------------------
%	CLASS DEFINITION
%----------------------------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}

\ProvidesClass{example}[2015/02/28 Example LaTeX Class v1.0] % Class information printed in the log during every compilation

\DeclareOption{OPONE}{ % Declare a class option to set a new command with the option value (used as a toggle later)
   \newcommand{\classtoggle}{OPONE}
}

\DeclareOption{OPTWO}{ % Declare a class option to set a new command with the option value (used as a toggle later)
   \newcommand{\classtoggle}{OPTWO}
}

\ProcessOptions\relax % Process class options

\LoadClass[a4paper,10pt]{article} % Load the primary class with set options

\@ifundefined{classtoggle} % Check that the \classtoggle has been defined, i.e. one of the two required class options above has been specified
{\ClassError{example}{You have not used one of the required options}{You must specify one of the class options defined in the template file.}} % If one of the options has not been specified, quit with an error to that effect
{} % Otherwise do nothing

%----------------------------------------------------------------------------------------
%	REQUIRED PACKAGES
%----------------------------------------------------------------------------------------

\usepackage{ifthen} % Required for if statements to check the value of the \classtoggle command

%----------------------------------------------------------------------------------------
%	FURTHER DOCUMENT LAYOUT SPECIFICATIONS
%----------------------------------------------------------------------------------------

% Example of using the option passed to the class for changing the layout of the document by modifying margin sizes
\ifthenelse{\equal{\classtoggle}{OPONE}} % If the OPONE option was passed to the class
{\usepackage[top=1in, bottom=1in, left=1in, right=1in]{geometry}} % Define the margins as 1 inch on all sides
{} % Otherwise do nothing
\ifthenelse{\equal{\classtoggle}{OPTWO}} % If the OPTWO option was passed to the class
{\usepackage[top=2in, bottom=2in, left=2in, right=2in]{geometry}} % Define the margins as 2 inches on all sides
{} % Otherwise do nothing

%----------------------------------------------------------------------------------------

\endinput