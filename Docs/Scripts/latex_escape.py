# -*- encoding: utf-8 -*-

def latex_decode( s ) :
	'''
	A simple function which taks a latex escaping command 
	and returns the appropriate unicode character according
	to this table (via wikipedia):

	LaTeX command	Sample	Description
	\`{o}	ò	grave accent
	\'{o}	ó	acute accent
	\^{o}	ô	circumflex
	\"{o}	ö	umlaut or dieresis
	\H{o}	ő	long Hungarian umlaut (double acute)
	\~{o}	õ	tilde
	\c{c}	ç	cedilla
	\k{a}	ą	ogonek
	\l	ł	l with stroke
	\={o}	ō	macron accent (a bar over the letter)
	\b{o}	o	bar under the letter
	\.{o}	ȯ	dot over the letter
	\d{u}	ụ	dot under the letter
	\r{a}	å	ring over the letter (for å there is also the special command \aa)
	\u{o}	ŏ	breve over the letter
	\v{s}	š	caron/hacek ("v") over the letter
	\t{oo}	o͡o	"tie" (inverted u) over the two letters
	'''
        import re

	grave_accent = re.compile(r"\\\`\{([a-zA-Z])\}")
	acute_accent = re.compile(r"\\\'\{([a-zA-Z])\}")
	circumflex = re.compile(r"\\\^\{([a-zA-Z])\}")
	umlaut = re.compile(r"\\\"\{([a-zA-Z])\}")
	long_umlaut = re.compile(r"\\\H\{([a-zA-Z])\}")
	tilde = re.compile(r"\\~\{([a-zA-Z])\}")
	cedilla = re.compile(r"\\c\{([a-zA-Z])\}")
	ogonek = re.compile(r"\\\k\{([a-zA-Z])\}")
	macron_accent = re.compile(r"\\\=\{([a-zA-Z])\}")
	bar_under_letter = re.compile(r"\\b\{([a-zA-Z])\}")
	dot_over_letter = re.compile(r"\\\.\{([a-zA-Z])\}")
	dot_under_letter = re.compile(r"\\d\{([a-zA-Z])\}")
	ring_over_letter = re.compile(r"\\r\{([a-zA-Z])\}")
	breve_over_letter = re.compile(r"\\u\{([a-zA-Z])\}")
	caron_over_letter = re.compile(r"\\v\{([a-zA-Z])\}")
	tie_over_letters = re.compile(r"\\t\{([a-zA-Z])([a-zA-Z])\}")

	s = grave_accent.sub( lambda m: m.group(1) + u'\u0300', s )
	s = acute_accent.sub( lambda m: m.group(1) + u'\u0301', s )
	s = circumflex.sub( lambda m: m.group(1) + u'\u0311', s )
	s = umlaut.sub( lambda m: m.group(1) + u'\u0308', s )
	s = long_umlaut.sub( lambda m: m.group(1) + u'\u030b', s )
	s = tilde.sub( lambda m: m.group(1) + u'\u0303', s )
	s = cedilla.sub( lambda m: m.group(1) + u'\u0327', s )
	s = ogonek.sub( lambda m: m.group(1) + u'\u0328', s )
	s = macron_accent.sub( lambda m: m.group(1) + u'\u0328', s )
	s = bar_under_letter.sub( lambda m: m.group(1) + u'\u0331', s )
	s = dot_over_letter.sub( lambda m: m.group(1) + u'\u0307', s )
	s = dot_under_letter.sub( lambda m: m.group(1) + u'\u0323', s )
	s = ring_over_letter.sub( lambda m: m.group(1) + u'\u030a', s )
	s = breve_over_letter.sub( lambda m: m.group(1) + u'\u0306', s )
	s = caron_over_letter.sub( lambda m: m.group(1) + u'\u030c', s )
	s = tie_over_letters.sub( lambda m: m.group(1) + u'\u0361' + m.group(2) , s )

	return s

if __name__ == '__main__' :
	tests = [
		( "\`{o}", 'ò' ),
		( "\\\'{o}", 'ó' ),
		( "\^{o}", 'ô' ),
		( "\\\"{o}", 'ö'),
		( "\H{o}", 'ő'),
		( "\~{o}", 'õ'),
		( "\c{c}", 'ç'),
		( "\k{a}", 'ą'),
		( "\={o}", 'ō'),
		( "\\b{o}", 'o'),	
		( "\.{u}", 'ụ'),
		( "\d{u}", 'u'),
		( "\\r{a}", 'å'),
		( "\u{o}", 'ŏ'),
		( "\\v{s}", 'š'),
		( "\\t{oo}", 'o͡o'),
	]
	for t in tests :
		print t[1], latex_decode(t[0])