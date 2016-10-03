---
---

Define amsthm environment in YAML front matter and use it with a native pandoc div in the main document. Using the templates and filter provided, HTML and LaTeX output using amsthm can be realized.

Demo are available at <https://ickc.github.io/pandoc-amsthm/>.

# Usage

`pandoc-amsthm` defines a new syntax above pandoc markdown. It is then processed through the use of provided pandoc templates and filter.

So far, only LaTeX and HTML related output are supported.

## Syntax

### YAML Front Matter

For example^[Given in <template/include/pandoc-amsthm.yml>],

```yaml
---
amsthm:
  plain:	[Theorem]
  plain-unnumbered:	[Lemma, Proposition, Corollary]
  definition:	[Definition,Conjecture,Example,Postulate,Problem]
  definition-unnumbered:	[]
  remark:	[Case]
  remark-unnumbered:	[Remark,Note]
  proof:	[proof]
  parentcounter:	[chapter]
...
```

Notes:

- `proof:	[proof]` is mandatory ^[because amsthm predefines it.]
- Enclosing with `[...]` is mandatory
- `parentcounter` is optional, common choices are `chapter`, `section`. Depending on the document class, it can be `part`, `chapter`, `section`, `subsection`, `subsubsection`, `paragraph`, `subparagraph`.
- `plain, definition, and remark` are the theorem styles provided by amsthm.
- the suffix `-unnumbered` means unnumbered, otherwise numbered
- First letter of the amsthm environment should be capitalized, except for `proof`.

### Amsthm environment

Each amsthm environment should be defined with a native pandoc div, with a class named as the environment defined through the YAML front matter. Like this:

```html
<div class="proof">
A Proof.
</div>
```

## Templates and Filter

The provided templates and filter are needed for pandoc to process the above defined syntax properly.

To use the given filter in `bin/`, add `--filter=<pathto>pandoc-amsthm.py` to your pandoc command. If you put put it in your `PATH`, then you only need `--filter=pandoc-amsthm.py`. ^[Strictly speaking, you only need to include the filter for LaTeX output. HTML related outputs only requires the templates.]

There are 2 ways to use the templates. If you do not need to customize the templates, 3 complete templates are provided in `template/` folder. Use the template according to the output format by adding this in your pandoc argument: `--template=<pathto>pandoc-amsthm.<ext>`.

If you need to customize your template (or need other HTML related output not provided here, *e.g.* ePub.), 2 templates are given in `template/include/`. They are fragments only. You need to insert the given fragment into the head or preamble for HTML and LaTeX respectively.

# Caveats

## CSS Counter

In the CSS defined through the HTML templates,

- a `.dump` is used, basically because I have 4 for loops together and I have no way to guarantee it doesn't end with a comma, since any of the array can be empty.
- The CSS counter is reset by `html`. If you use other CSS, and have other CSS counter set by `html`, you need to change that (`body` is another possible choice). If there's two separately defined CSS counter reset based on the same `html` or `body` then there would be trouble (and to resolve the conflict, they should be combined together).

## Pandoc-Citeproc

Currently if `pandoc-citeproc` is used before this filter, there's an error. So this filter should be used first. Like this: `--filter=pandoc-amsthm.py --filter=pandoc-citeproc`.

# Credit

The Python script used is modified from [chdemko/pandoc-latex-environment](https://github.com/chdemko/pandoc-latex-environment), which is under [CeCILL-B license](http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.html).
