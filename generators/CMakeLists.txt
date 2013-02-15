#todo for all: install README, lcg_configure, doc/URL
#
#---lhapdf------------------------------------------------------------------------------------------
#todo: add installation of PDF sets
#todo: add installation of examples
set(HOMEPAGE_lhapdf http://projects.hepforge.org/lhapdf/)
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
  DEPENDS HepMC
)

#---ThePEG------------------------------------------------------------------------------------------
LCGPackage_Add(
  thepeg
  URL http://www.hepforge.org/archive/thepeg/ThePEG-${thepeg_native_version}.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-LHAPDF=${lhapdf_home}/lib --with-gsl=${GSL_home} --without-javagui
  BUILD_IN_SOURCE 1
  DEPENDS HepMC GSL lhapdf
)

#---Herwig++------------------------------------------------------------------------------------------
#todo: every version of herwig++ depends on the corresponding PARTICULAR VERSION of ThePEG
#Version 2.6.2 compiles on Mac, however the installation does not run :-(
if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    herwig++
    URL http://www.hepforge.org/archive/herwig/Herwig++-${herwig++_native_version}.tar.bz2
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home} --with-thepeg=${thepeg_home} --with-boost=${Boost_home}
    BUILD_IN_SOURCE 1
    DEPENDS GSL Boost thepeg
  )
endif()

#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL http://annapurna.ifj.edu.pl/~tprzedzinski/resources/TAUOLA.${tauola++_native_version}/TAUOLA.${tauola++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND echo "Configuring tauola++"
            COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-lhapdf=${lhapdf_home}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf
)

#---pythia6-------------------------------------------------------------------------------------------
math(EXPR major "${pythia6_native_version} / 100")
math(EXPR minor "${pythia6_native_version} % 100")
LCGPackage_Add(
   pythia6
   DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://www.hepforge.org/archive/pythia6/pythia-6.${major}.${minor}.f.gz
                                     -Dsource_dir=<SOURCE_DIR>
                                     -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
   UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia6/files  <SOURCE_DIR>
#   configure_file(${SOURCE_DIR}/fhhiggscorr.f ${SOURCE_DIR}dummy/ COPYONLY)
#   UPDATE_COMMAND ../../../../../lcgcmake/generators/pythia6/prepare_pythia6 ${major}.${minor}
#   CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/../share
)

#---agile------------------------------------------------------------------------------------------
string(REPLACE "." "_" Boost_underscore_twodigit ${Boost_config_version_twodigit})
LCGPackage_Add(
  agile
  URL http://www.hepforge.org/archive/agile/AGILe-${agile_native_version}.tar.bz2
#  Comments about configuring:
#  1. boost configuring if taken from CERN AFS external is different
#  2. datadir was needed historically, now probably not
#  3. python dependency like this requires adding ${Python_home}/lib to LD_LIBRARY_PATH
#  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
#     --datadir=<INSTALL_DIR>/../share
#     --with-hepmc=${HepMC_home}
#     --with-boost-incpath=${Boost_home}/include/boost-1_48
#     PYTHON=${Python_home}/bin/python
#     SWIG=${swig_home}/bin/swig
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> 
     --with-hepmc=${HepMC_home} 
     --with-boost=${Boost_home}
     PYTHON=${Python_home}/bin/python 
     SWIG=${swig_home}/bin/swig
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost Python swig
)

#---photos++------------------------------------------------------------------------------------------
LCGPackage_Add(
  photos++
  URL http://annapurna.ifj.edu.pl/~tprzedzinski/resources/PHOTOS.${photos++_native_version}/PHOTOS.${photos++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC
)

#---evtgen------------------------------------------------------------------------------------------
set(EVTGEN_TAG R01-01-00)
if(NOT APPLE)    #  (build fails on Mac " unknown option: -soname")
LCGPackage_Add(
  evtgen
  SVN_REPOSITORY http://svnweb.cern.ch/guest/evtgen/tags/${EVTGEN_TAG}
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --hepmcdir=${HepMC_home} --pythiadir=${pythia8_home} --photosdir=${photos_home} --tauoladir=${tauola_home}
  BUILD_IN_SOURCE 1   
  DEPENDS HepMC pythia8 photos++ tauola++
)
endif()
