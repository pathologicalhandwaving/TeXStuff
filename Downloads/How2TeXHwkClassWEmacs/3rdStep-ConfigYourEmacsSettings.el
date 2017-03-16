; finally you should add your own class into the variable `org-latex-classes'
  (add-to-list 'org-latex-classes
    ("networkHW" "\\documentclass{networkHW}" ;; ONLY this line matters, the rest is just format controlling, just leave them be
    ("\\section{%s}" . "\\section*{%s}")
    ("\\subsection{%s}" . "\\subsection*{%s}")
    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
    ("\\paragraph{%s}" . "\\paragraph*{%s}")
    ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
    )
