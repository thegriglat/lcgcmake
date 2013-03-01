#todo for all: install README, lcg_configure, doc/URL

#todo: share/sources in lcgcmake-build/LocalInstallArea is not deleted on make clean-package target

# cook Boost include subpath string (used by several packages)
string(REPLACE "." "_" Boost_underscore_twodigit ${Boost_config_version_twodigit})

#todo: the path
#  ${Boost_home}/include/boost-${Boost_underscore_twodigit}
# is non-standard and used by several generators,
# provide the path as predefined variable from steering machinery,
# for example ${Boost_home_include} ?

#---lhapdf------------------------------------------------------------------------------------------
#todo: add installation of examples

if(EXISTS /afs/cern.ch)
 set(lhapdf_sets /afs/cern.ch/sw/lcg/external/MCGenerators/lhapdf/${lhapdf_native_version}/share/PDFsets)
else()
 set(lhapdf_sets /Users/mato/Development/externals/PDFsets)   # For testing purposes
endif()

LCGPackage_Add(
  lhapdf
  URL http://www.hepforge.org/archive/lhapdf/lhapdf-${lhapdf_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/../share --enable-low-memory  --disable-pyext --disable-doxygen --disable-octave
  INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E create_symlink ${lhapdf_sets} <INSTALL_DIR>/../share/lhapdf/PDFsets
  BUILD_IN_SOURCE 1
)

#---pythia8------------------------------------------------------------------------------------------
#todo: add more precompiled examples, config, tests
set(HOMEPAGE http://home.thep.lu.se/~torbjorn/Pythia.html)
LCGPackage_Add(
  pythia8
  URL http://home.thep.lu.se/~torbjorn/pythia8/pythia8<NATIVE_VERSION>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia8  <SOURCE_DIR>/examples
         COMMAND ${CMAKE_COMMAND} -E make_directory <SOURCE_DIR>/doc
         COMMAND ${CMAKE_COMMAND} -E echo ${HOMEPAGE} > <SOURCE_DIR>/doc/URL
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/../share --with-hepmc=${HepMC_home} --enable-shared
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> make install
          COMMAND ${CMAKE_COMMAND} -E remove <INSTALL_DIR>/xmldoc
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR> create_symlink ../share/xmldoc xmldoc
  CONFIGURE_EXAMPLES_COMMAND <SOURCE_DIR>/examples/configure
                             --with-pythia8=<INSTALL_DIR>
                             --with-lhapdf=${lhapdf_home}
  BUILD_EXAMPLES_COMMAND  make -C <SOURCE_DIR>/examples main01 main03
  INSTALL_EXAMPLES_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
                   COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/examples cp bin/main01.exe bin/main03.exe main03.cmnd test <INSTALL_DIR>/bin
#  TEST_COMMAND ${CMAKE_COMMAND} -E chdir  <INSTALL_DIR>/bin ./main01.exe
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir  <INSTALL_DIR>/bin ./test
  DEPENDS HepMC lhapdf
)

#---ThePEG------------------------------------------------------------------------------------------
#todo: will autoreconf work if the patches are applied?
LCGPackage_Add(
  thepeg
  URL http://www.hepforge.org/archive/thepeg/ThePEG-${thepeg_native_version}.tar.bz2
#  UPDATE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> autoreconf --install --force
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

LCGPackage_Add(
  pythia6
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=<pythia6_url_<NATIVE_VERSION>>
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia6/files  <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_COMMAND} -DMYVERSION=<NATIVE_VERSION> -P preparePythia6.cmake
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

#---agile------------------------------------------------------------------------------------------  
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
     --with-lcgtag=${LCG_platform}
     PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
     SWIG=${swig_home}/bin/swig
  BUILD_COMMAND make all  LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
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

#---Rivet------------------------------------------------------------------------------------------
LCGPackage_Add(
  rivet
  URL http://www.hepforge.org/archive/rivet/Rivet-${rivet_native_version}.tar.bz2
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> 
     --with-hepmc=${HepMC_home} 
     --with-boost-incpath=${Boost_home}/include/boost-${Boost_underscore_twodigit}
     --with-fastjet=${fastjet_home}
     --with-gsl=${GSL_home}
     --with-lcgtag=${LCG_platform}
     --disable-pdfmanual
     --enable-unvalidated
     PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
     SWIG=${swig_home}/bin/swig
  BUILD_COMMAND make all  LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig
)

#---Sherpa------------------------------------------------------------------------------------------
#todo: HEPEVT size subversion 4000 / 10000
LCGPackage_Add(
  sherpa
  URL http://www.hepforge.org/archive/sherpa/SHERPA-MC-${sherpa_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=4000
     --enable-lhapdf=${lhapdf_home}
     --enable-hepmc2=${HepMC_home}
     --enable-rivet=${rivet_home}
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf HepMC rivet Boost GSL
)

#---HepMCAnalysis------------------------------------------------------------------------------------
#todo: add dependency on ROOT
if(${hepmcanalysis_native_version} MATCHES 3[.]4[.]13)
  set(hepmcanalysis_author_version 00-03-04-13)
endif()
if(${hepmcanalysis_native_version} MATCHES 3[.]4[.]14)
  set(hepmcanalysis_author_version 00-03-04-14)
endif()
LCGPackage_Add(
  hepmcanalysis
  URL http://hepmcanalysistool.desy.de/releases/HepMCAnalysis-${hepmcanalysis_author_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/hepmcanalysis/files  <SOURCE_DIR>
  CONFIGURE_COMMAND echo "no configure step"
  BUILD_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./confmake ${HepMC_native_version} ${fastjet_native_version} ${CLHEP_native_version}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
  DEPENDS HepMC fastjet CLHEP
)

#---MC-TESTER----------------------------------------------------------------------------------------
#todo: add dependency on ROOT
LCGPackage_Add(
  mctester
#  URL http://hibiscus.if.uj.edu.pl/~przedzinski/MC-TESTER.${mctester_native_version}.tar.gz
  URL http://mc-tester.web.cern.ch/MC-TESTER/MC-TESTER-${mctester_native_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E touch <SOURCE_DIR>/make.inc
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/../share --with-HepMC=${HepMC_home} --with-root=${ROOTSYS}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC
)

#---HIJING----------------------------------------------------------------------------------------
LCGPackage_Add(
  hijing
  URL http://service-spi.web.cern.ch/service-spi/external/MCGenerators/distribution/hijing/hijing-${hijing_native_version}-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/${hijing_native_version} <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/${hijing_native_version} <SOURCE_DIR>   
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/${hijing_native_version}
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
)

#---Starlight---------------------------------------------------------------------------------------
string(SUBSTRING ${starlight_native_version} 1 -1 STARLIGHT_REV)
LCGPackage_Add(
  starlight
  SVN_REPOSITORY http://starlight.hepforge.org/svn/trunk
  SVN_REVISION -r ${STARLIGHT_REV}
  PATCH_COMMAND patch < ${CMAKE_CURRENT_SOURCE_DIR}/starlight/patches/patch-${starlight_native_version}
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

#---HERWIG----------------------------------------------------------------------------------------
LCGPackage_Add(
  herwig
  URL http://service-spi.web.cern.ch/service-spi/external/MCGenerators/distribution/herwig/herwig-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)

#---CRMC (FORMER EPOS)-----------------------------------------------------------------------------
LCGPackage_Add(
  crmc
  SVN_REPOSITORY https://devel-ik.fzk.de/svn/mc/crmc/tags/${crmc_native_version}
  CONFIGURE_COMMAND echo no configure step
  BUILD_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> make -f Makefile CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> make -f Makefile install CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
  DEPENDS HepMC
)
