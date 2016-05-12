See the repository in [ickc/pandoc-amsthm: provide amsthm environments in pandoc with output in LaTeX and HTML](https://github.com/ickc/pandoc-amsthm).
  
# Usage #

Define amsthm environment in YAML front matter, using the templates provided, HTML and LaTeX output using amsthm can be realized.

In LaTeX output, a filter `pandoc-amsthm.py` needed to be used.

For example,

## Example ##

### YAML Definition ###

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
---
```

Note:

- proof environment: `proof: [proof]`
	- the proof variable has to be there, since the amsthm pre-defined it, but we need it there to for the filter to recognize the div to turn it into a LaTeX environment.
	- It also has to be in **lower case**, to match the pre-definition in the LaTeX amsthm package.
- **even if it is a single element array, it has to be enclosed in `[]`** due to how the filter is written e.g. `[Theorem]`,`[Case]`, `[proof]`
- `plain, definition, and remark` are the theorem styles provided by amsthm, see [the documentation of amsthm in CTAN](http://ctan.math.washington.edu/tex-archive/macros/latex/required/amscls/doc/amsthdoc.pdf)
- the suffix `-unnumbered` means unnumbered, otherwise numbered, corresponding to starred and un-starred amsthm environment respectively.
- `parentcounter` defines the parent counter. Only has effects in LaTeX, such that the counter will reset base on the value you set. e.g. `parentcounter: chapter`. For the possible set of values to choose from, see [the documentation of amsthm in CTAN](http://ctan.math.washington.edu/tex-archive/macros/latex/required/amscls/doc/amsthdoc.pdf). It can either be enclosed with `[]` or not.
- For the amsthm environments other than `proof`, **uppercase first letter is recommended**, since it will be displayed as is.

### Markdown Content ###

A **native pandoc Div** with a **class** named as the environment defined in the YAML front matter, with **case-matched**. **Multiple classes are allowed**, as long as no 2 classes of 2 amsthm environment is put together.

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

### Pandoc Commands to Use ###

Commands to used (see `build.sh`):

```bash
pandoc -s --toc --template=./templates/pandoc-amsthm.html --mathjax -o index.html index.md
pandoc -s --toc --template=./templates/pandoc-amsthm.html5 --mathjax -o index-html5.html index.md
pandoc -s --toc --template=./templates/pandoc-amsthm.latex --filter=./py/pandoc-amsthm.py -o index.tex index.md
pandoc -s --toc --template=./templates/pandoc-amsthm.latex --filter=./py/pandoc-amsthm.py -o index.pdf index.md
```

### Demo Output ###

See the outputs in:

- <https://ickc.github.io/pandoc-amsthm/index-html5.html>
- <https://ickc.github.io/pandoc-amsthm/index.html>
- <https://ickc.github.io/pandoc-amsthm/index.pdf>

The equations in the example in the demo is copied from [Riemann hypothesis - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Riemann_hypothesis).

## Other Usages

Because of how the filter works, a side benefit/undocumented usage is this:

```yaml
---
amsthm:
  unofficial-use:	[flushright]
---
```

```html
<div align="right" class="flushright">
This text should flushed to the right.
</div>
```

# Notes #

The required LaTeX codes in the preamble and the CSS in HTML are provided in the template. So no other things are needed. The only non-official things are the custom templates and the filter. I wish both can make into the official pandoc language and program.

There's a script `build-local.sh` to test local installation of the amsthm templates and filters. The templates should be copied to `~/.pandoc/templates/` and the `pandoc-amsthm.py` should be copied to one of your PATH.

# Caveats #

## CSS Counter ##

In the CSS defined in HTML,

- a `.dump` is used, basically because I have 4 for loops together and I have no way to guarantee it doesn't end with a comma, since any of the array can be empty.
- The CSS counter is reset by `html`. If you use other CSS, and have other CSS counter set by `html`, you need to change that (`body` is another possible choice). If there's two separately defined CSS counter reset based on the same `html` or `body` then there would be trouble (and they should be combined together).

## Pandoc-Citeproc ##

Currently if pandoc-citeproc is used before this filter, there's an error. So this filter should be used first.

# Credit

The Python script used is modified from [chdemko/pandoc-latex-environment: Pandoc filter for adding LaTeX environement on specific div](https://github.com/chdemko/pandoc-latex-environment), which is under [CeCILL-B license](http://www.cecill.info/licences/Licence_CeCILL-B_V1-en.html).