
#---pythia8------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia8
  URL http://home.thep.lu.se/~torbjorn/pythia8/pythia8<NATIVE_VERSION>.tgz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> --lcgplatform=${LCG_TARGET} --enable-shared --with-hepmc=${HepMC_home}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND cmake -E copy_directory <SOURCE_DIR>/include  <INSTALL_DIR>/include
          COMMAND cmake -E copy_directory <SOURCE_DIR>/lib  <INSTALL_DIR>/lib
          COMMAND cmake -E copy_directory <SOURCE_DIR>/xmldoc  <INSTALL_DIR>/xmldoc
  DEPENDS HepMC
)

#---ThePEG------------------------------------------------------------------------------------------
LCGPackage_Add(
  thepeg
  URL http://www.hepforge.org/archive/thepeg/ThePEG-${thepeg_native_version}.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home}
  BUILD_IN_SOURCE 1
  DEPENDS GSL
)

#---Herwig++------------------------------------------------------------------------------------------
if(NOT APPLE)
  LCGPackage_Add(
    herwig++
    URL http://www.hepforge.org/archive/herwig/Herwig++-${herwig++_native_version}.tar.bz2
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home} --with-thepeg=${thepeg_home} --with-boost=${Boost_home}
    BUILD_IN_SOURCE 1
    DEPENDS thepeg Boost
  )
endif()