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
| `name_to_text`            | Displayed text for a name, when it differs from the name. Keyed by the name exactly as it appears in the list above, including a trailing `*`. The key `proof` renames the proof (`\proofname` in LaTeX). |
| `parent_counter`          | Number theorems within this LaTeX sectioning unit (`part`, `chapter`, `section`, …). |
| `counter_depth`           | Non-LaTeX only: how many heading levels prefix the theorem number. By default it follows `parent_counter` and `--top-level-division`, so both kinds of output number alike; without `parent_counter` it is `0`, numbering theorems through the document. |
| `counter_ignore_headings` | Headings that do not advance the counters, such as `List of Figures` added by pandoc-crossref. |
| `css`                     | `false` leaves out the stylesheet described under [Styling HTML](#styling-html). |

### Cross-references

Give the div an identifier and refer to it with `@id` (the number) or
`[@id]` (the number in parentheses). Raw `\ref{id}` and `\eqref{id}`
also work. References may come before the theorem they point to. In
LaTeX output these become `\ref` and `\eqref`; in other output, a link
to the environment.

Capitalise the first letter of the identifier to put the environment's
name before the number: with the div `{#euler .Theorem}`, `@Euler`
gives "Theorem 1" and `[@Euler]` gives "(Theorem 1)". In LaTeX output
this is `Theorem~\ref{euler}`, as you would type it by hand, so the
name is the one you declared (`name_to_text`), whatever the position
in the sentence, only the number is a link, and no extra package is
needed. Unlike typing the name yourself, it stays right if the
environment changes later. The capital letter only selects this form;
an identifier that itself starts with a capital letter is always an
ordinary reference, so use lowercase identifiers for this.

A reference to an unnumbered environment prints nothing meaningful in
LaTeX, which gives the last number set before it, usually the
section's. LaTeX output keeps it as `\ref`, as written; other output
leaves it unresolved. The filter warns about it either way.

### Tips

- Pass `-N` (`--number-sections`) with `parent_counter`. Without it,
  LaTeX steps no section counter and numbers theorems 0.1, 0.2, …;
  other output does the same, and the filter warns. Theorem numbers
  also follow `secnumdepth` and parts (`--top-level-division=part`) as
  LaTeX does: a part is not in a chapter's number and does not restart
  it.
- LaTeX output loads `amsthm` and defines the environments through
  `header-includes`, so it needs a standalone document (`-s`, or any
  PDF output).

### Styling HTML

Each environment is a div with classes `amsthm` and `amsthm-<style>`
(`amsthm-plain`, `amsthm-definition`, `amsthm-remark`, `amsthm-proof`),
its heading is a span with class `amsthm-title`, and the end-of-proof
symbol is a span with class `amsthm-qed`. The filter adds the little
CSS it needs to HTML output itself, as a `:where()` rule of zero
specificity, so a rule of your own always wins no matter where your
stylesheet sits. `css: false` leaves it out altogether.

### Known limitations

In LaTeX output `amsthm` does the typesetting; in other output the
filter rebuilds the same result from Pandoc's elements (see
[DESIGN.md](DESIGN.md)). Some things cannot be expressed that way:

- **Language.** In LaTeX, babel translates "Proof" into the document's
  `lang`, as "Beweis" for `lang: de`. Other output always says
  "Proof". Set `name_to_text: {proof: Beweis}` to name it in both.
- **The end-of-proof symbol** cannot be pushed to the right margin.
  The CSS does this in HTML.
- **Vertical space** around environments is left to the output format.
- **Section numbering under Quarto.** Quarto numbers HTML sections
  itself and does not tell the filter whether `number-sections` is on,
  so HTML output always numbers theorems within the sections, as if it
  were.
- **A list or code block that starts an environment** runs in to its
  heading in LaTeX, as `amsthm` sets environments as lists; other
  output starts it on a new line.

## Paper cuts when composing with Quarto

Quarto has a theorem system of its own, and it claims syntax this
filter has used since 2016. Quarto converts two kinds of div into its
own theorems before any user filter runs, and that pass cannot be
switched off:

- divs whose class is `proof`, `remark` or `solution`, labelled with a
  `name` attribute rather than `info`;
- divs whose identifier starts with `thm-`, `lem-`, `cor-`, `prp-`,
  `cnj-`, `def-`, `exm-` or `exr-`.

The extension works around the first: it runs before Quarto's own
processing (`at: pre-ast`), and drops the `proof`, `remark` and
`solution` classes from environments it has already handled, so Quarto
does not add a second heading. The `amsthm-<style>` class still says
what each environment is.

The second is yours to avoid:

- **Do not give an amsthm environment an identifier starting with one
  of Quarto's prefixes.** `::: {#thm-euler .Theorem}` comes out as
  "Theorem 1 Theorem 1.", because Quarto numbers it again. Use any
  other identifier, such as `#euler` or `#thm:euler`.
- **Do not mix Quarto's theorems with this filter's in one document.**
  The two keep separate counters, so the numbering would be wrong.

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
pixi run bootstrap-tinytex    # once per machine, for the site's PDF
```

See [DESIGN.md](DESIGN.md) for how features are designed and checked:
LaTeX output first, then the same result built from Pandoc's AST for
every other format.

The filter is `_extensions/amsthm/amsthm.lua`. Specs under `spec/` use
[busted](https://lunarmodules.github.io/busted/) syntax and run through
a small built-in shim, so no Lua packages are needed.
