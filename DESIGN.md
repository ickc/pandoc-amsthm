# Design

pandoc-amsthm brings what `amsthm` does in LaTeX to Pandoc's Markdown,
for every output format. Each feature is designed in three steps, in
this order.

## 1. LaTeX output first

Start from how someone would use `amsthm` in a hand-written LaTeX
document: `\newtheorem`, `\theoremstyle`, `\begin{Theorem}[note]`,
`\label` and `\ref`, `\proofname`, and so on. Map that usage to Pandoc
conventions: environments are declared in YAML metadata, used as
fenced divs, and referred to with citation syntax. When the output is
LaTeX, the filter writes what that person would have written, and
lets `amsthm` do the typesetting.

So a feature starts from something that can be done with `amsthm`, and
its LaTeX output is what a LaTeX author would write by hand. The filter
does not change `amsthm`'s behaviour in LaTeX to agree with its other
output. Where LaTeX itself behaves oddly, such as `\ref` to an
unnumbered theorem printing the number of the enclosing section, the
LaTeX output still says what the author asked for, and the filter may
warn about it.

A feature that needs another package is weighed against the cost: the
package has to be installed, and it has to fit in Pandoc's and Quarto's
templates. For example, cleveref must be loaded after hyperref, which
Pandoc's template loads after `header-includes`.

## 2. Other output: the same result, built from the AST

For any other format, the filter builds the same result itself, from
Pandoc's AST: it counts the numbers, writes the headings, italicises
the body, resolves the references. The test for this rendering is:
**write it out as LaTeX without `amsthm`, and the PDF should look the
same as the one `amsthm` typesets**, up to details that the AST cannot
express.

When that holds, other formats come out right too, because nothing in
this rendering is specific to LaTeX: no raw TeX, only Pandoc elements.
For example, `amsthm` makes the body of a plain theorem italic, and
italic text inside it upright. This affects the numbers printed by
`\ref` and leaves `\eqref` upright, so the AST rendering does the same.

## 3. Known limitations

What Pandoc's AST cannot express is a known limitation, listed in the
README, not something to work around with format-specific tricks. Some
limitations can still be met halfway in a single format, such as the
CSS for HTML. Current ones:

- The end-of-proof symbol cannot be pushed to the right margin; the
  CSS does this in HTML.
- Vertical space around environments is left to the output format.
- `amsthm` sets an environment as a list, so a list or code block that
  starts one runs in to its heading in LaTeX. The AST starts it on a
  new line.
- Anything LaTeX computes from the document's language, such as the
  word "Proof" translated by babel, stays in English. Name it yourself
  with `name_to_text`.

## Checking a change

To see whether the AST rendering matches, render one document both
ways and compare the PDFs:

```sh
# amsthm typesets it
pandoc -L amsthm.lua doc.md -N -s -o amsthm.pdf
# the filter's own rendering, written as LaTeX without it
pandoc -L amsthm.lua doc.md -N -s -t native |
  pandoc -f native -N -s -o baked.pdf
```

With `-t native` the filter takes the path it takes for any non-LaTeX
format, and the second `pandoc` writes the result without it. Pass the
same options, such as `--top-level-division`, to both. This comparison
is visual and not automated. Expect the limitations above, and one
difference that comes from the comparison itself: after a run-in
heading (`\paragraph`), the baked environment runs in to the heading.
