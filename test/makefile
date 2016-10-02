SOURCES:=test.md
	
HTML:=test.html
HTML5:=test-html5.html
TeX:=test.tex
PDF:=test.pdf

TEMPLATEPATH:=../template/
FILTERPATH:=../bin/

all: $(HTML) $(HTML5) $(TeX) $(PDF)

$(HTML): $(SOURCES) $(TEMPLATEPATH)pandoc-amsthm.html
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.html --mathjax -o $@ $<
$(HTML5): $(SOURCES) $(TEMPLATEPATH)pandoc-amsthm.html5
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.html5 --mathjax -o $@ $<
$(TeX): $(SOURCES) $(TEMPLATEPATH)pandoc-amsthm.latex $(FILTERPATH)pandoc-amsthm.py
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.latex --filter=$(FILTERPATH)pandoc-amsthm.py -o $@ $<
$(PDF): $(SOURCES) $(TEMPLATEPATH)pandoc-amsthm.latex $(FILTERPATH)pandoc-amsthm.py
	pandoc -s --toc --template=$(TEMPLATEPATH)pandoc-amsthm.latex --filter=$(FILTERPATH)pandoc-amsthm.py -o $@ $<

clean:
	rm -f $(HTML) $(HTML5) $(TeX) $(PDF)
