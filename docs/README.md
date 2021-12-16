---
title: amsthm---provide a syntax to use amsthm environments in pandoc,
  with output in LaTeX and HTML
---

``` table
---
header: false
markdown: true
include: badges.csv
...
```

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