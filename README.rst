===========================================================================================
amsthm—provide a syntax to use amsthm environments in pandoc, with output in LaTeX and HTML
===========================================================================================

:Date:   January 26, 2022

.. contents::
   :depth: 3
..

|Documentation Status| |image1|

|GitHub Actions| |Coverage Status| |image2| |Codacy Badge| |Scrutinizer Status| |CodeClimate Quality Status|

|Supported versions| |Supported implementations| |PyPI Wheel| |PyPI Package latest release| |GitHub Releases| |Development Status| |Downloads| |Commits since latest release| |License|

|Conda Recipe| |Conda Downloads| |Conda Version| |Conda Platforms|

Introduction
============

amsthm provide a syntax to use amsthm environments in pandoc, with output in LaTeX and HTML.

Usage
=====

From ``makefile``:

.. code:: makefile

   tests/model-target.md: tests/model-source.md
       pandoc -F amsthm $< -o $@
   tests/model-latex.tex: tests/model-source.md
       pandoc -F amsthm $< -o $@ --top-level-division=chapter --toc -N
   tests/model-latex.pdf: tests/model-source.md
       pandoc -F amsthm $< -o $@ --top-level-division=chapter --toc -N
   tests/model-html.html: tests/model-source.md
       pandoc -F amsthm $< -o $@ --toc -N -s

Syntax
======

See ``tests/model-source.md`` (or next page in documentation site) for an example.

Tips
====

-  Use ``-N``, ``--number-sections`` to enable numbering in pandoc. This is mandatory for LaTeX output.
-  To match LaTeX and non-LaTeX output numbering scheme, match these 2 settings manually

   -  LaTeX output: pandoc’s cli flag ``--top-level-division=[section|chapter|part]`` and the use of ``parent_counter`` in pandoc-amsthm
   -  non-LaTeX output: ``counter_depth`` in pandoc-amsthm

Supported pandoc versions
=========================

pandoc versioning semantics is `MAJOR.MAJOR.MINOR.PATCH <https://pvp.haskell.org>`__ and panflute’s is MAJOR.MINOR.PATCH. Below we shows matching versions of pandoc that panflute supports, in descending order. Only major version is shown as long as the minor versions doesn’t matter.

.. table:: Version Matching [1]_

   +---------------+------------------+---------------------------+-------------------------------+
   | pandoc-amsthm | panflute version | supported pandoc versions | supported pandoc API versions |
   +===============+==================+===========================+===============================+
   | 2.0.0         | 2.1.3            | 2.14.0.3–2.17.x           | 1.22–1.22.1                   |
   +---------------+------------------+---------------------------+-------------------------------+

.. [1]
   For pandoc API verion, check https://hackage.haskell.org/package/pandoc for pandoc-types, which is the same thing.

.. |Documentation Status| image:: https://readthedocs.org/projects/pandoc-amsthm/badge/?version=latest
   :target: https://pandoc-amsthm.readthedocs.io/en/latest/?badge=latest&style=plastic
.. |image1| image:: https://github.com/ickc/pandoc-amsthm/workflows/GitHub%20Pages/badge.svg
   :target: https://ickc.github.io/pandoc-amsthm
.. |GitHub Actions| image:: https://github.com/ickc/pandoc-amsthm/workflows/Python%20package/badge.svg
.. |Coverage Status| image:: https://codecov.io/gh/ickc/pandoc-amsthm/branch/master/graphs/badge.svg?branch=master
   :target: https://codecov.io/github/ickc/pandoc-amsthm
.. |image2| image:: https://coveralls.io/repos/ickc/pandoc-amsthm/badge.svg?branch=master&service=github
   :target: https://coveralls.io/r/ickc/pandoc-amsthm
.. |Codacy Badge| image:: https://app.codacy.com/project/badge/Grade/9631bb6bae2746e6947ede3b4b042e67
   :target: https://www.codacy.com/gh/ickc/pandoc-amsthm/dashboard?utm_source=github.com&utm_medium=referral&utm_content=ickc/pandoc-amsthm&utm_campaign=Badge_Grade
.. |Scrutinizer Status| image:: https://img.shields.io/scrutinizer/quality/g/ickc/pandoc-amsthm/master.svg
   :target: https://scrutinizer-ci.com/g/ickc/pandoc-amsthm/
.. |CodeClimate Quality Status| image:: https://codeclimate.com/github/ickc/pandoc-amsthm/badges/gpa.svg
   :target: https://codeclimate.com/github/ickc/pandoc-amsthm
.. |Supported versions| image:: https://img.shields.io/pypi/pyversions/amsthm.svg
   :target: https://pypi.org/project/amsthm
.. |Supported implementations| image:: https://img.shields.io/pypi/implementation/amsthm.svg
   :target: https://pypi.org/project/amsthm
.. |PyPI Wheel| image:: https://img.shields.io/pypi/wheel/amsthm.svg
   :target: https://pypi.org/project/amsthm
.. |PyPI Package latest release| image:: https://img.shields.io/pypi/v/amsthm.svg
   :target: https://pypi.org/project/amsthm
.. |GitHub Releases| image:: https://img.shields.io/github/tag/ickc/pandoc-amsthm.svg?label=github+release
   :target: https://github.com/ickc/pandoc-amsthm/releases
.. |Development Status| image:: https://img.shields.io/pypi/status/amsthm.svg
   :target: https://pypi.python.org/pypi/amsthm/
.. |Downloads| image:: https://img.shields.io/pypi/dm/amsthm.svg
   :target: https://pypi.python.org/pypi/amsthm/
.. |Commits since latest release| image:: https://img.shields.io/github/commits-since/ickc/pandoc-amsthm/v2.0.0.svg
   :target: https://github.com/ickc/pandoc-amsthm/compare/v2.0.0...master
.. |License| image:: https://img.shields.io/pypi/l/amsthm.svg
.. |Conda Recipe| image:: https://img.shields.io/badge/recipe-amsthm-green.svg
   :target: https://anaconda.org/conda-forge/amsthm
.. |Conda Downloads| image:: https://img.shields.io/conda/dn/conda-forge/amsthm.svg
   :target: https://anaconda.org/conda-forge/amsthm
.. |Conda Version| image:: https://img.shields.io/conda/vn/conda-forge/amsthm.svg
   :target: https://anaconda.org/conda-forge/amsthm
.. |Conda Platforms| image:: https://img.shields.io/conda/pn/conda-forge/amsthm.svg
   :target: https://anaconda.org/conda-forge/amsthm
