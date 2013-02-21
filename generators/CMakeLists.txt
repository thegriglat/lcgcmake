#todo for all: install README, lcg_configure, doc/URL
#
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
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home} --with-thepeg=${thepeg_home} 
                      --with-boost-incpath=${Boost_home}/include/boost-${Boost_underscore_twodigit}
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
#  Note: The definition of these variables can be programmed
set(pythia6_url_426    http://www.hepforge.org/archive/pythia6/pythia-6.4.26.f.gz)
set(pythia6_url_426.2  http://www.hepforge.org/archive/pythia6/pythia-6.4.26.f.gz)
set(pythia6_url_427    http://www.hepforge.org/archive/pythia6/pythia-6.4.27.f.gz)
set(pythia6_url_427.2  http://www.hepforge.org/archive/pythia6/pythia-6.4.27.f.gz)
set(pythia6_size_426   4000)  
set(pythia6_size_426.2 10000)  
set(pythia6_size_427   4000)  
set(pythia6_size_427.2 10000)  

LCGPackage_Add(
  pythia6
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=<pythia6_url_<NATIVE_VERSION>>
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia6/files  <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_COMMAND} -P preparePythia6.cmake
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DHEPEVT_SIZE=<pythia6_size_<NATIVE_VERSION>>
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
     --with-boost-incpath=${Boost_home}/include/boost-${Boost_underscore_twodigit}
     PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib
     SWIG=${swig_home}/bin/swig
  BUILD_COMMAND make all  LD_LIBRARY_PATH=${Python_home}/lib
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib
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
  UPDATE_COMMAND echo update not needed
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --hepmcdir=${HepMC_home} --pythiadir=${pythia8_home} --photosdir=${photos_home} --tauoladir=${tauola_home}
  BUILD_IN_SOURCE 1   
  DEPENDS HepMC pythia8 photos++ tauola++
)
endif()
