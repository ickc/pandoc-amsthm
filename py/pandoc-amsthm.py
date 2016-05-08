#!/usr/bin/env python

"""
A pandoc filter to define amsthm environement through YAML, the use of Div,
with templates and this filter.
See detail in https://github.com/ickc/pandoc-amsthm
Credit: https://github.com/chdemko/pandoc-latex-environment
"""

from pandocfilters import toJSONFilters, RawBlock, stringify

import re

def environment(key, value, format, meta):
    # Is it a div and the right format?
    if key == 'Div' and format == 'latex':

        # Get the attributes
        [[id, classes, properties], content] = value

        currentClasses = set(classes)

        for environment, definedClasses in getDefined(meta).items():
            for definedClass in definedClasses:
                # Is the classes correct?
                if definedClass in currentClasses:
                    value[1] = [RawBlock('tex', '\\begin{' + definedClass + '}')] + content + [RawBlock('tex', '\\end{' + definedClass + '}')]
                    break

def getDefined(meta):
    # Return the amsthm environment defined in the meta
    if not hasattr(getDefined, 'value'):
        getDefined.value = {}
        if 'amsthm' in meta and meta['amsthm']['t'] == 'MetaMap':
            for environment, classes in meta['amsthm']['c'].items():
                if classes['t'] == 'MetaList':
                    getDefined.value[environment] = []
                    for klass in classes['c']:
                        string = stringify(klass)
                        if re.match('^[a-zA-Z][\w.:-]*$', string):
                            getDefined.value[environment].append(string)
                    getDefined.value[environment] = set(getDefined.value[environment])
    return getDefined.value

def main():
    toJSONFilters([environment])

if __name__ == '__main__':
    main()

