include config.mk

BINDIR=bin
DOCDIR=manuals
PWD=$(shell pwd)
# processes ST_wtch_DR and ST_wtch_DS do not compile (missing QCDloop code)
PROCESSES=WW WZ HJ W_ew-BW Wbb Wj HJJ Wp_Wp_J_J VBF_Wp_Wp ZZ W_ew-BMNNP Dijet gg_H VBF_H Z W hvq Zj ST_sch ST_tch ST_tch_4f

all: mksetup mkbinaries

mkbinaries:
	export PATH=${FASTJET}/bin:${LHAPDF}/bin:$${PATH} && \
	for i in $(PROCESSES) ; do \
	  echo "=> Making $$i ..." && \
	  $(MAKE) -C $$i pwhg_main FC=$(FC) COMPILER=$(FC) || exit 1 ; \
	done

mksetup:
	( echo "#!/bin/sh" ; \
	  echo "" ; \
	  echo "# Source this script to setup environment (bash shell):" ; \
	  echo "#   \$$ source $(PREFIX)/$(BINDIR)/setup.sh" ; \
	  echo "" ; \
	  echo "export PATH=$(PREFIX)/$(BINDIR):\$${PATH}" ; \
	  echo "export LD_LIBRARY_PATH=$(FASTJET)/lib:$(shell $(LHAPDF)/bin/lhapdf-config --libdir):\$${LD_LIBRARY_PATH}" ; \
	  echo "export LHAPATH=$(shell $(LHAPDF)/bin/lhapdf-config --pdfsets-path)" ; \
	) > setup.sh
	( echo "#!/bin/csh" ; \
	  echo "" ; \
	  echo "# Source this script to setup environment (csh shell):" ; \
	  echo "#   \$$ source $(PREFIX)/$(BINDIR)/setup.csh" ; \
	  echo "" ; \
	  echo "setenv PATH $(PREFIX)/$(BINDIR):\$${PATH}" ; \
	  echo "setenv LD_LIBRARY_PATH $(FASTJET)/lib:$(shell $(LHAPDF)/bin/lhapdf-config --libdir):\$${LD_LIBRARY_PATH}" ; \
	  echo "setenv LHAPATH $(shell $(LHAPDF)/bin/lhapdf-config --pdfsets-path)" ; \
	) > setup.csh

# to copy documentation we use more complicated `find ... | xargs ...` way
# instead of simple `cp` to avoid error
#   "cp: will not overwrite just-created ..."
install:
	mkdir -p $(PREFIX)/$(BINDIR)
	for i in $(PROCESSES) ; do \
	  cp -f $$i/pwhg_main $(PREFIX)/$(BINDIR)/$$i || exit 1 ; \
	done
	cp -f setup.sh setup.csh $(PREFIX)/$(BINDIR)/
	mkdir -p $(DATADIR)/$(DOCDIR)
	find . -name "*.pdf" -o -name "*.ps.gz" | xargs -I "{}" cp {} $(DATADIR)/$(DOCDIR)/

clean:
	for i in $(PROCESSES) ; do \
	  make -C $$i clean ; \
	done
	rm -f setup.sh setup.csh
