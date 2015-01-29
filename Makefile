TEXDIR := book/tex
RMD_CHAPTERS := $(shell find . -name '*.rmd')
TEX_CHAPTERS := $(patsubst ./%.rmd, $(TEXDIR)/%.tex, $(RMD_CHAPTERS))

all: book/ggplot2-book.pdf

book/ggplot2-book.pdf: $(TEXDIR)/ggplot2-book.pdf
	cp $(TEXDIR)/ggplot2-book.pdf book/ggplot2-book.pdf
	Rscript -e 'embedFonts("book/ggplot2-book.pdf")'
	touch book/ggplot2-book.pdf
	
# compile tex to pdf
# http://stackoverflow.com/questions/3148492/makefile-silent-remove
$(TEXDIR)/ggplot2-book.pdf: $(TEXDIR)/ggplot2-book.tex $(TEXDIR)/krantz.cls $(TEX_CHAPTERS)
	cp -r figures $(TEXDIR)/figures
	cp -r tbls $(TEXDIR)/tbls
	cp -r diagrams $(TEXDIR)/diagrams
	cd $(TEXDIR) && @rm ggplot2-book.ind 2> /dev/null || true
	cd $(TEXDIR) && @rm ggplot2-book.out 2> /dev/null || true
	cd $(TEXDIR) && xelatex ggplot2-book.tex
	cd $(TEXDIR) && makeindex ggplot2-book
	cd $(TEXDIR) && xelatex ggplot2-book.tex 
	cd $(TEXDIR) && xelatex ggplot2-book.tex
	touch $(TEXDIR)/ggplot2-book.pdf

# copy over LaTeX templates and style files
$(TEXDIR)/krantz.cls: book/krantz.cls
	cp book/krantz.cls $(TEXDIR)/krantz.cls
$(TEXDIR)/ggplot2-book.tex: book/ggplot2-book.tex
	cp book/ggplot2-book.tex $(TEXDIR)/ggplot2-book.tex

# rmd -> tex
$(TEX_CHAPTERS): render-tex.R $(RMD_CHAPTERS)
	Rscript render-tex.R $?
	touch $(TEX_CHAPTERS)
	
tbls: render-tbls.R
	Rscript render-tbls.R && touch tbls/