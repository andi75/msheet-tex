TEX = pdflatex -interaction nonstopmode
BIB = bibtex
GS = gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sPAPERSIZE=a4
# force german
# DAT2TEX = perl mktex.pl --lang=de
# force english
# DAT2TEX = perl mktex.pl --lang=en
# select language from .dat and default to "de"
DAT2TEX = perl mktex.pl

BASE = mktex.pl problem.tex template.tex

#for debugging:
.PRECIOUS: %.tex

#spell::
#	 ispell *.tex

%.tex : %.txt
	$(DAT2TEX) $(basename $^ .txt)

%.pdf : %.tex
	$(TEX) $^

all: $(addsuffix .pdf, $(basename $(wildcard *.txt)))
	
semiclean::
	rm -fv *.aux *.log *.bbl *.blg *.toc *.out *.lot *.lo *.4ct *.4tc *.idv *.lg *.tmp *.xref *.dvi *.tex

clean::
	rm -fv *.aux *.log *.bbl *.blg *.toc *.out *.lot *.lo *.4ct *.4tc *.idv *.lg *.tmp *.xref *.dvi *.tex *.pdf

