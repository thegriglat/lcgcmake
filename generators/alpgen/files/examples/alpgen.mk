-include config.mk
#
ifeq (x$(ALPGENINSTALLED),x)
  ALPGENINSTALLED=..
endif
ifeq (x$(ALPGENLIBS),x)
  ALPGENLIBS=../lib/archive
endif
#
# DEFINE DIRECTORY AND FILE ALIASES
alp= ${ALPGENINSTALLED}/alplib
prclib= ${ALPGENINSTALLED}/$(prc)lib
prcusr= ${ALPGENINSTALLED}/$(prc)work
prcfile=$(prclib)/$(prc)
ifeq ($(strip $(usrfile)),)
  execfile=$(prc)gen.exe
  usrfile=$(prcusr)/$(prc)usr
else
  execfile=$(usrfile).exe
endif

ifneq ($(prc),hjet)

  PARTON= $(prcfile).f $(usrfile).f

  INC=  $(prclib)/$(prc).inc $(alp)/alpgen.inc

  gen: $(PARTON) $(INC)
	mkdir -p ../bin
	$(FC) $(FFLAGS) -o ../bin/$(execfile) $(PARTON) \
	-L${ALPGENLIBS} -lalpgen -I$(prclib) -I$(alp)
	ln -fs ../bin/$(execfile) $(execfile)

else

  PARTON= $(prcfile).f $(usrfile).f $(prclib)/77/VX77.f

  INC=  $(prclib)/$(prc).inc $(alp)/alpgen.inc $(wildcard $(prclib)/77/*.inc)

  gen: $(PARTON) $(INC)
	mkdir -p ../bin
#   check the list of files with the author's hjetwork/Makefile
	$(FC) $(FFLAGS) -o ../bin/$(execfile) $(PARTON) \
	$(alp)/alpgen.f $(alp)/alputi.f $(alp)/alppdf.f $(alp)/Aint90.f
	ln -fs ../bin/$(execfile) $(execfile)

endif
