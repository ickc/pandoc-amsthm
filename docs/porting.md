---
title: Porting to v4
---

Version 4 of the filter takes the note of a theorem or proof from a span
with class `info` at the start of the environment, instead of the `info`
attribute:

```markdown
::: {#lagrange .Theorem info="*Lagrange*"}
The order of a subgroup divides the order of the group.
:::
```

is now written

```markdown
::: {#lagrange .Theorem}
[*Lagrange*]{.info} The order of a subgroup divides the order of the group.
:::
```

pandoc reads the span with the rest of the document, with the same
reader and extensions, so the filter no longer reads Markdown itself,
and runs where filters are sandboxed. Without the filter, the note is
the start of the paragraph.

# Who needs to do anything

The attribute still works for a note of plain text: letters, digits,
spaces, and `, . ; : ! ? ( ) / -`. Anything else, such as emphasis,
math, a citation or reference, raw TeX, or an apostrophe, v3 read as
Markdown, and v4 shows as typed, with a warning for the first such note
in a document:

```
[amsthm] warning: the info attribute is plain text since amsthm v4, so info="*Lagrange*" is shown as typed; write the note as a leading [...]{.info} span to keep its markup (once per document; see https://ickc.github.io/pandoc-amsthm/porting.html)
```

Documents with such notes need porting. Others render as before, and
can stay as they are; porting them too keeps one form in a project.
Typography that `smart` gave a note of otherwise plain text, a dash
from `--` or an ellipsis from `...`, is not warned about: v4 shows it as
typed.

# Port in three steps

The porting filter, `amsthm-port-v4.lua`, is attached to each
[release](https://github.com/ickc/pandoc-amsthm/releases) beside
`amsthm.lua`. It reads each environment's `info` attribute as v3 read
it, writes the note as a span at the start of the environment, and
removes the attribute, so that the document renders as it did. It
needs no particular version of `amsthm.lua`.

pandoc can only port a document by writing all of it again, and its
Markdown writer spells many things its own way: line breaks, list
markers, tables, the metadata block (whose comments it drops). So
format the document with that writer first, and commit, to keep those
changes out of the porting diff.

## 1. Format and commit

[panblack](https://github.com/ickc/panblack) formats Markdown with
pandoc, and writes a file only if pandoc renders the formatted file as
it rendered the original, so this commit changes no output. With
panblack 1.0, which is configured by `.panblack.yaml` (the Python 0.x
is deprecated; until 1.0 is released, its documentation explains how to
build it):

```sh
panblack init > .panblack.yaml   # once, if the project has no config
panblack --diff                  # see what would change
panblack                         # format the files .panblack.yaml covers
git commit -am "Format with panblack"
```

`panblack init` reads Markdown as
`markdown-simple_tables-multiline_tables-smart-latex_macros` and keeps
your line breaks (`wrap: preserve`); its documentation explains each
setting. Use the reader settings your documents are written for, the
same in the next step.

Without panblack, the command of the next step without the filter
formats a document, with no check that its output is unchanged.

## 2. Run the porting filter

With the reader extensions and writer options you formatted with, and
`-s`, without which pandoc leaves out the metadata block:

```sh
FROM=markdown-simple_tables-multiline_tables-smart-latex_macros
for f in *.md; do
  pandoc "$f" -s -f "$FROM" -t "$FROM" --wrap=preserve --columns=72 \
    -L amsthm-port-v4.lua -o "$f.v4" && mv "$f.v4" "$f"
done
panblack
```

Running panblack again formats the result as the rest of the project,
should your pandoc write something differently from the one panblack
bundles.

If the environments are declared in a metadata file rather than in each
document, such as Quarto's `_quarto.yml` or a `--metadata-file`, name it
with `-M amsthm-port-metadata=_quarto.yml` (repeat it for several). The
filter reads it for the names only; `--metadata-file` would copy the
file's contents into each document.

The filter lists each note it ports on stderr, with the span it wrote:

```
[amsthm-port] ported {#lagrange .Theorem info="*Lagrange*"}: [*Lagrange*]{.info}
```

## 3. Review the diff

```sh
git diff
```

Each environment that had a note should have lost its `info` attribute
and gained a span at the start of its first paragraph, or, before a
list or a display, a paragraph holding only the span. Nothing else
should have changed; if something did, it is the writer's, from options
that differ from the ones you formatted with.

# Quarto, and other documents a preprocessor reads

pandoc's Markdown writer is not safe for a `.qmd` file: it escapes
shortcodes (`{{< meta title >}}` becomes `{{\< meta title \>}}`), and
writes an executable cell (```` ```{python} ````) as inline code. The
same goes for R Markdown and other templates read before pandoc, and
panblack leaves such files out too. Port these by hand, from the
filter's list, writing nothing:

```sh
pandoc page.qmd -f markdown -t markdown -L amsthm-port-v4.lua \
  -M amsthm-port-metadata=_quarto.yml -o /dev/null
```

For each line, remove the `info` attribute from that environment and
start its first paragraph with the span. The list writes the span as
pandoc would, so keep any shortcode in it as you typed it. Then update
the extension, `quarto update extension ickc/pandoc-amsthm`.

# What the filter leaves to you

It warns about each of these, naming the div, and leaves it as it is:

- **A div whose environment it does not know**, declared in a metadata
  file not named with `-M amsthm-port-metadata`.
- **A note that is not text**, such as `info="- a list"`, on which v3
  stopped with an error: write the note you meant.
- **A div naming two environments**, which amsthm leaves alone too.
- **A div that already starts with a note span** and still has the
  attribute. v4 uses the span and warns; remove the attribute.

An empty `info=""` is removed: it gave no note in v3 either.
