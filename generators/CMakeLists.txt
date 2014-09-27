#---Options-----------------------------------------------------------------------------------------
set(PDFsets "--all" CACHE STRING "The PDFsets to be downloaded for the 'lhspdfsets' package (default --all)")

if (VALIDATION)
  set (timeout 90000)
  set (rivettests_stat_size  100000)
else()
  set (timeout 1500)
  set (rivettests_stat_size  1000)
endif()
#---General parameters------------------------------------------------------------------------------
set (gen_url "http://service-spi.web.cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles")

set(Python_cmd ${Python_home}/bin/python)
set(Exec_cmd ${env_cmd})

set (AIDA2ROOT "${CMAKE_SOURCE_DIR}/generators/reference/aida2root.py")
string(REPLACE "." "_" Boost_underscore_twodigit ${Boost_config_version_twodigit})
set(Boost_home_include ${Boost_home}/include/boost-${Boost_underscore_twodigit})
if(APPLE)
  set(library_path DYLD_LIBRARY_PATH)
else()
  set(library_path LD_LIBRARY_PATH)
endif()
string(REPLACE "opt" "dbg" LCG_platform_dbg ${LCG_platform})

foreach(v ${rivet_native_version})
  if(v VERSION_EQUAL 2.0.0 OR v VERSION_GREATER 2.0.0)
    set(rivet2_home ${CMAKE_INSTALL_PREFIX}/${rivet_directory_name}/${v}/${LCG_system})
  endif()
endforeach()

foreach(v ${lhapdf_native_version})
  if(v VERSION_LESS 6.0.0)
    set(lhapdf5_home ${CMAKE_INSTALL_PREFIX}/${lhapdf_directory_name}/${v}/${LCG_system})
    set(lhapdf5vers ${v})
  else()
    set(lhapdf6_home ${CMAKE_INSTALL_PREFIX}/${lhapdf_directory_name}/${v}/${LCG_system})
    set(lhapdf6vers ${v})
  endif()
endforeach()

foreach(v ${pythia8_native_version})
  set(pythia8_work_version ${v})
endforeach()

list(GET pythia6_native_version -1 pythia6_test_version_full)
#This is not good that versions .2 cannot be tested with agile if there is a corresponding version without .2, solution to be found:
string(REGEX MATCH "[0-9][0-9][0-9]" pythia6_test_version ${pythia6_test_version_full})

list(GET swig_native_version -1 swig_test_version)
string(REGEX MATCH "[0-9]+[.][0-9]+[.][0-9]+" swig_author_version ${swig_test_version})

### sh <-> csh switch
if ($ENV{SHELL} MATCHES ".*csh")  # for tcsh, csh
  set (shell_ext "csh")
  set (SH_SHELL "/bin/sh")
else()   
  set (shell_ext "sh")
  set (SH_SHELL $ENV{SHELL})
endif()

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
#           -Drepo=http://www.hepforge.org/archive/lhapdf/pdfsets/<NATIVE_VERSION>
	   -Drepo=http://cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/LHAPDF5SETS/<NATIVE_VERSION>
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

list(GET lhapdf_native_version -1 pdf_version_full)
string(REGEX MATCH "[0-9]+.[0-9]+" pdf_version "${pdf_version_full}")
LCG_add_test(lhapdf6sets.download
   PRE_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current
       COMMAND ${CMAKE_COMMAND} -E echo "Download LHAPDF6 PDF sets (version ${pdf_version}) ..."
  TEST_COMMAND ${CMAKE_COMMAND}
               -Ddistr=${CMAKE_SOURCE_DIR}/generators/lhapdf6sets
               -Drepo=http://www.hepforge.org/archive/lhapdf/pdfsets/${pdf_version}
               -DPDFsets=${PDFsets}
               -Ddst_dir=${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
               -P ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6sets/pdfsets.cmake
)


#---cython------------------------------------------------------------------------------------------
LCGPackage_Add(
  cython
  URL ${gen_url}/Cython-${cython_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_home}/bin/python setup.py build -e "${env_cmd} python"
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
  INSTALL_COMMAND make install  
  COMMAND ${CMAKE_COMMAND} -E create_symlink yamlcpp <INSTALL_DIR>/../../../yaml-cpp

)


#---Yoda-------------------------------------------------------------------------------------------
LCGPackage_Add(
  yoda
  URL ${gen_url}/YODA-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
      --with-boost=${Boost_home}
  IF EXISTS "${ROOT_home}/" THEN
      --enable-root
      ROOTCONFIG=${ROOT_home}/bin/root-config
  ENDIF
      PYTHON=${Python_home}/bin/python ${library_path}=${Python_home}/lib:$ENV{${library_path}}
      PYTHONPATH=${cython_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
  BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:$ENV{${library_path}} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH} LIBRARY_PATH=${Python_home}/lib
  INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:$ENV{${library_path}} PYTHONPATH=:${cython_pythonpath}:$ENV{PYTHONPATH} LIBRARY_PATH=${Python_home}/lib
  BUILD_IN_SOURCE 1
  DEPENDS Python Boost cython
)


#---lhapdf------------------------------------------------------------------------------------------
LCGPackage_Add(
  lhapdf
  IF <VERSION> VERSION_LESS 6.0.0 THEN
    URL ${gen_url}/lhapdf-<NATIVE_VERSION>.tar.gz
    PATCH_COMMAND patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/patches/lhapdf-getdata.patch
        CONFIGURE_COMMAND ./configure
      --prefix=<INSTALL_DIR>
      --datadir=<lhapdfsets_home>/../share
      --enable-low-memory
      --disable-pyext
      --disable-doxygen
      --disable-octave
      FCFLAGS=-g0 CFLAGS=-g0 CXXFLAGS=-g0
    INSTALL_COMMAND make install
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/lhapdf
          COMMAND ${CMAKE_COMMAND} -E create_symlink ../../../../lhapdfsets/<VERSION>/share/lhapdf <INSTALL_DIR>/../share/lhapdf
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets <INSTALL_DIR>/../share/PDFsets
          COMMAND ${CMAKE_COMMAND} -E remove -f <INSTALL_DIR>/../share/PDFsets.index
          COMMAND ${CMAKE_COMMAND} -E create_symlink lhapdf/PDFsets.index <INSTALL_DIR>/../share/PDFsets.index
    BUILD_IN_SOURCE 1
    DEPENDS lhapdfsets 
 ELSE
    URL ${gen_url}/LHAPDF-<NATIVE_VERSION>.tar.gz
      CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-boost=${Boost_home} --with-yaml-cpp=${yamlcpp_home}
      PYTHON=${Python_home}/bin/python
      CYTHON=${cython_home}/bin/cython
      PYTHONPATH=${cython_pythonpath}  CFLAGS=-O2 CXXFLAGS=-O2 FCFLAGS=-O2 LDFLAGS=-O2
    BUILD_COMMAND ${MAKE} all
    ${library_path}=${yamlcpp_home}/lib:$ENV{${library_path}} PYTHONPATH=${cython_pythonpath} LIBRARY_PATH=${Python_home}/lib
    INSTALL_COMMAND make install PYTHONPATH=${cython_pythonpath} LIBRARY_PATH=${Python_home}/lib
          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
    BUILD_IN_SOURCE 1
    DEPENDS Boost yamlcpp Python cython
  ENDIF
)

LCGPackage_set_home(pythia8)

#---lhapdf5 tests

foreach(v ${lhapdf_native_version})
  if(v VERSION_LESS 6.0.0)
    LCG_add_test(lhapdf-${v}.build
      BINARY_DIR lhapdf/tests/${v}
      SOURCE_DIR lhapdf/tests
      BUILD all
      BUILD_OPTIONS
       -DCMAKE_MODULE_PATH=${cmaketools_home}/modules 
       -DLHAPDF_ROOT_DIR=${lhapdf-${v}_home}
    )

    foreach(i native-CCTest1 native-CCTest3 native-CCTest4)
      LCG_add_test(lhapdf-${v}.${i}
        TEST_COMMAND lhapdf/tests/${v}/${i}
        ENVIRONMENT
          ${library_path}=${lhapdf-${v}_home}/lib:$ENV{${library_path}}
          LHAPATH=${lhapdfsets_home}/../share/lhapdf/PDFsets
        DEPENDS lhapdf-${v}.build
      )
    endforeach()
  endif()
endforeach()

#---lhapdf6 tests

foreach(v ${lhapdf_native_version})
  if(v VERSION_GREATER 5.9.9)
    LCG_add_test(lhapdf6-${v}.native-testpdf
      TEST_COMMAND lhapdf6/tests/${v}/native-testpdf CT10 1
      BINARY_DIR lhapdf6/tests/${v}
      SOURCE_DIR lhapdf6/tests
      BUILD native-testpdf
      BUILD_OPTIONS
       -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
       -DLHAPDF6_ROOT_DIR=${lhapdf-${v}_home}
       -DBOOST_ROOT=${Boost_home}
       -DBoost_INCLUDE_DIR=${Boost_home_include}
       -DYAMLCPP_ROOT_DIR=${yamlcpp_home}
      ENVIRONMENT
        ${library_path}=${lhapdf-${v}_home}/lib:${Boost_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
        LHAPDF_DATA_PATH=${lhapdf-${v}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
      DEPENDS lhapdf6sets.download
    )

    LCG_add_test(lhapdf6-${v}.genser-pythia8
      TEST_COMMAND lhapdf6/tests/pyt8/${v}/lhapdf6_pyt8
      BINARY_DIR lhapdf6/tests/pyt8/${v}
      SOURCE_DIR lhapdf6/tests/pyt8
      BUILD lhapdf6_pyt8
      BUILD_OPTIONS
       -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
       -DLHAPDF6_ROOT_DIR=${lhapdf-${v}_home}
       -DBOOST_ROOT=${Boost_home}
       -DBoost_INCLUDE_DIR=${Boost_home_include}
       -DYAMLCPP_ROOT_DIR=${yamlcpp_home}
       -DPYTHIA8_ROOT_DIR=${pythia8_home}
      ENVIRONMENT
        ${library_path}=${lhapdf-${v}_home}/lib:${pythia8_home}/lib:${Boost_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
        LHAPDF_DATA_PATH=${lhapdf-${v}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
        PYTHIA8DATA=${pythia8_home}/xmldoc
      POST_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c .
           COMMAND ${CMAKE_COMMAND} -E copy testi_lhapdf6.dat test_lhapdf6.dat
           COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh lhapdf6 ${CMAKE_SOURCE_DIR}/generators/lhapdf6/tests/pyt8/reference.dat ${v} ${LCG_VERSION} ${LCG_platform}
      DEPENDS lhapdf6sets.download
    )
  endif()
endforeach()


#---pythia8------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia8
  IF <pythia8_<NATIVE_VERSION>_author> VERSION_EQUAL "HEAD" THEN
    SVN_REPOSITORY https://pythia8.hepforge.org/svn/pythia81/trunk
  ELSE
    URL ${gen_url}/pythia8<pythia8_<NATIVE_VERSION>_author>.tgz
  ENDIF
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --enable-shared --lcgplatform=${LCG_platform}
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND $ENV{SHELL} -c "sed -i -e 's/cp -r/cp -rf/g' <SOURCE_DIR>/Makefile"
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${MAKE} install
          COMMAND ${CMAKE_COMMAND} -E create_symlink sources/xmldoc <INSTALL_DIR>/../share/xmldoc
  BUILD_IN_SOURCE 1
  CONFIGURE_EXAMPLES_COMMAND <SOURCE_DIR>/examples/configure
                             --with-pythia8=<INSTALL_DIR>
                             --with-lhapdf=${lhapdf_home}/lib/archive
                             --with-fastjet=${fastjet_home}
  BUILD_EXAMPLES_COMMAND ${MAKE} -C <SOURCE_DIR>/examples main01 main03
  INSTALL_EXAMPLES_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
                   COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/examples cp bin/main01.exe bin/main03.exe main03.cmnd <INSTALL_DIR>/bin
  DEPENDS HepMC lhapdf fastjet
)

foreach(v ${pythia8_native_version})

LCG_add_test(pythia8-${v}.build
  BINARY_DIR pythia8/tests/${v}
  SOURCE_DIR pythia8/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
   -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
   -DPYTHIA8_ROOT_DIR=${pythia8-${v}_home} -DHEPMC_ROOT_DIR=${HepMC_home}
   -DFASTJET_ROOT_DIR=${fastjet_home}
)

LCG_add_test(pythia8-${v}.genser-main14_genser
  TEST_COMMAND pythia8/tests/${v}/pythia8_main14_genser ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/ref-pythia8-186-main14-xsec-x86_64-slc6-gcc48-opt.dat
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
  DEPENDS pythia8-${v}.build)

LCG_add_test(pythia8-${v}.native-main01
  TEST_COMMAND pythia8/tests/${v}/native-main01
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
  DEPENDS pythia8-${v}.build)

LCG_add_test(pythia8-${v}.genser-test1
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test1
  POST_COMMAND ${CMAKE_COMMAND} -E copy pythia8/tests/${v}/testi_pythia8.dat pythia8/tests/${v}/test_pythia8.dat
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
  DEPENDS pythia8-${v}.build)

LCG_add_test(pythia8-${v}.genser-test2
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8_test2.cmnd pythia8/tests/${v}/.
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test2
  POST_COMMAND $ENV{SHELL} -c "cat pythia8/tests/${v}/testi_pythia8.dat >> pythia8/tests/${v}/test_pythia8.dat"
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
  DEPENDS pythia8-${v}.build pythia8-${v}.genser-test1)

LCG_add_test(pythia8-${v}.genser-test3
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test3
  POST_COMMAND $ENV{SHELL} -c "cat pythia8/tests/${v}/testi_pythia8.dat >> pythia8/tests/${v}/test_pythia8.dat"
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
  DEPENDS pythia8-${v}.build pythia8-${v}.genser-test1)

LCG_add_test(pythia8-${v}.genser-test4
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test4
  POST_COMMAND $ENV{SHELL} -c "cat pythia8/tests/${v}/testi_pythia8.dat >> pythia8/tests/${v}/test_pythia8.dat"
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
  DEPENDS pythia8-${v}.build pythia8-${v}.genser-test1)

LCG_add_test(pythia8-${v}.compare
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c pythia8/tests/${v}/.
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh pythia8 ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/reference.dat ${v} ${LCG_VERSION} ${LCG_platform}
  DEPENDS pythia8-${v}.genser-test2 pythia8-${v}.genser-test3 pythia8-${v}.genser-test4)

endforeach()

if (hepmc3_native_version)

 LCG_add_test(hepmc3-pythia8-test1
  BINARY_DIR hepmc3/tests
  SOURCE_DIR hepmc3/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
   -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
   -DPYTHIA8_ROOT_DIR=${pythia8_home}
   -DHEPMC_ROOT_DIR=${hepmc3_home}
   -DBOOST_ROOT=${Boost_home}
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${hepmc3_home}/../share/sources/examples/pythia8_ee_to_Z_to_tautau.conf .
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/generators/hepmc3/tests ./hepmc3_pythia8_test1
  ENVIRONMENT
    PYTHIA8DATA=${pythia8_home}/xmldoc
 )

endif()

#---pythia82------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia82
  IF <pythia82_<NATIVE_VERSION>_author> VERSION_EQUAL "HEAD" THEN
    SVN_REPOSITORY https://pythia8.hepforge.org/svn/pythia82/trunk
  ELSE
    URL ${gen_url}/pythia8<pythia82_<NATIVE_VERSION>_author>.tgz
  ENDIF
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc2=${HepMC_home} --with-lhapdf6=${lhapdf6_home} --with-boost=${Boost_home} --enable-shared
  BUILD_COMMAND ${MAKE}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf-${lhapdf6vers} Boost
)


#---vincia------------------------------------------------------------------------------------------

LCGPackage_Add(
  vincia
  IF <NATIVE_VERSION> VERSION_EQUAL "HEAD" THEN
    SVN_REPOSITORY https://vincia.hepforge.org/svn/trunk
  ELSE
    URL ${gen_url}/vincia-<NATIVE_VERSION>.tgz
  ENDIF
  UPDATE_COMMAND ${CMAKE_COMMAND} -DSRC=${CMAKE_CURRENT_SOURCE_DIR}/vincia/files -DDST=<SOURCE_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
-DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DPYTHIA8_ROOT_DIR=${pythia8_home}
-DROOTSYS=${ROOT_home} -DFASTJET_ROOT_DIR=${fastjet_home}

  DEPENDS ROOT pythia8 fastjet 
)

if (vincia_native_version)

LCG_add_test( vincia-pretest
    TEST_COMMAND ${CMAKE_COMMAND} -E copy_directory ${vincia_home}/tunes ${vincia_home}/bin/tunes
)

#foreach( vinciatest vincia01.exe vincia02.exe vincia03-root.exe vincia04-root.exe vincia05-root.exe vincia06.exe vincia07-root.exe vincia08-root.exe vincia09-root.exe vincia10-root.exe vincia_test_LHE.exe)
#  vincia02.exe vincia06.exe vincia07-root.exe vincia09-root.exe vincia_test_LHE.exe)
foreach( vinciatest vincia01.exe )
LCG_add_test(${vinciatest}
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${vincia_home}/bin/ ./${vinciatest} 
    ENVIRONMENT
    ${library_path}=${pythia8_home}/lib:${fastjet_home}/lib:${vincia_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
    VINCIADATA=${vincia_home}/settings/xmldoc
    DEPENDS vincia-pretest
)
endforeach()

endif()

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

foreach(v ${thepeg_native_version})
  LCG_add_test(thepeg-${v}.genser-scripts-setupThePEG
    PRE_COMMAND ${CMAKE_COMMAND} -E make_directory thepeg/${v}
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir thepeg/${v} $ENV{SHELL} -c "source ${thepeg-${v}_home}/thepegenv-genser.sh
      setupThePEG ${thepeg-${v}_home}/share/ThePEG/MultiLEP.in"
  )
  LCG_add_test(thepeg-${v}.genser-scripts-runThePEG
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir thepeg/${v} $ENV{SHELL} -c "source ${thepeg-${v}_home}/thepegenv-genser.sh
      runThePEG MultiLEP.run"
    POST_COMMAND ${CMAKE_COMMAND} -E chdir thepeg/${v} cat MultiLEP.out
    DEPENDS thepeg-${v}.genser-scripts-setupThePEG
  )
endforeach()

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
    BUILD_COMMAND ${MAKE} all ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${fastjet_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${fastjet_home}/lib
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib make ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${fastjet_home}/lib:$ENV{${library_path}} CPPFLAGS=-I${fastjet_home}/include LIBRARY_PATH=${fastjet_home}/lib
	        COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib/AlpGen 
                                   make BasicLesHouchesFileReader.so HERWIGINCLUDE=-I<SOURCE_DIR>/include 
                                                                     ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${herwig++_home}/lib/Herwig++:${fastjet_home}/lib:$ENV{${library_path}} CPPFLAGS=-I${fastjet_home}/include LIBRARY_PATH=${fastjet_home}/lib
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/Contrib/AlpGen 
                                   make AlpGenHandler.so HERWIGINCLUDE=-I<SOURCE_DIR>/include
                                   ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${herwig++_home}/lib/Herwig++:${fastjet_home}/lib:$ENV{${library_path}} CPPFLAGS=-I${fastjet_home}/include LIBRARY_PATH=${fastjet_home}/lib
    INSTALL_COMMAND make install ${library_path}=${thepeg_v_home}/lib/ThePEG:${GSL_home}/lib:${Boost_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${fastjet_home}/lib
            COMMAND  ${CMAKE_COMMAND} -E create_symlink herwig++ <INSTALL_DIR>/../../../herwigpp
            COMMAND  ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/Contrib/AlpGen/AlpGenHandler.so <INSTALL_DIR>/lib/Herwig++/	    
            COMMAND  ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/Contrib/AlpGen/BasicLesHouchesFileReader.so <INSTALL_DIR>/lib/Herwig++/ 
    BUILD_IN_SOURCE 1
    DEPENDS GSL Boost thepeg-<herwig++_<VERSION>_thepeg> fastjet
  )

foreach(v ${herwig++_native_version})
LCG_add_test(herwigpp-${v}.native-LHC 
			  TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${herwig++-${v}_home}/../share/sources/src/LHC.in 
			       COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N100 LHC.run -d1 
                          POST_COMMAND cat LHC.out
			       COMMAND cat LHC.log	
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})

LCG_add_test(herwigpp-${v}.native-TVT 
			  TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${herwig++-${v}_home}/../share/sources/src/TVT.in 
                               COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N100 TVT.run -d1 
                          POST_COMMAND cat TVT.out
                               COMMAND cat TVT.log  
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})

LCG_add_test(herwigpp-${v}.genser-LHC-W
  TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${CMAKE_SOURCE_DIR}/generators/herwig++/tests/LHC-W.in --repo=${herwig++-${v}_home}/share/Herwig++/HerwigDefaults.rpo
       COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N50 LHC-W.run -d1
  POST_COMMAND cat LHC-W.out
       COMMAND cat LHC-W.log
  BINARY_DIR herwig++/tests
  SOURCE_DIR herwig++/tests
  ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
  LHAPDF_DATA_PATH=${lhapdf_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
)

# native herwig++ tests (not all of them are run)

LCG_add_test(herwigpp-${v}.native-LEP-VV 
      TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests make -j1 test-LEP-VV REPO=${herwig++-${v}_home}/share/Herwig++/HerwigDefaults.rpo
           COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests cat LEP-VV.log       
      ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})
 
foreach(herwig-leptest LEP-VH LEP-VBF LEP-BB LEP-Quarks LEP-Leptons LEP-default LEP-Powheg)
LCG_add_test(herwigpp-${v}.native-${herwig-leptest}
      TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests make -j1 test-${herwig-leptest} REPO=${herwig++-${v}_home}/share/Herwig++/HerwigDefaults.rpo
           COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests cat ${herwig-leptest}.log       
      ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
      DEPENDS herwigpp-${v}.native-LEP-VV)
endforeach()
endforeach()



#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL ${gen_url}/TAUOLA.<NATIVE_VERSION>-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-pic --with-hepmc=${HepMC_home} --with-tau-spinner --with-lhapdf=${lhapdf_home} CFLAGS=-O2 CXXFLAGS=-O2 FFLAGS=-O2  F77=${CMAKE_Fortran_COMPILER}
  BUILD_COMMAND  make install CPATH=${Boost_home_include} 
          COMMAND  ${CMAKE_COMMAND} -E create_symlink tauola++ <INSTALL_DIR>/../../../tauolapp
#          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf
)

foreach(v ${tauola++_native_version})
LCG_add_test(tauolapp-${v}.build
  BINARY_DIR tauolapp/tests/${v}
  SOURCE_DIR tauolapp/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
   -DTAUOLAPP_ROOT_DIR=${tauola++-${v}_home}
   -DPYTHIA8_ROOT_DIR=${pythia8_home}
   -DHEPMC_ROOT_DIR=${HepMC_home})

foreach(i genser-test1 native-taumain_stand_alone native-taummk_pythia native-taumain_hepevt)
  LCG_add_test(tauolapp-${v}.${i}
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir tauolapp/tests/${v} ./${i}
    ENVIRONMENT PYTHIA8DATA=${pythia8_home}/xmldoc ${library_path}=${tauola++-${v}_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    DEPENDS tauolapp-${v}.build)
endforeach()

LCG_add_test(tauolapp-${v}.genser-test1-1_2000
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir tauolapp/tests/${v} ./genser-test1 1 2000
  ENVIRONMENT
    ${library_path}=${tauola++-${v}_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  POST_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c .
       COMMAND ${CMAKE_COMMAND} -E copy tauolapp/tests/${v}/testi.dat test_tauolapp.dat
       COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh tauolapp ${CMAKE_SOURCE_DIR}/generators/tauolapp/tests/reference.dat ${v} ${LCG_VERSION} ${LCG_platform}
  DEPENDS tauolapp-${v}.build
  
)
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

foreach(v ${pythia6_native_version})
LCG_add_test(pythia6-${v}.build
  BINARY_DIR pythia6/tests/${v}
  SOURCE_DIR pythia6/tests
  BUILD all
  BUILD_OPTIONS -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
                -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
                -DPYTHIA6_ROOT_DIR=${pythia6-${v}_home} -DHEPMC_ROOT_DIR=${HepMC_home}
                -DFASTJET_ROOT_DIR=${fastjet_home}
  ENVIRONMENT ${library_path}=${pythia6-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}})

LCG_add_test(pythia6-${v}.native-test
  TEST_COMMAND pythia6/tests/${v}/pythia6_orig_test1
  ENVIRONMENT ${library_path}=${pythia6-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
  DEPENDS pythia6-${v}.build)

LCG_add_test(pythia6-${v}.genser-test
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia6/tests/${v} ./pythia6_genser_test1
  POST_COMMAND ${CMAKE_COMMAND} -E chdir pythia6/tests/${v} ${CMAKE_COMMAND} -E copy testi_pythia6.dat test_pythia6.dat
  ENVIRONMENT ${library_path}=${pythia6-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
  DEPENDS pythia6-${v}.build
  )

LCG_add_test(pythia6-${v}.genser-compare
  PRE_COMMAND ${CMAKE_COMMAND} -E chdir pythia6/tests/${v} ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c .
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia6/tests/${v} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh pythia6 ${CMAKE_SOURCE_DIR}/generators/pythia6/tests/reference.dat ${v} ${LCG_VERSION} ${LCG_platform}
  DEPENDS pythia6-${v}.genser-test
  
)
endforeach()

#---agile------------------------------------------------------------------------------------------  
LCGPackage_Add(
  agile
  URL ${gen_url}/AGILe-<NATIVE_VERSION>.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
     --with-hepmc=${HepMC_home} 
     --with-boost-incpath=${Boost_home_include}
     --with-lcgtag=${LCG_platform}
     PYTHON=${Python_home}/bin/python 
     ${library_path}=${Python_home}/lib:${pcre_home}/lib:$ENV{${library_path}}
     SWIG=${swig_home}/bin/swig
     SWIG_LIB=${swig_home}/share/swig/${swig_author_version}
     "CFLAGS=-g0 -O2" "CXXFLAGS=-g0 -O2" "FFLAGS=-g0 -O2"
  BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:${pcre_home}/lib:$ENV{${library_path}} SWIG_LIB=${swig_home}/share/swig/${swig_author_version} LIBRARY_PATH=${Python_home}/lib
  INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:${pcre_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${Python_home}/lib
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/agileenv.csh <INSTALL_DIR>/.
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/agileenv.sh <INSTALL_DIR>/.
          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost Python swig
)

foreach(v ${agile_native_version})
LCG_add_test(agile-${v}.genser-scripts-pythia6
  TEST_COMMAND $ENV{SHELL} -c "source ${agile-${v}_home}/agileenv-genser.sh
    agile-runmc Pythia6:${pythia6_test_version} -o agile-scripts-hepmc-${v}.dat"
)

LCG_add_test(agile-${v}.native-test_pythia6 TEST_COMMAND ${agile-${v}_home}/bin/agile-runmc Pythia6:${pythia6_test_version} -o hepmcfile.dat
                              ENVIRONMENT PATH=${agile-${v}_home}/bin:${Python_home}/bin:$ENV{PATH}
                                          ${library_path}=${agile-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
                                          PYTHONPATH=${agile-${v}_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
                                          AGILE_GEN_PATH=${agile-${v}_home}/../../..
                              )
endforeach()

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

foreach(v ${photos_native_version})
LCG_add_test(photos-${v}.genser-test TEST_COMMAND photos/tests/${v}/photos_test1
                          BINARY_DIR photos/tests/${v}
                          SOURCE_DIR photos/tests
                          BUILD photos_test1
                          BUILD_OPTIONS -DPHOTOS_ROOT_DIR=${photos-${v}_home} 
                                        -DPYTHIA6_ROOT_DIR=${pythia6_home}
                                        -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
                          FAILREGEX "Fatal error"
                          ENVIRONMENT ${library_path}=${photos-${v}_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})
endforeach()

endif()

#---professor------------------------------------------------------------------------------------------

LCGPackage_Add(
  professor
  URL ${gen_url}/professor-<NATIVE_VERSION>.tar.bz2
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages 
		${Exec_cmd} ${library_path}=${ROOT_home}/lib:$ENV{${library_path}}
		${Python_cmd} setup.py build  -e "${env_cmd} python"

  INSTALL_COMMAND ${Exec_cmd} PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages 
		${Exec_cmd} ${library_path}=${ROOT_home}/lib:$ENV{${library_path}}
                ${Python_cmd} setup.py install --prefix <INSTALL_DIR> 

  BUILD_IN_SOURCE 1
  DEPENDS Python matplotlib pyminuit scipy 
)

foreach (v ${professor_native_version})
LCG_add_test(professor-${v}.genser-import
  TEST_COMMAND ${Python_cmd} -c "import professor.user as prof;"
  ENVIRONMENT PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages:${professor-${v}_home}/lib/python${Python_config_version_twodigit}/site-packages ${library_path}=${ROOT_home}/lib:$ENV{${library_path}}
)

LCG_add_test(professor-${v}.genser-executable
  TEST_COMMAND ${professor-${v}_home}/bin/prof-interpolate -h
  ENVIRONMENT PYTHONPATH=${pyanalysis_home}/lib/python${Python_config_version_twodigit}/site-packages:${professor-${v}_home}/lib/python${Python_config_version_twodigit}/site-packages ${library_path}=${ROOT_home}/lib:${Python_home}/lib:$ENV{${library_path}} PATH=${Python_home}/bin:$ENV{PATH}
)

LCG_add_test(professor-${v}.genser-scripts-executable
  TEST_COMMAND $ENV{SHELL} -c "source ${professor-${v}_home}/professorenv-genser.sh
               prof-interpolate -h"
)

endforeach()

#---pyquen--------------------------------------------------------------------------------------
LCGPackage_Add(
  pyquen
  DOWNLOAD_COMMAND ${CMAKE_COMMAND} -Durl=${gen_url}/pyquen<pyquen_<NATIVE_VERSION>_author>.f
                                    -Dsource_dir=<SOURCE_DIR>
                                    -P ${CMAKE_SOURCE_DIR}/cmake/scripts/DownloadURL.cmake
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/pyquen/files/CMakeLists.txt <SOURCE_DIR>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

foreach(v ${pyquen_native_version})
LCG_add_test(pyquen-${v}.genser-test1
  TEST_COMMAND pyquen/tests/${v}/pyquen_test1
  BINARY_DIR pyquen/tests/${v}
  SOURCE_DIR pyquen/tests
  BUILD pyquen_test1
  BUILD_OPTIONS
   -DPYQUEN_ROOT_DIR=${pyquen-${v}_home}
   -DPYTHIA6_ROOT_DIR=${pythia6_home}
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
  ENVIRONMENT ${library_path}=${pyquen-${v}_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})
endforeach()

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

foreach(v ${hydjet_native_version})
LCG_add_test(hydjet-${v}.genser-test
  TEST_COMMAND hydjet/tests/${v}/hydjet_test1
  BINARY_DIR hydjet/tests/${v}
  SOURCE_DIR hydjet/tests
  BUILD all
  BUILD_OPTIONS
   -DHYDJET_ROOT_DIR=${hydjet-${v}_home}
   -DPYTHIA6_ROOT_DIR=${pythia6_home}
   -DPYQUEN_ROOT_DIR=${pyquen_home}
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
  ENVIRONMENT ${library_path}=${hydjet-${v}_home}/lib:${pyquen_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})
endforeach()

#---photos++------------------------------------------------------------------------------------------
LCGPackage_Add(
  photos++
  URL ${gen_url}/PHOTOS.<photos++_<NATIVE_VERSION>_author>-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} CFLAGS=-O2 CXXFLAGS=-O2 FFLAGS=-O2 F77=${CMAKE_Fortran_COMPILER} 
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND  make install
          COMMAND  ${CMAKE_COMMAND} -E create_symlink photos++ <INSTALL_DIR>/../../../photospp
#          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  DEPENDS HepMC
)

foreach(v ${photos++_native_version})

 LCG_add_test(photospp-${v}.build
  BINARY_DIR photospp/tests/${v}
  SOURCE_DIR photospp/tests
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
   -DPHOTOSPP_ROOT_DIR=${photos++-${v}_home}
   -DPYTHIA8_ROOT_DIR=${pythia8_home}
   -DHEPMC_ROOT_DIR=${HepMC_home}
   -DCMAKE_BUILD_TYPE=Debug)

  LCG_add_test(photospp-${v}.native-photos_standalone
    PRE_COMMAND ${CMAKE_COMMAND} -E remove -f photos_standalone_example.dat
        COMMAND ${CMAKE_COMMAND} -E create_symlink ${photos++-${v}_home}/../share/sources/examples/photos_standalone_example.dat photos_standalone_example.dat
    TEST_COMMAND photospp/tests/${v}/native-photos_standalone
    ENVIRONMENT ${library_path}=${photos++-${v}_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    DEPENDS photospp-${v}.build)

 LCG_add_test(photospp-${v}.native-photos_hepevt
    TEST_COMMAND  ${CMAKE_COMMAND} -E chdir photospp/tests/${v} ./native-photos_hepevt
    ENVIRONMENT
      PYTHIA8DATA=${pythia8_home}/xmldoc 
      ${library_path}=${photos++-${v}_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    DEPENDS photospp-${v}.build)

 LCG_add_test(photospp-${v}.genser-test1
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir photospp/tests/${v} ./genser-test1
  ENVIRONMENT
    ${library_path}=${photos++-${v}_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  POST_COMMAND ${CMAKE_COMMAND} -E copy photospp/tests/${v}/testi.dat photospp/tests/${v}/test_photospp.dat
  DEPENDS photospp-${v}.build
  
 )

if ( NOT ${v} MATCHES "3.52")
 LCG_add_test(photospp-${v}.genser-test2
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir photospp/tests/${v} ./genser-test2
  ENVIRONMENT
    ${library_path}=${photos++-${v}_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  POST_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c photospp/tests/${v}/.
       COMMAND $ENV{SHELL} -c "cat photospp/tests/${v}/testi.dat >> photospp/tests/${v}/test_photospp.dat"
       COMMAND ${CMAKE_COMMAND} -E chdir photospp/tests/${v} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh photospp ${CMAKE_SOURCE_DIR}/generators/photospp/tests/reference.dat ${v} ${LCG_VERSION} ${LCG_platform}
  DEPENDS photospp-${v}.build photospp-${v}.genser-test1
  
 )
endif()

 LCG_add_test(photospp-${v}.genser-test3
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir photospp/tests/${v} ./genser-test3
  ENVIRONMENT
    ${library_path}=${photos++-${v}_home}/lib:${HepMC_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8_home}/xmldoc
  DEPENDS photospp-${v}.build
  
 )

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
LCG_add_test(evtgen-${version}.genser-test TEST_COMMAND evtgen-${version}/tests/evtgen_test1 ${evtgen-${version}_home}/share/DECAY_2010.DEC ${evtgen-${version}_home}/share/evt.pdl ${CMAKE_CURRENT_SOURCE_DIR}/evtgen/tests/DDALITZ.DEC 10000
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

foreach(version ${evtgen_native_version})
  LCG_add_test(evtgen-${version}.compare
    PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c .
        COMMAND ${CMAKE_COMMAND} -E copy evtgen-${version}/tests/testi.dat test_evtgen-${version}.dat
    TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh evtgen-${version} ${CMAKE_SOURCE_DIR}/generators/evtgen/tests/compare/reference.dat _ ${LCG_VERSION} ${LCG_platform}
    DEPENDS evtgen-${version}.genser-test
    
  )
endforeach()


set (yoda_convert_scripts "aida" "flat")
if (EXISTS "${ROOT_home}/")
  list(APPEND yoda_convert_scripts "root")
endif()
foreach(v ${yoda_native_version})
  foreach(f ${yoda_convert_scripts})
  LCG_add_test(yoda-${v}.genser-scripts-yoda2${f}
    PRE_COMMAND ${CMAKE_COMMAND} -E make_directory yoda/tests/${v}
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir yoda/tests/${v} $ENV{SHELL} -c "source ${yoda-${v}_home}/yodaenv-genser.sh
      yoda2${f} ${CMAKE_SOURCE_DIR}/generators/reference/sherpa_riv2.yoda"
  )
  endforeach()
endforeach()


#---Rivet-----------------------------------------------------------------------------------------

set(yoda_rivet_home <yoda-<rivet_<NATIVE_VERSION>_yoda>_home>)

LCGPackage_Add(
  rivet
  URL ${gen_url}/Rivet-<VERSION>.tar.bz2
  IF <VERSION> VERSION_LESS 2.0.0 THEN
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
       --with-hepmc=${HepMC_home}
       --with-boost-incpath=${Boost_home_include}
       --with-fastjet=${fastjet_home}
       --with-gsl=${GSL_home}
       --with-lcgtag=${LCG_platform}
       --disable-pdfmanual
       --enable-unvalidated
       PYTHON=${Python_home}/bin/python 
       ${library_path}=${Python_home}/lib:${pcre_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
       SWIG=${swig_home}/bin/swig
       CC=${CMAKE_C_COMPILER}
       CXX=${CMAKE_CXX_COMPILER}
       CFLAGS=-O2
       SWIG_LIB=${swig_home}/share/swig/${swig_author_version}
    BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:${pcre_home}/lib:${GSL_home}/lib:$ENV{${library_path}} SWIG_LIB=${swig_home}/share/swig/${swig_author_version} LIBRARY_PATH=${Python_home}/lib:${GSL_home}/lib
    INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:${pcre_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${Python_home}/lib:${GSL_home}/lib
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
            COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
            COMMAND ${CMAKE_COMMAND} -E create_symlink ${LCG_platform} <INSTALL_DIR>/../${LCG_platform_dbg}
  ELSE
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
       --with-hepmc=${HepMC_home}
       --with-boost=${Boost_home_include}
       --with-fastjet=${fastjet_home}
       --with-yoda=${yoda_rivet_home}
       --with-yaml-cpp=${yamlcpp_home}
       --with-gsl=${GSL_home}
       --with-lcgtag=${LCG_platform}
       --disable-pdfmanual
       --enable-unvalidated
       PYTHON=${Python_home}/bin/python
       PYTHONPATH=${cython_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
       ${library_path}=${Python_home}/lib:${pcre_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
       CC=${CMAKE_C_COMPILER}
       CXX=${CMAKE_CXX_COMPILER}
       SWIG_LIB=${swig_home}/share/swig/${swig_author_version}
    BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:${pcre_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}} PYTHONPATH=${cython_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH} SWIG_LIB=${swig_home}/share/swig/${swig_author_version} LIBRARY_PATH=${Python_home}/lib:${GSL_home}/lib
    INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:${pcre_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
                    PYTHONPATH=${cython_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
                    LIBRARY_PATH=${Python_home}/lib:${GSL_home}/lib
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.csh <INSTALL_DIR>/
            COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/rivetenv.sh <INSTALL_DIR>/
            COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  ENDIF
  BUILD_IN_SOURCE 1
  DEPENDS HepMC Boost fastjet GSL Python swig
  IF NOT <VERSION> VERSION_LESS 2.0.0 THEN
    yoda-<rivet_<VERSION>_yoda> yamlcpp
  ENDIF
)

foreach(v ${rivet_native_version})
if (${v} MATCHES "^2.[.]*")

LCG_add_test(
       rivet-${v}.genser-atlas
       TEST_COMMAND  ${rivet-${v}_home}/bin/rivet --ignore-beams -a ATLAS_2012_I1083318 ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc
       ENVIRONMENT ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet-${v}_home}/lib:${yoda-${rivet_${v}_yoda}_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
                   PATH=${Python_home}/bin:$ENV{PATH}
)

LCG_add_test(
       rivet-${v}.genser-atlas_script
       TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv.${shell_ext}
                    rivet --ignore-beams -a ATLAS_2012_I1083318 ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc"
       ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
                   ${library_path}=${Python_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
)
else()
LCG_add_test(rivet-${v}.native-MC_DIJET
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv.${shell_ext}
               rivet --analysis=MC_DIJET ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc"
  ENVIRONMENT
    ${library_path}=${GSL_home}/lib:$ENV{${library_path}}
    PATH=${Python_home}/bin:$ENV{PATH}
)
endif()

LCG_add_test(rivet-${v}.genser-scripts-source
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh"
)
LCG_add_test(rivet-${v}.genser-scripts-mkanalysis
  TEST_COMMAND ${SH_SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh
      rivet-mkanalysis ATLAS_2010_S8591806"
)
LCG_add_test(rivet-${v}.genser-scripts-buildplugin
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh
      rivet-buildplugin RivetATLAS_2010_S8591806.so ATLAS_2010_S8591806.cc"
  DEPENDS rivet-${v}.genser-scripts-mkanalysis
)
LCG_add_test(rivet-${v}.genser-scripts-findid
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh
      rivet-findid 1003.0694"
)
LCG_add_test(rivet-${v}.genser-scripts-which
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh
      which rivet-which && rivet-which ATLAS_2010_S8591806* || echo rivet-which is not available for this rivet version"
)
LCG_add_test(rivet-${v}.genser-scripts-rivet
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh
      rivet -a MC_WJETS -H data-${v}.yoda ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc"
)
LCG_add_test(rivet-${v}.genser-scripts-rivet-mkhtml
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh
      rivet-mkhtml -o rivet-mkhtml-${v} ${CMAKE_SOURCE_DIR}/generators/reference/pythia6_riv2_zjets.yoda ${CMAKE_SOURCE_DIR}/generators/reference/pythia8_riv2_zjets.yoda"
)

endforeach()

#---QD------------------------------------------------------------------------------------------
LCGPackage_Add(
  qd
 URL ${gen_url}/qd-${qd_native_version}.tar.gz
 UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/qd-<NATIVE_VERSION> <SOURCE_DIR>
 COMMAND ${CMAKE_COMMAND} -E remove_directory <SOURCE_DIR>/<NATIVE_VERSION>

  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --enable-shared

  INSTALL_COMMAND make install 

  BUILD_IN_SOURCE 1
  DEPENDS Python
)


#---BlackHat------------------------------------------------------------------------------------------
LCGPackage_Add(
  blackhat
  URL ${gen_url}/blackhat-${blackhat_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-QDpath=${qd_home} "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0"  
  PYTHON=${Python_home}/bin/python
  ${library_path}=${Python_home}/lib:$ENV{${library_path}}
  PYTHONPATH=${Python_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
  INSTALL_COMMAND make install "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0"
  
  BUILD_IN_SOURCE 1
  DEPENDS qd
)


#---Sherpa------------------------------------------------------------------------------------------
LCGPackage_Add(
  sherpa
  URL ${gen_url}/SHERPA-MC-<sherpa_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=${lhapdf_home}
     --enable-hepmc2=${HepMC_home}
     --enable-openloops=.
     --enable-lhole
     --with-sqlite3=${sqlite_home}  "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0"
#Boost includes below are necessary only for sherpa 1 series
  BUILD_COMMAND ${MAKE} LIBRARY_PATH=${lhapdf_home}/lib CPPFLAGS=-I${Boost_home_include} CPATH=${Boost_home_include} 
  INSTALL_COMMAND make install LIBRARY_PATH=${lhapdf_home}/lib
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf HepMC sqlite
)

#---Sherpa with MPI support------------------------------------------------------------------------------------------
LCGPackage_Add(
  sherpa-openmpi
  URL ${gen_url}/SHERPA-MC-<sherpa-openmpi_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa-openmpi_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=${lhapdf_home}
     --enable-hepmc2=${HepMC_home}
     --enable-blackhat=${blackhat_home}
     --enable-openloops=.
     --enable-lhole
     --enable-mpi
     --with-sqlite3=${sqlite_home}  "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0" PATH=${openmpi_home}/bin:$ENV{PATH} ${library_path}=${openmpi_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${openmpi_home}/lib
  BUILD_COMMAND ${MAKE} PATH=${openmpi_home}/bin:$ENV{PATH} LIBRARY_PATH=${lhapdf_home}/lib ${library_path}=${openmpi_home}/lib:${blackhat_home}/lib:$ENV{${library_path}} CPPFLAGS=-I${Boost_home_include}
  INSTALL_COMMAND make install LIBRARY_PATH=${lhapdf_home}/lib PATH=${openmpi_home}/bin:$ENV{PATH} LIBRARY_PATH=${lhapdf_home}/lib ${library_path}=${openmpi_home}/lib:${blackhat_home}/lib:$ENV{${library_path}}
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf HepMC sqlite openmpi blackhat
)


LCGPackage_Add(
  sherpa-mpich2
  URL ${gen_url}/SHERPA-MC-<sherpa-mpich2_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa-mpich2_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=${lhapdf_home}
     --enable-hepmc2=${HepMC_home}
     --enable-blackhat=${blackhat_home}
     --enable-openloops=.
     --enable-lhole
     --enable-mpi
     --with-sqlite3=${sqlite_home} "CFLAGS=-O2 -g0 -fPIC" "CXXFLAGS=-O2 -g0 -fPIC" "FFLAGS=-O2 -g0 -fPIC" PATH=${mpich2_home}/bin:$ENV{PATH} ${library_path}=${mpich2_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${mpich2_home}/lib
  BUILD_COMMAND ${MAKE} PATH=${mpich2_home}/bin:$ENV{PATH} LIBRARY_PATH=${lhapdf_home}/lib ${library_path}=${mpich2_home}/lib:${blackhat_home}/lib:$ENV{${library_path}} CPPFLAGS=-I${Boost_home_include}
  INSTALL_COMMAND make install LIBRARY_PATH=${lhapdf_home}/lib PATH=${mpich2_home}/bin:$ENV{PATH} ${library_path}=${mpich2_home}/lib:${blackhat_home}/lib:$ENV{${library_path}} 
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf HepMC sqlite mpich2 blackhat
)


# $PWD is needed because Sherpa uses this variable to know current directory
foreach(v ${sherpa_native_version})
LCG_add_test(sherpa-${v}.native-LHC_Z
  PRE_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa/native-LHC_Z/${v}
      COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/native-LHC_Z/${v}
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/native-LHC_Z/${v} ${sherpa-${v}_home}/bin/Sherpa -j20 -f ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_Z.dat
  ENVIRONMENT
    ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${sqlite_home}/lib:$ENV{${library_path}}
    PATH=${sqlite_home}/bin:$ENV{PATH}
    PWD=.
)

LCG_add_test(sherpa-${v}.native-LHC_ZJets
  PRE_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa/native-LHC_ZJets/${v}
      COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/native-LHC_ZJets/${v}
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/native-LHC_ZJets/${v} ${sherpa-${v}_home}/bin/Sherpa -j20 -f ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_ZJets.dat
  ENVIRONMENT
    ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${sqlite_home}/lib:$ENV{${library_path}}
    PATH=${sqlite_home}/bin:$ENV{PATH}
    PWD=.
  
)
endforeach()

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

foreach(v ${hepmcanalysis_native_version})
LCG_add_test(hepmcanalysis-${v}.build
  BINARY_DIR hepmcanalysis/tests/${v}
  SOURCE_DIR hepmcanalysis/tests  
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_SEARCHPATH1=${CMAKE_SOURCE_DIR}/cmake/modules
   -DCMAKE_MODULE_SEARCHPATH2=${cmaketools_home}/modules
   -DHEPMCANALYSIS_ROOT_DIR=${hepmcanalysis-${v}_home}
   -DPYTHIA6_ROOT_DIR=${pythia6_home}
   -DHEPMC_ROOT_DIR=${HepMC_home}
   -DFASTJET_ROOT_DIR=${fastjet_home}
   -DROOTSYS=${ROOT_home}
   -DLHAPDF_ROOT_DIR=${lhapdf_home}
   -DCLHEP_ROOT_DIR=${CLHEP_home}	
  ENVIRONMENT ${library_path}=${ROOT_home}/lib:${fastjet_home}/lib:${CLHEP_home}/lib:${HepMC_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})
 

LCG_add_test(hepmcanalysis-${v}.native-pythia6
   TEST_COMMAND hepmcanalysis/tests/${v}/native-pythia6 ${hepmcanalysis-${v}_home}/../share/sources/examples/pythia6/Process.config
   DEPENDS hepmcanalysis-${v}.build
   ENVIRONMENT ${library_path}=${hepmcanalysis-${v}_home}/lib:${ROOT_home}/lib:${fastjet_home}/lib:${CLHEP_home}/lib:${HepMC_home}/lib:${pythia6_home}/lib:$ENV{${library_path}}
)
    
LCG_add_test(hepmcanalysis-${v}.native-hepmcreader
    BINARY_DIR hepmcanalysis/tests/${v}
    PRE_COMMAND ${CMAKE_COMMAND} -E create_symlink ${hepmcanalysis-${v}_home}/../share/sources/examples/hepmcreader/Process.config Process.config
        COMMAND ${CMAKE_COMMAND} -E create_symlink ${CMAKE_SOURCE_DIR}/generators/rivet/tests/data.hepmc sample1.input
    TEST_COMMAND hepmcanalysis/tests/${v}/native-hepmcreader Process.config
    DEPENDS hepmcanalysis-${v}.build
    ENVIRONMENT ${library_path}=${hepmcanalysis-${v}_home}/lib:${ROOT_home}/lib:${fastjet_home}/lib:${CLHEP_home}/lib:${HepMC_home}/lib:${pythia6_home}/lib:$ENV{${library_path}}
)
endforeach()



#---MC-TESTER----------------------------------------------------------------------------------------
LCGPackage_Add(mctester
  URL ${gen_url}/MC-TESTER-${mctester_native_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E touch make.inc 
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-HepMC=${HepMC_home} --with-root=${ROOT_home}/bin "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0"
  BUILD_COMMAND ${MAKE} -j1 ${library_path}=${ROOT_home}/lib:$ENV{${library_path}} ROOTSYS=${ROOT_home}
  INSTALL_COMMAND make -j1 install 
#          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  BUILD_IN_SOURCE 1
  DEPENDS HepMC ROOT
)

foreach(v ${mctester_native_version})
LCG_add_test(mctester-${v}.build
  BINARY_DIR mctester/tests/${v}
  SOURCE_DIR mctester/tests  
  BUILD all
  BUILD_OPTIONS
   -DCMAKE_MODULE_SEARCHPATH1=${CMAKE_SOURCE_DIR}/cmake/modules
   -DCMAKE_MODULE_SEARCHPATH2=${cmaketools_home}/modules
   -DMCTESTER_ROOT_DIR=${mctester-${v}_home}
   -DPYTHIA8_ROOT_DIR=${pythia8_home}
   -DHEPMC_ROOT_DIR=${HepMC_home}
   -DROOTSYS=${ROOT_home}
   ENVIRONMENT ${library_path}=${mctester-${v}_home}/lib:${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}})
  
LCG_add_test(mctester-${v}.native-pythia
    BINARY_DIR mctester/tests/${v}
    PRE_COMMAND ${CMAKE_COMMAND} -E create_symlink ${mctester-${v}_home}/../share/sources/examples-C++/pythia/SETUP.C SETUP.C
    TEST_COMMAND mctester/tests/${v}/mctester_test_pyt8
    ENVIRONMENT ${library_path}=${ROOT_home}/lib:${mctester-${v}_home}/lib:${pythia8_home}/lib:${HepMC_home}/lib:$ENV{${library_path}} 
                PYTHIA8DATA=${pythia8_home}/xmldoc
    DEPENDS mctester-${v}.build
  	)
    
endforeach()

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

foreach(v ${hijing_native_version})
LCG_add_test(hijing-${v}.native-example1-nopause TEST_COMMAND hijing/tests/${v}/hijing_orig_example1-nopause
                          BINARY_DIR hijing/tests/${v}
                          SOURCE_DIR hijing/tests
                          BUILD hijing_orig_example1-nopause
                          BUILD_OPTIONS -DHIJING_ROOT_DIR=${hijing-${v}_home} 
                                        -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
                          ENVIRONMENT ${library_path}=${hijing-${v}_home}/lib:$ENV{${library_path}})
endforeach()

endif()

#---Starlight---------------------------------------------------------------------------------------
string(SUBSTRING ${starlight_native_version} 1 -1 STARLIGHT_REV)
LCGPackage_Add(
  starlight
  URL ${gen_url}/starlight-r${STARLIGHT_REV}.tgz
  UPDATE_COMMAND <VOID>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

foreach(v ${starlight_native_version})
LCG_add_test(starlight-${v}.native-slight
  PRE_COMMAND ${CMAKE_COMMAND} -E remove -f slight.in
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${starlight-${v}_home}/../share/sources/config/slight.in.new slight.in
  TEST_COMMAND ${starlight-${v}_home}/bin/starlight)
endforeach()

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

foreach(v ${tauola_native_version})
  LCG_add_test(tauola-${v}.genser-test TEST_COMMAND tauola/tests/${v}/tauola_test1
                          BINARY_DIR tauola/tests/${v}
                          SOURCE_DIR tauola/tests
                          BUILD tauola_test1
                          BUILD_OPTIONS -DTAUOLA_ROOT_DIR=${tauola-${v}_home} 
                                        -DPHOTOS_ROOT_DIR=${photos_home} 
                                        -DPYTHIA6_ROOT_DIR=${pythia6_home}
                                        -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
                          ENVIRONMENT ${library_path}=${tauola-${v}_home}/lib:${photos_home}/lib:${pythia6_home}/lib:$ENV{${library_path}})
endforeach()

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

foreach(v ${alpgen_native_version})
LCG_add_test(
  alpgen-${v}.native-examples
  PRE_COMMAND ${CMAKE_COMMAND} -E remove_directory tmpalpgen
      COMMAND ${CMAKE_COMMAND} -E make_directory tmpalpgen/examples-${v}
      COMMAND ${CMAKE_COMMAND} -E copy_directory ${alpgen-${v}_home}/../share/sources/examples tmpalpgen/examples-${v}
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/alpgen/tests/inputalpgen tmpalpgen/examples-${v}
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/alpgen/tests/inputalpgen2 tmpalpgen/examples-${v}
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/alpgen/tests/inputalpgen3 tmpalpgen/examples-${v}
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir tmpalpgen/examples-${v} $ENV{SHELL} -c "./configure_simple --with-alpgeninstalled=${alpgen-${v}_home}/../share/sources --with-alpgenlibs=${alpgen-${v}_home}/lib/archive
               make -f Makefile_simple zjet
               ./zjetgen.exe < inputalpgen
               ./zjetgen.exe < inputalpgen2"
)
endforeach()

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
foreach(v ${crmcold_native_version})
  if(NOT ${crmcold-${v}_home} STREQUAL "")
    LCG_add_test(crmcold-${v}.genser-scripts
      TEST_COMMAND $ENV{SHELL} -c "source ${crmcold-${v}_home}/crmcoldenv-genser.sh
        crmc -T 1 -c ${crmcold-${v}_home}/crmc.param"
    )
    LCG_add_test(crmcold-${v}.native-crmc
      TEST_COMMAND ${crmcold-${v}_home}/bin/crmc -T 1 -c ${crmcold-${v}_home}/crmc.param
      ENVIRONMENT ${library_path}=${HepMC_home}/lib:$ENV{${library_path}}
    )
  endif()
endforeach()
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
               -DBOOST_INCLUDEDIR=${Boost_home_include}
               -DBoost_NO_SYSTEM_PATHS=TRUE
     IF <NATIVE_VERSION> VERSION_GREATER 1.3 THEN
               -D__PYTHIA__=ON -D__SIBYLL__=ON  -D__PHOJET__=ON
               -D__DPMJET__=ON -D__QGSJETII04__=ON
     ENDIF
    DEPENDS HepMC Boost ROOT
  )
  
foreach(v ${crmc_native_version})
  LCG_add_test(crmc-${v}.genser-scripts
    TEST_COMMAND $ENV{SHELL} -c "source ${crmc-${v}_home}/crmcenv-genser.sh
      crmc -T 1 -c ${crmc-${v}_home}/crmc.param"
  )
  LCG_add_test(crmc-${v}.native-crmc
    TEST_COMMAND ${crmc-${v}_home}/bin/crmc -T 1 -c ${crmc-${v}_home}/crmc.param
    ENVIRONMENT ${library_path}=${crmc-${v}_home}/lib:${ROOT_home}/lib:${HepMC_home}/lib:${Boost_home}/lib:$ENV{${library_path}}	
  )
endforeach()
endif()

#---powheg-box--------------------------------------------------------------------------------------
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
  BUILD_COMMAND ${MAKE} CPATH=${Boost_home_include} 
  BUILD_IN_SOURCE 1
  DEPENDS fastjet lhapdf
 )

foreach(v ${powheg-box_native_version})
# WZ, Wp_Wp_J_J, VBF_Wp_Wp are skiped - example steering files do not work
foreach(i WW HJ W_ew-BW Wbb Wj HJJ ZZ W_ew-BMNNP Dijet gg_H VBF_H Z W hvq Zj ST_sch ST_tch ST_tch_4f)
  LCG_add_test(powheg-box-${v}.native-${i}
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/tests/runtest.sh ${powheg-box-${v}_home}/bin ${powheg-box-${v}_home}/../share/sources ${i}
    ENVIRONMENT
      ${library_path}=${lhapdf5_home}/lib:${fastjet_home}/lib:$ENV{${library_path}}
      LHAPATH=${lhapdfsets_home}/../share/PDFsets
      LHAPDF_DATA_PATH=${lhapdf_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
  )
endforeach()
endforeach()
endif()

#---sacrifice------------------------------------------------------------------------------------------

set(pythia8_sacrifice_home <pythia8-<sacrifice_<NATIVE_VERSION>_pythia8>_home>)

LCGPackage_Add(
  sacrifice
  URL ${gen_url}/Sacrifice-${sacrifice_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
		--with-HepMC=${HepMC_home} --with-pythia=${pythia8_sacrifice_home}
                --with-LHAPDF=${lhapdf_home} --with-photos=${photos++_home}
                --with-boost=${Boost_home} --with-MCUtils
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND ${MAKE} install 
  BUILD_IN_SOURCE 1
  DEPENDS pythia8-<sacrifice_<VERSION>_pythia8>  Boost HepMC lhapdf photos++
)

foreach(v ${sacrifice_native_version})
LCG_add_test(sacrifice-${v}.genser-scripts
  TEST_COMMAND ${SH_SHELL} -c "source ${sacrifice-${v}_home}/sacrificeenv-genser.sh
    run-pythia  --collision-energy 8000 -i ${CMAKE_SOURCE_DIR}/generators/sacrifice/AU2-CT10.params -n 1000 --photos"
  ENVIRONMENT LHAPDF_DATA_PATH=${lhapdf_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
)

LCG_add_test(sacrifice-${v}.genser-AU2-CT10
   TEST_COMMAND ${sacrifice-${v}_home}/bin/run-pythia  --collision-energy 8000 -i ${CMAKE_SOURCE_DIR}/generators/sacrifice/AU2-CT10.params -n 1000 --photos 
   ENVIRONMENT ${library_path}=${photos++_home}/lib:${lhapdf_home}/lib:${HepMC_home}/lib:${pythia8-${sacrifice_${v}_pythia8}_home}/lib:$ENV{${library_path}}
	       LHAPATH=${lhapdfsets_home}/../share/lhapdf/PDFsets
               LHAPDF_DATA_PATH=${lhapdf_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
   )
endforeach()




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


#--- MadGraph5aMCatNLO -------------------------------------------------------------------------------
LCGPackage_Add(
  madgraph5amc
#  URL https://launchpad.net/mg5amcnlo/2.0/2.1.0/+download/MG5_aMC_v<NATIVE_VERSION>.tar.gz
  URL ${gen_url}/MG5_aMC_v<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${MAKE} -j1 -C vendor/CutTools
        COMMAND ${MAKE} -j1 -C vendor/StdHEP
  INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
          COMMAND ${CMAKE_COMMAND} -E copy <INSTALL_DIR>/doc.tgz <INSTALL_DIR>/../share/
          COMMAND ${CMAKE_COMMAND} -E remove <INSTALL_DIR>/doc.tgz
          COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/doc
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

if (madgraph5amc_native_version)

LCG_add_test(madgraph5amc_copy
  TEST_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/generators/mgcopy
       COMMAND ${CMAKE_COMMAND} -E copy_directory ${madgraph5amc_home} ${CMAKE_BINARY_DIR}/generators/mgcopy
)         

#LCG_add_test(madgraph5amc_testmanager
#  TEST_COMMAND ${Python_cmd} ${CMAKE_BINARY_DIR}/generators/mgcopy/tests/test_manager.py
#  DEPENDS madgraph5amc_copy
#)

LCG_add_test(madgraph5amc_zjetsLO
  TEST_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/generators/mgwork
       COMMAND $ENV{SHELL} -c "cd ${CMAKE_BINARY_DIR}/generators/mgwork
           ${CMAKE_BINARY_DIR}/generators/mgcopy/bin/mg5_aMC ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/tests/cardsLO.dat
           ${CMAKE_BINARY_DIR}/generators/mgwork/MYPROC/bin/generate_events"
  DEPENDS madgraph5amc_copy
)

LCG_add_test(madgraph5amc_zjetsLO_hadronize
  PRE_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8_test2.cmnd ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/generators/mgwork/MYPROC/Events/run_01/unweighted_events.lhe.gz ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization/Zg_pythia8_mg.lhe.gz
      COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization/Zg_pythia8_mg.lhe
      COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization gunzip Zg_pythia8_mg.lhe.gz
      COMMAND $ENV{SHELL} -c "cat ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization/Zg_pythia8_mg.lhe | sed '/LesHouchesEvents/s/3.0/1.0/' > ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization/Zg_pythia8.lhe"
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization ${CMAKE_BINARY_DIR}/generators/pythia8/tests/${pythia8_work_version}/pythia8_genser_test2
  ENVIRONMENT
    ${library_path}=${pythia8-${pythia8_work_version}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    PYTHIA8DATA=${pythia8-${pythia8_work_version}_home}/xmldoc
  DEPENDS pythia8-${pythia8_work_version}.build madgraph5amc_zjetsLO
)

#substitute {madgraph5amc_native_version} below by {v} when there will be several versions
LCG_add_test(madgraph5amc_compare
  TEST_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization/.
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization/testi_pythia8.dat ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization/test_madgraph5amc.dat
       COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/generators/mgwork/hadronization ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh madgraph5amc ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/tests/reference.dat ${madgraph5amc_native_version} ${LCG_VERSION} ${LCG_platform}
  DEPENDS madgraph5amc_zjetsLO_hadronize
)

endif()

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

foreach(v ${jhu_native_version})
LCG_add_test(jhu-${v}.genser-scripts
  TEST_COMMAND $ENV{SHELL} -c "source ${jhu-${v}_home}/jhuenv-genser.sh
    cd \$JHU_HOME
    JHUGen VegasNc0=100000 VegasNc1=500000 VegasNc2=100"
)

LCG_add_test(jhu-${v}.native-JHUGen
  PRE_COMMAND ${CMAKE_COMMAND} -E remove -f pdfs
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${jhu-${v}_home}/pdfs pdfs
  TEST_COMMAND ${jhu-${v}_home}/bin/JHUGen VegasNc0=100000 VegasNc1=500000 VegasNc2=100)

LCG_add_test(jhu-${v}.native-testF
  TEST_COMMAND ${jhu-${v}_home}/bin/testF)

LCG_add_test(jhu-${v}.native-testC
  TEST_COMMAND ${jhu-${v}_home}/bin/testC)
endforeach()


#--- fastnlo_toolkit -------------------------------------------------------------------------------
LCGPackage_Add(
  fastnlo_toolkit
  URL ${gen_url}/fastnlo_toolkit-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND ./configure
      --prefix=<INSTALL_DIR>
  #   LHAPDF5 is used, LHAPDF6 not yet possible because of no possibility to specify Boost includes
  #   In addition, the explicit LHAPDF5 PDF set file name is used in the test below
      --with-lhapdf=${lhapdf_home}
      --with-fastjet=${fastjet_home}
      --with-yoda=${yoda_home}
  #    --enable-pyext   # need to specify swig package if this option is switched on!
  BUILD_COMMAND ${MAKE} CPATH=${Boost_home_include} 
  INSTALL_COMMAND ${MAKE} install
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf yoda fastjet
)

# List of .tab files is available on http://fastnlo.hepforge.org/scenarios/tables-lhc.html
if (UNIX AND fastnlo_toolkit_native_version)
# CMS inclusive forward jets 2011 (anti-kT R=0.5; pT, eta); LO, NLO; RIVET_ID: CMS_2012_I1087342
set(fastnlo_toolkit_tabfile "fnl2222b_I1087342.tab")
LCG_add_test(fastnlo_toolkit.download
  TEST_COMMAND $ENV{SHELL} -c "wget -q -O ${fastnlo_toolkit_tabfile}.gz http://fastnlo.hepforge.org/scenarios/tables-v21/${fastnlo_toolkit_tabfile}.gz
              gzip -df ${fastnlo_toolkit_tabfile}.gz")
foreach(v ${fastnlo_toolkit_native_version})
  foreach(fnlotest "example" "yodaout")
  LCG_add_test(fastnlo_toolkit-${v}.native-fnlo-tk-${fnlotest}
    TEST_COMMAND $ENV{SHELL} -c "source ${fastnlo_toolkit-${v}_home}/fastnlo_toolkitenv-genser.sh
              fnlo-tk-${fnlotest} ${fastnlo_toolkit_tabfile}"
  DEPENDS fastnlo_toolkit.download)
  endforeach()
LCG_add_test(fastnlo_toolkit-${v}.native-fnlo-tk-cppread
  TEST_COMMAND $ENV{SHELL} -c "source ${fastnlo_toolkit-${v}_home}/fastnlo_toolkitenv-genser.sh
              fnlo-tk-cppread ${fastnlo_toolkit_tabfile} ${lhapdfsets_home}/../share/PDFsets/CT10nnlo.LHgrid"
  DEPENDS fastnlo_toolkit.download)
endforeach()
endif()


### tests of generators using rivet 2

LCG_add_test(rivet-tests.genser-buildanalysis
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet2_home}/rivetenv.${shell_ext}
         rivet-buildplugin RivetGENSER_MC_ZJETS.so ${CMAKE_SOURCE_DIR}/generators/rivetgenser/GENSER_MC_ZJETS.cc"
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/rivetgenser/GENSER_MC_ZJETS.info ${CMAKE_BINARY_DIR}/generators
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/rivetgenser/GENSER_MC_ZJETS.plot ${CMAKE_BINARY_DIR}/generators
  ENVIRONMENT
    ${library_path}=${GSL_home}/lib:$ENV{${library_path}}
    PATH=${Python_home}/bin:$ENV{PATH}
)

foreach(v ${pythia8_native_version})
string(REGEX MATCH "[0-9][0-9][0-9]" v_test_version ${v})
LCG_add_test(
  pythia8-${v}.genser-zjetsgenser-rivet
  PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8-zjets-rivet.params | sed \"s/Main:numberOfEvents.*/Main:numberOfEvents = ${rivettests_stat_size}/g\" | cat > ${CMAKE_BINARY_DIR}/generators/pythia8/tests/pythia8-${v}.zjetsgenser-rivet.params"
  TEST_COMMAND ${CMAKE_BINARY_DIR}/generators/pythia8/tests/${v}/pythia8 ${CMAKE_BINARY_DIR}/generators/pythia8/tests/pythia8-${v}.zjetsgenser-rivet.params pythia8-${v}.genser-zjetsgenser.hempc.dat
       COMMAND ${rivet2_home}/bin/rivet --show-analysis GENSER_MC_ZJETS
       COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a GENSER_MC_ZJETS --histo-file=pythia8-${v}.genser-zjetsgenser-rivet.yoda pythia8-${v}.genser-zjetsgenser.hempc.dat
  ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
              RIVET_ANALYSIS_PATH=${CMAKE_BINARY_DIR}/generators
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia8-${v}.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} pythia8 ${v_test_version} zjetsgenser ${LCG_VERSION} ${LCG_platform}
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjetsgenser-rivet.root ${CMAKE_BINARY_DIR}/generators/pythia8-${v}.genser-zjetsgenser-rivet.root "Path=XS,Z_pt,jet_mult,jet_mult_norm" "limit=0.05,0.1,0.1,0.1"
  TIMEOUT ${timeout}
  DEPENDS rivet-tests.genser-prepare_references rivet-tests.genser-buildanalysis pythia8-${v}.build
)
endforeach()

foreach(v ${pythia8_native_version})
string(REGEX MATCH "[0-9][0-9][0-9]" v_test_version ${v})
LCG_add_test(
  pythia8-${v}.genser-zjets-rivet
  PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8-zjets-rivet.params | sed \"s/Main:numberOfEvents.*/Main:numberOfEvents = ${rivettests_stat_size}/g\" | cat > ${CMAKE_BINARY_DIR}/generators/pythia8/tests/pythia8-${v}.zjets-rivet.params"
  TEST_COMMAND ${CMAKE_BINARY_DIR}/generators/pythia8/tests/${v}/pythia8 ${CMAKE_BINARY_DIR}/generators/pythia8/tests/pythia8-${v}.zjets-rivet.params pythia8-${v}.genser-zjets.hempc.dat
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS --histo-file=pythia8-${v}.genser-zjets-rivet.yoda pythia8-${v}.genser-zjets.hempc.dat
  ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
                   ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
                   PYTHONPATH=${Python_home}/bin:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
            PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia8-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} pythia8 ${v_test_version} zjets ${LCG_VERSION} ${LCG_platform}
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/pythia8-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.05,0.10"
  TIMEOUT ${timeout}
  DEPENDS rivet-tests.genser-prepare_references pythia8-${v}.build
)
#I cannot pass the command below because of quotes. In addition it requires to have ${rivet2_home}/bin in the path
#rivet-mkhtml -o pythia8html -s --mc-errs pythia8_riv2.yoda:'Title=Reference' pythia8_riv2_i.yoda:'LineColor=blue'
endforeach()

### PYTHIA 6 RIVET TESTS
foreach (v ${pythia6_native_version})
string(REGEX MATCH "[0-9][0-9][0-9]" v_test_version ${v})
LCG_add_test(
  pythia6-${v}.genser-ttbar-rivet
  TEST_COMMAND ${agile_home}/bin/agile-runmc --list-gens
       COMMAND ${agile_home}/bin/agile-runmc Pythia6:${v_test_version} -o pythia6-${v}.genser-ttbar.hepmc.dat --paramfile=${CMAKE_SOURCE_DIR}/generators/agile_configs/pythia6-ttbar-8tev.params -n ${rivettests_stat_size}
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_TTBAR --histo-file=pythia6-${v}.genser-ttbar-rivet.yoda pythia6-${v}.genser-ttbar.hepmc.dat
  ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${agile_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              AGILE_GEN_PATH=${agile_home}/../../..
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/pythia6.genser-ttbar-rivet.root ${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-ttbar-rivet.root "Path=XS,jet_HT,jet_mult" "limit=0.05,0.10,0.10"
  TIMEOUT ${timeout}
  DEPENDS rivet-tests.genser-prepare_references
)

LCG_add_test(
  pythia6-${v}.genser-zjets-rivet
  TEST_COMMAND ${agile_home}/bin/agile-runmc Pythia6:${v_test_version} -o pythia6-${v}.genser-zjets.hepmc.dat --paramfile=${CMAKE_SOURCE_DIR}/generators/agile_configs/pythia6-zjets-8tev.params -n ${rivettests_stat_size}
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS --histo-file=pythia6-${v}.genser-zjets-rivet.yoda pythia6-${v}.genser-zjets.hepmc.dat
  ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${agile_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              AGILE_GEN_PATH=${agile_home}/../../..
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
#       COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} pythia6 ${v_test_version} zjets ${LCG_VERSION} ${LCG_platform}
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/pythia6.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.05,0.10"
  DEPENDS rivet-tests.genser-prepare_references
  TIMEOUT ${timeout}
)
endforeach()

foreach(v ${herwig++_native_version})
LCG_add_test(herwigpp-${v}.genser-ttbar-rivet
   PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/herwig++/tests/LHC-ttbar.in | sed '/HepMCFile:Filename/s/herwigpp_ttbar.hepmc/herwigpp-${v}_ttbar.hepmc/g'| sed 's/saverun LHC-ttbar/saverun LHC-ttbar-${v}/g' > ${CMAKE_BINARY_DIR}/generators/LHC-ttbar-${v}.in"
  TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${CMAKE_BINARY_DIR}/generators/LHC-ttbar-${v}.in
       COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N${rivettests_stat_size} LHC-ttbar-${v}.run -d1
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_TTBAR -H herwigpp-${v}.genser-ttbar-rivet.yoda herwigpp-${v}_ttbar.hepmc
       COMMAND cat LHC-ttbar-${v}.out
       COMMAND cat LHC-ttbar-${v}.log
       BINARY_DIR herwig++/tests
       SOURCE_DIR herwig++/tests
  ENVIRONMENT ${library_path}=${Python_home}/lib:${herwig++-${v}_home}/lib/Herwig++:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-ttbar-rivet.root ${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-ttbar-rivet.root "Path=XS,jet_HT,jet_mult" "limit=0.05,0.10,0.10"
  DEPENDS rivet-tests.genser-prepare_references
  TIMEOUT ${timeout}
)
  
LCG_add_test(herwigpp-${v}.genser-zjets-rivet
   PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/herwig++/tests/LHC-zjets.in | sed '/HepMCFile:Filename/s/herwigpp_zjets.hepmc/herwigpp-${v}_zjets.hepmc/g' | sed 's/saverun LHC-zjets/saverun LHC-zjets-${v}/g' > ${CMAKE_BINARY_DIR}/generators/LHC-zjets-${v}.in"
  TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${CMAKE_BINARY_DIR}/generators/LHC-zjets-${v}.in
       COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N${rivettests_stat_size} LHC-zjets-${v}.run -d1
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS -H herwigpp-${v}.genser-zjets-rivet.yoda herwigpp-${v}_zjets.hepmc
       COMMAND cat LHC-zjets-${v}.out
       COMMAND cat LHC-zjets-${v}.log
       BINARY_DIR herwig++/tests
       SOURCE_DIR herwig++/tests
  ENVIRONMENT ${library_path}=${Python_home}/lib:${herwig++-${v}_home}/lib/Herwig++:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
              LHAPATH=${lhapdfsets_home}/../share/lhapdf/PDFsets
              LHAPDF_DATA_PATH=${lhapdf_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.05,0.10"
  DEPENDS rivet-tests.genser-prepare_references
  TIMEOUT ${timeout}
)
endforeach()

foreach(v ${sherpa_native_version})
if (${v} MATCHES "^2.[.]*")
 LCG_add_test(sherpa-${v}.genser-zjets-rivet
   PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_ZJets_riv2.dat | sed '/EVENT_OUTPUT/s/sherpa_zjets/sherpa-${v}_zjets/g' > ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.dat"
       COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/zjets/${v}
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/zjets/${v} ${sherpa-${v}_home}/bin/Sherpa -f ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.dat -e ${rivettests_stat_size}
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS --histo-file=sherpa-${v}.genser-zjets-rivet.yoda sherpa/zjets/${v}/sherpa-${v}_zjets.hepmc2g
  ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:${rivet2_home}/bin:{yoda_home}/bin:$ENV{PATH}
              ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${Python_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:$ENV{PYTHONPATH}
              PWD=.
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/sherpa.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.05,0.10"
  DEPENDS rivet-tests.genser-prepare_references
  TIMEOUT ${timeout}
 )
else()
 LCG_add_test(sherpa-${v}.genser-zjets-rivet
   PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHCV1_ZJets_riv2.dat | sed '/HEPMC2/s/sherpa_zjets/sherpa-${v}_zjets/g' > ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.dat"
       COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/zjets/${v}
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/zjets/${v} ${sherpa-${v}_home}/bin/Sherpa -f ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.dat  -e ${rivettests_stat_size}
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS --histo-file=sherpa-${v}.genser-zjets-rivet.yoda sherpa/zjets/${v}/sherpa-${v}_zjets.hepmc2g
  ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:${rivet2_home}/bin:{yoda_home}/bin:$ENV{PATH}
              ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${Python_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:$ENV{PYTHONPATH}
              PWD=.
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/sherpa.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.0001,0.10"
  DEPENDS rivet-tests.genser-prepare_references
  TIMEOUT ${timeout}
 )
#COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a MC_ZJETS -H sherpa.genser-zjets-rivet_zjets_i.yoda sherpa_zjets.hepmc2g
endif()
endforeach()

foreach(v ${herwig_native_version})
string(REGEX MATCH "6.[0-9][0-9][0-9]" v_test_version ${v})
LCG_add_test(
  herwig-${v}.genser-zjets-rivet
  TEST_COMMAND ${CMAKE_COMMAND} -E echo available generators for the given AGILE_GEN_PATH:
       COMMAND ${agile_home}/bin/agile-runmc --list-gens
       COMMAND ${CMAKE_COMMAND} -E echo
       COMMAND ${agile_home}/bin/agile-runmc Herwig:${v_test_version} -o hepmcfile_herwig-${v}_zjets.dat --paramfile ${CMAKE_SOURCE_DIR}/generators/agile_configs/herwig-zjets-8tev.params -n ${rivettests_stat_size}
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS -H herwig-${v}.genser-zjets-rivet.yoda hepmcfile_herwig-${v}_zjets.dat
  ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${agile_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
              AGILE_GEN_PATH=${agile_home}/../../..
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwig-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/herwig.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/herwig-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.05,0.10"
  DEPENDS rivet-tests.genser-prepare_references 
  TIMEOUT ${timeout}
)
endforeach()


foreach(v ${alpgen_native_version})
LCG_add_test(
  alpgen-${v}.genser-zjets-rivet
  TEST_COMMAND ${CMAKE_COMMAND} -E echo available generators for the given AGILE_GEN_PATH:
       COMMAND ${agile_home}/bin/agile-runmc --list-gens
       COMMAND ${CMAKE_COMMAND} -E echo 
       COMMAND ${CMAKE_COMMAND} -E chdir tmpalpgen/examples-${v} $ENV{SHELL} -c "${agile_home}/bin/agile-runmc AlpGenPythia6:${pythia6_test_version}:${v} -o hepmcfile_alpgen_zjets.dat --paramfile ${CMAKE_SOURCE_DIR}/generators/agile_configs/alpgen-zjets.params -n 1000 < inputalpgen3"
       COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS -H alpgen-${v}.genser-zjets-rivet.yoda tmpalpgen/examples-${v}/hepmcfile_alpgen_zjets.dat
  ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${agile_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              AGILE_GEN_PATH=${agile_home}/../../..
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/alpgen-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/alpgen.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/alpgen-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.05,0.10"
  DEPENDS alpgen-${v}.native-examples rivet-tests.genser-prepare_references
  
)
endforeach()

LCG_add_test(rivet-tests.genser-prepare_references
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/alpgen_riv2.yoda ${CMAKE_BINARY_DIR}/generators/alpgen.genser-zjets-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/herwig_riv2.yoda ${CMAKE_BINARY_DIR}/generators/herwig.genser-zjets-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/sherpa_riv2.yoda ${CMAKE_BINARY_DIR}/generators/sherpa.genser-zjets-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/herwigpp_riv2_zjets.yoda ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-zjets-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/herwigpp_riv2_ttbar.yoda ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-ttbar-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/pythia6_riv2_zjets.yoda ${CMAKE_BINARY_DIR}/generators/pythia6.genser-zjets-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/pythia6_riv2_ttbar.yoda ${CMAKE_BINARY_DIR}/generators/pythia6.genser-ttbar-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/pythia8_riv2_zjets.yoda ${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjets-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/pythia8_riv2_zjetsgenser.yoda ${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjetsgenser-rivet.yoda
  TEST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/alpgen.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwig.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/sherpa.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
  ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
)

if (VALIDATION)
  execute_process(COMMAND date "+%F" OUTPUT_VARIABLE date)
  set (path2database "/afs/cern.ch/user/s/sftnight/public/genservis.db")
  LCG_add_test(rivet-tests.copy2database
    TEST_COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/push2database.sh -P ${CMAKE_BINARY_DIR}/generators -r LCG_${LCG_VERSION} -p ${LCG_platform} -c "${rivettests_stat_size} ${date}" -d ${path2database}
  )
  set(date)
  set(path2database)
endif()

LCG_add_test(debug-symbols-test 
             TEST_COMMAND ${CMAKE_SOURCE_DIR}/cmake/scripts/check_debug_symbols.sh ${CMAKE_INSTALL_PREFIX}
)

#---test of the test infrasgtructure---------------------------------------------------------------
LCG_add_test(test-test PRE_COMMAND /bin/echo pre-comand 1
                           COMMAND /bin/echo pre-comand 2
                           COMMAND /bin/echo pre-comand 3
                           COMMAND /bin/echo pre-comand 4
                           COMMAND /bin/echo pre-comand 5
                      TEST_COMMAND /bin/echo test-command 1
                           COMMAND /bin/echo test-command 2 
                           IF "2.0.0" VERSION_GREATER "1.5.3" THEN
                            COMMAND /bin/echo VERSION_GREATER works
                           ENDIF
                           COMMAND /bin/echo test-command 3
                      POST_COMMAND /bin/echo post-command 1
                           COMMAND date )



