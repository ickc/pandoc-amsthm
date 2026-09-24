# Changelog

## Unreleased

Other output now follows what `amsthm` does in LaTeX more closely.
[DESIGN.md](DESIGN.md) describes the approach, and `pixi run bake`
compares the two renderings.

- Cross-references link to the environment in HTML and other non-LaTeX
  output. As hyperref does for `\ref`, only the number is a link
  ([#21](https://github.com/ickc/pandoc-amsthm/issues/21)).
- `@Euler`, with the first letter of the identifier capitalised, puts
  the environment's name before the number: "Theorem 1", written
  `Theorem~\ref{euler}` in LaTeX. `[@Euler]` gives "(Theorem 1)"
  ([#22](https://github.com/ickc/pandoc-amsthm/issues/22)).
- Theorem numbers count sections as LaTeX does: without `-N` they are
  0.1, 0.2, … with a warning; headings deeper than `secnumdepth` do not
  count; with `--top-level-division=part`, parts neither appear in nor
  restart a chapter's number, and are Roman numerals when theorems are
  numbered within them.
- In italic text, such as the body of a plain theorem or the note of a
  proof, a reference from `@id` or `\ref` is italic, and one from
  `[@id]` or `\eqref` upright, as in LaTeX.
- The end-of-proof symbol is `$\quad\Box$`, amsthm's `\quad\openbox`,
  which renders in every format and stays on the line of the text before
  it; the Unicode ◻ was missing from LaTeX's default fonts.
- `name_to_text: {proof: ...}` renames the proof, setting `\proofname`
  in LaTeX.
- A reference to an unnumbered environment gets a warning.
- LaTeX: a theorem note holding math, raw TeX or a citation with a
  locator, such as `info="on $[0,1]$"`, no longer ends at its first `]`.
- Markdown output: emphasis inside a plain theorem no longer leaves a
  stray `**`.
- An empty `amsthm:` key no longer stops the filter with an error.
- README: a list of known limitations.

## v3.0.0

Rewritten as a Pandoc Lua filter. The input syntax is unchanged.

- **Breaking:** run it with `pandoc -L amsthm.lua` instead of
  `pandoc -F amsthm`. Get `amsthm.lua` from the GitHub releases; the
  `amsthm` Python package is deprecated.
- **Breaking:** requires Pandoc 3.1.1 or later.
- **Breaking:** LaTeX output loads `amsthm` itself and puts the
  environment definitions in `header-includes` rather than at the start
  of the body, so it needs a standalone document (`-s`).
- **Breaking:** `counter_depth` defaults to follow `parent_counter` and
  `--top-level-division`, so LaTeX and other output number alike. Set
  `counter_depth: 0` for the old default.
- **Breaking:** in HTML and other non-LaTeX output, environments get the
  classes `amsthm` and `amsthm-<style>`, the heading is wrapped in an
  `amsthm-title` span, and the end-of-proof symbol is an `amsthm-qed`
  span, styled by CSS that the filter adds to HTML output.
- Works as a Quarto extension: `quarto add ickc/pandoc-amsthm`. Under
  Quarto the filter runs before Quarto's own theorem processing and drops
  the `proof`, `remark` and `solution` classes it has handled, so Quarto
  does not add a second heading.
- New `css` option: `false` leaves out the stylesheet added to HTML.
- LaTeX output no longer defines each theorem label twice.
- Fixed, compared with v2: in LaTeX output, theorem bodies stay in the
  document instead of being rendered on their own, so citations
  (`--natbib`, `--biblatex`, citeproc), writer options and later filters
  apply inside them. Nested environments are numbered in document order
  and keep their own style in other output. Headings marked
  `.unnumbered` no longer step the theorem numbers, which also follow
  `--number-offset`. A single value such as `plain: Main Theorem` is
  read as one environment rather than one per character, and an
  unsupported `parent_counter` is dropped rather than passed to LaTeX.
  Plain-style theorems with long paragraphs are no longer slow.
- Documentation moved to <https://ickc.github.io/pandoc-amsthm>.

## v2.1.0

- Requires panflute 2.3.x, supporting pandoc 2.14.0.3–3.11.
- Requires Python 3.10 or later.
- Packaging: built with uv, developed with pixi, released to PyPI via
  trusted publishing with attestations.

## v2.0.0

Python implementation built on panflute.

## v1.2.3

First release, as a proof of concept.
