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
    """
    # initialize
    environments = set()
    unnumbered = set()
    counter_dict = {}
    counter = {}
    shared_environments = {}
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
    return environments, unnumbered, counter_dict, counter, shared_environments


def get_metadata(doc):
    """
    Getting the metadata:

    - doc.environments: set of all environments for matching the div
    - doc.unnumbered: set of unnumbered environments for checking if counter is needed
    - doc.counter_dict: dict to lookup the shared counter for each environment
    - doc.counter: dict of shared counters
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
    # (0, 1, 2, 3, 4) corresponds to (environments, unnumbered, counter_dict, counter, shared_environments)
    doc.environments = set().union(*[all_parsed_metadata[i][0] for i in amsthm_style])
    doc.unnumbered = set().union(*[all_parsed_metadata[i][1] for i in amsthm_style])
    doc.counter_dict = dict(ChainMap(*[all_parsed_metadata[i][2] for i in amsthm_style]))
    doc.counter = dict(ChainMap(*[all_parsed_metadata[i][3] for i in amsthm_style]))
    doc.shared_environments = dict(ChainMap(*[all_parsed_metadata[i][4] for i in amsthm_style]))
    doc.style = {i: all_parsed_metadata[i][0] for i in amsthm_style}
    # get parent counter
    doc.parentcounter = amsthm_metadata['parentcounter']


def amsthm(elem, doc):
    print('doc.environments:', doc.environments)
    print('doc.unnumbered:', doc.unnumbered)
    print('doc.counter_dict:', doc.counter_dict)
    print('doc.counter:', doc.counter)
    print('doc.shared_environments:', doc.shared_environments)
    print('doc.style:', doc.style)
    print('doc.parentcounter:', doc.parentcounter)
#     print(doc.get_metadata(''))
#     k,v = dict(doc.get_metadata('amsthm.plain'))
#     print(k, v)
#     for i in doc.get_metadata('amsthm'):
#         print(i)
#     for i in doc.content:
#         print(type(i))
#     if isinstance(elem, pf.MetaMap) and 'amsthm' in elem.content:
#         elem.content['amsthm'].walk(print, doc)

#     if isinstance(elem, pf.MetaMap):
#         print(elem)
#         print(elem.next)
#     if isinstance(elem, pf.MetaMap):
#         print(elem)
    pass


def finalize(doc):
    pass


def main(doc=None):
    return pf.run_filter(amsthm,
                         prepare=get_metadata,
                         finalize=finalize,
                         doc=doc) 


if __name__ == '__main__':
    main()