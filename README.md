---
---

Define amsthm environment in YAML front matter and use it with a native pandoc div in the main document. Using the templates and filter provided, HTML and LaTeX output using amsthm can be realized. See the repository in [ickc/pandoc-amsthm: provide amsthm environments in pandoc with output in LaTeX and HTML](https://github.com/ickc/pandoc-amsthm).

# Usage

`pandoc --template=<pathto>pandoc-amsthm.<ext> --filter=<pathto>pandoc-amsthm.py ...`

Templates are provided in `template/`, choose the appropriate `.html`, `.html5`, `.latex` for HTML, HTML5, and LaTeX output.

A filter is provided in `bin/pandoc-amsthm.py`. Only LaTeX output really required the filter. It will check for the output format so it is safe to include the filters for any output format.

In the document, YAML front matter is required to defined the amsthm environment. And whenever an amsthm environment is used in the main document, a native pandoc div is used.

The syntax of both the YAML definition and the native pandoc div is best shown by the following example:

## Example

### YAML Definition

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
  parentcounter:	chapter
...
```

Note:

- proof environment: `proof: [proof]`
	- the proof variable has to be there, since the amsthm pre-defined it, but we need it there to for the filter to recognize the div to turn it into a LaTeX environment.
	- It also has to be in **lower case**, to match the pre-definition in the LaTeX amsthm package.
- **even if it is a single element array, it has to be enclosed in `[]`** due to how the filter is written e.g. `[Theorem]`,`[Case]`, `[proof]`
- `plain, definition, and remark` are the theorem styles provided by amsthm, see [the documentation of amsthm in CTAN](http://ctan.math.washington.edu/tex-archive/macros/latex/required/amscls/doc/amsthdoc.pdf)
- the suffix `-unnumbered` means unnumbered, otherwise numbered, corresponding to starred and un-starred amsthm environment respectively.
- `parentcounter` defines the parent counter. Only has effects in LaTeX, such that the counter will reset base on the value you set. e.g. `parentcounter: chapter`. For the possible set of values to choose from, see [the documentation of amsthm in CTAN](http://ctan.math.washington.edu/tex-archive/macros/latex/required/amscls/doc/amsthdoc.pdf). It can either be enclosed with `[]` or not.
- For the amsthm environments other than `proof`, **uppercase first letter is recommended**, since it will be displayed in the output as is.

### Markdown Content ###

A **native pandoc Div** with a **class** named as the environment defined in the YAML front matter, with **case-matched**. More than 1 amsthm classes cannot be used simultaneously.

For example,

```html
<div class="proof">
A Proof.
</div>
<div class="Theorem">
A Theorem.
</div>
<div class="Theorem boxed">
A boxed theorem if you define so in CSS. (Of course other filters needed if you want it boxed in LaTeX too.)
</div>
```

## Demo

A demo is provided in `test/`. You can see the `makefile` for the command used there.

There's also another makefile `makefile-local` to test local installation of the amsthm templates and filters. The templates should be copied to `~/.pandoc/templates/` and the `pandoc-amsthm.py` should be copied to one of your PATH.

See the outputs in:

- <https://ickc.github.io/pandoc-amsthm/test/test-html5.html>
- <https://ickc.github.io/pandoc-amsthm/test/test.html>
- <https://ickc.github.io/pandoc-amsthm/test/test.pdf>

The equations in the example in the demo is copied from [Riemann hypothesis - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Riemann_hypothesis).

## Other Usages

Because of how the filter works, a side benefit/unofficial usage is:

```yaml
---
amsthm:
  unofficial-use:	[flushright]
...
```

```html
<div align="right" class="flushright">
This text should flushed to the right.
</div>
```

# Caveats #

## CSS Counter ##

In the CSS defined in HTML,

- a `.dump` is used, basically because I have 4 for loops together and I have no way to guarantee it doesn't end with a comma, since any of the array can be empty.
- The CSS counter is reset by `html`. If you use other CSS, and have other CSS counter set by `html`, you need to change that (`body` is another possible choice). If there's two separately defined CSS counter reset based on the same `html` or `body` then there would be trouble (and to resolve the conflict, they should be combined together).

## Pandoc-Citeproc ##

Currently if pandoc-citeproc is used before this filter, there's an error. So this filter should be used first.

# Credit

The Python script used is modified from [chdemko/pandoc-latex-environment: Pandoc filter for adding LaTeX environement on specific div](https://github.com/chdemko/pandoc-latex-environment), which is under [CeCILL-B license](http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.html).