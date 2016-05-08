SOURCES=index.md
COMPILED=index.html index-html5.html index.tex index.pdf
TEMPLATEPATH=./templates/
FILTERPATH=./py/

all: $(COMPILED)

index.html: $(SOURCES)
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.html --mathjax -o index.html $<
index-html5.html: $(SOURCES)
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.html5 --mathjax -o index-html5.html $<
index.tex: $(SOURCES)
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.latex --filter=$(FILTERPATH)pandoc-amsthm.py -o index.tex $<
index.pdf: $(SOURCES)
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.latex --filter=$(FILTERPATH)pandoc-amsthm.py -o index.pdf $<