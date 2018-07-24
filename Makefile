TEX = pdflatex -interaction nonstopmode
BIB = bibtex
GS = gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite 
DAT2TEX = perl mktex.pl

BASE = mktex.pl problem.tex template.tex

#for debugging:
.PRECIOUS: %.tex

#spell::
#	 ispell *.tex

%.tex : %.dat
	$(DAT2TEX) $(basename $^ .dat)

%.pdf : %.tex
	$(TEX) $^

all: $(addsuffix .pdf, $(basename $(wildcard *.dat)))
	
clean::
	rm -fv *.aux *.log *.bbl *.blg *.toc *.out *.lot *.lo *.4ct *.4tc *.idv *.lg *.tmp *.xref *.dvi *.tex *.pdf

