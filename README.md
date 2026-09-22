# pandoc-amsthm

[![Test](https://github.com/ickc/pandoc-amsthm/actions/workflows/test.yml/badge.svg)](https://github.com/ickc/pandoc-amsthm/actions/workflows/test.yml)
[![GitHub release](https://img.shields.io/github/v/release/ickc/pandoc-amsthm)](https://github.com/ickc/pandoc-amsthm/releases)
[![License](https://img.shields.io/github/license/ickc/pandoc-amsthm)](https://github.com/ickc/pandoc-amsthm/blob/main/LICENSE)

A Lua filter that gives [Pandoc](https://pandoc.org) and
[Quarto](https://quarto.org) the theorem environments of the LaTeX
[`amsthm`](https://ctan.org/pkg/amsthm) package. You declare the
environments once in the document's metadata, and write them as
[fenced divs](https://pandoc.org/MANUAL.html#divs-and-spans).

- LaTeX and Beamer output uses `amsthm` itself: the filter emits
  `\newtheorem`, `\theoremstyle` and `\begin{…}…\end{…}`.
- Any other output (HTML, EPUB, Markdown, …) gets the same numbering,
  styles and cross-references, computed by the filter.

See the [rendered example](https://ickc.github.io/pandoc-amsthm/example/)
and [its source](https://ickc.github.io/pandoc-amsthm/source.html).

## Installation

Pandoc 3.1.1 or later is required.

**Pandoc**: download `amsthm.lua` from the
[latest release](https://github.com/ickc/pandoc-amsthm/releases/latest)
and pass it with `-L`:

```sh
pandoc -L amsthm.lua input.md -N -o output.html
```

**Quarto**: install the extension into your project,

```sh
quarto add ickc/pandoc-amsthm
```

then list it in the document or project metadata:

```yaml
filters:
  - amsthm
```

## Usage

Declare environments under `amsthm` in the metadata, grouped by
`amsthm` theorem style:

```yaml
---
amsthm:
  plain:
    - Theorem:        # Theorem has its own counter,
        - Lemma       # which Lemma and Corollary share
        - Corollary
    - Conjecture\*    # a trailing * makes it unnumbered
    - KL
  definition:
    - Definition
  remark:
    - Case
  name_to_text:
    KL: Klein's Lemma
  parent_counter: section
---
```

Then use each name as the class of a div. The optional `info`
attribute is the note in parentheses, and may contain Markdown:

```markdown
::: {#thm:euler .Theorem info="Euler"}
$e^{i\pi} + 1 = 0$.
:::

As @thm:euler shows, … and see also [@thm:euler].

::: proof
Obvious.
:::
```

`proof` is always defined. Names containing spaces become classes with
underscores: `Main Theorem` is written as `::: Main_Theorem`.

### Options

| Key                       | Meaning |
| ------------------------- | ------- |
| `plain`, `definition`, `remark` | Environments in that style. An entry is a name, or a map from a name to the names that share its counter. |
| `name_to_text`            | Displayed text for a name, when it differs from the name. |
| `parent_counter`          | Number theorems within this LaTeX sectioning unit (`part`, `chapter`, `section`, …). |
| `counter_depth`           | Non-LaTeX only: how many heading levels prefix the theorem number. By default it follows `parent_counter` and `--top-level-division`, so both kinds of output number alike; without `parent_counter` it is `0`, numbering theorems through the document. |
| `counter_ignore_headings` | Headings that do not advance the counters, such as `List of Figures` added by pandoc-crossref. |

### Cross-references

Give the div an identifier and refer to it with `@id` (the number) or
`[@id]` (the number in parentheses). Raw `\ref{id}` and `\eqref{id}`
also work. References may come before the theorem they point to. In
LaTeX output these become `\ref` and `\eqref`.

### Tips

- Pass `-N` (`--number-sections`); LaTeX output needs it for the
  numbering to make sense.
- LaTeX output loads `amsthm` and defines the environments through
  `header-includes`, so it needs a standalone document (`-s`, or any
  PDF output).

### Styling HTML

Each environment is a div with classes `amsthm` and `amsthm-<style>`
(`amsthm-plain`, `amsthm-definition`, `amsthm-remark`, `amsthm-proof`),
its heading is a span with class `amsthm-title`, and the end-of-proof
symbol is a span with class `amsthm-qed`. The filter adds the little
CSS it needs to HTML output itself; add your own rules to restyle.

## Migrating from v2

Version 2 and earlier were a Python package built on
[panflute](https://github.com/sergiocorreia/panflute). The Lua filter
needs nothing besides Pandoc, and the input syntax is unchanged.

| v2 (Python)          | v3 (Lua)                                   |
| -------------------- | ------------------------------------------ |
| `pip install amsthm` | download `amsthm.lua`, or `quarto add`     |
| `pandoc -F amsthm`   | `pandoc -L amsthm.lua`                     |
| Pandoc ≥ 2.14        | Pandoc ≥ 3.1.1                             |

Also changed in v3:

- LaTeX: `amsthm` is loaded for you. Remove your own
  `\usepackage{amsthm}` if you like; it does no harm. The
  environment definitions moved from the start of the body to the
  preamble.
- `counter_depth` now defaults to match `parent_counter` rather than
  `0`. Set `counter_depth: 0` to keep the old numbering.
- HTML: environments carry the classes above, and the end-of-proof
  symbol is a span with a class instead of an inline style.

## Development

Everything is provisioned by [pixi](https://pixi.sh):

```sh
pixi run test         # all specs, under pandoc's bundled Lua
pixi run gen-golden   # regenerate tests/model-{latex.tex,target.md}
pixi run -e pandoc-min test   # against the oldest supported pandoc
pixi run docs         # render the site into docs/_site
pixi run docs-preview # serve it with live reload
```

The filter is `_extensions/amsthm/amsthm.lua`. Specs under `spec/` use
[busted](https://lunarmodules.github.io/busted/) syntax and run through
a small built-in shim, so no Lua packages are needed.
