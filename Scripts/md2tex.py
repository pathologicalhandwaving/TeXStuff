'''
md2tex.py
 - author: Richard Dong
 - description: Convert markdown to latex
'''
import re
import fileinput

class State:
    MARKDOWN = 0
    LATEX = 1
    EQUATION = 2

class Converter:
  def __init__(self):
    self.state = State.MARKDOWN
    self.vars = dict()
  def convert_line(self, line):
    line = line.rstrip('\n\r')
    if line == '<!-- latex':
      self.state = State.LATEX
      return ''
    elif line == 'latex -->':
      self.state = State.MARKDOWN
      return ''
    elif line == '$$' and self.state == State.MARKDOWN:
      self.state = State.EQUATION
      return r'\begin{equation}'
    elif line == '$$' and self.state == State.EQUATION:
      self.state = State.MARKDOWN
      return r'\end{equation}'
    elif line.startswith('<!-- var '):
      for (k, v) in re.findall(r'(\w+)="([^"]+)"', line):
        self.vars[k] = v
      return ''
    elif self.state == State.MARKDOWN:
      return self.convert_markdown(line)
    else:
      return line
  def convert_markdown(self, line):
    m = re.match(r'^(#+)\s*(.+)$', line)
    if m is not None:
      if len(m.group(1)) == 1: return r'\chapter{' + m.group(2) + '}'
      return '\\' + 'sub' * (len(m.group(1)) - 2) + 'section{' + m.group(2) + '}'
    m = re.match(r'^!\[([^\]]*)\]\(([^\)]+)\)$', line)
    if m is not None:
      return r'''\begin{figure}[!h]
        \centering\includegraphics[width=%s\linewidth]{%s}
        \caption{%s}\label{%s}
        \end{figure}''' % (self.vars['width'], m.group(2), m.group(1), self.vars['label'])
    line = re.sub(r'\$\$', '$', line)
    line = re.sub(r'\[cite:(\w+(,\w+)*)\]', r'\\cite{\1}', line)
    line = re.sub(r'\[fig:(\w+)\]', r'\\figurename~\\ref{\1}', line)
    return line

converter = Converter()
for line in fileinput.input():
  print(converter.convert_line(line))
