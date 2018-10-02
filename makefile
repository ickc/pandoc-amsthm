SHELL := /usr/bin/env bash

demo: tests/model-latex.pdf tests/model-target.pdf tests/model-target.html tests/model-target.native tests/model-source.native

clean:
	cd tests && latexmk -c model-latex.tex
	rm -f tests/model-target.html tests/model-target.native tests/model-source.native tests/demo.md test.py

Clean:
	cd tests && latexmk -C model-latex.tex
	rm -f tests/model-latex.pdf tests/model-target.pdf tests/model-target.html tests/model-target.native tests/model-source.native

tests/model-latex.pdf: tests/model-latex.tex
	cd tests && latexmk -pdf model-latex.tex

tests/model-target.pdf: tests/model-target.md
	pandoc --pdf-engine=xelatex -s -o $@ $<

tests/model-target.html: tests/model-target.md
	pandoc -t html5 --mathjax -s -o $@ $<

%.native: %.md
	pandoc -t native -s -o $@ $<
