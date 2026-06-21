SHELL = /usr/bin/env bash

# This makefile is a thin convenience wrapper around `pixi run`. The
# real definitions live in pixi.toml under [tasks].

.PHONY: test test-unit test-golden demo-html demo-latex gen-golden \
        readme clean

test:
	pixi run test
test-unit:
	pixi run test-unit
test-golden:
	pixi run test-golden

demo-html:
	pixi run demo-html
demo-latex:
	pixi run demo-latex

gen-golden:
	pixi run gen-golden

readme: README.rst
README.rst: docs/README.md
	pixi run pandoc --toc --wrap=none $< \
		-V title='pandoc-amsthm Documentation' -s -t rst -o $@

clean:
	rm -f tests/model-latex.pdf tests/model-html.html
