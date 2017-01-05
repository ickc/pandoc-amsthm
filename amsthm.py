#!/usr/bin/env python3
"""
Pandoc filter using panflute
"""

from collections import OrderedDict, ChainMap
import panflute as pf
import json


def parse_metadata(eachStyle):
    """
    Input: eachStyle is the metadata under the key of amsthm styles, i.e. plain, definition, or remark
    Output:
    environments: set of all environments
    unnumbered: set of all unnumbered environments
    counter_dict: a dictionary with keys as the environments and the values as the shared counter
    counter: a dictionary with keys as the shared counter, and values as the counter (int), initialized as 0
    shared_environments: a dictionary with keys as the shared counter, and values as all other environments using this counter
    standalone_environments: a set of standalone environments (that do not share its counter)
    """
    # initialize
    environments = set()
    unnumbered = set()
    counter_dict = {}
    counter = {}
    shared_environments = {}
    standalone_environments = set()
    # parsing
    for environment in eachStyle:
        # check if it is a dict: hence numbered environments with shared counters
        if isinstance(environment, dict):
            for main, shared in environment.items():
                environments.add(main)
                counter_dict[main] = main
                counter[main] = 0
                # check if it is a string (1 item) or a list
                if isinstance(shared, str):
                    environments.add(shared)
                    counter_dict[shared] = main
                    shared_environments[main] = [shared]
                else:
                    environments.update(shared)
                    for i in shared:
                        counter_dict[i] = main
                    shared_environments[main] = shared
        # check if it is unnumbered
        elif str(environment)[-1] == '*':
            environment = str(environment)[0:-1]
            environments.add(environment)
            unnumbered.add(environment)
        # else it is a numbered environment with unshared counter
        else:
            environment = str(environment)
            environments.add(environment)
            counter_dict[environment] = environment
            counter[environment] = 0
            standalone_environments.add(environment)
    return environments, unnumbered, counter_dict, counter, shared_environments, standalone_environments


def get_metadata(doc):
    """
    Getting the metadata:

    - doc.environments: set of all environments for matching the div
    - doc.unnumbered: set of unnumbered environments for checking if counter is needed
    - doc.counter_dict: dict to lookup the shared counter for each environment
    - doc.counter: dict of shared counters
    - doc.shared_environments: a dictionary with keys as the shared counter, and values as all other environments using this counter
    - doc.standalone_environments: a set of standalone environments (that do not share its counter)
    - doc.style: dicts of plain, definition, remark
    - header level mapping to part/chapter/section @todo
    """
    amsthm_metadata = doc.get_metadata('amsthm')
    # parse each styles
    all_parsed_metadata = {}
    amsthm_style = ('plain', 'definition', 'remark')
    for i in amsthm_style:
        all_parsed_metadata[i] = parse_metadata(amsthm_metadata[i])
    # store output in doc
    # (0, 1, 2, 3, 4, 5) corresponds to (environments, unnumbered, counter_dict, counter, shared_environments, standalone_environments)
    doc.environments = set().union(*[all_parsed_metadata[i][0] for i in amsthm_style])
    doc.unnumbered = set().union(*[all_parsed_metadata[i][1] for i in amsthm_style])
    doc.counter_dict = dict(ChainMap(*[all_parsed_metadata[i][2] for i in amsthm_style]))
    doc.counter = dict(ChainMap(*[all_parsed_metadata[i][3] for i in amsthm_style]))
    doc.shared_environments = dict(ChainMap(*[all_parsed_metadata[i][4] for i in amsthm_style]))
    doc.standalone_environments = set().union(*[all_parsed_metadata[i][5] for i in amsthm_style])
    doc.style = {i: all_parsed_metadata[i][0] for i in amsthm_style}
    # get parent counter
    doc.parentcounter = amsthm_metadata['parentcounter']


def define_latex_enviroments(doc):
    """
    For LaTeX output only, convert the metadata obtained in get_metadata to LaTeX amsthm environment's definition
    """
    latex_amsthm_def = []
    amsthm_style = ('plain', 'definition', 'remark')
    for style in amsthm_style:
        if doc.style[style]:
            latex_amsthm_def += [r'\theoremstyle{' + style + '}']
            for i in doc.style[style]:
                # unnumbered environment
                if i in doc.unnumbered:
                    latex_amsthm_def += [r'\newtheorem*{' + i + '}{' + i + '}']
                # numbered, standalone environment
                elif i in doc.standalone_environments:
                    latex_amsthm_def += [r'\newtheorem{' + i + '}{' + i + '}[' + doc.parentcounter + ']']
                # numbered, shared environments
                elif i in doc.shared_environments:
                    latex_amsthm_def += [r'\newtheorem{' + i + '}{' + i + '}[' + doc.parentcounter + ']']
                    for shared in doc.shared_environments[i]:
                        latex_amsthm_def += [r'\newtheorem{' + shared + '}['+ i + ']{' + shared + '}']
    doc.content.insert(0, pf.RawBlock('\n'.join(latex_amsthm_def), format='latex'))

def prepare(doc):
    get_metadata(doc)
    if doc.format == 'latex':
        define_latex_enviroments(doc)


def amsthm(elem, doc):
    pass


def finalize(doc):
#     print('doc.environments:', doc.environments)
#     print('doc.unnumbered:', doc.unnumbered)
#     print('doc.counter_dict:', doc.counter_dict)
#     print('doc.counter:', doc.counter)
#     print('doc.shared_environments:', doc.shared_environments)
#     print('doc.style:', doc.style)
#     print('doc.parentcounter:', doc.parentcounter)
    pass


def main(doc=None):
    return pf.run_filter(amsthm,
                         prepare=prepare,
                         finalize=finalize,
                         doc=doc) 


if __name__ == '__main__':
    main()