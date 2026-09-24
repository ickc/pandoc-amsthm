# Changelog

## Unreleased

Closer to what `amsthm` does in LaTeX, in every output.

- Cross-references link to the environment in HTML and other non-LaTeX
  output, as hyperref makes them do in LaTeX
  ([#21](https://github.com/ickc/pandoc-amsthm/issues/21)).
- `@Euler`, with the first letter of the identifier capitalised, gives
  the environment's name with the number, "Theorem 1", as `\Cref` does;
  `[@Euler]` gives "(Theorem 1)". LaTeX output writes it as
  `Theorem~\ref{euler}`
  ([#22](https://github.com/ickc/pandoc-amsthm/issues/22)).
- `name_to_text: {proof: ...}` renames the proof, in other output as
  well as in LaTeX, where it sets `\proofname`. LaTeX output already
  followed the document's `lang`.
- In the italic body of a plain theorem, a reference from `@id` or
  `\ref` is italic, and one from `[@id]` or `\eqref` upright, as in
  LaTeX.
- LaTeX: a reference to an unnumbered environment is left to citeproc,
  as in other output, rather than printing the enclosing section's
  number.
- LaTeX: a theorem note holding math, raw TeX or a citation with a
  locator, such as `info="on $[0,1]$"`, no longer ends at its first `]`.
- Markdown output: emphasis inside a plain theorem no longer leaves a
  stray `**`.
- An empty `amsthm:` key no longer stops the filter with an error.

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
