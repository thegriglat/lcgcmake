include config.mk

IFGF = $(shell echo ${FC} | grep gfortran)

ifeq (x$(IFGF),x)
  MYFC=$(FC)
else
  MYFC=gfortran
endif

BINDIR=bin
DOCDIR=manuals
PWD=$(shell pwd)
# processes ST_wtch_DR and ST_wtch_DS do not compile (missing QCDloop code)
PROCESSES=DMV DMGG DMS DMS_tloop gg_H_quark-mass-effects hvq \
HZJ ttb_dec vbf_wp_wp Wbb_dec Wj Z ZZ ZZ WZ ggHZ HW ST_tch_4f VBF_Z_Z Wp_Wp_J_J Z2jet \
HJ HWJ VBF_H W W_ew-BMNNP WW Z_ew-BMNNPV HJJ HZ trijet W2jet Wgamma WZ Zj gg_H_2HDM gg_H_MSSM

# to be cleaned 

# Wbbj - sometime fails with gfortran: internal compiler error: Killed (program f951 

# disquark  - no Makefile

# VBF_HJJJ: pwhg_analysis-dummy.f:10: Error: Can't open included file '../pwhg_book.h'

#gg_H_MSSM
#init_couplings.f:503:0: fatal error: SLHA.h: No such file or directory
# #include "SLHA.h"
# ^
#compilation terminated.

# dijet - pwhg_analysis.f:10: Error: Can't open included file '../pwhg_book.h'

# ttH - takes ages to compile...(?)
# dislepton-jet - takes ages to compile...(?)
#

all: mksetup mkbinaries

mkbinaries:
	export PATH=${FASTJET}/bin:${LHAPDF}/bin:$${PATH} && \
	for i in $(PROCESSES) ; do \
	  echo "=> Making $$i ..." && \
	  echo "=> FC = $(FC), MYFC = $(MYFC)" && \
	  $(MAKE) -C $$i pwhg_main FC=$(MYFC) COMPILER=$(MYFC) CHAPLIN=$(CHAPLIN) FEYNHIGGS=$(FEYNHIGGS) || exit 1 ; \
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
