========================================================================================
amsthm — a Pandoc Lua filter providing amsthm environments with output in LaTeX and HTML
========================================================================================


.. contents::
   :depth: 3
..

|GitHub Releases| |License|

Introduction
============

``amsthm.lua`` is a native `Pandoc <https://pandoc.org>`__ Lua filter that provides a Markdown syntax for ``amsthm`` theorem/proof environments, producing correctly-numbered output in LaTeX (via the LaTeX ``amsthm`` package) and in any non-LaTeX format (HTML, Markdown, …) by emulating LaTeX’s numbering and styling in the Pandoc AST.

Since version 3, the filter is implemented as a single Lua file. Previous versions (≤ 2.x) shipped a Python implementation built on ```panflute`` <https://github.com/sergiocorreia/panflute>`__; the Lua port removes that dependency and is invoked as ``pandoc -L amsthm.lua`` (instead of ``pandoc -F amsthm``).

Installation
============

Download ``amsthm.lua`` from the `releases page <https://github.com/ickc/pandoc-amsthm/releases>`__ and drop it next to your source (or anywhere on your filesystem).

Usage
=====

.. code:: makefile

   tests/model-target.md: tests/model-source.md
       pandoc -L amsthm.lua $< -o $@
   tests/model-latex.tex: tests/model-source.md
       pandoc -L amsthm.lua $< -o $@ --top-level-division=chapter --toc -N
   tests/model-latex.pdf: tests/model-source.md
       pandoc -L amsthm.lua $< -o $@ --top-level-division=chapter --toc -N
   tests/model-html.html: tests/model-source.md
       pandoc -L amsthm.lua $< -o $@ --toc -N -s

Syntax
======

See ```tests/model-source.md`` <tests/model-source.md>`__ for an example covering every feature: shared counters, unnumbered theorems (``*`` suffix), names containing spaces, Markdown-formatted ``info`` attributes, cite-before-definition cross-references, pandoc-crossref-style ``@id``/``[@id]`` citations, raw LaTeX ``\ref{}``/``\eqref{}`` references, proof environments with custom labels, and deep counter nesting.

Tips
====

- Use ``-N``/``--number-sections`` to enable numbering in Pandoc. This is mandatory for LaTeX output.
- To match LaTeX and non-LaTeX numbering schemes, set both:

  - LaTeX output: Pandoc’s ``--top-level-division=[section|chapter|part]`` plus ``parent_counter`` in the ``amsthm:`` metadata block.
  - non-LaTeX output: ``counter_depth`` in the ``amsthm:`` metadata block.

Supported Pandoc versions
=========================

The filter targets the Pandoc Lua API present in **Pandoc ≥ 2.17** (the introduction of ``elem:walk`` and ``traverse = 'topdown'``). Development and CI pin a recent Pandoc 3.x via the included ``pixi.toml``.

Migration from 2.x
==================

========================= ==========================
2.x (Python)              3.x (Lua)
========================= ==========================
``pip install amsthm``    download ``amsthm.lua``
``pandoc -F amsthm …``    ``pandoc -L amsthm.lua …``
panflute ≥ 2.1.3 required no Lua/Python deps
========================= ==========================

The input syntax (the YAML ``amsthm:`` metadata block and the ``:::``-Div classes) is unchanged.

Development
===========

.. code:: sh

   pixi install            # provisions pandoc + lua from conda-forge
   pixi run test           # runs the full test suite
   pixi run test-unit      # just the busted-compatible unit specs
   pixi run test-golden    # just the golden/snapshot tests
   pixi run gen-golden     # regenerate tests/model-{latex.tex,target.md}

Tests are written as standard `busted <https://lunarmodules.github.io/busted/>`__ specs. They run under Pandoc’s bundled Lua via a small busted-compatible shim (``spec/busted_shim.lua``) so that the suite has no external dependencies; if a real ``busted`` is installed (via ``luarocks``), the runner uses it preferentially.

.. |GitHub Releases| image:: https://img.shields.io/github/tag/ickc/pandoc-amsthm.svg?label=github+release
   :target: https://github.com/ickc/pandoc-amsthm/releases
.. |License| image:: https://img.shields.io/github/license/ickc/pandoc-amsthm.svg
