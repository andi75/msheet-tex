TEX = pdflatex -interaction nonstopmode
BIB = bibtex
GS = gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite 
DAT2TEX = perl mktex.pl

PAPER = uebung
PAPER-L = uebung-l

BIBFILE = temp.bib

all: $(PAPER).pdf $(PAPER-L).pdf

view: $(PAPER).pdf
	open $(PAPER).pdf

view-l: $(PAPER-L).pdf
	open $(PAPER-L).pdf

spell::
	ispell *.tex

clean::
	rm -fv *.aux *.log *.bbl *.blg *.toc *.out *.lot *.lo $(PAPER).pdf $(PAPER).tex $(PAPER-L).pdf $(PAPER-L).tex

$(PAPER).tex: $(PAPER).dat template.tex problem.tex
	$(DAT2TEX) $(PAPER)

$(PAPER).pdf: $(PAPER).tex
	$(TEX) $(PAPER) 

$(PAPER-L).tex: $(PAPER-L).dat template.tex problem.tex
	$(DAT2TEX) $(PAPER-L)

$(PAPER-L).pdf: $(PAPER-L).tex
	$(TEX) $(PAPER-L) 
