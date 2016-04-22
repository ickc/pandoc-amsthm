#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

pandoc -s --toc --template=./templates/default.html --mathjax -o index.html index.md
pandoc -s --toc --template=./templates/default.html5 --mathjax -o index-html5.html index.md
pandoc -s --toc --template=./templates/default.latex --filter=./py/latexdivs.py -o index.tex index.md
pandoc -s --toc --template=./templates/default.latex --filter=./py/latexdivs.py -o index.pdf index.md