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
her=${ALPGENINSTALLED}/herlib
alp=${ALPGENINSTALLED}/alplib

# LINKING GENERIC EXECUTABLE FOR HERWIG EVENT-EVOLUTION
hwuser:
	mkdir -p ../bin
	$(FC) $(FFLAGS) -o ../bin/hwuser.exe $(her)/hwuser.f \
	$(her)/atoher.f -L${ALPGENLIBS} -L$(HERWIGLOCATION) \
	-lherwig -lalpsho -lherwig_dummy -lherwig_pdfdummy
	ln -fs ../bin/hwuser.exe hwuser.exe

hwuserex1:
	mkdir -p ../bin
	$(FC) $(FFLAGS) -o ../bin/hwuserex1.exe $(her)/hwuser.f \
	$(her)/atoher.f -L${ALPGENLIBS} -L$(HERWIGLOCATION) \
	-lherwig -lalpsho -lherwig_dummy -lherwig_pdfdummy 
	ln -fs ../bin/hwuserex1.exe hwuser.exe

# DIRECTORY CLEANUP UTILITIES:
#
# remove object files, etc
cleanall:
	-rm $(her)/fort.* $(her)/*.top $(her)/*.par \
	$(her)/*.wgt $(her)/*.unw $(her)/*.mon \
	$(her)/*.stat
