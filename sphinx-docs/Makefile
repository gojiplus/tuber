SPHINXOPTS ?= -W --keep-going
SPHINXBUILD ?= sphinx-build
SOURCEDIR = .
BUILDDIR = ../_site

.PHONY: html clean
html:
	$(SPHINXBUILD) $(SPHINXOPTS) -b html $(SOURCEDIR) $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR)

