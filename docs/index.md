---
---

Define amsthm environment in YAML front matter and use it with a native pandoc div in the main document. Using the templates and filter provided, HTML and LaTeX output using amsthm can be realized.

See the repository in [ickc/pandoc-amsthm](https://github.com/ickc/pandoc-amsthm).

You can also read the [README here](https://ickc.github.io/pandoc-amsthm/README.html).

# Demo

A demo is provided in `test/`. In command line, you can `cd` into the folder and `make` should compile these examples. Click and see the results:

- [test-html5.html](https://ickc.github.io/pandoc-amsthm/test/test-html5.html)
- [test.html](https://ickc.github.io/pandoc-amsthm/test/test.html)
- [test.pdf](https://ickc.github.io/pandoc-amsthm/test/test.pdf)

There's also another makefile `makefile-local` to test local installation of the amsthm templates and filters. The templates should be copied to `~/.pandoc/templates/` and the `pandoc-amsthm.py` should be copied to one of your `PATH`. You can then run `make -f makefile-local` to see if you set it up correctly.

The equations in the example in the demo is copied from [Riemann hypothesis - Wikipedia, the free encyclopedia](https://en.wikipedia.org/wiki/Riemann_hypothesis).

# Example

## YAML Definition

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

## Markdown Content

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

## Commands

```bash
pandoc -s --toc --template=<pathto>pandoc-amsthm.html --mathjax -o ...
pandoc -s --toc --template=<pathto>pandoc-amsthm.html5 --mathjax -o ...
pandoc -s --toc --template=<pathto>pandoc-amsthm.latex --filter=<pathto>pandoc-amsthm.py -o ...
pandoc -s --toc --template=<pathto>pandoc-amsthm.latex --filter=<pathto>pandoc-amsthm.py -o ...
```

# Other Usages

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
