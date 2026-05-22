TEX_SOURCES := $(wildcard *.tex)
LITERATURE := latexlit.bib
PDFS := $(TEX_SOURCES:.tex=.pdf)
BASENAMES := $(basename $(TEX_SOURCES))

INTERMEDIATE_EXT := aux bbl bcf blg log out run.xml toc lof lot lol idx ilg ind
INTERMEDIATE_FILES := $(foreach base,$(BASENAMES),$(foreach ext,$(INTERMEDIATE_EXT),$(base).$(ext)))

.PHONY: all install clean clean-all

all: $(PDFS)

install: all
	mkdir -p ../pdf
	cp -f $(PDFS) ../pdf/

%.pdf: %.tex $(LITERATURE)
	pdflatex $<
	biber $(basename $<)
	pdflatex $<
	pdflatex $<

clean:
	rm -f $(INTERMEDIATE_FILES)

clean-all: clean
	rm -f $(PDFS)
