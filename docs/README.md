---
title: amsthm---provide a syntax to use amsthm environments in pandoc,
  with output in LaTeX and HTML
---

[![Documentation Status](https://readthedocs.org/projects/pandoc-amsthm/badge/?version=latest)](https://pandoc-amsthm.readthedocs.io/en/latest/?badge=latest&style=plastic)
[![Documentation Status](https://github.com/ickc/pandoc-amsthm/workflows/GitHub%20Pages/badge.svg)](https://ickc.github.io/pandoc-amsthm)

![GitHub Actions](https://github.com/ickc/pandoc-amsthm/workflows/Python%20package/badge.svg)
[![Coverage Status](https://codecov.io/gh/ickc/pandoc-amsthm/branch/master/graphs/badge.svg?branch=master)](https://codecov.io/github/ickc/pandoc-amsthm)
[![Coverage Status](https://coveralls.io/repos/ickc/pandoc-amsthm/badge.svg?branch=master&service=github)](https://coveralls.io/r/ickc/pandoc-amsthm)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/9631bb6bae2746e6947ede3b4b042e67)](https://www.codacy.com/gh/ickc/pandoc-amsthm/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ickc/pandoc-amsthm&amp;utm_campaign=Badge_Grade)
[![Scrutinizer Status](https://img.shields.io/scrutinizer/quality/g/ickc/pandoc-amsthm/master.svg)](https://scrutinizer-ci.com/g/ickc/pandoc-amsthm/)
[![CodeClimate Quality Status](https://codeclimate.com/github/ickc/pandoc-amsthm/badges/gpa.svg)](https://codeclimate.com/github/ickc/pandoc-amsthm)

[![Supported versions](https://img.shields.io/pypi/pyversions/amsthm.svg)](https://pypi.org/project/amsthm)
[![Supported implementations](https://img.shields.io/pypi/implementation/amsthm.svg)](https://pypi.org/project/amsthm)
[![PyPI Wheel](https://img.shields.io/pypi/wheel/amsthm.svg)](https://pypi.org/project/amsthm)
[![PyPI Package latest release](https://img.shields.io/pypi/v/amsthm.svg)](https://pypi.org/project/amsthm)
[![GitHub Releases](https://img.shields.io/github/tag/ickc/pandoc-amsthm.svg?label=github+release)](https://github.com/ickc/pandoc-amsthm/releases)
[![Development Status](https://img.shields.io/pypi/status/amsthm.svg)](https://pypi.python.org/pypi/amsthm/)
[![Downloads](https://img.shields.io/pypi/dm/amsthm.svg)](https://pypi.python.org/pypi/amsthm/)
[![Commits since latest release](https://img.shields.io/github/commits-since/ickc/pandoc-amsthm/v1.2.3.svg)](https://github.com/ickc/pandoc-amsthm/compare/v1.2.3...master)
![License](https://img.shields.io/pypi/l/amsthm.svg)

[![Conda Recipe](https://img.shields.io/badge/recipe-amsthm-green.svg)](https://anaconda.org/conda-forge/amsthm)
[![Conda Downloads](https://img.shields.io/conda/dn/conda-forge/amsthm.svg)](https://anaconda.org/conda-forge/amsthm)
[![Conda Version](https://img.shields.io/conda/vn/conda-forge/amsthm.svg)](https://anaconda.org/conda-forge/amsthm)
[![Conda Platforms](https://img.shields.io/conda/pn/conda-forge/amsthm.svg)](https://anaconda.org/conda-forge/amsthm)

# Introduction

amsthm provide a syntax to use amsthm environments in pandoc, with
output in LaTeX and HTML.

# Usage

From `makefile`:

``` makefile
tests/model-target.md: tests/model-source.md
    pandoc -F amsthm $< -o $@
tests/model-latex.tex: tests/model-source.md
    pandoc -F amsthm $< -o $@ --top-level-division=chapter --toc -N
tests/model-latex.pdf: tests/model-source.md
    pandoc -F amsthm $< -o $@ --top-level-division=chapter --toc -N
tests/model-html.html: tests/model-source.md
    pandoc -F amsthm $< -o $@ --toc -N -s
```

# Syntax

See `tests/model-source.md` (or next page in documentation site) for an example.

# Tips

-   Use `-N`, `--number-sections` to enable numbering in pandoc. This is
    mandatory for LaTeX output.
-   To match LaTeX and non-LaTeX output numbering scheme, match these 2
    settings manually
    -   LaTeX output: pandoc's cli flag
        `--top-level-division=[section|chapter|part]` and the use of
        `parent_counter` in pandoc-amsthm
    -   non-LaTeX output: `counter_depth` in pandoc-amsthm

# Supported pandoc versions

pandoc versioning semantics is [MAJOR.MAJOR.MINOR.PATCH](https://pvp.haskell.org) and panflute's is MAJOR.MINOR.PATCH. Below we shows matching versions of pandoc that panflute supports, in descending order. Only major version is shown as long as the minor versions doesn't matter.

| pandoc-amsthm | panflute version | supported pandoc versions | supported pandoc API versions |
| ------------- | ---------------- | ------------------------- | ----------------------------- |
| 2.0.0         | 2.1.3            | 2.14.0.3–2.17.x           | 1.22–1.22.1                   |

: Version Matching^[For pandoc API verion, check https://hackage.haskell.org/package/pandoc for pandoc-types, which is the same thing.]
