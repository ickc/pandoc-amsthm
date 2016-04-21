#!/usr/bin/env python

"""
It doesn't work: Span is in a Para
Pandoc filter to convert spans with latex="true" to LaTeX
environments in LaTeX output. The first class
will be regarded as the name of the latex environment
e.g.
<span latex="true" class="text abc">...</span>
will becomes
\text{...}
"""

from pandocfilters import toJSONFilter, RawBlock, Span


def latex(x):
    return RawBlock('latex', x)


def latexspans(key, value, format, meta):
    if key == 'Span':
        [[ident, classes, kvs], contents] = value
        if ["latex","true"] in kvs:
            if format == "latex":
                if ident == "":
                    label = ""
                else:
                    label = '\\label{' + ident + '}'
                return([latex('\\{' + classes[0] + label)] + contents + [latex('}')])

if __name__ == "__main__":
    toJSONFilter(latexspans)
