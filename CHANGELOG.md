# Changelog

## v3.0.0 (unreleased)

Rewritten as a Pandoc Lua filter. The input syntax is unchanged.

- **Breaking:** run it with `pandoc -L amsthm.lua` instead of
  `pandoc -F amsthm`. Get `amsthm.lua` from the GitHub releases; the
  `amsthm` Python package is no longer developed.
- **Breaking:** requires Pandoc 3.1.1 or later.
- Works as a Quarto extension: `quarto add ickc/pandoc-amsthm`.
- LaTeX output no longer defines each theorem label twice.
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
