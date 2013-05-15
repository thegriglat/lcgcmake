SOEXT = .so

FC = gfortran
F77 = gfortran
FFLAGS = -O2 -fPIC -Wuninitialized
FCFLAGS = -O2 -fPIC -Wuninitialized
CFLAGS = -O2 -fPIC
CXXFLAGS = -O2 -fPIC -Wall

# flags:
FFLAGSSHARED = -fPIC
CFLAGSSHARED = -fPIC
CXXFLAGSSHARED = -fPIC
LDFLAGSSHARED =

FLIBS =   -L/afs/cern.ch/sw/lcg/contrib/gcc/4.6.2/x86_64-slc6-gcc46-opt/lib/gcc/x86_64-unknown-linux-gnu/4.6.2 -L/afs/cern.ch/sw/lcg/contrib/gcc/4.6.2/x86_64-slc6-gcc46-opt/lib/gcc/x86_64-unknown-linux-gnu/4.6.2/../../../../lib64 -L/lib/../lib64 -L/usr/lib/../lib64 -L/afs/cern.ch/sw/lcg/contrib/gcc/4.6.2/x86_64-slc6-gcc46-opt/lib/gcc/x86_64-unknown-linux-gnu/4.6.2/../../.. -lgfortran -lm -lquadmath

#Package-specific:>
TESTS_SHARED = 1
TESTS_ARCHIVE =

HEPMC_VERSION = 
HEPMC_PATH = /afs/cern.ch/sw/lcg/external/HepMC/2.06.05/x86_64-slc6-gcc46-opt
INCLUDE_HEPMC =   -I/afs/cern.ch/sw/lcg/external/HepMC/2.06.05/x86_64-slc6-gcc46-opt/include 
LIBS_HEPMC =   -L/afs/cern.ch/sw/lcg/external/HepMC/2.06.05/x86_64-slc6-gcc46-opt/lib -lHepMC -lHepMCfio 
LIBS_HEPMC_PATH = /afs/cern.ch/sw/lcg/external/HepMC/2.06.05/x86_64-slc6-gcc46-opt/lib

CLHEP_VERSION = 2.1.2.5
CLHEP_PATH = /afs/cern.ch/sw/lcg/external/clhep/2.1.2.5/x86_64-slc6-gcc46-opt
INCLUDE_CLHEP =   -I/afs/cern.ch/sw/lcg/external/clhep/2.1.2.5/x86_64-slc6-gcc46-opt/include 
LIBS_CLHEP_PATH = /afs/cern.ch/sw/lcg/external/clhep/2.1.2.5/x86_64-slc6-gcc46-opt/lib
LIBS_CLHEP =  -L/afs/cern.ch/sw/lcg/external/clhep/2.1.2.5/x86_64-slc6-gcc46-opt/lib -lCLHEP 

# from above:
export FC
export CXX
export FFLAGS
export CFLAGS
export CXXFLAGS
export FFLAGSSHARED
export CFLAGSSHARED
export CXXFLAGSSHARED
export LDFLAGSSHARED

export FLIBS

#Package-specific:>
export TESTS_SHARED
export TESTS_ARCHIVE

#---  Needed by libanalyserhepmc: ---
export HEPMC_PATH
export INCLUDE_HEPMC
export LIBS_HEPMC_PATH
export LIBS_HEPMC

export CLHEP_PATH
export INCLUDE_CLHEP
export LIBS_CLHEP_PATH
export LIBS_CLHEP
#-------------------------------------

#<
