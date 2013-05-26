#todo for all: install README, lcg_configure

#todo: insufficient output from the build step. set(CMAKE_VERBOSE_MAKEFILE ON) helps only partly

#todo: put log file under the platform directory, no platform name is needed in the log file names
#todo: do not split err/out

#todo: tarballs

# cook Boost include subpath string (used by several packages)
string(REPLACE "." "_" Boost_underscore_twodigit ${Boost_config_version_twodigit})
set(Boost_home_include ${Boost_home}/include/boost-${Boost_underscore_twodigit})

if(APPLE)
  set(library_path DYLD_LIBRARY_PATH)
else()
  set(library_path LD_LIBRARY_PATH)
endif()
set(CMAKE_VERBOSE_MAKEFILE ON)


#---lhapdfsets--------------------------------------------------------------------------------------

LCGPackage_set_home(lhapdfsets)

if(NOT EXISTS ${lhapdfsets_home}/../share/PDFsets)
LCGPackage_Add(
  lhapdfsets
  URL http://www.hepforge.org/archive/lhapdf/lhapdf-${lhapdfsets_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID> 
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>
          COMMAND <SOURCE_DIR>/bin/lhapdf-getdata --force --dest=<INSTALL_DIR>/../share/PDFsets cteq6l
)
else()
  add_custom_target(lhapdfsets COMMENT "LHAPDF data sets already installed.")
endif()

#---lhapdf------------------------------------------------------------------------------------------
#todo: install ALL precompiled examples and paths.sh
#todo: making tarballs is specific for lhapdf

LCGPackage_Add(
  lhapdf
  URL http://www.hepforge.org/archive/lhapdf/lhapdf-${lhapdf_native_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/files  <SOURCE_DIR>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>  --enable-low-memory  --disable-pyext --disable-doxygen --disable-octave
  INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E create_symlink ${lhapdfsets_home}/../share/PDFsets <INSTALL_DIR>/share/lhapdf/PDFsets

#          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share/lhapdf ${CMAKE_COMMAND} -E make_directory PDFsets
#          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets PDFsets
#          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets.index PDFsets.index

          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib ${CMAKE_COMMAND} -E make_directory archive
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib/archive ${CMAKE_COMMAND} -E create_symlink ../libLHAPDF.a libLHAPDF.a

#          this below does not work: file is not yet there
#          COMMAND ${CMAKE_COMMAND} -E copy <INSTALL_DIR>/../logs/lhapdf-${LCG_platform}-build-out.log <INSTALL_DIR> 
          COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/examples  <INSTALL_DIR>/../share/examples
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/examples/lhapdf-cctest1 <INSTALL_DIR>/bin
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/examples/lhapdf-example1 <INSTALL_DIR>/bin

  BUILD_IN_SOURCE 1
  DEPENDS lhapdfsets
)
LCG_add_test(lhapdf_genser_test1 COMMAND lhapdf/tests/lhapdf_genser_test1
                          BINARY_DIR lhapdf/tests
                          SOURCE_DIR lhapdf/tests
                          BUILD lhapdf_genser_test1
                          BUILD_OPTIONS -DLHAPDF_ROOT_DIR=${lhapdf_home} -DLHAPDFSETS_ROOT_DIR=${lhapdfsets_home} -DLHAPATH=${lhapdfsets_home}/../share
                          ENVIRONMENT ${library_path}=${lhapdf_home}/lib:$ENV{${library_path}})


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
  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/pythia8/scripts/run_lcg_configure <INSTALL_DIR> <INSTALL_DIR>/../share ${HepMC_home} ${LCG_platform}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> make install
          COMMAND ${CMAKE_COMMAND} -E remove <INSTALL_DIR>/xmldoc
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR> ${CMAKE_COMMAND} -E create_symlink ../share/xmldoc xmldoc
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink sources/lcg_readme README
  CONFIGURE_EXAMPLES_COMMAND <SOURCE_DIR>/examples/configure
                             --with-pythia8=<INSTALL_DIR>
                             --with-lhapdf=${lhapdf_home}/lib
  BUILD_EXAMPLES_COMMAND $(MAKE) -C <SOURCE_DIR>/examples main01 main03
  INSTALL_EXAMPLES_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
                   COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/examples cp bin/main01.exe bin/main03.exe main03.cmnd test <INSTALL_DIR>/bin
#  TEST_COMMAND ${CMAKE_COMMAND} -E chdir  <INSTALL_DIR>/bin ./main01.exe
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir  <INSTALL_DIR>/bin ./test
  DEPENDS HepMC lhapdf
)

LCG_add_test(pythia8-build  BINARY_DIR pythia8/tests SOURCE_DIR pythia8/tests
                            BUILD all
                            BUILD_OPTIONS -DPYTHIA8_ROOT_DIR=${pythia8_home} -DHEPMC_ROOT_DIR=${HepMC_home})

foreach(t genser_test3 genser_test4 
orig_test1 
)
  LCG_add_test(pythia8-${t} COMMAND pythia8/tests/pythia8_${t}
                            ENVIRONMENT ${library_path}=${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
                                        PYTHIA8DATA=${pythia8_home}/xmldoc
                            DEPENDS pythia8-build)
endforeach()

#---ThePEG------------------------------------------------------------------------------------------
#todo: will autoreconf work if the patches are applied?
LCGPackage_Add(
  thepeg
  URL http://www.hepforge.org/archive/thepeg/ThePEG-${thepeg_native_version}.tar.bz2
#  UPDATE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> autoreconf --install --force
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-LHAPDF=${lhapdf_home}/lib --with-gsl=${GSL_home} --without-javagui
  BUILD_COMMAND make all V=1 
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
    PATCH_COMMAND patch -p0 -i ${CMAKE_CURRENT_SOURCE_DIR}/herwig++-${herwig++_native_version}.patch
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-gsl=${GSL_home} --with-thepeg=${thepeg_home} 
                      --with-boost=${Boost_home} LD_LIBRARY_PATH=${thepeg_home}/lib:${GSL_home}/lib:${Boost_home}/lib:$ENV{LD_LIBRARY_PATH}
    BUILD_COMMAND make all V=1 LD_LIBRARY_PATH=${thepeg_home}/lib:${GSL_home}/lib:${Boost_home}/lib:$ENV{LD_LIBRARY_PATH}
    INSTALL_COMMAND make install  LD_LIBRARY_PATH=${thepeg_home}/lib:${GSL_home}/lib:${Boost_home}/lib:${HepMC_home}/lib:$ENV{LD_LIBRARY_PATH}
    BUILD_IN_SOURCE 1
    DEPENDS GSL Boost thepeg
  )

LCG_add_test(herwigpp_orig_test1 COMMAND herwig++/tests/herwigpp_orig_test1
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          BUILD herwigpp_orig_test1
                          BUILD_OPTIONS -DHERWIGPP_ROOT_DIR=${herwig++_home} -DTHEPEG_ROOT_DIR=${thepeg_home} -DHEPMC_ROOT_DIR=${HepMC_home}
                          ENVIRONMENT ${library_path}=${herwig++_home}/lib:$ENV{${library_path}})
endif()



#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL http://annapurna.ifj.edu.pl/~tprzedzinski/resources/TAUOLA.${tauola++_native_version}/TAUOLA.${tauola++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-lhapdf=${lhapdf_home}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf
)

LCG_add_test(tauolapp-build  BINARY_DIR tauolapp/tests SOURCE_DIR tauolapp/tests
                            BUILD all
                            BUILD_OPTIONS -DTAUOLAPP_ROOT_DIR=${tauola++_home} -DPYTHIA8_ROOT_DIR=${pythia8_home} -DHEPMC_ROOT_DIR=${HepMC_home})

foreach(t 1 2 3)
  LCG_add_test(tauolapp_orig_test${t} COMMAND tauolapp/tests/tauolapp_orig_test${t}
                            ENVIRONMENT ${library_path}=${tauola++_home}/lib:$ENV{${library_path}}
                            DEPENDS pythia8-build)
endforeach()

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

#---photos------------------------------------------------------------------------------------------
LCGPackage_Add(
  photos
  URL http://sftweb.cern.ch/generators/files/generator/tarballs/photos-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --lcgplatform=${LCG_platform}  --userfflags=-fno-automatic --enable-shared
  BUILD_COMMAND make FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_Fortran_COMPILER}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib  <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include  <INSTALL_DIR>/include
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib ${CMAKE_COMMAND} -E create_symlink archive/libphotos.a libphotos.a
)

LCG_add_test(photos-test1 COMMAND photos/tests/photos_test1
                          BINARY_DIR photos/tests
                          SOURCE_DIR photos/tests
                          BUILD photos_test1
                          BUILD_OPTIONS -DPHOTOS_ROOT_DIR=${photos_home} -DPYTHIA6_ROOT_DIR=${pythia6_home}
                          FAILREGEX "Fatal error"
                          ENVIRONMENT ${library_path}=${photos_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})

#---pyquen--------------------------------------------------------------------------------------

string(REPLACE "." "_" pyquen_underscore_version ${pyquen_native_version})
LCGPackage_Add(
  pyquen
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://lokhtin.web.cern.ch/lokhtin/pyquen/pyquen${pyquen_underscore_version}.f
                                    -Dsource_dir=<SOURCE_DIR>/src
                                    -P  ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pyquen/files  <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_COMMAND} -P preparePyquen.cmake

  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)

LCG_add_test(pyquen-test1 COMMAND pyquen/tests/pyquen_test1
                          BINARY_DIR pyquen/tests
                          SOURCE_DIR pyquen/tests
                          BUILD pyquen_test1
                          BUILD_OPTIONS -DPYQUEN_ROOT_DIR=${pyquen_home} -DPYTHIA6_ROOT_DIR=${pythia6_home}
                          ENVIRONMENT ${library_path}=${pyquen_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})

#---hydjet--------------------------------------------------------------------------------------

string(REPLACE "." "_" hydjet_underscore_version ${hydjet_native_version})
LCGPackage_Add(
  hydjet
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://lokhtin.web.cern.ch/lokhtin/hydro/hydjet${hydjet_underscore_version}.f
                                    -Dsource_dir=<SOURCE_DIR>/src
                                    -P  ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://lokhtin.web.cern.ch/lokhtin/hydro/jetset_73.f
                                    -Dsource_dir=<SOURCE_DIR>/jetset
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/hydjet/files  <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_COMMAND} -P prepareHydjet.cmake
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)
LCG_add_test(hydjet-test COMMAND hydjet/tests/hydjet_test
                          BINARY_DIR hydjet/tests
                          SOURCE_DIR hydjet/tests
                          BUILD hydjet_test
                          BUILD_OPTIONS -DHYDJET_ROOT_DIR=${hydjet_home} -DPYTHIA6_ROOT_DIR=${pythia6_home} -DPYQUEN_ROOT_DIR=${pyquen_home}
                          ENVIRONMENT ${library_path}=${hydjet_home}/lib:${pyquen_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})


#---photos++------------------------------------------------------------------------------------------
LCGPackage_Add(
  photos++
  URL http://annapurna.ifj.edu.pl/~tprzedzinski/resources/PHOTOS.${photos++_native_version}/PHOTOS.${photos++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC
)
LCG_add_test(photospp_orig_test1 COMMAND photospp/tests/photospp_orig_test1
                          BINARY_DIR photospp/tests
                          SOURCE_DIR photospp/tests
                          BUILD photospp_orig_test1
                          BUILD_OPTIONS -DPHOTOSPP_ROOT_DIR=${photos++_home} -DPYTHIA8_ROOT_DIR=${pythia8_home} -DHEPMC_ROOT_DIR=${HepMC_home}
                          ENVIRONMENT ${library_path}=${photos++_home}/lib:$ENV{${library_path}})
LCG_add_test(photospp_orig_test2 COMMAND photospp/tests/photospp_orig_test2
                          BINARY_DIR photospp/tests
                          SOURCE_DIR photospp/tests
                          BUILD photospp_orig_test2
                          BUILD_OPTIONS -DPHOTOSPP_ROOT_DIR=${photos++_home} -DPYTHIA8_ROOT_DIR=${pythia8_home} -DHEPMC_ROOT_DIR=${HepMC_home} -DMCTESTER_ROOT_DIR=${mctester_home}
                          ENVIRONMENT ${library_path}=${photos++_home}/lib:$ENV{${library_path}})

#---evtgen------------------------------------------------------------------------------------------
if(NOT APPLE)    #  (build fails on Mac " unknown option: -soname")
LCGPackage_Add(
  evtgen
  SVN_REPOSITORY http://svnweb.cern.ch/guest/evtgen/tags/<evtgen_<NATIVE_VERSION>_tag>
  UPDATE_COMMAND <VOID>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --hepmcdir=${HepMC_home} --pythiadir=${pythia8_home} --photosdir=${photos++_home} --tauoladir=${tauola++_home} 
  BUILD_COMMAND make -j1
  INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink  sources/evt.pdl evt.pdl
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink  sources/DECAY_2010.DEC DECAY.DEC
  BUILD_IN_SOURCE 1  
  DEPENDS HepMC pythia8 photos++ tauola++
)

LCG_add_test(evtgen_orig_test1 COMMAND evtgen/tests/evtgen_orig_test1
                          BINARY_DIR evtgen/tests
                          SOURCE_DIR evtgen/tests
                          BUILD evtgen_orig_test1
                          BUILD_OPTIONS -DEVTGEN_ROOT_DIR=${evtgen_home} -DPYTHIA8_ROOT_DIR=${pythia8_home} -DPHOTOSPP_ROOT_DIR=${photos++_home} -DTAUOLAPP_ROOT_DIR=${tauola++_home} -DHEPMC_ROOT_DIR=${HepMC_home}
                          ENVIRONMENT ${library_path}=${evtgen_home}/lib:${photos++_home}/lib:${pythia8_home}/lib:${tauola++_home}/lib:$ENV{${library_path}})
endif()

#---Cython------------------------------------------------------------------------------------------
LCGPackage_Add(
  cython
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Cython-${cython_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_home}/bin/python setup.py build
  INSTALL_COMMAND ${Python_home}/bin/python setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python setuptools
)
set(cython_pythonpath ${cython_home}/lib/python${Python_config_version_twodigit}/site-packages)

#---yaml-cpp----------------------------------------------------------------------------------------
LCGPackage_Add(
  yaml_cpp
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/yaml-cpp-${yaml_cpp_native_version}.tar.gz
  CMAKE_ARGS -DBOOST_ROOT=${Boost_home} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DBUILD_SHARED_LIBS=ON
  BUILD_IN_SOURCE 1
)


#---Yoda-------------------------------------------------------------------------------------------
LCGPackage_Add(
  yoda
  URL http://www.hepforge.org/archive/yoda/YODA-${yoda_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
      --with-boost=${Boost_home}
      PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
      PYTHONPATH=${cython_home}/lib/python2.7/site-packages:$ENV{PYTHONPATH}
  BUILD_COMMAND make all V=1 LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH}
  BUILD_IN_SOURCE 1
  DEPENDS Python Boost cython
)

#---Rivet2-----------------------------------------------------------------------------------------
LCGPackage_Add(
  rivet2
  URL http://www.hepforge.org/archive/rivet/Rivet-${rivet2_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --with-hepmc=${HepMC_home} 
     --with-boost=${Boost_home_include}
     --with-fastjet=${fastjet_home}
     --with-yoda=${yoda_home}
     --with-yaml-cpp=${yaml_cpp_home}
     --with-gsl=${GSL_home}
     --with-lcgtag=${LCG_platform}
     --disable-pdfmanual
     --enable-unvalidated
     PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
     SWIG=${swig_home}/bin/swig
     CC=${CMAKE_C_COMPILER}
     CXX=${CMAKE_CXX_COMPILER}
  BUILD_COMMAND make all V=1 LD_LIBRARY_PATH=${Python_home}/lib:${yaml_cpp_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:${yaml_cpp_home}/lib:$ENV{LD_LIBRARY_PATH}
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig yoda yaml_cpp
)

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
  BUILD_COMMAND make HepMCdir=${HepMC_home} FastJetdir=${fastjet_home} ROOTSYS=${ROOT_home} CLHEPdir=${CLHEP_home}
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
LCG_add_test(hijing_orig_test1 COMMAND hijing/tests/hijing_orig_test1
                          BINARY_DIR hijing/tests
                          SOURCE_DIR hijing/tests
                          BUILD hijing_orig_test1
                          BUILD_OPTIONS -DHIJING_ROOT_DIR=${hijing_home}
                          ENVIRONMENT ${library_path}=${hijing_home}/lib:$ENV{${library_path}})

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
LCG_add_test(starlight_genser_test1 COMMAND starlight/tests/starlight_genser_test1
                          BINARY_DIR starlight/tests
                          SOURCE_DIR starlight/tests
                          BUILD starlight_genser_test1
                          BUILD_OPTIONS -DSTARLIGHT_ROOT_DIR=${starlight_home}
                          ENVIRONMENT ${library_path}=${starlight_home}/lib:$ENV{${library_path}})



#---HERWIG----------------------------------------------------------------------------------------
LCGPackage_Add(
  herwig
  URL http://cern.ch/service-spi/external/MCGenerators/distribution/herwig/herwig-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  INSTALL_COMMAND make install 
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/include ${CMAKE_COMMAND} -E create_symlink HERWIG65.INC herwig65.inc
  BUILD_IN_SOURCE 1
)

#---CRMC (FORMER EPOS)-----------------------------------------------------------------------------
LCGPackage_Add(
  crmc
  URL http://sftweb.cern.ch/generators/files/generator/tarballs/crmc-${crmc_native_version}.tar.gz
#  SVN_REPOSITORY https://devel-ik.fzk.de/svn/mc/crmc/tags/${crmc_native_version}
  CONFIGURE_COMMAND echo "No configure step"
  BUILD_COMMAND make -f Makefile CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
  INSTALL_COMMAND make -f Makefile install CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
	   COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/tabs  <INSTALL_DIR>/tabs
  BUILD_IN_SOURCE 1
  DEPENDS HepMC
)

#---tauola------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola
    URL http://sftweb.cern.ch/generators/files/generator/tarballs/tauola-${tauola_native_version}-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/data --with-pythia6=${pythia6_home} --with-photos=${photos_home} --with-hepevt=4000
  BUILD_COMMAND make FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_Fortran_COMPILER}
  BUILD_IN_SOURCE 1
  DEPENDS photos pythia6
)
LCG_add_test(tauola-test1 COMMAND tauola/tests/tauola_test1
                          BINARY_DIR tauola/tests
                          SOURCE_DIR tauola/tests
                          BUILD tauola_test1
                          BUILD_OPTIONS -DTAUOLA_ROOT_DIR=${tauola_home} -DPHOTOS_ROOT_DIR=${photos_home} -DPYTHIA6_ROOT_DIR=${pythia6_home}
                          ENVIRONMENT ${library_path}=${tauola_home}/lib:${photos_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})

#---jimmy------------------------------------------------------------------------------------------
LCGPackage_Add(
  jimmy
    URL http://sftweb.cern.ch/generators/files/generator/tarballs/jimmy-${jimmy_native_version}-src.tgz
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
           COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-herwig=${herwig_home}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
	    COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib ${CMAKE_COMMAND} -E create_symlink archive/libjimmy.a libjimmy.a
    BUILD_IN_SOURCE 1
  DEPENDS herwig
)

#---hydjet++---------------------------------------------------------------------------------------
LCGPackage_Add(
  hydjet++
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://lokhtin.web.cern.ch/lokhtin/hydjet++/HYDJET++${hydjet++_native_version}.ZIP
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  COMMAND unzip <SOURCE_DIR>/HYDJET++${hydjet++_native_version}.ZIP -d <SOURCE_DIR>
  COMMAND cp <SOURCE_DIR>/Makefile <SOURCE_DIR>/Makefile.orig
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/hydjet++/files  <SOURCE_DIR>
  CONFIGURE_COMMAND <SOURCE_DIR>/configure
  BUILD_COMMAND make
#  BUILD_COMMAND make  CXX=${CMAKE_CXX_COMPILER}
#                      PRIMARYF77=${CMAKE_Fortran_COMPILER}
#                     PATH=$ENV{PATH}:/afs/cern.ch/sw/lcg/app/releases/ROOT/5.34.00/x86_64-slc5-gcc43-opt/root/bin
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
  BUILD_IN_SOURCE 1
)

#---alpgen-----------------------------------------------------------------------------
LCGPackage_Add(
  alpgen
  URL http://mlm.web.cern.ch/mlm/alpgen/V2.1/v<alpgen_<NATIVE_VERSION>_author>.tgz 
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/alpgen/files  <SOURCE_DIR>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)



