include config.mk

BINDIR=bin
DOCDIR=manuals
PWD=$(shell pwd)
#PROCESSES=WW WZ HJ W_ew-BW Wbb Wj HJJ ST_wtch_DR  Wp_Wp_J_J VBF_Wp_Wp ZZ W_ew-BMNNP Dijet gg_H ST_sch ST_tch VBF_H Z W hvq Zj ST_wtch_DS
PROCESSES=WW WZ HJ W_ew-BW Wbb Wj HJJ Wp_Wp_J_J VBF_Wp_Wp ZZ W_ew-BMNNP Dijet gg_H VBF_H Z W hvq Zj ST_sch ST_tch ST_tch_4f

all: mksetup mkbinaries

mkbinaries:
	mkdir -p $(BINDIR)
	for i in $(PROCESSES) ; do \
	  ( echo "=> Making $$i ..." && \
	    cd $$i && \
	    export PATH=${FASTJET}/bin:${LHAPDF}/bin:$${PATH} && \
	    $(MAKE) pwhg_main FC=$(FC) && \
	    cp pwhg_main ../$(BINDIR)/$$i ) ; \
	done

mksetup:
	mkdir -p $(BINDIR)
	( echo "#!/bin/sh" ; \
	  echo "" ; \
	  echo "# Source this script to setup environment (bash shell):" ; \
	  echo "#   \$$ source $(PREFIX)/$(BINDIR)/setup.sh" ; \
	  echo "" ; \
	  echo "export PATH=$(PREFIX)/$(BINDIR):\$${PATH}" ; \
	  echo "export LD_LIBRARY_PATH=$(FASTJET)/lib:$(shell $(LHAPDF)/bin/lhapdf-config --libdir):\$${LD_LIBRARY_PATH}" ; \
	  echo "export LHAPATH=$(shell $(LHAPDF)/bin/lhapdf-config --pdfsets-path)" ; \
	) > $(BINDIR)/setup.sh
	( echo "#!/bin/csh" ; \
	  echo "" ; \
	  echo "# Source this script to setup environment (csh shell):" ; \
	  echo "#   \$$ source $(PREFIX)/$(BINDIR)/setup.csh" ; \
	  echo "" ; \
	  echo "setenv PATH $(PREFIX)/$(BINDIR):\$${PATH}" ; \
	  echo "setenv LD_LIBRARY_PATH $(FASTJET)/lib:$(shell $(LHAPDF)/bin/lhapdf-config --libdir):\$${LD_LIBRARY_PATH}" ; \
	  echo "setenv LHAPATH $(shell $(LHAPDF)/bin/lhapdf-config --pdfsets-path)" ; \
	) > $(BINDIR)/setup.csh

# to copy documentation we use more complicated `find ... | xargs ...` way
# instead of simple `cp` to avoid error
#   "cp: will not overwrite just-created ..."
install:
	if [[ "$(PREFIX)" != "$(PWD)" ]] ; then \
	  mkdir -p $(PREFIX)/$(BINDIR) && \
	  cp -rf $(BINDIR)/* $(PREFIX)/$(BINDIR) ; \
	fi
	mkdir -p $(DATADIR)/$(DOCDIR) && \
	find . -name "*.pdf" -o -name "*.ps.gz" | xargs -I "{}" cp {} $(DATADIR)/$(DOCDIR)

clean:
	rm -rf $(BINDIR)
	for i in $(PROCESSES) ; do \
	  ( echo "=> Cleaning $$i ..." && \
	    cd $$i && \
	    make clean ) ; \
	done
