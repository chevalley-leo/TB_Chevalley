BUILDDIR=build
LATEXMK=latexmk
INKSCAPE=inkscape
FIGDIR=assets/figures
DRAWIO=drawio
OUT=report

SVGS=$(wildcard $(FIGDIR)/*.svg)
DIOS=$(wildcard $(FIGDIR)/*.drawio)
PDFS=$(wildcard $(FIGDIR)/*.pdf)
PYFS=$(wildcard $(FIGDIR)/*.py)
FIGS_SVG=$(patsubst %.svg, $(BUILDDIR)/%.svg.pdf, $(SVGS))
FIGS_DIO=$(patsubst %.drawio, $(BUILDDIR)/%.drawio.pdf, $(DIOS))
FIGS_PDF=$(patsubst %.pdf, $(BUILDDIR)/%.pdf, $(PDFS))
FIGS_PY=$(patsubst %.py, $(BUILDDIR)/%.py.pdf, $(PYFS))

FIGS=$(FIGS_SVG) $(FIGS_DIO) $(FIGS_PDF) $(FIGS_PY)

all: $(OUT).tex $(FIGS) | $(BUILDDIR)
	$(LATEXMK) -pdf
	biber $(OUT)
	$(LATEXMK) -pdf $(OUT)
	$(LATEXMK) -pdf $(OUT)

figures: $(FIGS)

$(FIGS_SVG): $(BUILDDIR)/%.svg.pdf: %.svg | dirs
	dbus-run-session inkscape --export-area-drawing -o $@ $<

$(FIGS_PY): $(BUILDDIR)/%.py.pdf: %.py | dirs
	python3 $< > $@

$(FIGS_DIO): $(BUILDDIR)/%.drawio.pdf: %.drawio | dirs
	xvfb-run -a $(DRAWIO) --crop --export --format pdf --output $@ $< --disable-gpu --headless --no-sandbox

$(FIGS_PDF): $(BUILDDIR)/%.pdf: %.pdf | dirs
	cp $< $@

dirs: $(BUILDDIR)

$(BUILDDIR): $(BUILDDIR)/$(FIGDIR)

$(BUILDDIR)/$(FIGDIR):
	mkdir -p $@

clean:
	$(RM) $(BUILDDIR)/$(OUT).*
	$(LATEXMK) -C

mrproper:
	$(RM) -rf $(BUILDDIR)

biber: bibliography.bib
	biber --tool --validate-datamodel $<

fresh: $(wildcard *.tex)
	find . -name '*.tex' -print0 | xargs -n1 -0 perl -0777 -pi -e "s/\%\%if.+?\%\%fi//gs"

.PHONY: all figures dirs clean mrproper biber fresh