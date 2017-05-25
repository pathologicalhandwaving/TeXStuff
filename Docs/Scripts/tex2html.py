#!/usr/bin/env python3

class LaTeXDocument:
    class TextNode:
        def __init__(self, text):
            self.text = text

    class BreakNode:
        pass

    class CommandNode:
        def __init__(self, command, args, optargs):
            self.command = command
            self.args = args
            self.optargs = optargs

        def arg_text(self, index):
            return self.args[0].items[index].text

        def arg_items(self, index):
            return iter(self.args[index].items)

    class ListNode:
        def __init__(self, items):
            self.items = items

    def __init__(self, root):
        self.root = root

class LaTeXDocumentBuilder:
    def __init__(self, source):
        self.stream = iter(source)
        self.current = next(self.stream)
        self.command_characters = set(
            'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789*\\'
        )

    def next(self):
        try:
            self.current = next(self.stream)
        except StopIteration:
            self.current = 'EOF'

    def accept_any(self):
        accepted = self.current
        self.next()
        return accepted

    def accept(self, options):
        if self.current in options:
            return self.accept_any()
        else:
            return None

    def build(self):
        return LaTeXDocument(self.parse_document())

    def parse_document(self):
        return self.parse_children_until({'EOF'})

    # parse multiple child nodes until a marker
    def parse_children_until(self, until):
        children = []
        current_text = []

        def save_text():
            nonlocal current_text
            text = (
                ''
                .join(current_text)
                .strip()
                .replace('---', '–')
                .replace('--', '—')
                .replace('``', '"')
                .replace('\'\'', '"')
            )
            if text:
                children.append(LaTeXDocument.TextNode(text))
            current_text = []

        while not self.accept(until):
            # comments
            if self.accept({'%'}):
                while not self.accept({'\n'}):
                    self.accept_any()
            # double line breaks
            elif self.accept({'\n'}):
                current_text.append('\n')
                if self.accept({'\n'}):
                    save_text()
                    children.append(LaTeXDocument.BreakNode())
            # commands
            elif self.accept({'\\'}):
                save_text()
                children.append(self.parse_command())
            # maths
            elif self.accept({'$'}):
                save_text()
                children.append(self.parse_maths())
            else:
                current_text.append(self.accept_any())
        save_text()

        return LaTeXDocument.ListNode(children)

    def parse_command(self):
        command = []

        # command name
        current = self.accept(self.command_characters)
        while current:
            command.append(current)
            current = self.accept(self.command_characters)
        command = ''.join(command)

        # arguments
        optargs = []
        args = []
        start = True
        while start:
            start = self.accept({'[', '{'})
            if start == '[':
                optargs.append(self.parse_children_until({']'}))
            elif start == '{':
                args.append(self.parse_children_until({'}'}))

        return LaTeXDocument.CommandNode(command, args, optargs)

    def parse_maths(self):
        contents = []
        inline = not(self.accept({'$'}))
        while not self.accept({'$'}):
            contents.append(self.accept_any())

        if not inline:
            self.accept({'$'})

        return LaTeXDocument.CommandNode(
            '$' if inline else '$$',
            [LaTeXDocument.TextNode(''.join(contents))],
            []
        )

class HTMLDocument:
    class Node:
        def __init__(self, name, children, *attrs, **kwattrs):
            self.name = name
            self.children = children
            self.attrs = list(attrs)
            self.kwattrs = {k: '"{}"'.format(v) for k, v in kwattrs.items()}

        def pretty_print(self, indent=0):
            inline = self.name in {'span', 'a'}
            space = " " * indent if not inline else ''
            kwattrs = ["{}={}".format(k, v) for k, v in self.kwattrs.items()]
            attrs = " ".join(self.attrs + kwattrs)
            attrs = " " + attrs if attrs else ''
            newline = '\n' if not inline else ''

            if not self.children:
                return "{indent}<{name}{attrs}>{newline}".format(
                    indent=space,
                    name=self.name,
                    attrs=attrs,
                    newline=newline
                )
            else:
                children = "".join(
                    child.pretty_print(indent + 1)
                    for child in self.children
                )
                return (
                    "{indent}<{name}{attrs}>{newline}{children}{indent}</{name}>{newline}"
                    .format(
                        indent=space,
                        name=self.name,
                        attrs=attrs,
                        children=children,
                        newline=newline
                    )
                )

    class Text:
        def __init__(self, text):
            self.text = (
                text
                .replace('&', '&amp;')
                .replace('<', '&lt;')
                .replace('>', '&gt;')
            )

        def pretty_print(self, indent=0):
            return self.text + " "

    def __init__(self, root):
        self.root = root

    def pretty_print(self):
        header = """<!doctype html>
<meta charset="utf-8">
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    extensions: ["tex2jax.js"],
    jax: ["input/TeX", "output/HTML-CSS"],
    "HTML-CSS": { availableFonts: ["TeX"] }
  });
</script>
<script type="text/javascript"
  src="https://cdn.mathjax.org/mathjax/latest/MathJax.js">
</script>
<link rel="stylesheet" type="text/css" href="../style.css"/>
"""
        return header + self.root.pretty_print()

class HTMLDocumentBuilder:
    def __init__(self, source):
        self.root = source.root
        self.fig_count = 1
        self.figures = {}

    def build(self):
        return HTMLDocument(self.parse())

    def parse(self):
        # find the document start
        stream = iter(self.root.items)
        done = False
        while not done:
            current = next(stream)
            done = (
                type(current) is LaTeXDocument.CommandNode and
                current.command == 'begin'
            )

        return self.parse_block(stream, "document")

    def parse_block(self, stream, block_name):
        children = []
        while True:
            try:
                item = next(stream)
            except StopIteration:
                break
            if (
                type(item) is LaTeXDocument.CommandNode and
                item.command == 'end'
            ):
                break
            else:
                children.extend(self.parse_item(item, stream))

        tags = {
            'document': ('body', (), {}),
            'centering': ('div', (), {'class': 'centered'}),
            'figure': ('figure', (), {}),
            'forest': ('div', (), {}),
            'itemize': ('ul', (), {'class': 'itemize'}),
            'enumerate': ('ol', (), {}),
            'description': ('ul', (), {'class': 'description'}),
            'lstlisting': ('code', (), {}),
            'minipage': ('div', (), {}),
            'subfigure': ('figure', (), {})
        }
        tag, attrs, kwattrs = tags[block_name]
        return HTMLDocument.Node(tag, children, *attrs, **kwattrs)

    def parse_list(self, stream):
        items = []
        while True:
            try:
                item = next(stream)
                items.extend(self.parse_item(item, stream))
            except StopIteration:
                break
        return items

    def parse_item(self, item, stream):
        if type(item) is LaTeXDocument.TextNode:
            return [HTMLDocument.Text(item.text)]
        elif type(item) is LaTeXDocument.BreakNode:
            return [HTMLDocument.Node("br", [])]
        elif type(item) is LaTeXDocument.CommandNode:
            skip = {
                'medskip',
                'par',
                'centering',
                'pagebreak',
                'sffamily',
                'smallskip',
                'hfill',
                'setlength',
                '\\',
                '' # deals with things like \#FF0000 which are a pain otherwise
            }
            if item.command in skip:
                return []
            elif item.command == '$':
                return [HTMLDocument.Text(
                    '\\({}\\)'.format(item.args[0].text)
                )]
            elif item.command == '$$':
                return [HTMLDocument.Text(
                    '\\[{}\\]'.format(item.args[0].text)
                )]
            elif item.command == 'begin':
                return [self.parse_block(stream, item.arg_text(0))]
            elif item.command == 'label':
                self.figures[item.arg_text(0)] = self.fig_count
                self.fig_count += 1
                return []
            elif item.command == 'huge':
                return [HTMLDocument.Node(
                    "h1",
                    self.parse_list(item.arg_items(0))
                )]
            elif item.command == 'Large':
                return [HTMLDocument.Node(
                    "h2",
                    self.parse_list(item.arg_items(0))
                )]
            elif item.command == 'section':
                return [HTMLDocument.Node(
                    "h3",
                    self.parse_list(item.arg_items(0))
                )]
            elif item.command == 'subsection' or item.command == 'subsection*':
                return [HTMLDocument.Node(
                    "h4",
                    self.parse_list(item.arg_items(0))
                )]
            elif item.command == 'includegraphics':
                return [HTMLDocument.Node(
                    "img",
                    [],
                    src=item.arg_text(0)
                )]
            elif item.command == 'caption' or item.command == 'caption*':
                return [HTMLDocument.Node(
                    "figcaption",
                    (
                        [HTMLDocument.Text(
                            'Figure {}: '.format(self.fig_count)
                        )] +
                        self.parse_list(item.arg_items(0))
                    )
                )]
            elif item.command == 'emph':
                return [HTMLDocument.Node(
                    "span",
                    self.parse_list(item.arg_items(0)),
                    **{'class': "emphasis"} # gross
                )]
            elif item.command == 'url':
                return [HTMLDocument.Node(
                    "a",
                    [HTMLDocument.Text(item.arg_text(0))],
                    href=item.arg_text(0)
                )]
            elif item.command == 'path':
                return [HTMLDocument.Node(
                    "span",
                    [HTMLDocument.Text(item.arg_text(0))],
                    **{'class': 'filepath'}
                )]
            elif item.command == 'fbox':
                return self.parse_list(item.arg_items(0))
            elif item.command == 'colorbox':
                return [HTMLDocument.Node(
                    "span",
                    self.parse_list(item.arg_items(1)),
                    **{'class': "highlight"}
                )]
            elif item.command == 'textsf':
                return [HTMLDocument.Node(
                    "span",
                    self.parse_list(item.arg_items(0)),
                    **{'class': "sans-serif"}
                )]
            elif item.command == 'texttt':
                return [HTMLDocument.Node(
                    "span",
                    self.parse_list(item.arg_items(0)),
                    **{'class': "typewriter"}
                )]
            elif item.command == 'textbf':
                return [HTMLDocument.Node(
                    "span",
                    self.parse_list(item.arg_items(0)),
                    **{'class': "bold"}
                )]
            elif item.command == 'item':
                return [HTMLDocument.Node(
                    "li",
                    []
                )]
            elif item.command == 'parbox':
                return self.parse_list(item.arg_items(1))
            elif item.command in {'ref', 'autoref', 'subref'}:
                return [HTMLDocument.Text(
                    'figure {}'.format(self.figures[item.arg_text(0)])
                )]
            else:
                raise NotImplementedError(item.command)

if __name__ == '__main__':
    import sys
    source = sys.stdin.read()
    doc = LaTeXDocumentBuilder(source).build()
    html = HTMLDocumentBuilder(doc).build()
    print(html.pretty_print())
