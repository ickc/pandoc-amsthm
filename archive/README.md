# References #

- The `amsthm.css` is from my other repository: [multimarkdown-latex-css/css-source/amsthm at gh-pages · ickc/multimarkdown-latex-css](https://github.com/ickc/multimarkdown-latex-css/tree/gh-pages/css-source/amsthm), which is borrowed from a blog post (forgot where I see it. Let me know to put back the reference).
- The `pandoc-load-amsthm-chapter.tex` is modified from my other repository: [ickc/peg-multimarkdown-latex-support: Default support files for generating LaTeX documents with MMD 3 through MMD 5](https://github.com/ickc/peg-multimarkdown-latex-support)
- The pandoc filters in [py/](py/) are from my other repository: [pandocfilters/examples/amsthm at master · ickc/pandocfilters](https://github.com/ickc/pandocfilters/tree/master/examples/amsthm), which is borrowed from `theorem.py` in [pandocfilters/examples at master · jgm/pandocfilters](https://github.com/jgm/pandocfilters/tree/master/examples).

# Usage #

See `amsthm.sh` for examples:

```bash
pandoc -f markdown -S --base-header-level=1 --toc --toc-depth=6 -N --normalize -s --latex-engine=pdflatex --include-in-header=./pandoc-load-amsthm-chapter.tex --filter=./py/case.py --filter=./py/conjecture.py --filter=./py/corollary.py --filter=./py/definition.py --filter=./py/example.py --filter=./py/lemma.py --filter=./py/note.py --filter=./py/postulate.py --filter=./py/problem.py --filter=./py/proof.py --filter=./py/proposition.py --filter=./py/remark.py --filter=./py/theorem.py -o index.tex index.md

pandoc -f markdown -S --base-header-level=1 --toc --toc-depth=6 -N --normalize -s --latex-engine=pdflatex --include-in-header=./pandoc-load-amsthm-chapter.tex --filter=./py/case.py --filter=./py/conjecture.py --filter=./py/corollary.py --filter=./py/definition.py --filter=./py/example.py --filter=./py/lemma.py --filter=./py/note.py --filter=./py/postulate.py --filter=./py/problem.py --filter=./py/proof.py --filter=./py/proposition.py --filter=./py/remark.py --filter=./py/theorem.py -o index.pdf index.md

pandoc -f markdown -S --base-header-level=1 --toc --toc-depth=6 -N --normalize -s --mathjax="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS_CHTML-full" -c ./css/amsthm.css --filter=./py/case.py --filter=./py/conjecture.py --filter=./py/corollary.py --filter=./py/definition.py --filter=./py/example.py --filter=./py/lemma.py --filter=./py/note.py --filter=./py/postulate.py --filter=./py/problem.py --filter=./py/proof.py --filter=./py/proposition.py --filter=./py/remark.py --filter=./py/theorem.py -t html -o index.html index.md
```

# Demo #

- [HTML](https://ickc.github.io/pandoc-amsthm/)
- [LaTeX](https://ickc.github.io/pandoc-amsthm/index.pdf)

# Todo #

- The CSS is [not compatible with the pandoc filters yet](https://ickc.github.io/pandoc-amsthm/), because the css was wrote for something else.
- The python pandoc filters could be combined.
- Using the YAML front matter to create amsthm environments. Is it possible?

# Appendix

`replace.sh` is written to generate any other combinations of pandoc filters. For example,

```bash
./replace.sh -f theorem -t lemma theorem.py
```

would copy `theorem.py` to `lemma.py` and replace both `theorem` and `Theorem` to `lemma` and `Lemma`.

I then used this script to generate the 13 environment that I used. This can be applied to any other environments.