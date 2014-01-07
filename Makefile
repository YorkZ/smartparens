SHELL = /bin/sh
EMACS ?= emacs
CASK ?= cask
ECUKES ?= ecukes
FILES = $(wildcard *.el)
ELCFILES = $(FILES:.el=.elc)

LIBS =

.PHONY: all compile clean clean-elc clean-elpa elpa ecukes-features test unit-tests print-deps travis-ci

#$(shell find elpa/ecukes-*/ecukes | tail -1)

all: compile
compile: $(ELCFILES)

$(ELCFILES): %.elc: %.el
	@$(EMACS) --batch -Q -L . $(LIBS) -f batch-byte-compile $<

test: unit-tests #ecukes-features

unit-tests: elpa
	${CASK} exec ${EMACS} -Q -batch -L . -L tests \
		-l tests/smartparens-test.el -f ert-run-tests-batch-and-exit

ecukes-features: elpa
	${CASK} exec ${ECUKES} --no-win

elpa:
	mkdir -p elpa
	${CASK} install 2> elpa/install.log

clean-elpa:
	rm -rf elpa

clean-elc:
	rm -f $(ELCFILES) tests/*.elc

clean: clean-elpa clean-elc

print-deps:
	${EMACS} --version
	@echo CASK=${CASK}
	@echo ECUKES=${ECUKES}

travis-ci: print-deps test
