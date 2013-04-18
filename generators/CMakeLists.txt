#todo for all: install README, lcg_configure

#todo: insufficient output from the build step. set(CMAKE_VERBOSE_MAKEFILE ON) helps only partly

#todo: put log file under the platform directory, no platform name is needed in the log file names
#todo: do not split err/out

#todo: tarballs

# cook Boost include subpath string (used by several packages)
string(REPLACE "." "_" Boost_underscore_twodigit ${Boost_config_version_twodigit})
set(Boost_home_include ${Boost_home}/include/boost-${Boost_underscore_twodigit})


set(CMAKE_VERBOSE_MAKEFILE ON)

#---lhapdf------------------------------------------------------------------------------------------
#todo: install ALL precompiled examples and paths.sh
#todo: making tarballs is specific for lhapdf

#if(EXISTS /afs/cern.ch)
# set(lhapdf_sets /afs/cern.ch/sw/lcg/external/MCGenerators/lhapdf/${lhapdf_native_version}/share/PDFsets)
#else()
# set(lhapdf_sets /Users/mato/Development/externals/PDFsets)   # For testing purposes
#endif()

LCGPackage_Add(
  lhapdf
  URL http://www.hepforge.org/archive/lhapdf/lhapdf-${lhapdf_native_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/files  <SOURCE_DIR>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/../share --enable-low-memory  --disable-pyext --disable-doxygen --disable-octave
  INSTALL_COMMAND make install
#          this below is for some tests
#          COMMAND ${CMAKE_COMMAND} -E create_symlink ${lhapdf_sets} <INSTALL_DIR>/../share/lhapdf/PDFsets
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share/lhapdf ${CMAKE_COMMAND} -E make_directory PDFsets
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets PDFsets
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets.index PDFsets.index
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib ${CMAKE_COMMAND} -E make_directory archive
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib/archive ${CMAKE_COMMAND} -E create_symlink ../libLHAPDF.a libLHAPDF.a
#          this below does not work: file is not yet there
#          COMMAND ${CMAKE_COMMAND} -E copy <INSTALL_DIR>/../logs/lhapdf-${LCG_platform}-build-out.log <INSTALL_DIR> 
          COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/examples  <INSTALL_DIR>/../share/examples
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/examples/lhapdf-cctest1 <INSTALL_DIR>/bin
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/examples/lhapdf-example1 <INSTALL_DIR>/bin
#          real PDF sets getting and installation, takes a long time: 
#          COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/scripts/instlpdfsets <INSTALL_DIR>/bin <INSTALL_DIR>/../share/lhapdf/PDFsets 
#          test PDF sets getting and installation:
#          COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/scripts/instlpdfsets_test <INSTALL_DIR>/bin <INSTALL_DIR>/../share/lhapdf/PDFsets
  BUILD_IN_SOURCE 1
)

#---pythia8------------------------------------------------------------------------------------------
#todo: add more precompiled examples, config, tests
set(HOMEPAGE http://home.thep.lu.se/~torbjorn/Pythia.html)
LCGPackage_Add(
  pythia8
  URL http://home.thep.lu.se/~torbjorn/pythia8/pythia8<NATIVE_VERSION>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia8/examples  <SOURCE_DIR>/examples
         COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia8/files  <SOURCE_DIR>
         COMMAND REALHEPMCVERSION=${HepMC_native_version} REALGENVERSION=<NATIVE_VERSION> ./usesed
         COMMAND ${CMAKE_COMMAND} -E remove <SOURCE_DIR>/usesed
         COMMAND ${CMAKE_COMMAND} -E remove <INSTALL_DIR>/../share/sources/usesed
         COMMAND ${CMAKE_COMMAND} -E make_directory <SOURCE_DIR>/doc
         COMMAND ${CMAKE_COMMAND} -E echo ${HOMEPAGE} > <SOURCE_DIR>/doc/URL
  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/pythia8/scripts/run_lcg_configure <INSTALL_DIR> <INSTALL_DIR>/../share ${HepMC_native_version} ${LCG_platform}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> make install
          COMMAND ${CMAKE_COMMAND} -E remove <INSTALL_DIR>/xmldoc
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR> ${CMAKE_COMMAND} -E create_symlink ../share/xmldoc xmldoc
  CONFIGURE_EXAMPLES_COMMAND <SOURCE_DIR>/examples/configure
                             --with-pythia8=<INSTALL_DIR>
                             --with-lhapdf=${lhapdf_home}/lib
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
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-LHAPDF=${lhapdf_home}/lib --with-gsl=${GSL_home} --without-javagui
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
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home} --with-thepeg=${thepeg_home} 
                      --with-boost=${Boost_home}
    BUILD_IN_SOURCE 1
    DEPENDS GSL Boost thepeg
  )
endif()

#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL http://annapurna.ifj.edu.pl/~tprzedzinski/resources/TAUOLA.${tauola++_native_version}/TAUOLA.${tauola++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-lhapdf=${lhapdf_home}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf
)

#---pythia6-------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia6
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://www.hepforge.org/archive/pythia6/pythia-<pythia6_<NATIVE_VERSION>_author>.f.gz
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia6/files  <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_COMMAND} -DHEPEVT_SIZE=<pythia6_<NATIVE_VERSION>_hepevt> -P preparePythia6.cmake
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

#---agile------------------------------------------------------------------------------------------  
LCGPackage_Add(
  agile
  URL http://www.hepforge.org/archive/agile/AGILe-${agile_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
     --with-hepmc=${HepMC_home} 
     --with-boost-incpath=${Boost_home_include}
     --with-lcgtag=${LCG_platform}
     PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
     SWIG=${swig_home}/bin/swig
  BUILD_COMMAND make all LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost Python swig
)

#---photos++------------------------------------------------------------------------------------------
LCGPackage_Add(
  photos++
  URL http://annapurna.ifj.edu.pl/~tprzedzinski/resources/PHOTOS.${photos++_native_version}/PHOTOS.${photos++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC
)

#---evtgen------------------------------------------------------------------------------------------
if(NOT APPLE)    #  (build fails on Mac " unknown option: -soname")
LCGPackage_Add(
  evtgen
  SVN_REPOSITORY http://svnweb.cern.ch/guest/evtgen/tags/<evtgen_<NATIVE_VERSION>_tag>
  UPDATE_COMMAND <VOID>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --hepmcdir=${HepMC_home} --pythiadir=${pythia8_home} --photosdir=${photos++_home} --tauoladir=${tauola++_home}
  BUILD_IN_SOURCE 1   
  DEPENDS HepMC pythia8 photos++ tauola++
)
endif()

#---Rivet------------------------------------------------------------------------------------------
LCGPackage_Add(
  rivet
  URL http://www.hepforge.org/archive/rivet/Rivet-${rivet_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --with-hepmc=${HepMC_home} 
     --with-boost-incpath=${Boost_home_include}
     --with-fastjet=${fastjet_home}
     --with-gsl=${GSL_home}
     --with-lcgtag=${LCG_platform}
     --disable-pdfmanual
     --enable-unvalidated
     PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
     SWIG=${swig_home}/bin/swig
     CC=${CMAKE_C_COMPILER}
     CXX=${CMAKE_CXX_COMPILER}
  BUILD_COMMAND make all V=1 LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig
)

#---Sherpa------------------------------------------------------------------------------------------
LCGPackage_Add(
  sherpa
  URL http://www.hepforge.org/archive/sherpa/SHERPA-MC-<sherpa_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=${lhapdf_home}
     --enable-hepmc2=${HepMC_home}
     --enable-rivet=${rivet_home}
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf HepMC rivet
)

#---HepMCAnalysis------------------------------------------------------------------------------------
LCGPackage_Add(
  hepmcanalysis
  URL http://hepmcanalysistool.desy.de/releases/HepMCAnalysis-<hepmcanalysis_<NATIVE_VERSION>_author>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/hepmcanalysis/files <SOURCE_DIR>
  CONFIGURE_COMMAND echo "No configure step"
  BUILD_COMMAND ./build.sh --sysname=${LCG_platform} --hepmc-version=${HepMC_native_version} --fastjet-version=${fastjet_native_version} --clhep-version=${CLHEP_native_version} --root-version=${ROOT_native_version}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
  BUILD_IN_SOURCE 1
  DEPENDS HepMC fastjet CLHEP ROOT
)

#---MC-TESTER----------------------------------------------------------------------------------------
LCGPackage_Add(
  mctester
  URL http://cern.ch/MC-TESTER/MC-TESTER-${mctester_native_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E touch make.inc
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-HepMC=${HepMC_home} --with-root=${ROOT_home}/bin
  BUILD_COMMAND make LD_LIBRARY_PATH=${ROOT_home}/lib:$ENV{LD_LIBRARY_PATH}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC ROOT
)

#---HIJING----------------------------------------------------------------------------------------
LCGPackage_Add(
  hijing
  URL http://cern.ch/service-spi/external/MCGenerators/distribution/hijing/hijing-${hijing_native_version}-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/${hijing_native_version} <SOURCE_DIR>   
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/${hijing_native_version}
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND make FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
  BUILD_IN_SOURCE 1
)

#---Starlight---------------------------------------------------------------------------------------
string(SUBSTRING ${starlight_native_version} 1 -1 STARLIGHT_REV)
LCGPackage_Add(
  starlight
  SVN_REPOSITORY http://starlight.hepforge.org/svn/trunk
  SVN_REVISION -r ${STARLIGHT_REV}
  UPDATE_COMMAND <VOID>
  PATCH_COMMAND patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/starlight/patches/patch-${starlight_native_version}
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

#---HERWIG----------------------------------------------------------------------------------------
LCGPackage_Add(
  herwig
  URL http://cern.ch/service-spi/external/MCGenerators/distribution/herwig/herwig-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)

#---CRMC (FORMER EPOS)-----------------------------------------------------------------------------
LCGPackage_Add(
  crmc
  SVN_REPOSITORY https://devel-ik.fzk.de/svn/mc/crmc/tags/${crmc_native_version}
  CONFIGURE_COMMAND echo "No configure step"
  BUILD_COMMAND make -f Makefile CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
  INSTALL_COMMAND make -f Makefile install CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC
)
