SHELL := /bin/bash

all: default.html default.tex

default.html: default.yml pandoc-amsthm.html
	pandoc --template=pandoc-amsthm.html default.yml -o $@

default.tex: default.yml pandoc-amsthm.latex
	pandoc --template=pandoc-amsthm.latex default.yml -o $@

clean: default.html default.tex
