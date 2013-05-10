#
# Libraries Makefile.
#
#                  M. Kirsanov 18.12.2009

SHELL = /bin/sh

include config.mk

# flags:
#
FFLAGSSHARED = -fPIC
CFLAGSSHARED = -fPIC
CXXFLAGSSHARED = -fPIC
#
LDFLAGSSHARED = $(CXXFLAGS) -pthread -fPIC


# Location of directories.
TOPDIR=$(shell \pwd)
TMPD=tmp
INCDIR=include
SRCDIR=src
LIBDIR=lib
LIBDIRARCH=lib/archive
BINDIR=bin


export ARCH
export FC
export CC
export FFLAGS
export CFLAGS
export CXXFLAGS
export FFLAGSSHARED
export CFLAGSSHARED
export CXXFLAGSSHARED
export LDFLAGSSHARED
#
export TOPDIR
export TMPD
export INCDIR
export SRCDIR
export LIBDIR
export LIBDIRARCH
export BINDIR


all: libs


libs:
	@LIBNAME=$(LIBDIR)/archive/libhydjet++.a ; DIRNAME=src ; \
	export LIBNAME ; export DIRNAME ; \
	$(MAKE) -f Makearchive.subdir

	@LIBNAME=$(LIBDIR)/libhydjet++.so ; DIRNAME=src ; \
	export LIBNAME ; export DIRNAME ; \
	$(MAKE) -f Makeshared.subdir

clean:
	rm -f *~; rm -f \#*;
	rm -rf $(TMPD)
	rm -rf $(LIBDIR)
	rm -rf $(BINDIR)
	cd $(SRCDIR); rm -f *~; rm -f \#*; cd -
	cd $(INCDIR); rm -f *~; rm -f \#*; cd -
	cd doc; rm -f *~; rm -f \#*; cd -
	cd examples; rm -rf *.exe; rm -f *~; rm -f \#*; rm -f core*; cd -
