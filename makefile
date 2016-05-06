SOURCES=index.md
COMPILED=index.html index-html5.html index.tex index.pdf

all: $(SOURCES) $(COMPILED)

index.html: $(SOURCES)
	pandoc -s --toc --template=./templates/pandoc-amsthm.html --mathjax -o index.html $(SOURCES)
index-html5.html: $(SOURCES)
	pandoc -s --toc --template=./templates/pandoc-amsthm.html5 --mathjax -o index-html5.html $(SOURCES)
index.tex: $(SOURCES)
	pandoc -s --toc --template=./templates/pandoc-amsthm.latex --filter=./py/pandoc-amsthm.py -o index.tex $(SOURCES)
index.pdf: $(SOURCES)
	pandoc -s --toc --template=./templates/pandoc-amsthm.latex --filter=./py/pandoc-amsthm.py -o index.pdf $(SOURCES)