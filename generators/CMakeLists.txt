#---lhapdf------------------------------------------------------------------------------------------
#todo: add installation of PDF sets
#todo: add installation of examples
LCGPackage_Add(  
  lhapdf
  URL http://www.hepforge.org/archive/lhapdf/lhapdf-${lhapdf_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/../share --enable-low-memory  --disable-pyext --disable-doxygen --disable-octave
  BUILD_IN_SOURCE 1
)

#---pythia8------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia8
  URL http://home.thep.lu.se/~torbjorn/pythia8/pythia8<NATIVE_VERSION>.tgz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> --lcgplatform=${LCG_TARGET}-opt --enable-shared --with-hepmc=${HepMC_home}
  BUILD_IN_SOURCE 1
#  DEPENDS HepMC
# for tests:
  DEPENDS
)

#---ThePEG------------------------------------------------------------------------------------------
#todo: add lhapdf dependency
LCGPackage_Add(
  thepeg
  URL http://www.hepforge.org/archive/thepeg/ThePEG-${thepeg_native_version}.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home}
  BUILD_IN_SOURCE 1
  DEPENDS GSL
)

#---Herwig++------------------------------------------------------------------------------------------
#Version 2.6.2 compiles on Mac:
#if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    herwig++
    URL http://www.hepforge.org/archive/herwig/Herwig++-${herwig++_native_version}.tar.bz2
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home} --with-thepeg=${thepeg_home} --with-boost=${Boost_home}
    BUILD_IN_SOURCE 1
    DEPENDS thepeg Boost
  )
#endif()

#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL http://annapurna.ifj.edu.pl/~tprzedzinski/resources/TAUOLA.${tauola++_native_version}/TAUOLA.${tauola++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND echo "Configuring tauola++"
            COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-lhapdf=${lhapdf_home}
  BUILD_IN_SOURCE 1
#  DEPENDS HepMC lhapdf
#for tests:
  DEPENDS lhapdf
)

#---pythia6-------------------------------------------------------------------------------------------
#todo: solve the problem that distfile is not a tar file
#LCGPackage_Add(
#  pythia6
#  URL http://www.hepforge.org/archive/pythia6/pythia-6.4.27.f.gz
#  UPDATE_COMMAND /afs/cern.ch/user/m/mkirsano/scratch0/GENSER/GENSER5/lcgcmake/generators/prepare_pythia6
#  CONFIGURE_COMMAND ./configure --prefix=${INSTALL_DIR} --datadir=${INSTALL_DIR}/../share
#  BUILD_IN_SOURCE 1
#  DEPENDS
#)

#---agile------------------------------------------------------------------------------------------
#todo: nonstandard include path for boost, needs BVM=echo ${BOOST_VERSION} | cut -d . -f 1-2 | tr . _
#todo: specify swig using a version variable
LCGPackage_Add(
  agile
  URL http://www.hepforge.org/archive/agile/AGILe-${agile_native_version}.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/../share --with-hepmc=${HepMC_home} --with-boost-incpath=${Boost_home}/include/boost-1_48 PYTHON=${Python_home}/bin/python SWIG=/afs/cern.ch/sw/lcg/external/swig/1.3.40/${LCG_TARGET}-opt/bin/swig
  BUILD_IN_SOURCE 1
#  DEPENDS HepMC Boost Python swig
#for tests:
  DEPENDS
)
