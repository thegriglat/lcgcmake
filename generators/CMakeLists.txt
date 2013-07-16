#todo for all: install README, lcg_configure

#todo: insufficient output from the build step. set(CMAKE_VERBOSE_MAKEFILE ON) helps only partly

#todo: do not split err/out

# cook Boost include subpath string (used by several packages)
#---General parameters--------------------------------------------------------------------------------------------
set(Python_cmd ${Python_home}/bin/python)
set(Exec_cmd ${CMAKE_SOURCE_DIR}/cmake/scripts/exec-with-env)

string(REPLACE "." "_" Boost_underscore_twodigit ${Boost_config_version_twodigit})
set(Boost_home_include ${Boost_home}/include/boost-${Boost_underscore_twodigit})
if(APPLE)
  set(library_path DYLD_LIBRARY_PATH)
else()
  set(library_path LD_LIBRARY_PATH)
endif()
set(CMAKE_VERBOSE_MAKEFILE ON)
find_library(FORTRAN_LIBRARY NAMES gfortran
             HINTS /usr/local/gfortran/lib ENV LD_LIBRARY_PATH)


#---lhapdfsets--------------------------------------------------------------------------------------
LCGPackage_set_home(lhapdfsets)
get_filename_component(lhapdfsets_root ${lhapdfsets_home} PATH)
if(NOT EXISTS ${lhapdfsets_root}/share/lhapdf/PDFsets)
LCGPackage_Add(
  lhapdfsets
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/lhapdf-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID> 
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>
#          for tests:
#          COMMAND <SOURCE_DIR>/bin/lhapdf-getdata --force --dest=<INSTALL_DIR>/../share/lhapdf/PDFsets cteq6l
          COMMAND <SOURCE_DIR>/bin/lhapdf-getdata --force --dest=<INSTALL_DIR>/../share/lhapdf/PDFsets --all
          COMMAND ${CMAKE_COMMAND} -E copy <INSTALL_DIR>/../share/sources/PDFsets.index <INSTALL_DIR>/../share/lhapdf
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets.index <INSTALL_DIR>/../share/PDFsets.index
          COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/../share/sources
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../../.. ${CMAKE_TAR} czf distribution/lhapdfsets/lhapdfsets-<NATIVE_VERSION>-src.tgz lhapdfsets/<NATIVE_VERSION>/share
)
else()
  add_custom_target(lhapdfsets COMMENT "LHAPDF data sets already installed in ${lhapdfsets_root}/share/lhapdf/PDFsets")
endif()

#---lhapdf------------------------------------------------------------------------------------------
LCGPackage_Add(
  lhapdf
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/lhapdf-<NATIVE_VERSION>.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/files  <SOURCE_DIR>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=${lhapdfsets_home}/../share/lhapdf/PDFsets 
                                --enable-low-memory  --disable-pyext --disable-doxygen --disable-octave FCFLAGS=-g0 CFLAGS=-g0 CXXFLAGS=-g0
  INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/../share
          COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/../share/lhapdf
          COMMAND ${CMAKE_COMMAND} -E create_symlink ../../../../lhapdfsets/${lhapdfsets_native_version}/share/PDFsets <INSTALL_DIR>/../share/lhapdf/PDFsets
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E make_directory  <INSTALL_DIR>/lib/archive
          COMMAND ${CMAKE_COMMAND} -E create_symlink ../libLHAPDF.a <INSTALL_DIR>/lib/archive/libLHAPDF.a
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
                          BUILD_OPTIONS -DCMAKE_MODULE_PATH=${cmaketools_home}/modules 
                                        -DLHAPDF_ROOT_DIR=${lhapdf_home} -DLHAPDFSETS_ROOT_DIR=${lhapdfsets_home}
                          ENVIRONMENT ${library_path}=${lhapdf_home}/lib:$ENV{${library_path}} LHAPATH=${lhapdfsets_home}/../share/PDFsets)


#---pythia8------------------------------------------------------------------------------------------
#todo: add more precompiled examples, config, tests
set(HOMEPAGE http://home.thep.lu.se/~torbjorn/Pythia.html)
LCGPackage_Add(
  pythia8
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/pythia8<NATIVE_VERSION>.tgz
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
                            BUILD_OPTIONS -DCMAKE_MODULE_PATH=${cmaketools_home}/modules -DPYTHIA8_ROOT_DIR=${pythia8_home} -DHEPMC_ROOT_DIR=${HepMC_home})

foreach(t genser_test3 genser_test4 
orig_test1 
)
  LCG_add_test(pythia8-${t} COMMAND pythia8/tests/pythia8_${t}
                            ENVIRONMENT ${library_path}=${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
                                        PYTHIA8DATA=${pythia8_home}/xmldoc
                            DEPENDS pythia8-build)
endforeach()

#---ThePEG------------------------------------------------------------------------------------------
LCGPackage_Add(
  thepeg
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/ThePEG-<NATIVE_VERSION>.tar.bz2
# UPDATE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> autoreconf --install --force
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --with-LHAPDF=${lhapdf_home}/lib --with-gsl=${GSL_home} --without-javagui
  BUILD_COMMAND $(MAKE) all V=1 
  BUILD_IN_SOURCE 1
  DEPENDS HepMC GSL lhapdf
)

#---Herwig++------------------------------------------------------------------------------------------
#Version 2.6.2 compiles on Mac, however the installation does not run :-(
set(thepeg_v_home <thepeg-<herwig++_<NATIVE_VERSION>_thepeg>_home>)
if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    herwig++
    URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/Herwig++-<NATIVE_VERSION>.tar.bz2
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
		      --with-gsl=${GSL_home} --with-thepeg=${thepeg_v_home} --with-fastjet=${fastjet_home} 
                      --with-boost=${Boost_home} LD_LIBRARY_PATH=${thepeg_v_home}/lib:${GSL_home}/lib:${Boost_home}/lib:$ENV{LD_LIBRARY_PATH}
    BUILD_COMMAND $(MAKE) all V=1 LD_LIBRARY_PATH=${thepeg_v_home}/lib:${GSL_home}/lib:${Boost_home}/lib:$ENV{LD_LIBRARY_PATH}
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib make LD_LIBRARY_PATH=${thepeg_v_home}/lib:${GSL_home}/lib:${Boost_home}/lib:$ENV{LD_LIBRARY_PATH}   
	  COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib/AlpGen make BasicLesHouchesFileReader.so HERWIGINCLUDE=-I<SOURCE_DIR>/include 
			LD_LIBRARY_PATH=${thepeg_v_home}/lib:${GSL_home}/lib:${Boost_home}/lib:${herwig++_home}/lib:$ENV{LD_LIBRARY_PATH}
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib/AlpGen make AlpGenHandler.so HERWIGINCLUDE=-I<SOURCE_DIR>/include 
                        LD_LIBRARY_PATH=${thepeg_v_home}/lib:${GSL_home}/lib:${Boost_home}/lib:${herwig++_home}/lib:$ENV{LD_LIBRARY_PATH}
    INSTALL_COMMAND make install  LD_LIBRARY_PATH=${thepeg_v_home}/lib:${GSL_home}/lib:${Boost_home}/lib:${HepMC_home}/lib:$ENV{LD_LIBRARY_PATH}
            COMMAND  ${CMAKE_COMMAND} -E create_symlink herwig++ <INSTALL_DIR>/../../../herwigpp
            COMMAND  ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/Contrib/AlpGen/AlpGenHandler.so <INSTALL_DIR>/lib/Herwig++/	    
            COMMAND  ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/Contrib/AlpGen/BasicLesHouchesFileReader.so <INSTALL_DIR>/lib/Herwig++/ 
    BUILD_IN_SOURCE 1
    DEPENDS GSL Boost thepeg fastjet
  )

LCG_add_test(herwigpp_orig_test1 COMMAND herwig++/tests/herwigpp_orig_test1
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          BUILD herwigpp_orig_test1
                          BUILD_OPTIONS -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
                                        -DHERWIGPP_ROOT_DIR=${herwig++_home} -DTHEPEG_ROOT_DIR=${thepeg_home} 
                                        -DHEPMC_ROOT_DIR=${HepMC_home} -DGSL_ROOT_DIR=${GSL_home}
                          ENVIRONMENT ${library_path}=${herwig++_home}/lib:${GSL_home}/lib:$ENV{${library_path}})
endif()



#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/TAUOLA.<NATIVE_VERSION>-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-pic --with-hepmc=${HepMC_home} --with-lhapdf=${lhapdf_home}
  INSTALL_COMMAND  make install
          COMMAND  ${CMAKE_COMMAND} -E create_symlink tauola++ <INSTALL_DIR>/../../../tauolapp
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf
)

LCG_add_test(tauolapp-build BINARY_DIR tauolapp/tests SOURCE_DIR tauolapp/tests
                            BUILD all
                            BUILD_OPTIONS  -DCMAKE_MODULE_PATH=${cmaketools_home}/modules 
                                           -DTAUOLAPP_ROOT_DIR=${tauola++_home} 
                                           -DPYTHIA8_ROOT_DIR=${pythia8_home} -DHEPMC_ROOT_DIR=${HepMC_home})

foreach(t 1 2 3)
  LCG_add_test(tauolapp_orig_test${t} COMMAND tauolapp/tests/tauolapp_orig_test${t}
                            ENVIRONMENT ${library_path}=${tauola++_home}/lib:$ENV{${library_path}}
                            DEPENDS pythia8-build)
endforeach()

#---pythia6-------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia6
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/pythia-<pythia6_<NATIVE_VERSION>_author>.f.gz
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/pythia6/files  <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_COMMAND} -DHEPEVT_SIZE=<pythia6_<NATIVE_VERSION>_hepevt> -P preparePythia6.cmake
         COMMAND ${CMAKE_COMMAND} -E remove <SOURCE_DIR>/pythia-6.4.27.f
         COMMAND ${CMAKE_COMMAND} -E remove <SOURCE_DIR>/preparePythia6.cmake
         COMMAND ${CMAKE_COMMAND} -E remove <SOURCE_DIR>/splitter.pl
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)
LCG_add_test(pythia6-test1 COMMAND pythia6/tests/pythia6_test1
                           BINARY_DIR pythia6/tests
                           SOURCE_DIR pythia6/tests
                           BUILD pythia6_test1
                           BUILD_OPTIONS -DCMAKE_MODULE_PATH=${cmaketools_home}/modules 
                                         -DPYTHIA6_ROOT_DIR=${pythia6_home} -DHEPMC_ROOT_DIR=${HepMC_home}
                           ENVIRONMENT ${library_path}=${pythia6_home}/lib:${HepMC_home}/lib:$ENV{${library_path}})

#---agile------------------------------------------------------------------------------------------  
LCGPackage_Add(
  agile
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/AGILe-${agile_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
     --with-hepmc=${HepMC_home} 
     --with-boost-incpath=${Boost_home_include}
     --with-lcgtag=${LCG_platform}
     PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
     SWIG=${swig_home}/bin/swig
  BUILD_COMMAND $(MAKE) all LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost Python swig
)

#---photos------------------------------------------------------------------------------------------
LCGPackage_Add(
  photos
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/photos-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --lcgplatform=${LCG_platform}  --userfflags=-fno-automatic --enable-shared
  BUILD_COMMAND $(MAKE) FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
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

LCGPackage_Add(
  pyquen
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/pyquen<pyquen_<NATIVE_VERSION>_author>.f
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
LCGPackage_Add(
  hydjet
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/hydjet<hydjet_<NATIVE_VERSION>_author>.f
                                    -Dsource_dir=<SOURCE_DIR>/src
                                    -P  ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/jetset_73.f
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
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/PHOTOS.${photos++_native_version}-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND  make install
          COMMAND  ${CMAKE_COMMAND} -E create_symlink photos++ <INSTALL_DIR>/../../../photospp
  DEPENDS HepMC
)

LCG_add_test(photospp-build BINARY_DIR photospp/tests
                            SOURCE_DIR photospp/tests
                            BUILD all
                            BUILD_OPTIONS  -DCMAKE_MODULE_PATH=${cmaketools_home}/modules 
                                           -DPHOTOSPP_ROOT_DIR=${photos++_home} -DPYTHIA8_ROOT_DIR=${pythia8_home} 
                                           -DHEPMC_ROOT_DIR=${HepMC_home})
LCG_add_test(photospp_orig_test1 COMMAND photospp/tests/photospp_orig_test1
                          ENVIRONMENT ${library_path}=${photos++_home}/lib:$ENV{${library_path}}
                          DEPENDS photospp-build)
LCG_add_test(photospp_orig_test2 COMMAND photospp/tests/photospp_orig_test2
                          ENVIRONMENT ${library_path}=${photos++_home}/lib:$ENV{${library_path}}
                          DEPENDS photospp-build)

#---evtgen------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "mac")
  set(evtgen-build-options "FLIBS=-L/usr/local/gfortran/lib\ -lgfortran")
endif()
LCGPackage_Add(
  evtgen
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/evtgen-<NATIVE_VERSION>.tar.gz
  UPDATE_COMMAND <VOID>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
                                --hepmcdir=${HepMC_home}
                                --pythiadir=<pythia8-<evtgen_<NATIVE_VERSION>_pythia8>_home> 
                                --photosdir=${photos++_home} 
                                --tauoladir=<tauola++-<evtgen_<NATIVE_VERSION>_tauola++>_home>
  BUILD_COMMAND make -j1 "${evtgen-build-options}"
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
                          BUILD_OPTIONS -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
                                        -DROOTSYS=${ROOT_home}
                                        -DEVTGEN_ROOT_DIR=${evtgen_home} -DPYTHIA8_ROOT_DIR=${pythia8_home}
                                        -DPHOTOSPP_ROOT_DIR=${photos++_home} -DHEPMC_ROOT_DIR=${HepMC_home}
                          ENVIRONMENT ${library_path}=${evtgen_home}/lib:${photos++_home}/lib:${pythia8_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}})

#---cython------------------------------------------------------------------------------------------
LCGPackage_Add(
  cython
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/Cython-${cython_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_home}/bin/python setup.py build
  INSTALL_COMMAND ${Python_home}/bin/python setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python
)
set(cython_pythonpath ${cython_home}/lib/python${Python_config_version_twodigit}/site-packages)

#---yaml-cpp----------------------------------------------------------------------------------------
LCGPackage_Add(
  yaml_cpp
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/yaml-cpp-${yaml_cpp_native_version}.tar.gz
  CMAKE_ARGS -DBOOST_ROOT=${Boost_home} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DBUILD_SHARED_LIBS=ON
  BUILD_IN_SOURCE 1
)


#---Yoda-------------------------------------------------------------------------------------------
LCGPackage_Add(
  yoda
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/YODA-${yoda_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
      --with-boost=${Boost_home}
      PYTHON=${Python_home}/bin/python LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
      PYTHONPATH=${cython_home}/lib/python2.7/site-packages:$ENV{PYTHONPATH}
  BUILD_COMMAND $(MAKE) all V=1 LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH}
  BUILD_IN_SOURCE 1
  DEPENDS Python Boost cython
)

#---lhapdf6------------------------------------------------------------------------------------------
LCGPackage_Add(
  lhapdf6
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/LHAPDF-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
     --with-boost=${Boost_home}
     --with-yaml-cpp=${yaml_cpp_home}
     PYTHON=${Python_home}/bin/python
     CYTHON=${cython_home}/bin/cython
  BUILD_COMMAND $(MAKE) all V=1 LD_LIBRARY_PATH=${yaml_cpp_home}/lib:$ENV{LD_LIBRARY_PATH} PYTHONPATH=${cython_pythonpath}
  BUILD_IN_SOURCE 1
#  INSTALL_COMMAND make install PYTHONPATH=${cython_home}/lib/python2.7/site-packages
  INSTALL_COMMAND make install PYTHONPATH=${cython_pythonpath}
  DEPENDS Boost yaml_cpp Python cython
)

#---Rivet2-----------------------------------------------------------------------------------------
LCGPackage_Add(
  rivet2
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/Rivet-${rivet2_native_version}.tar.bz2
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
  BUILD_COMMAND $(MAKE) all V=1 LD_LIBRARY_PATH=${Python_home}/lib:${yaml_cpp_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:${yaml_cpp_home}/lib:$ENV{LD_LIBRARY_PATH}
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig yoda yaml_cpp
)

#---Rivet------------------------------------------------------------------------------------------
LCGPackage_Add(
  rivet
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/Rivet-<NATIVE_VERSION>.tar.bz2
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
  BUILD_COMMAND $(MAKE) all V=1 LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND make install LD_LIBRARY_PATH=${Python_home}/lib:$ENV{LD_LIBRARY_PATH}
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig
)

#---Sherpa------------------------------------------------------------------------------------------
LCGPackage_Add(
  sherpa
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/SHERPA-MC-<sherpa_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=${lhapdf_home}
     --enable-hepmc2=${HepMC_home}
     --enable-rivet=${rivet_home} CXXFLAGS=-g0
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf HepMC rivet
)

#---HepMCAnalysis------------------------------------------------------------------------------------
LCGPackage_Add(
  hepmcanalysis
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/HepMCAnalysis-<hepmcanalysis_<NATIVE_VERSION>_author>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/hepmcanalysis/files <SOURCE_DIR>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND $(MAKE) VERBOSE=1 HepMCdir=${HepMC_home} FastJetdir=${fastjet_home} ROOTSYS=${ROOT_home} CLHEPdir=${CLHEP_home}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
  BUILD_IN_SOURCE 1
  DEPENDS HepMC fastjet CLHEP ROOT

)

#---MC-TESTER----------------------------------------------------------------------------------------
LCGPackage_Add(
  mctester
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/MC-TESTER-${mctester_native_version}.tar.gz
  UPDATE_COMMAND $s{CMAKE_COMMAND} -E touch make.inc 
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-HepMC=${HepMC_home} --with-root=${ROOT_home}/bin
  BUILD_COMMAND $(MAKE) LD_LIBRARY_PATH=${ROOT_home}/lib:$ENV{LD_LIBRARY_PATH}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC ROOT
)

#---HIJING----------------------------------------------------------------------------------------
LCGPackage_Add(
  hijing
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/hijing-${hijing_native_version}-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/${hijing_native_version} <SOURCE_DIR>   
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/${hijing_native_version}
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND $(MAKE) FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy  <SOURCE_DIR>/tmp/hidata.o <INSTALL_DIR>/lib
       	  COMMAND ${CMAKE_COMMAND} -E copy  <SOURCE_DIR>/tmp/ludata.o <INSTALL_DIR>/lib
       	  COMMAND ${CMAKE_COMMAND} -E copy  <SOURCE_DIR>/tmp/pyhidata.o <INSTALL_DIR>/lib
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
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/herwig-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> "FFLAGS=-O2 -fPIC -Wuninitialized -fno-automatic"
#  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/herwig/scripts/run_lcg_configure <INSTALL_DIR>
  INSTALL_COMMAND make install 
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/include ${CMAKE_COMMAND} -E create_symlink HERWIG65.INC herwig65.inc
  BUILD_IN_SOURCE 1
)

#---tauola------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/tauola-${tauola_native_version}-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/data --with-pythia6=${pythia6_home} --with-photos=${photos_home} --with-hepevt=4000
  BUILD_COMMAND $(MAKE) FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
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
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/jimmy-${jimmy_native_version}-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
           COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --with-herwig=${herwig_home}
  BUILD_COMMAND $(MAKE) FC=${CMAKE_Fortran_COMPILER}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
	    COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib ${CMAKE_COMMAND} -E create_symlink archive/libjimmy.a libjimmy.a
    BUILD_IN_SOURCE 1
  DEPENDS herwig
)

#---hydjet++---------------------------------------------------------------------------------------
LCGPackage_Add(
  hydjet++
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/HYDJET++<hydjet++_<NATIVE_VERSION>_author>.ZIP
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  COMMAND unzip <SOURCE_DIR>/HYDJET++<hydjet++_<NATIVE_VERSION>_author>.ZIP -d <SOURCE_DIR>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PATH=${ROOT_home}/bin:$ENV{PATH} make -j2 F77LIBSO=${FORTRAN_LIBRARY}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E create_symlink hydjet++ <INSTALL_DIR>/../../../hydjetpp        
  BUILD_IN_SOURCE 1
  DEPENDS ROOT
)

#---alpgen-----------------------------------------------------------------------------
LCGPackage_Add(
  alpgen
  URL http://mlm.web.cern.ch/mlm/alpgen/V2.1/v<alpgen_<NATIVE_VERSION>_author>.tgz 
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/alpgen/files  <SOURCE_DIR>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  INSTALL_COMMAND make install
#          COMMAND ${CMAKE_COMMAND} -E create_symlink <INSTALL_DIR>/../share/sources <INSTALL_DIR>/../share/alpgen-author
	 COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink  sources alpgen-author
  BUILD_IN_SOURCE 1
)

#---CRMC (FORMER EPOS)-----------------------------------------------------------------------------

if ( ${crmc_native_version} MATCHES "^v")
LCGPackage_Add(
  crmc
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/crmc-${crmc_native_version}.tar.gz
  # SVN_REPOSITORY https://devel-ik.fzk.de/svn/mc/crmc/tags/${crmc_native_version}
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND $(MAKE) -f Makefile CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
  INSTALL_COMMAND make -f Makefile install CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/tabs  <INSTALL_DIR>/tabs
  BUILD_IN_SOURCE 1
  DEPENDS HepMC
)
else(${crmc_native_version} MATCHES "^v")
LCGPackage_Add(
  crmc
  URL http://sftweb.cern.ch/generators/files/generator/tarballs/crmc-${crmc_native_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DROOTSYS=${ROOT_home}
             -DHEPMC_PREFIX=${HepMC_home} -DBOOST_ROOT=${Boost_home}
             -DBOOST_INCLUDE_DIR=${Boost_home_include}
             #-DBoost_LIBRARYDIR=
  BUILD_IN_SOURCE 1
# INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib  <INSTALL_DIR>/lib
#         COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/bin  <INSTALL_DIR>/bin
#         COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/tabs <INSTALL_DIR>/../share/tabs
#         COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>  ${CMAKE_COMMAND} -E create_symlink  ../share/tabs tabs
  DEPENDS HepMC Boost ROOT
)
endif(${crmc_native_version} MATCHES "^v")
#---powhegbox---------------------------------------------------------------------------------------
LCGPackage_Add(
  powheg-box
  SVN_REPOSITORY --username anonymous --password anonymous --quiet svn://powhegbox.mib.infn.it/trunk/POWHEG-BOX 
  SVN_REVISION -r 2092
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/files <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/scripts/usesed
  CONFIGURE_COMMAND ./configure  
		--prefix=<INSTALL_DIR> 
		--datadir=<INSTALL_DIR>/../share
		--fastjet=${fastjet_home} 
		--lhapdf=${lhapdf_home}
  BUILD_COMMAND $(MAKE)
  BUILD_IN_SOURCE 1
  DEPENDS fastjet lhapdf
)
#---baurmc------------------------------------------------------------------------------------------
LCGPackage_Add(
  baurmc
  URL http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/baurmc-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --lcgplatform=${LCG_platform}  --userfflags=-fno-automatic --enable-shared
  BUILD_COMMAND $(MAKE) FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
  BUILD_IN_SOURCE 1
)





