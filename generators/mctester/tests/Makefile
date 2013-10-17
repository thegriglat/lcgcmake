###############################################################################
# Pythia 8 example
###############################################################################

# include global default settings from make.inc file (compilers' flags, etc).
include ../../make.inc
include make.inc

PROGRAM=pythia_test

################################################################################
#
# MC-TESTER needs the following libraries to be linked:
#
# 1) HEPEvent - C++ interface to various F77 event records.
#    This library resides in /lib subdirectory of MC-Tester.
# 2) MCTester - main MCTester library. Its sources may be
#    found in /src subdirectory of MC-Tester
# 3) ROOT libraries. The dependencies are found by executing root-config command
#    Note that root needs to be properly installed and ROOTSYS variable set.
#    (see ROOT_INSTALL from main Tester directory for details)
# 4) HepMCEvent - MC-Tester C++ interface for HepMC event objects.
# 5) HepMC library - 
# 6) Pythia8 libraries -
#
# It is sufficient to link these libraries, to use MC-Tester with your program.

#Libraries to include
HEPEVT_LIB  = ../../lib/libHEPEvent.$(LIB_EXT)
TESTER_LIB  = ../../lib/libMCTester.$(LIB_EXT)
HEPMCEVT_LIB = ../../lib/libHepMCEvent.$(LIB_EXT)

#Paths to be linked with rpath
HERE        := $(shell cd ../.. && pwd)

TESTER_INC=../../include

all: $(PROGRAM).exe
	@echo " ***************************************************"
	@echo "  Executable file OK. "
	@echo "  To run example, please execute: "
	@echo "    ./$(PROGRAM).exe"
	@echo "  then execute "
	@echo "    make move1 "
	@echo " or "
	@echo "    make move2 "
	@echo " to move result files to either"
	@echo "   /analyze/prod1     or"
	@echo "   /analyze/prod2     directory."
	@echo " ***************************************************"
ifeq ($(PYTHIA8DATA), )
	@echo " Please remember to set PYTHIA8DATA:"
	@echo " export PYTHIA8DATA="${PYTHIALOCATION}/xmldoc
	@echo " ***************************************************"
endif

$(PROGRAM).exe: $(PROGRAM).cc
	$(CXX) $(CXXFLAGS) -I$(HEPMCLOCATION)/include -I$(PYTHIALOCATION)/include \
	-I$(TESTER_INC) $(PROGRAM).cc -o $@ \
	${HEPMCEVT_LIB} -L$(PYTHIALOCATION)/lib/archive -lpythia8 -llhapdfdummy -lhepmcinterface \
	$(HEPMCLOCATION)/lib/libHepMC.a $(TESTER_LIB) $(HEPEVT_LIB) $(ROOTGLIBS) \
	-Wl,-rpath,$(HERE)/lib \
	-Wl,-rpath,$(ROOTLIBPATH)
#
# Cleanup targets:
#
move1:
	cp mc-tester.root ../../analyze/prod1/

move2:
	cp mc-tester.root ../../analyze/prod2/
clean:
	rm -f $(PROGRAM).o 
	rm -f *~

Clean: clean
	rm -f $(PROGRAM).exe
	rm -f mc-tester.root
	rm -rf config.log config.status autom4te.cache
	rm -rf make.inc
##############################################################################
# Other dependencies:
##############################################################################
../../make.inc:
	@echo ""
	@echo "Please execute ./configure in main directory first!"
	@echo ""
	@false

make.inc:
	@echo ""
	@echo "Please execute ./configure first!"
	@echo ""
	@false

