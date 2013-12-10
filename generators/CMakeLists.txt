#---Options-----------------------------------------------------------------------------------------
set(PDFsets "--all" CACHE STRING "The PDFsets to be downloaded for the 'lhspdfsets' package (default --all)")

#---General parameters------------------------------------------------------------------------------
set (gen_url "http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles")

set(Python_cmd ${Python_home}/bin/python)
set(Exec_cmd ${CMAKE_SOURCE_DIR}/cmake/scripts/exec-with-env)

set (AIDA2ROOT "${CMAKE_SOURCE_DIR}/generators/reference/aida2root.py")
string(REPLACE "." "_" Boost_underscore_twodigit ${Boost_config_version_twodigit})
set(Boost_home_include ${Boost_home}/include/boost-${Boost_underscore_twodigit})
if(APPLE)
  set(library_path DYLD_LIBRARY_PATH)
else()
  set(library_path LD_LIBRARY_PATH)
endif()
string(REPLACE "opt" "dbg" LCG_platform_dbg ${LCG_platform})


#---lhapdfsets--------------------------------------------------------------------------------------
message(STATUS "PDFsets to download: ${PDFsets}")
LCGPackage_Add(
  lhapdfsets
  URL ${gen_url}/lhapdf-<NATIVE_VERSION>.tar.gz
  PATCH_COMMAND patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/patches/lhapdf-getdata.patch
  BINARY_PACKAGE 1
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>
          COMMAND ${CMAKE_COMMAND}
           -Ddistr=<SOURCE_DIR>
           -Drepo=http://www.hepforge.org/archive/lhapdf/pdfsets/<NATIVE_VERSION>
           -DPDFsets=${PDFsets}
           -Ddst_dir=<INSTALL_DIR>/../share/lhapdf
           -P ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/pdfsets.cmake
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/PDFsets.index
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets.index <INSTALL_DIR>/../share/PDFsets.index
          COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf/mktarball.sh <INSTALL_DIR> <NATIVE_VERSION>
	  COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/../../distribution/lhapdfsets 
          COMMAND ${CMAKE_COMMAND} -E create_symlink ../../../distribution/lhapdfsets/lhapdfsets-<NATIVE_VERSION>-src.tgz 
 				<INSTALL_DIR>/../../distribution/lhapdfsets/lhapdfsets-<NATIVE_VERSION>-src.tgz
)

#---lhapdf------------------------------------------------------------------------------------------
LCGPackage_Add(
  lhapdf
  URL ${gen_url}/lhapdf-<NATIVE_VERSION>.tar.gz
  PATCH_COMMAND patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/patches/lhapdf-getdata.patch
  CONFIGURE_COMMAND ./configure
    --prefix=<INSTALL_DIR>
    --datadir=<lhapdfsets-<NATIVE_VERSION>_home>/../share
    --enable-low-memory
    --disable-pyext
    --disable-doxygen
    --disable-octave
    FCFLAGS=-g0 CFLAGS=-g0 CXXFLAGS=-g0
  INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/lhapdf
          COMMAND ${CMAKE_COMMAND} -E create_symlink ../../../../lhapdfsets/<NATIVE_VERSION>/share/lhapdf <INSTALL_DIR>/../share/lhapdf
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/PDFsets.index
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets.index <INSTALL_DIR>/../share/PDFsets.index
  BUILD_IN_SOURCE 1
  DEPENDS lhapdfsets-<NATIVE_VERSION>
)

LCG_add_test(lhapdf_build
  BINARY_DIR lhapdf/tests
  SOURCE_DIR lhapdf/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules 
   -DLHAPDF_ROOT_DIR=${lhapdf_home}
)

foreach(i lhapdf_orig_testCC1 lhapdf_orig_testCC3 lhapdf_orig_testCC4)
  LCG_add_test(${i}
    TEST_COMMAND lhapdf/tests/${i}
    ENVIRONMENT
      ${library_path}=${lhapdf_home}/lib:$ENV{${library_path}}
      LHAPATH=${lhapdfsets_home}/../share/lhapdf/PDFsets
    DEPENDS lhapdf_build
  )
endforeach()

#---pythia8------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia8
  URL ${gen_url}/pythia8<pythia8_<NATIVE_VERSION>_author>.tgz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --enable-shared --lcgplatform=${LCG_platform}
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${MAKE} install
          COMMAND ${CMAKE_COMMAND} -E create_symlink sources/xmldoc <INSTALL_DIR>/../share/xmldoc
  BUILD_IN_SOURCE 1
  CONFIGURE_EXAMPLES_COMMAND <SOURCE_DIR>/examples/configure
                             --with-pythia8=<INSTALL_DIR>
                             --with-lhapdf=${lhapdf_home}/lib/archive
                             --with-fastjet=${fastjet_home}
  BUILD_EXAMPLES_COMMAND ${MAKE} -C <SOURCE_DIR>/examples main01 main03
  INSTALL_EXAMPLES_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
                   COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/examples cp bin/main01.exe bin/main03.exe main03.cmnd <INSTALL_DIR>/bin
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/bin ./main01.exe
  DEPENDS HepMC lhapdf fastjet
)

LCGPackage_set_home(rivet2)

LCG_add_test(pythia8-build
  BINARY_DIR pythia8/tests
  SOURCE_DIR pythia8/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
   -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
   -DPYTHIA8_ROOT_DIR=${pythia8_home} -DHEPMC_ROOT_DIR=${HepMC_home}
   -DFASTJET_ROOT_DIR=${fastjet_home}
)

LCG_add_test(pythia8_outhepmc
  TEST_COMMAND pythia8/tests/pythia8_outhepmc
  ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS pythia8-build
  LABELS PhysicsCheck
)

LCG_add_test(
  pythia8_riv2_test
  TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/riv2test.sh ${rivet2_home} hepmcoutzjets_pythia8.dat
  ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
                   ${library_path}=${Python_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
  DEPENDS pythia8_outhepmc
  LABELS PhysicsCheck
)

LCG_add_test(pythia8-genser_test1_nightly
  TEST_COMMAND pythia8/tests/pythia8_genser_test1
  ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS pythia8-build)

LCG_add_test(pythia8-orig_test1
  TEST_COMMAND pythia8/tests/pythia8_orig_test1
  ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS pythia8-build)

LCG_add_test(pythia8-genser_test1
  TEST_COMMAND pythia8/tests/pythia8_genser_test1
  POST_COMMAND ${CMAKE_COMMAND} -E copy testi_pythia8.dat test_pythia8.dat
  ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS pythia8-build
  LABELS PhysicsCheck
)

LCG_add_test(pythia8-genser_test2
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8_test2.cmnd .
  TEST_COMMAND pythia8/tests/pythia8_genser_test2
  POST_COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/mergetest
  ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS pythia8-build pythia8-genser_test1
  LABELS PhysicsCheck
)

LCG_add_test(pythia8-genser_test3
  TEST_COMMAND pythia8/tests/pythia8_genser_test3
  POST_COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/mergetest
  ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS pythia8-build pythia8-genser_test1
  LABELS PhysicsCheck
)

LCG_add_test(pythia8-genser_test4
  TEST_COMMAND pythia8/tests/pythia8_genser_test4
  POST_COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/mergetest
  ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS pythia8-build pythia8-genser_test1
  LABELS PhysicsCheck
)

LCG_add_test(pythia8-compare
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c .
  TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh pythia8 ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/reference.dat
  DEPENDS pythia8-genser_test2 pythia8-genser_test3 pythia8-genser_test4
  LABELS PhysicsCheck
)


#---ThePEG------------------------------------------------------------------------------------------

LCGPackage_Add(
  thepeg
  URL ${gen_url}/ThePEG-<NATIVE_VERSION>.tar.bz2
# UPDATE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> autoreconf --install --force
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
                                --with-hepmc=${HepMC_home}
                                IF <VERSION> VERSION_LESS 1.9.0 THEN
                                   --with-LHAPDF=${lhapdf_home}/lib
                                ELSE
                                   --with-lhapdf=${lhapdf_home}
                                ENDIF
                                --with-gsl=${GSL_home} --without-javagui CFLAGS=-O2 CXXFLAGS=-O2 FFLAGS=-O2
  BUILD_COMMAND ${MAKE} all ${library_path}=${lhapdf_home}:${lhapdf_home}/lib:$ENV{${library_path}}
  INSTALL_COMMAND make install-strip ${library_path}=${lhapdf_home}:${lhapdf_home}/lib:$ENV{${library_path}}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC GSL lhapdf
)

#---Herwig++------------------------------------------------------------------------------------------
#Version 2.6.2 compiles on Mac, however the installation does not run :-(
set(thepeg_v_home <thepeg-<herwig++_<NATIVE_VERSION>_thepeg>_home>)
  LCGPackage_Add(
    herwig++
    URL ${gen_url}/Herwig++-<NATIVE_VERSION>.tar.bz2
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
		                              --with-gsl=${GSL_home}
                                  --with-thepeg=${thepeg_v_home}
                                  --with-fastjet=${fastjet_home}
                                  --with-boost=${Boost_home}
                                  ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:$ENV{${library_path}}
    BUILD_COMMAND ${MAKE} all ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:$ENV{${library_path}}
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib make ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:$ENV{${library_path}}   
	        COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib/AlpGen 
                                   make BasicLesHouchesFileReader.so HERWIGINCLUDE=-I<SOURCE_DIR>/include 
                                                                     ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${herwig++_home}/lib/Herwig++:$ENV{${library_path}}
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib/AlpGen 
                                   make AlpGenHandler.so HERWIGINCLUDE=-I<SOURCE_DIR>/include
                                   ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${herwig++_home}/lib/Herwig++:$ENV{${library_path}}
    INSTALL_COMMAND make install  ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
            COMMAND  ${CMAKE_COMMAND} -E create_symlink herwig++ <INSTALL_DIR>/../../../herwigpp
            COMMAND  ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/Contrib/AlpGen/AlpGenHandler.so <INSTALL_DIR>/lib/Herwig++/	    
            COMMAND  ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/Contrib/AlpGen/BasicLesHouchesFileReader.so <INSTALL_DIR>/lib/Herwig++/ 
    BUILD_IN_SOURCE 1
    DEPENDS GSL Boost thepeg-<herwig++_<VERSION>_thepeg> fastjet
  )

LCG_add_test(herwigpp_orig_test1 
			  TEST_COMMAND ${herwig++_home}/bin/Herwig++ read ${herwig++_home}/../share/sources/src/LHC.in 
			       COMMAND ${herwig++_home}/bin/Herwig++ run -N100 LHC.run -d1 
                          POST_COMMAND cat LHC.out
			       COMMAND cat LHC.log	
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          ENVIRONMENT ${library_path}=${herwig++_home}/lib/Herwig++:${thepeg_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})

LCG_add_test(herwigpp_orig_test2 
			  TEST_COMMAND ${herwig++_home}/bin/Herwig++ read ${herwig++_home}/../share/sources/src/TVT.in 
                               COMMAND ${herwig++_home}/bin/Herwig++ run -N100 TVT.run -d1 
                          POST_COMMAND cat TVT.out
                               COMMAND cat TVT.log  
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          ENVIRONMENT ${library_path}=${herwig++_home}/lib/Herwig++:${thepeg_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})

LCG_add_test(herwigpp_thepeg_test
                          TEST_COMMAND ${herwig++_home}/bin/Herwig++ read ${CMAKE_SOURCE_DIR}/generators/herwig++/tests/LHC-diffractive.in --repo=${herwig++_home}/share/Herwig++/HerwigDefaults.rpo
                               COMMAND ${herwig++_home}/bin/Herwig++ run -N100 LHC-diffractive.run -d1
                          POST_COMMAND cat LHC-diffractive.out
                               COMMAND cat LHC-diffractive.log
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          ENVIRONMENT ${library_path}=${herwig++_home}/lib/Herwig++:${thepeg_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
                                      LHAPATH=${lhapdfsets_home}/../share/lhapdf/PDFsets
                          )



#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL ${gen_url}/TAUOLA.<NATIVE_VERSION>-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-pic --with-hepmc=${HepMC_home} --with-lhapdf=${lhapdf_home} CFLAGS=-O2 CXXFLAGS=-O2 FFLAGS=-O2  F77=${CMAKE_Fortran_COMPILER}    
  INSTALL_COMMAND  make install
          COMMAND  ${CMAKE_COMMAND} -E create_symlink tauola++ <INSTALL_DIR>/../../../tauolapp
#          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf
)

LCG_add_test(tauolapp-build
  BINARY_DIR tauolapp/tests
  SOURCE_DIR tauolapp/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
   -DTAUOLAPP_ROOT_DIR=${tauola++_home}
   -DPYTHIA8_ROOT_DIR=${pythia8_home}
   -DHEPMC_ROOT_DIR=${HepMC_home})

foreach(i tauolapp_test1 tauolapp_orig_test1 tauolapp_orig_test2 tauolapp_orig_test3)
  LCG_add_test(${i}
    TEST_COMMAND tauolapp/tests/${i}
    ENVIRONMENT PYTHIA8DATA=${pythia8_home}/xmldoc ${library_path}=${tauola++_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    DEPENDS tauolapp-build)
endforeach()

#---pythia6-------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia6
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=${gen_url}/pythia-<pythia6_<NATIVE_VERSION>_author>.f.gz
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
# copy.cmake is a custom command, it works better than copy_directory and excludes .svn
  UPDATE_COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/pythia6/files -DDST=<SOURCE_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${CMAKE_COMMAND} -DHEPEVT_SIZE=<pythia6_<NATIVE_VERSION>_hepevt> -P preparePythia6.cmake
         COMMAND ${CMAKE_COMMAND} -E remove <SOURCE_DIR>/pythia-<pythia6_<NATIVE_VERSION>_author>.f 
         COMMAND ${CMAKE_COMMAND} -E remove <SOURCE_DIR>/preparePythia6.cmake
         COMMAND ${CMAKE_COMMAND} -E remove <SOURCE_DIR>/splitter.pl
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

LCG_add_test(pythia6-build
  BINARY_DIR pythia6/tests
  SOURCE_DIR pythia6/tests
  BUILD all
  BUILD_OPTIONS -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
                -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
                -DPYTHIA6_ROOT_DIR=${pythia6_home} -DHEPMC_ROOT_DIR=${HepMC_home}
                -DFASTJET_ROOT_DIR=${fastjet_home}
  ENVIRONMENT ${library_path}=${pythia6_home}/lib:${HepMC_home}/lib:$ENV{${library_path}})

LCG_add_test(pythia6-orig_test1
  TEST_COMMAND pythia6/tests/pythia6_orig_test1
  ENVIRONMENT ${library_path}=${pythia6_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
  DEPENDS pythia6-build)

LCG_add_test(pythia6-genser_test1
  TEST_COMMAND pythia6/tests/pythia6_genser_test1
  POST_COMMAND ${CMAKE_COMMAND} -E copy testi_pythia6.dat test_pythia6.dat
  ENVIRONMENT ${library_path}=${pythia6_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
  DEPENDS pythia6-build
  LABELS PhysicsCheck)

LCG_add_test(pythia6-compare
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c .
  TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh pythia6 ${CMAKE_SOURCE_DIR}/generators/pythia6/tests/reference.dat
  DEPENDS pythia6-genser_test1
  LABELS PhysicsCheck
)


#---agile------------------------------------------------------------------------------------------  
LCGPackage_Add(
  agile
  URL ${gen_url}/AGILe-${agile_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
     --with-hepmc=${HepMC_home} 
     --with-boost-incpath=${Boost_home_include}
     --with-lcgtag=${LCG_platform}
     PYTHON=${Python_home}/bin/python ${library_path}=${Python_home}/lib:$ENV{${library_path}}
     SWIG=${swig_home}/bin/swig
     "CFLAGS=-g0 -O2" "CXXFLAGS=-g0 -O2" "FFLAGS=-g0 -O2"
  BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:$ENV{${library_path}}
  INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:$ENV{${library_path}}
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/agileenv.csh <INSTALL_DIR>/.
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/agileenv.sh <INSTALL_DIR>/.
          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost Python swig
)

LCG_add_test(agile_orig_test1 TEST_COMMAND ${agile_home}/bin/agile-runmc Pythia6:427 -o hepmcfile.dat
                              ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
                                          ${library_path}=${agile_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
                                          PYTHONPATH=${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
                                          AGILE_GEN_PATH=${agile_home}/../../..
                              )

#---photos------------------------------------------------------------------------------------------
if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    photos
    URL ${gen_url}/photos-<NATIVE_VERSION>-src.tgz
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
           COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
    CONFIGURE_COMMAND ./configure --lcgplatform=${LCG_platform}  --userfflags=-fno-automatic --enable-shared
    BUILD_COMMAND ${MAKE} FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib  <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include  <INSTALL_DIR>/include
            COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib ${CMAKE_COMMAND} -E create_symlink archive/libphotos.a libphotos.a
  )

LCG_add_test(photos-test1 TEST_COMMAND photos/tests/photos_test1
                          BINARY_DIR photos/tests
                          SOURCE_DIR photos/tests
                          BUILD photos_test1
                          BUILD_OPTIONS -DPHOTOS_ROOT_DIR=${photos_home} -DPYTHIA6_ROOT_DIR=${pythia6_home}
                          FAILREGEX "Fatal error"
                          ENVIRONMENT ${library_path}=${photos_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})

endif()

#---professor------------------------------------------------------------------------------------------

LCGPackage_Add(
  professor
  URL ${gen_url}/professor-<NATIVE_VERSION>.tar.bz2
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages 
		${Exec_cmd} ${library_path}=${ROOT_home}/lib:$ENV{${library_path}}
		${Python_cmd} setup.py build

  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages 
		${Exec_cmd} ${library_path}=${ROOT_home}/lib:$ENV{${library_path}}
                ${Python_cmd} setup.py install --prefix <INSTALL_DIR> 

  BUILD_IN_SOURCE 1
  DEPENDS Python matplotlib pyminuit scipy 
)

#---pyquen--------------------------------------------------------------------------------------
LCGPackage_Add(
  pyquen
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=${gen_url}/pyquen<pyquen_<NATIVE_VERSION>_author>.f
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/pyquen/files/CMakeLists.txt <SOURCE_DIR>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

LCG_add_test(pyquen_test1
  TEST_COMMAND pyquen/tests/pyquen_test1
  BINARY_DIR pyquen/tests
  SOURCE_DIR pyquen/tests
  BUILD pyquen_test1
  BUILD_OPTIONS
   -DPYQUEN_ROOT_DIR=${pyquen_home}
   -DPYTHIA6_ROOT_DIR=${pythia6_home}
  ENVIRONMENT ${library_path}=${pyquen_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})

#---hydjet--------------------------------------------------------------------------------------
LCGPackage_Add(
  hydjet
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=${gen_url}/hydjet<hydjet_<NATIVE_VERSION>_author>.f
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=${gen_url}/jetset_73.f
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/hydjet/files/CMakeLists.txt <SOURCE_DIR>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

LCG_add_test(hydjet_test1
  TEST_COMMAND hydjet/tests/hydjet_test1
  BINARY_DIR hydjet/tests
  SOURCE_DIR hydjet/tests
  BUILD all
  BUILD_OPTIONS
   -DHYDJET_ROOT_DIR=${hydjet_home}
   -DPYTHIA6_ROOT_DIR=${pythia6_home}
   -DPYQUEN_ROOT_DIR=${pyquen_home}
  ENVIRONMENT ${library_path}=${hydjet_home}/lib:${pyquen_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})

#---photos++------------------------------------------------------------------------------------------
LCGPackage_Add(
  photos++
  URL ${gen_url}/PHOTOS.<NATIVE_VERSION>-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} CFLAGS=-O2 CXXFLAGS=-O2 FFLAGS=-O2 F77=${CMAKE_Fortran_COMPILER} 
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND  make install
          COMMAND  ${CMAKE_COMMAND} -E create_symlink photos++ <INSTALL_DIR>/../../../photospp
#          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  DEPENDS HepMC
)

LCG_add_test(photospp-build
  BINARY_DIR photospp/tests
  SOURCE_DIR photospp/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
   -DPHOTOSPP_ROOT_DIR=${photos++_home}
   -DPYTHIA8_ROOT_DIR=${pythia8_home}
   -DHEPMC_ROOT_DIR=${HepMC_home})

  LCG_add_test(photospp_orig_test1
    PRE_COMMAND ${CMAKE_COMMAND} -E remove -f photos_standalone_example.dat
        COMMAND ${CMAKE_COMMAND} -E create_symlink ${photos++_home}/../share/sources/examples/photos_standalone_example.dat photos_standalone_example.dat
    TEST_COMMAND photospp/tests/photospp_orig_test1
    ENVIRONMENT ${library_path}=${photos++_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    DEPENDS photospp-build)

foreach(i photospp_orig_test2 photospp_test1 photospp_test2)
  LCG_add_test(${i}
    TEST_COMMAND photospp/tests/${i}
    ENVIRONMENT PYTHIA8DATA=${pythia8_home}/xmldoc ${library_path}=${photos++_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    DEPENDS photospp-build)
endforeach()

#---evtgen------------------------------------------------------------------------------------------
LCGPackage_Add(
  evtgen
  URL ${gen_url}/evtgen-<evtgen_<NATIVE_VERSION>_tag>.tar.gz
  UPDATE_COMMAND <VOID>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
                                --hepmcdir=${HepMC_home}
                                --pythiadir=<pythia8-<evtgen_<VERSION>_pythia8>_home>
                                --photosdir=${photos++_home} 
                                --tauoladir=<tauola++-<evtgen_<VERSION>_tauola++>_home>
  BUILD_COMMAND ${MAKE} -j1 FLIBS=-lgfortran
  INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink  sources/evt.pdl evt.pdl
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink  sources/DECAY_2010.DEC DECAY.DEC
  BUILD_IN_SOURCE 1  
  DEPENDS HepMC pythia8-<evtgen_<VERSION>_pythia8> photos++ tauola++-<evtgen_<VERSION>_tauola++>
)

foreach(version ${evtgen_native_version})
LCG_add_test(evtgen-${version}_test1 TEST_COMMAND evtgen-${version}/tests/evtgen_test1 ${evtgen-${version}_home}/share/DECAY_2010.DEC ${evtgen-${version}_home}/share/evt.pdl ${CMAKE_CURRENT_SOURCE_DIR}/evtgen/tests/DDALITZ.DEC 10000
                          BINARY_DIR evtgen-${version}/tests
                          SOURCE_DIR evtgen/tests
                          BUILD evtgen_test1
                          BUILD_OPTIONS -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
                                        -DMYADDMODULEPATH=${cmaketools_home}/modules
                                        -DROOTSYS=${ROOT_home}
                                        -DEVTGEN_ROOT_DIR=${evtgen-${version}_home} -DPYTHIA8_ROOT_DIR=${pythia8-${evtgen_${version}_pythia8}_home}
                                        -DPHOTOSPP_ROOT_DIR=${photos++_home} -DTAUOLAPP_ROOT_DIR=${tauola++-${evtgen_${version}_tauola++}_home}
                                        -DHEPMC_ROOT_DIR=${HepMC_home}
                          ENVIRONMENT ${library_path}=${evtgen-${version}_home}/lib:${photos++_home}/lib:${pythia8-${evtgen_${version}_pythia8}_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}} 
                                      PYTHIA8DATA=${pythia8-${evtgen_${version}_pythia8}_home}/xmldoc)

endforeach()
#---cython------------------------------------------------------------------------------------------
LCGPackage_Add(
  cython
  URL ${gen_url}/Cython-${cython_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_home}/bin/python setup.py build
  INSTALL_COMMAND ${Python_home}/bin/python setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python
)
set(cython_pythonpath ${cython_home}/lib/python${Python_config_version_twodigit}/site-packages)

#---yaml-cpp----------------------------------------------------------------------------------------
LCGPackage_Add(
  yamlcpp
  URL ${gen_url}/yaml-cpp-${yamlcpp_native_version}.tar.gz
  CMAKE_ARGS -DBOOST_ROOT=${Boost_home} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DBUILD_SHARED_LIBS=ON
  BUILD_IN_SOURCE 1
)


#---Yoda-------------------------------------------------------------------------------------------
LCGPackage_Add(
  yoda
  URL ${gen_url}/YODA-${yoda_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
      --with-boost=${Boost_home}
      PYTHON=${Python_home}/bin/python ${library_path}=${Python_home}/lib:$ENV{${library_path}}
      PYTHONPATH=${cython_home}/lib/python2.7/site-packages:$ENV{PYTHONPATH}
  BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:$ENV{${library_path}} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH}
  INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:$ENV{${library_path}} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH}
  BUILD_IN_SOURCE 1
  DEPENDS Python Boost cython
)


#---lhapdf6sets--------------------------------------------------------------------------------------

LCGPackage_Add(
  lhapdf6sets
  DOWNLOAD_COMMAND <VOID> 
  UPDATE_COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6sets/ -DDST=<SOURCE_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
  BINARY_PACKAGE 1
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>
          COMMAND ${CMAKE_COMMAND}
           -Ddistr=<SOURCE_DIR>
           -Drepo=http://www.hepforge.org/archive/lhapdf/pdfsets/<NATIVE_VERSION>
           -DPDFsets=${PDFsets}
           -Ddst_dir=<INSTALL_DIR>/../share/LHAPDF
           -P ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6sets/pdfsets.cmake
          COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6sets/mktarball.sh <INSTALL_DIR> <NATIVE_VERSION>

)


#---lhapdf6------------------------------------------------------------------------------------------
LCGPackage_Add(
  lhapdf6
  URL ${gen_url}/LHAPDF-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND ./configure
     --prefix=<INSTALL_DIR>
     --with-boost=${Boost_home}
     --with-yaml-cpp=${yamlcpp_home}
     PYTHON=${Python_home}/bin/python
     CYTHON=${cython_home}/bin/cython
     PYTHONPATH=${cython_pythonpath}
  BUILD_COMMAND ${MAKE} all ${library_path}=${yamlcpp_home}/lib:$ENV{${library_path}} PYTHONPATH=${cython_pythonpath}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND make install PYTHONPATH=${cython_pythonpath}
  DEPENDS lhapdf6sets Boost yamlcpp Python cython
)

LCG_add_test(lhapdf6_orig_testpdf
  TEST_COMMAND lhapdf6/tests/lhapdf6_orig_testpdf CT10 1
  BINARY_DIR lhapdf6/tests
  SOURCE_DIR lhapdf6/tests
  BUILD lhapdf6_orig_testpdf
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
   -DLHAPDF6_ROOT_DIR=${lhapdf6_home}
   -DBOOST_ROOT=${Boost_home}
   -DBoost_INCLUDE_DIR=${Boost_home_include}
   -DYAMLCPP_ROOT_DIR=${yamlcpp_home}
  ENVIRONMENT
    ${library_path}=${lhapdf6_home}/lib:${Boost_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
    LHAPDF_DATA_PATH=${lhapdf6_home}/share/LHAPDF:${lhapdf6sets_home}/../share/LHAPDF
)

#---Rivet2-----------------------------------------------------------------------------------------
LCGPackage_Add(
  rivet2
  URL ${gen_url}/Rivet-${rivet2_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --with-hepmc=${HepMC_home} 
     --with-boost=${Boost_home_include}
     --with-fastjet=${fastjet_home}
     --with-yoda=${yoda_home}
     --with-yaml-cpp=${yamlcpp_home}
     --with-gsl=${GSL_home}
     --with-lcgtag=${LCG_platform}
     --disable-pdfmanual
     --enable-unvalidated
     PYTHON=${Python_home}/bin/python
     PYTHONPATH=${cython_home}/lib/python2.7/site-packages:$ENV{PYTHONPATH}
     ${library_path}=${Python_home}/lib:$ENV{${library_path}}
     SWIG=${swig_home}/bin/swig
     CC=${CMAKE_C_COMPILER}
     CXX=${CMAKE_CXX_COMPILER}
  BUILD_COMMAND ${MAKE} all
                ${library_path}=${Python_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
                PYTHONPATH=${cython_home}/lib/python2.7/site-packages:$ENV{PYTHONPATH}
  INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
                PYTHONPATH=${cython_home}/lib/python2.7/site-packages:$ENV{PYTHONPATH}
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig yoda yamlcpp
)

LCG_add_test(
       rivet2_test_cms
       TEST_COMMAND  ${rivet2_home}/bin/rivet -a CMS_2012_I1184941 ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc
       ENVIRONMENT ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
                   PATH=${Python_home}/bin:$ENV{PATH}   
)

LCG_add_test(
       rivet2_test_atlas
       TEST_COMMAND  ${rivet2_home}/bin/rivet -a ATLAS_2012_I1083318 ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc
       ENVIRONMENT ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
                   PATH=${Python_home}/bin:$ENV{PATH}
)

LCG_add_test(
       rivet2_test_cms_script
       TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/rivet2/tests/testCMS.sh ${rivet2_home} ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc  
       ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
		   ${library_path}=${Python_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
)   

LCG_add_test(
       rivet2_test_atlas_script  
       TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/rivet2/tests/testATLAS.sh ${rivet2_home} ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc
       ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
		   ${library_path}=${Python_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
)




#---Rivet------------------------------------------------------------------------------------------
LCGPackage_Add(
  rivet
  URL ${gen_url}/Rivet-<NATIVE_VERSION>.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --with-hepmc=${HepMC_home} 
     --with-boost-incpath=${Boost_home_include}
     --with-fastjet=${fastjet_home}
     --with-gsl=${GSL_home}
     --with-lcgtag=${LCG_platform}
     --disable-pdfmanual
     --enable-unvalidated
     PYTHON=${Python_home}/bin/python ${library_path}=${Python_home}/lib:$ENV{${library_path}}
     SWIG=${swig_home}/bin/swig
     CC=${CMAKE_C_COMPILER}
     CXX=${CMAKE_CXX_COMPILER}
     CFLAGS=-O2
  BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:$ENV{${library_path}}
  INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:$ENV{${library_path}}
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
          COMMAND ${CMAKE_COMMAND} -E create_symlink ${LCG_platform} <INSTALL_DIR>/../${LCG_platform_dbg}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig
)

LCG_add_test(rivet_orig_test1
  TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/rivet/tests/test1.sh ${rivet_home} ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc
  ENVIRONMENT
    ${library_path}=${GSL_home}/lib:$ENV{${library_path}}
    PATH=${Python_home}/bin:$ENV{PATH}
)

#---Sherpa------------------------------------------------------------------------------------------
LCGPackage_Add(
  sherpa
  URL ${gen_url}/SHERPA-MC-<sherpa_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa_<NATIVE_VERSION>_hepevt>
     --enable-multithread
     --enable-lhapdf=${lhapdf_home}
     --enable-hepmc2=${HepMC_home}
     --enable-openloops=.
     --enable-rivet=${rivet_home} "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0"

  INSTALL_COMMAND make install 
#          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf HepMC rivet
)

# $PWD is needed because Sherpa uses this variable to know current directory
LCG_add_test(sherpa_orig_test1
  PRE_COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/tests
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/tests ${sherpa_home}/bin/Sherpa -j20 -f ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_Z.dat
  POST_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa/tests
  ENVIRONMENT
    ${library_path}=${sherpa_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
    PWD=.
)

LCG_add_test(sherpa_orig_test2
  PRE_COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/tests2
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/tests2 ${sherpa_home}/bin/Sherpa -j20 -f ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_ZJets.dat
  POST_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa/tests2
  ENVIRONMENT
    ${library_path}=${sherpa_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
    PWD=.
  LABELS PhysicsCheck
)


#---HepMCAnalysis------------------------------------------------------------------------------------
LCGPackage_Add(
  hepmcanalysis
  URL ${gen_url}/HepMCAnalysis-<hepmcanalysis_<NATIVE_VERSION>_author>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/hepmcanalysis/files <SOURCE_DIR>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${MAKE} VERBOSE=1 HepMCdir=${HepMC_home} FastJetdir=${fastjet_home} ROOTSYS=${ROOT_home} CLHEPdir=${CLHEP_home} 
			${library_path}=${CLHEP_home}/lib:$ENV{${library_path}}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
  BUILD_IN_SOURCE 1
  DEPENDS HepMC fastjet CLHEP ROOT

)
LCG_add_test(hepmcanalysis-build
  BINARY_DIR hepmcanalysis/tests
  SOURCE_DIR hepmcanalysis/tests  
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_SEARCHPATH1=${CMAKE_SOURCE_DIR}/cmake/modules
   -DCMAKE_MODULE_SEARCHPATH2=${cmaketools_home}/modules
   -DHEPMCANALYSIS_ROOT_DIR=${hepmcanalysis_home}
   -DPYTHIA6_ROOT_DIR=${pythia6_home}
   -DHEPMC_ROOT_DIR=${HepMC_home}
   -DFASTJET_ROOT_DIR=${fastjet_home}
   -DROOTSYS=${ROOT_home}
   -DLHAPDF_ROOT_DIR=${lhapdf_home}
   -DCLHEP_ROOT_DIR=${CLHEP_home}	
  ENVIRONMENT ${library_path}=${ROOT_home}/lib:${fastjet_home}/lib:${CLHEP_home}/lib:${HepMC_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})
 

LCG_add_test(hepmcanalysis_test_pythia6
   TEST_COMMAND hepmcanalysis/tests/hepmcanalysis_test_pythia6 ${hepmcanalysis_home}/../share/sources/examples/pythia6/Process.config
   DEPENDS hepmcanalysis-build
   ENVIRONMENT ${library_path}=${hepmcanalysis_home}/lib:${ROOT_home}/lib:${fastjet_home}/lib:${CLHEP_home}/lib:${HepMC_home}/lib:${pythia6_home}/lib:$ENV{${library_path}}
)
    
LCG_add_test(hepmcanalysis_test_hepmcreader
    BINARY_DIR hepmcanalysis/tests
    PRE_COMMAND ${CMAKE_COMMAND} -E create_symlink ${hepmcanalysis_home}/../share/sources/examples/hepmcreader/Process.config Process.config
        COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc sample1.input
    TEST_COMMAND hepmcanalysis/tests/hepmcanalysis_test_hepmcreader Process.config
    DEPENDS hepmcanalysis-build
    ENVIRONMENT ${library_path}=${hepmcanalysis_home}/lib:${ROOT_home}/lib:${fastjet_home}/lib:${CLHEP_home}/lib:${HepMC_home}/lib:${pythia6_home}/lib:$ENV{${library_path}}
)




#---MC-TESTER----------------------------------------------------------------------------------------
LCGPackage_Add(mctester
  URL ${gen_url}/MC-TESTER-${mctester_native_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E touch make.inc 
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-HepMC=${HepMC_home} --with-root=${ROOT_home}/bin "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0"
  BUILD_COMMAND ${MAKE} -j1 ${library_path}=${ROOT_home}/lib:$ENV{${library_path}}
  INSTALL_COMMAND make -j1 install 
#          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  BUILD_IN_SOURCE 1
  DEPENDS HepMC ROOT
)

LCG_add_test(mctester-build
  BINARY_DIR mctester/tests
  SOURCE_DIR mctester/tests  
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_SEARCHPATH1=${CMAKE_SOURCE_DIR}/cmake/modules
   -DCMAKE_MODULE_SEARCHPATH2=${cmaketools_home}/modules
   -DMCTESTER_ROOT_DIR=${mctester_home}
   -DPYTHIA8_ROOT_DIR=${pythia8_home}
   -DHEPMC_ROOT_DIR=${HepMC_home}
   -DROOTSYS=${ROOT_home}
   ENVIRONMENT ${library_path}=${mctester_home}/lib:${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}})
  
LCG_add_test(mctester_test_pyt8
    BINARY_DIR mctester/tests
    PRE_COMMAND ${CMAKE_COMMAND} -E create_symlink ${mctester_home}/../share/sources/examples-C++/pythia/SETUP.C SETUP.C
    TEST_COMMAND mctester/tests/mctester_test_pyt8
    ENVIRONMENT ${library_path}=${ROOT_home}/lib:${mctester_home}/lib:${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}} 
                PYTHIA8DATA=${pythia8_home}/xmldoc
    DEPENDS mctester-build
  	)
    

#---HIJING----------------------------------------------------------------------------------------

if(NOT APPLE)    #  (installation fails on MacOSX, can be fixed on macos)
 
  LCGPackage_Add(
    hijing
    URL ${gen_url}/hijing-${hijing_native_version}-src.tgz
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/${hijing_native_version} <SOURCE_DIR>   
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/${hijing_native_version}
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
    BUILD_COMMAND ${MAKE} FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy  <SOURCE_DIR>/tmp/hidata.o <INSTALL_DIR>/lib
       	  COMMAND ${CMAKE_COMMAND} -E copy  <SOURCE_DIR>/tmp/ludata.o <INSTALL_DIR>/lib
       	  COMMAND ${CMAKE_COMMAND} -E copy  <SOURCE_DIR>/tmp/pyhidata.o <INSTALL_DIR>/lib
    BUILD_IN_SOURCE 1
)
LCG_add_test(hijing_orig_test1 TEST_COMMAND hijing/tests/hijing_orig_test1
                          BINARY_DIR hijing/tests
                          SOURCE_DIR hijing/tests
                          BUILD hijing_orig_test1
                          BUILD_OPTIONS -DHIJING_ROOT_DIR=${hijing_home}
                          ENVIRONMENT ${library_path}=${hijing_home}/lib:$ENV{${library_path}})

endif()

#---Starlight---------------------------------------------------------------------------------------
string(SUBSTRING ${starlight_native_version} 1 -1 STARLIGHT_REV)
LCGPackage_Add(
  starlight
  URL ${gen_url}/starlight-r${STARLIGHT_REV}.tgz
  UPDATE_COMMAND <VOID>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

LCG_add_test(starlight_orig_test1
  PRE_COMMAND ${CMAKE_COMMAND} -E remove -f slight.in
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${starlight_home}/../share/sources/config/slight.in.new slight.in
  TEST_COMMAND ${starlight_home}/bin/starlight)

#---HERWIG----------------------------------------------------------------------------------------
LCGPackage_Add(
  herwig
  URL ${gen_url}/herwig-<NATIVE_VERSION>-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> "FFLAGS=-O2 -fPIC -Wuninitialized -fno-automatic" F77=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER}
#  CONFIGURE_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/herwig/scripts/run_lcg_configure <INSTALL_DIR>
  INSTALL_COMMAND make install FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} F77=${CMAKE_Fortran_COMPILER}
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/include ${CMAKE_COMMAND} -E create_symlink HERWIG65.INC herwig65.inc
  BUILD_IN_SOURCE 1
)

#---tauola------------------------------------------------------------------------------------------
if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    tauola
    URL ${gen_url}/tauola-${tauola_native_version}-src.tgz
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
           COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --datadir=<INSTALL_DIR>/data --with-pythia6=${pythia6_home} --with-photos=${photos_home} --with-hepevt=4000
    BUILD_COMMAND ${MAKE} FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
    BUILD_IN_SOURCE 1
    DEPENDS photos pythia6
  )
  LCG_add_test(tauola-test1 TEST_COMMAND tauola/tests/tauola_test1
                          BINARY_DIR tauola/tests
                          SOURCE_DIR tauola/tests
                          BUILD tauola_test1
                          BUILD_OPTIONS -DTAUOLA_ROOT_DIR=${tauola_home} -DPHOTOS_ROOT_DIR=${photos_home} -DPYTHIA6_ROOT_DIR=${pythia6_home}
                          ENVIRONMENT ${library_path}=${tauola_home}/lib:${photos_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})

endif()

#---jimmy------------------------------------------------------------------------------------------
LCGPackage_Add(
  jimmy
  URL ${gen_url}/jimmy-${jimmy_native_version}-src.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
           COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
  CONFIGURE_COMMAND ./configure --with-herwig=${herwig_home}
  BUILD_COMMAND ${MAKE} -j1 FC=${CMAKE_Fortran_COMPILER}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
            COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
	    COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/lib ${CMAKE_COMMAND} -E create_symlink archive/libjimmy.a libjimmy.a
    BUILD_IN_SOURCE 1
  DEPENDS herwig
)

#---hydjet++---------------------------------------------------------------------------------------
LCGPackage_Add(
  hydjet++
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=${gen_url}/HYDJET++<hydjet++_<NATIVE_VERSION>_author>.ZIP
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  COMMAND unzip <SOURCE_DIR>/HYDJET++<hydjet++_<NATIVE_VERSION>_author>.ZIP -d <SOURCE_DIR>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${EXEC} PATH=${ROOT_home}/bin:$ENV{PATH} ${MAKE} -j2 F77LIBSO=-lgfortran
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E create_symlink hydjet++ <INSTALL_DIR>/../../../hydjetpp        
  BUILD_IN_SOURCE 1
  DEPENDS ROOT
)

#---alpgen-----------------------------------------------------------------------------
LCGPackage_Add(
  alpgen
  URL ${gen_url}/alpgen_v<alpgen_<NATIVE_VERSION>_author>.tgz 
# copy.cmake is a custom command, it works better than copy_directory and excludes .svn
  UPDATE_COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/alpgen/files -DDST=<SOURCE_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
  BUILD_COMMAND ${MAKE} all
  INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/../share ${CMAKE_COMMAND} -E create_symlink  sources alpgen-author
  BUILD_IN_SOURCE 1
)

#---CRMC (FORMER EPOS)-----------------------------------------------------------------------------
# SVN repository:
#   https://devel-ik.fzk.de/svn/mc/crmc/tags/{version}

if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    crmcold
    URL ${gen_url}/crmc-<NATIVE_VERSION>.tar.gz
    CONFIGURE_COMMAND <VOID>
    BUILD_COMMAND ${MAKE} -f Makefile CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
    INSTALL_COMMAND make -f Makefile install CRMCROOT=<INSTALL_DIR> HEP_ROOT=${HepMC_home}
    BUILD_IN_SOURCE 1
    DEPENDS HepMC
  )
  
  # add test only if version is defined in toolchain configuration
  if(NOT ${crmcold_home} STREQUAL "")
    LCG_add_test(crmcold_orig_test
      TEST_COMMAND ${crmcold_home}/bin/crmc -T 1 -c ${crmcold_home}/crmc.param
      ENVIRONMENT ${library_path}=${HepMC_home}/lib:$ENV{${library_path}}
    )
  endif()
endif()

if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    crmc
    URL ${gen_url}/crmc.v<NATIVE_VERSION>.tar.gz
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -DROOTSYS=${ROOT_home}
               -DHEPMC_PREFIX=${HepMC_home}
               -DBOOST_ROOT=${Boost_home}
               -DBOOST_INCLUDE_DIR=${Boost_home_include}
#               -D__CRMCSTATIC__=ON
    DEPENDS HepMC Boost ROOT
  )
  
  LCG_add_test(crmc_orig_test
    TEST_COMMAND ${crmc_home}/bin/crmc -T 1 -c ${crmc_home}/crmc.param
  )
endif()

#---powhegbox---------------------------------------------------------------------------------------
if(NOT APPLE)    #  (installation fails on MacOSX)
 LCGPackage_Add(
  powheg-box
  URL ${gen_url}/powheg-box-<NATIVE_VERSION>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/files <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./distr-cleanup.sh
  CONFIGURE_COMMAND ./configure  
    --prefix=<INSTALL_DIR>
    --fastjet=${fastjet_home}
    --lhapdf=${lhapdf_home}
  BUILD_COMMAND ${MAKE}
  BUILD_IN_SOURCE 1
  DEPENDS fastjet lhapdf
 )

# WZ, Wp_Wp_J_J, VBF_Wp_Wp are skiped - example steering files do not work
foreach(i WW HJ W_ew-BW Wbb Wj HJJ ZZ W_ew-BMNNP Dijet gg_H VBF_H Z W hvq Zj ST_sch ST_tch ST_tch_4f)
  LCG_add_test(powheg-box_orig_test${i}
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/tests/runtest.sh ${powheg-box_home}/bin ${powheg-box_home}/../share/sources ${i}
    ENVIRONMENT
      ${library_path}=${lhapdf_home}/lib:${fastjet_home}/lib:$ENV{${library_path}}
      LHAPATH=${lhapdfsets_home}/../share/PDFsets
  )
endforeach()

endif()
#---baurmc------------------------------------------------------------------------------------------

if(NOT APPLE)    #  (installation fails on MacOSX)
  LCGPackage_Add(
    baurmc
    URL ${gen_url}/baurmc-<NATIVE_VERSION>-src.tgz
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/<NATIVE_VERSION> <SOURCE_DIR>
           COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>
    CONFIGURE_COMMAND ./configure --lcgplatform=${LCG_platform}  --userfflags=-fno-automatic --enable-shared
    BUILD_COMMAND ${MAKE} FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
    BUILD_IN_SOURCE 1
  )

endif()


#--- MadGraph5 -------------------------------------------------------------------------------------
LCGPackage_Add(
  madgraph5
  URL ${gen_url}/MadGraph5_v<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

LCGPackage_Add(
  madgraph5v2
  URL ${gen_url}/MadGraph5_v<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${MAKE} -j1 -C vendor/CutTools
  INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
  BUILD_IN_SOURCE 1
  DEPENDS Python
)


#--- JHU -------------------------------------------------------------------------------------------
LCGPackage_Add(
  jhu
  URL ${gen_url}/JHUGenerator.v<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${MAKE} -j1 -C JHUGenerator Comp=gfortran
        COMMAND ${MAKE} -C JHUGenME Comp=gfortran
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
          COMMAND ${CMAKE_COMMAND} -E copy JHUGenerator/JHUGen <INSTALL_DIR>/bin/
          COMMAND ${CMAKE_COMMAND} -E copy JHUGenME/testC <INSTALL_DIR>/bin/
          COMMAND ${CMAKE_COMMAND} -E copy JHUGenME/testF <INSTALL_DIR>/bin/
          COMMAND ${CMAKE_COMMAND} -E copy_directory JHUGenerator/pdfs <INSTALL_DIR>/pdfs
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/pdfs/Cteq61Pdf.f <INSTALL_DIR>/pdfs/Cteq61Pdf.o <INSTALL_DIR>/pdfs/mstwpdf.f <INSTALL_DIR>/pdfs/mstwpdf.o
  BUILD_IN_SOURCE 1
)

LCG_add_test(jhu_orig_test_JHUGen
  PRE_COMMAND ${CMAKE_COMMAND} -E remove -f pdfs
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${jhu_home}/pdfs pdfs
  TEST_COMMAND ${jhu_home}/bin/JHUGen VegasNc0=100000 VegasNc1=500000 VegasNc2=100)

LCG_add_test(jhu_orig_test_F
  TEST_COMMAND ${jhu_home}/bin/testF)

LCG_add_test(jhu_orig_test_C
  TEST_COMMAND ${jhu_home}/bin/testC)


### rivet 2 tests
# lcgcmake/generators/rivet-testing/pythia6/pythia6-ttbar-7tev.params

LCG_add_test(
rivet-pythia6-test
                TEST_COMMAND ${agile_home}/bin/agile-runmc Pythia6:428 -o hepmcfile.dat --paramfile ${CMAKE_SOURCE_DIR}/generators/rivet-testing/pythia6/pythia6-ttbar-7tev.params -n 1000
                     COMMAND  ${rivet2_home}/bin/rivet -a MC_XS -a MC_TTBAR hepmcfile.dat
                ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
                            ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${agile_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
                            PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python2.7/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
                            AGILE_GEN_PATH=${agile_home}/../../..
                LABELS PhysicsCheck
                POST_COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_SOURCE_DIR}/generators/reference/rivet-pythia6-test.yoda ${CMAKE_BINARY_DIR}/generators/Rivet.yoda "Path=XS" limit=0.90
                     COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/Rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
                     COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_SOURCE_DIR}/generators/reference/rivet-pythia6-test.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
                     COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_SOURCE_DIR}/generators/reference/rivet-pythia6-test.root ${CMAKE_BINARY_DIR}/generators/Rivet.root "Path=jet_HT,jet_mult" "limit=0.90,0.90"
                              )


LCG_add_test(rivet-herwigpp-ttbar-test
                          TEST_COMMAND ${herwig++_home}/bin/Herwig++ read ${CMAKE_SOURCE_DIR}/generators/herwig++/tests/LHC-ttbar.in
                               COMMAND ${herwig++_home}/bin/Herwig++ run -N1000 LHC-ttbar.run -d1
                               COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a MC_TTBAR LHC-ttbar.hepmc 
                               COMMAND cat LHC-ttbar.out
                               COMMAND cat LHC-ttbar.log
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          ENVIRONMENT ${library_path}=${herwig++_home}/lib/Herwig++:${thepeg_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
                                      PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python2.7/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
                                      PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
                          LABELS PhysicsCheck
                          POST_COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_SOURCE_DIR}/generators/reference/rivet-herwigpp-ttbar-test.yoda ${CMAKE_BINARY_DIR}/generators/Rivet.yoda "Path=XS" limit=0.90
                               COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/Rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
                               COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_SOURCE_DIR}/generators/reference/rivet-herwigpp-ttbar-test.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
                               COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_SOURCE_DIR}/generators/reference/rivet-herwigpp-ttbar-test.root ${CMAKE_BINARY_DIR}/generators/Rivet.root "Path=jet_HT,jet_mult" "limit=0.90,0.90"

)
  
  





#---test of the test infrasgtructure---------------------------------------------------------------
LCG_add_test(test-test PRE_COMMAND /bin/echo pre-comand 1
                           COMMAND /bin/echo pre-comand 2
                           COMMAND /bin/echo pre-comand 3
                           COMMAND /bin/echo pre-comand 4
                           COMMAND /bin/echo pre-comand 5
                      TEST_COMMAND /bin/echo test-command 1
                           COMMAND /bin/echo test-command 2 
                           COMMAND /bin/echo test-command 3
                      POST_COMMAND /bin/echo post-command 1
                           COMMAND date )



