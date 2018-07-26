This is a preliminary draft for my own use! This document is likely
to be outdated soon as I move stuff around. You've been warned!

Requirements (I use OS X, but a Linux or Cygwin setup should work just as well)

- perl executable in $PATH
- LaTeX installation with the shortlst.sty package installed
  (see https://ctan.org/pkg/shortlst)
- GNU make (optional, but convenient)

Usage:

Copy the files uebung.dat and uebung-l.dat from the Examples directory to
the current directory, then type 'make'.

Alternatively, the command 

perl mktex.pl uebung

will parse uebung.dat, and create a file uebung.tex, which can be transformed
into a PDF using

pdflatex uebung.tex

You can repeat the steps above for uebung-l to generate the solutions to the
problems.

Multiple language:

mktex.pl now supports outputting in multiple languages, if the
templates/exercises contain the appropriate translations. Either
edit the Makefile, or just add the --lang=en switch after mktex.pl,
e.g. 'perl mktex.pl --lang=en uebung' to switch to the english
output.
