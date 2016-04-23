#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR

pandoc -s --toc --mathjax -o test-local.html index.md
pandoc -s --toc --mathjax -t html5 -o test-local-html5.html index.md
pandoc -s --toc --filter=pandoc-amsthm.py -o test-local.tex index.md
pandoc -s --toc --filter=pandoc-amsthm.py -o test-local.pdf index.md