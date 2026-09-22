===========================================================================================
amsthm—provide a syntax to use amsthm environments in pandoc, with output in LaTeX and HTML
===========================================================================================

:Date: September 22, 2026

.. contents::
   :depth: 3
..

.. important::

   **This is the final release of the Python package ``amsthm`` (v2.1.1).** It is no longer maintained. pandoc-amsthm v3 is reimplemented as a pandoc Lua filter, and is not distributed on PyPI. Please check the repository at https://github.com/ickc/pandoc-amsthm/ or the documentation at https://ickc.github.io/pandoc-amsthm/.

|Documentation Status|

|GitHub Actions| |Coverage Status|

|Supported versions| |Supported implementations| |PyPI Wheel| |PyPI Package latest release| |GitHub Releases| |Development Status| |Downloads| |Commits since latest release| |License|

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

- Use ``-N``, ``--number-sections`` to enable numbering in pandoc. This is mandatory for LaTeX output.
- To match LaTeX and non-LaTeX output numbering scheme, match these 2 settings manually

  - LaTeX output: pandoc’s cli flag ``--top-level-division=[section|chapter|part]`` and the use of ``parent_counter`` in pandoc-amsthm
  - non-LaTeX output: ``counter_depth`` in pandoc-amsthm

Supported pandoc versions
=========================

pandoc versioning semantics is `MAJOR.MAJOR.MINOR.PATCH <https://pvp.haskell.org>`__ and panflute’s is MAJOR.MINOR.PATCH. pandoc-amsthm constrains the panflute version, and panflute in turn is responsible for pandoc compatibility. Below we show the matching versions, in descending order.

.. table:: Version Matching [1]_

   +---------------+------------------+---------------------------+-------------------------------+
   | pandoc-amsthm | panflute version | supported pandoc versions | supported pandoc API versions |
   +===============+==================+===========================+===============================+
   | 2.1.1         | 2.3.x            | 2.14.0.3–3.11             | 1.22–1.23.1                   |
   +---------------+------------------+---------------------------+-------------------------------+
   | 2.1.0         | 2.3.x            | 2.14.0.3–3.11             | 1.22–1.23.1                   |
   +---------------+------------------+---------------------------+-------------------------------+
   | 2.0.0         | 2.1.3            | 2.14.0.3–2.17.x           | 1.22–1.22.1                   |
   +---------------+------------------+---------------------------+-------------------------------+

.. [1]
   For pandoc API verion, check https://hackage.haskell.org/package/pandoc for pandoc-types, which is the same thing.

.. |Documentation Status| image:: https://github.com/ickc/pandoc-amsthm/workflows/GitHub%20Pages/badge.svg
   :target: https://ickc.github.io/pandoc-amsthm
.. |GitHub Actions| image:: https://github.com/ickc/pandoc-amsthm/workflows/Python%20package/badge.svg
.. |Coverage Status| image:: https://codecov.io/gh/ickc/pandoc-amsthm/branch/master/graphs/badge.svg?branch=master
   :target: https://codecov.io/github/ickc/pandoc-amsthm
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
.. |Commits since latest release| image:: https://img.shields.io/github/commits-since/ickc/pandoc-amsthm/latest.svg
   :target: https://github.com/ickc/pandoc-amsthm/releases/latest
.. |License| image:: https://img.shields.io/pypi/l/amsthm.svg
