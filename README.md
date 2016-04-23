The whole pandoc amsthm package is rewritten. The old one is in the archive folder.

# Usage #

Define amsthm environment in YAML front matter, using the templates provided, HTML and LaTeX output using amsthm can be realized.

In LaTeX output, a filter `latexdivs.py` needed to be used.

For example,

## Example ##

```yaml
---
amsthm:
  plain:	
    numbered:	Theorem
    unnumbered:	[Lemma, Proposition, Corollary]
  definition:	
    numbered:	[Definition,Conjecture,Example,Postulate,Problem]
    unnumbered:	[]
  remark:	
    numbered:	[Case]
    unnumbered:	[Remark,Note]
  parentcounter:	chapter
---
```

Commands to used (see `amsthm.sh`):

```bash
pandoc -s --toc --template=./templates/default.html --mathjax -o index.html index.md
pandoc -s --toc --template=./templates/default.html5 --mathjax -o index-html5.html index.md
pandoc -s --toc --template=./templates/default.latex --filter=./py/latexdivs.py -o index.tex index.md
pandoc -s --toc --template=./templates/default.latex --filter=./py/latexdivs.py -o index.pdf index.md
```

See the outputs in:

- <https://ickc.github.io/pandoc-amsthm/index-html5.html>
- <https://ickc.github.io/pandoc-amsthm/index.html>
- <https://ickc.github.io/pandoc-amsthm/index.pdf>

The examples in the demo copied from <[Riemann hypothesis - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Riemann_hypothesis)>

# Notes #

The required LaTeX codes in the preamble and the CSS in HTML are provided in the template. So no other things are needed. The only non-official things are the custom templates and the filter. I am hoping both can make into the official pandoc.