# DEFINE FORTRAN COMPILATION DEFAULTS
-include ../config.mk

-include config.mk
#
ifeq (x$(ALPGENINSTALLED),x)
  ALPGENINSTALLED=..
endif
ifeq (x$(ALPGENLIBS),x)
  ALPGENLIBS=../lib/archive
endif
#
# DEFINE DIRECTORY TREE STRUCTURE:
py=${ALPGENINSTALLED}/pylib
alp=${ALPGENINSTALLED}/alplib

# Include files
#INC= $(py)/hepevt.inc $(py)/hnt.inc $(py)/pythia6300.inc

# LINKING GENERIC EXECUTABLE FOR PYTHIA EVENT-EVOLUTION
pyuser:
	mkdir -p ../bin
	$(FC) $(FFLAGS) -o ../bin/pyuser.exe $(py)/pyuser.f $(py)/atopyt.f \
	-L${ALPGENLIBS} -L$(PYTHIA6LOCATION) \
	-lpythia6 -lalpsho -lpythia6_dummy -lpythia6_pdfdummy
	ln -fs ../bin/pyuser.exe pyuser.exe

pyuserex1:
	mkdir -p ../bin
	$(FC) $(FFLAGS) -I$(PYTHIA6LOCATION)/../../include \
	-o ../bin/pyuserex1.exe pyuser.f $(py)/atopyt.f \
	-L${ALPGENLIBS} -L$(PYTHIA6LOCATION) \
	-lpythia6 -lalpsho -lpythia6_dummy -lpythia6_pdfdummy \
	-L$(TESTSLOCATION) -ltests -lcernlibgenser
	ln -fs ../bin/pyuserex1.exe pyuserex1.exe

pyuserex2:
	mkdir -p ../bin
	$(FC) $(FFLAGS) -I$(PYTHIA6LOCATION)/../../include \
	-I$(TESTSLOCATION)/../../include \
	-I$(HEPMCLOCATION)/include -I$(CLHEPLOCATION)/include \
  -I$(alp) \
	-o ../bin/pyuserex2.exe pyuser.cc $(py)/atopyt.f \
	-L${ALPGENLIBS} -L$(PYTHIA6LOCATION) \
	-lpythia6 -lalpsho -lpythia6_dummy -lpythia6_pdfdummy \
	-L$(TESTSLOCATION) -lanalyserhepmc \
	-L$(HEPMCLOCATION)/lib -lHepMC -lHepMCfio \
	-L$(CLHEPLOCATION)/lib -lCLHEP
	ln -fs ../bin/pyuserex2.exe pyuserex2.exe

pyuserex2_pt_W:
	mkdir -p ../bin
	$(FC) $(FFLAGS) -I$(PYTHIA6LOCATION)/../../include \
	-I$(TESTSLOCATION)/../../include -I$(TESTSLOCATION)/../../examples/pt_W_analysis \
	-I$(HEPMCLOCATION)/include $(INCLUDE_CLHEP) \
	-o ../bin/pyuserex2_pt_W.exe pyuser_pt_W.cc $(py)/atopyt.f \
	-L${ALPGENLIBS} -L$(PYTHIA6LOCATION) \
	-lpythia6 -lalpsho -lpythia6_dummy -lpythia6_pdfdummy \
	-L$(TESTSLOCATION)/../ -lanalyserhepmc -lpt_W_analysis \
	-L$(HEPMCLOCATION)/lib -lHepMC -lHepMCfio  $(LIBS_CLHEP) \
	-L$(LIBS_ROOT_PATH) -lCore -lCint -lMatrix -lHist -ldl 
	ln -fs ../bin/pyuserex2_pt_W.exe pyuserex2_pt_W.exe

# DIRECTORY CLEANUP UTILITIES:
#
# remove object files, etc
cleanall:
	-rm fort.* *.top *.par *.wgt *.unw *.mon *.stat
