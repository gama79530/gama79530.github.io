# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = source
BUILDDIR      = build
USEDOCKER     = true

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile publish test clean

clean:
	@rm -rf docs build

preview:
	@$(if $(filter true, $(USEDOCKER)), docker compose run --rm github.io, bash) -c "rm -rf build && make html"

publish:
	@rm -rf docs build && mkdir docs
	@touch docs/.nojekyll
	@$(if $(filter true, $(USEDOCKER)), docker compose run --rm github.io, bash) -c "make html"
	@cp -r build/html/* docs
	@git add -f docs/
	@git commit -m "Publish"

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

