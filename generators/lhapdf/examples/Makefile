
SHELL = /bin/sh

include ./config.mk

LIBS := -L$(LHAPDFDIR)/lib -lLHAPDF 

override CPPFLAGS := -I$(LHAPDFDIR)/include -I$(LHAPDFDIR)/include/LHAPDF

override FFLAGS += -fPIC -ffree-form
override CXXFLAGS += -fPIC

exe_files_f := $(patsubst E%.f,lhapdf-e%,$(wildcard *.f))

exe_files_cc := $(patsubst CCT%.cc,lhapdf-cct%,$(wildcard *.cc))

exe_files := $(exe_files_cc) $(exe_files_f)

all: $(exe_files)
	@echo && \
	 echo "==> The following executables have been prepared:" && \
	 echo "    $(exe_files_cc)" && \
	 echo "    $(exe_files_f)" && \
	 echo && \
	 echo "==> type \`. path.sh' and run the examples: e.g." && \
	 echo "    ./lhapdf-example_name "

#-

lhapdf-example%: Example%.f
	$(FC) $(FFLAGS) -o $@ $< $(LIBS)

lhapdf-cctest%: CCTest%.cc
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) -o $@ $< $(LIBS)

#-

.PHONY: clean distclean

clean:
	rm -f *~
	rm -f $(exe_files)

distclean: clean
	rm -f  config.mk paths.sh

