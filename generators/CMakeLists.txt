#---Options-----------------------------------------------------------------------------------------
set(PDFsets "--all" CACHE STRING "The PDFsets to be downloaded for the 'lhspdfsets' package (default --all)")

set (minimal_PDF_set "ct10 MSTW2008lo68cl cteq6ll cteq6l")
if(${PDFsets} MATCHES "minimal")
  string (REPLACE "minimal" "${minimal_PDF_set}" PDFsets "${PDFsets}")
  set(PDFsets "${PDFsets}" CACHE STRING "Minimal PDFsets kit for the tests" FORCE)
endif()
message(STATUS "PDFsets to download                    : ${PDFsets}")

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
    set(rivet2_work_version ${v})
  endif()
endforeach()

foreach(v ${lhapdf_native_version})
  if(v VERSION_EQUAL 6.0.0 OR v VERSION_GREATER 6.0.0)
    set(lhapdf6_latest_version ${v})
  else()
    set(lhapdf5_latest_version ${v})
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
else()   
  set (shell_ext "sh")
endif()

#---lhapdfsets--------------------------------------------------------------------------------------
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
           "-DPDFsets=${PDFsets}"
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
           "-DPDFS=${PDFsets}"
           -Ddst_dir=<INSTALL_DIR>/../share/LHAPDF
           -P ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6sets/pdfsets.cmake
          COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6sets/mktarball.sh <INSTALL_DIR> <NATIVE_VERSION>
)

list(GET lhapdf_native_version -1 pdf_version_full)
# compatibily with toolchains with unmerged lhapdf
if (pdf_version_full VERSION_LESS 6)
  list(GET lhapdf6_native_version -1 pdf_version_full)
endif()
string(REGEX MATCH "[0-9]+.[0-9]+" pdf_version "${pdf_version_full}")
LCG_add_test(lhapdf6sets.download
   PRE_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current
       COMMAND ${CMAKE_COMMAND} -E echo "Download LHAPDF6 PDF sets (version ${pdf_version}) ..."
  TEST_COMMAND ${CMAKE_COMMAND}
               -Ddistr=${CMAKE_SOURCE_DIR}/generators/lhapdf6sets
               -Drepo=http://www.hepforge.org/archive/lhapdf/pdfsets/${pdf_version}
               "-DPDFS=${PDFsets}"
               -Ddst_dir=${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
               -P ${CMAKE_CURRENT_SOURCE_DIR}/lhapdf6sets/pdfsets.cmake
)


#---cython------------------------------------------------------------------------------------------
LCGPackage_Add(
  cython
  URL ${gen_url}/Cython-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_home}/bin/python setup.py build -e "${env_cmd} python"
  INSTALL_COMMAND ${Python_home}/bin/python setup.py install --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

#---yaml-cpp----------------------------------------------------------------------------------------
LCGPackage_Add(
  yamlcpp
  URL ${gen_url}/yaml-cpp-${yamlcpp_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DBUILD_SHARED_LIBS=ON
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND make install  
  COMMAND ${CMAKE_COMMAND} -E create_symlink yamlcpp <INSTALL_DIR>/../../../yaml-cpp
)

foreach(v ${yamlcpp_native_version})
LCG_add_test(yamlcpp-${v}.build
  BINARY_DIR yamlcpp/tests/${v}
  SOURCE_DIR yamlcpp/tests
  BUILD all
  BUILD_OPTIONS -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
                -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
                -DYAMLCPP_ROOT_DIR=${yamlcpp-${v}_home}
  ENVIRONMENT ${library_path}=${yamlcpp-${v}_home}/lib:$ENV{${library_path}})

LCG_add_test(yamlcpp-${v}.genser-produce-yaml
  TEST_COMMAND yamlcpp/tests/${v}/produce-yaml
  ENVIRONMENT ${library_path}=${yamlcpp-${v}_home}/lib:$ENV{${library_path}}
  DEPENDS yamlcpp-${v}.build)
endforeach()
#---Yoda-------------------------------------------------------------------------------------------

set(cython_pythonpath ${cython_home}/lib/python${Python_config_version_twodigit}/site-packages)
set(cython_v_pythonpath <cython-<yoda_<VERSION>_cython>_home>/lib/python${Python_config_version_twodigit}/site-packages)
set(cython_v_home <cython-<yoda_<VERSION>_cython>_home>)


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
      PYTHONPATH=${cython_v_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
      PATH=${cython_v_home}/bin:${Python_home}/bin:$ENV{PATH}
  BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:$ENV{${library_path}} PYTHONPATH=:${cython_v_pythonpath}:${Python_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH} PATH=${cython_v_home}/bin:${Python_home}/bin:$ENV{PATH}
  INSTALL_COMMAND make install ${library_path}=${Python_home}/lib:$ENV{${library_path}} PYTHONPATH=:${cython_v_pythonpath}:$ENV{PYTHONPATH} LIBRARY_PATH=${Python_home}/lib PATH=${cython_v_home}/bin:${Python_home}/bin:$ENV{PATH}
  BUILD_IN_SOURCE 1
  DEPENDS Python Boost cython-<yoda_<VERSION>_cython> 
)

#---heputils-------------------------------------------------------------------------------------------
LCGPackage_Add(
  heputils
  URL ${gen_url}/heputils-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND make install PREFIX=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
# if we add tests then probably it should depend on Boost and fastjet
)

#---mcutils-------------------------------------------------------------------------------------------
LCGPackage_Add(
  mcutils
  URL ${gen_url}/mcutils-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND make install PREFIX=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS heputils
)


#---lhapdf------------------------------------------------------------------------------------------
LCGPackage_Add(
  lhapdf
  IF <VERSION> VERSION_LESS 6.0.0 THEN
    URL ${gen_url}/lhapdf-<NATIVE_VERSION>.tar.gz
    PATCH_COMMAND patch -p0 < ${CMAKE_CURRENT_SOURCE_DIR}/patches/lhapdf-getdata.patch
        CONFIGURE_COMMAND ./configure
      --prefix=<INSTALL_DIR>
      --datadir=${CMAKE_INSTALL_PREFIX}/lhapdfsets/<VERSION>/share
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
    DEPENDS lhapdfsets-<NATIVE_VERSION>
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
    DEPENDS Boost Python cython
    IF <VERSION> VERSION_LESS 6.1.5 THEN yamlcpp ENDIF
  ENDIF
)


#---lhapdf (for LCGCMT releases) -------------------------------------------------------------------
LCGPackage_Add(
  lhapdf6
    URL ${gen_url}/LHAPDF-<NATIVE_VERSION>.tar.gz
      CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-boost=${Boost_home} --with-yaml-cpp=${yamlcpp_home}
        PYTHON=${Python_home}/bin/python
        CYTHON=${cython_home}/bin/cython
        PYTHONPATH=${cython_pythonpath}  CFLAGS=-O2 CXXFLAGS=-O2 FCFLAGS=-O2 LDFLAGS=-O2
    BUILD_COMMAND ${MAKE} all
      ${library_path}=${yamlcpp_home}/lib:$ENV{${library_path}} PYTHONPATH=${cython_pythonpath}  LIBRARY_PATH=${Python_home}/lib
    INSTALL_COMMAND make install PYTHONPATH=${cython_pythonpath} LIBRARY_PATH=${Python_home}/lib
            COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
    BUILD_IN_SOURCE 1
    DEPENDS Boost Python cython
    IF <VERSION> VERSION_LESS 6.1.5 THEN yamlcpp ENDIF
)

#---lhapdf5 and lhapdf6 moved after pythia8 tests

#---Protos------------------------------------------------------------------------------------------
LCGPackage_Add(
  protos
  URL ${gen_url}/Protos<protos_<VERSION>_author>.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${MAKE} FC=<protos_<VERSION>_FC> LIBRARY_PATH=<lhapdf-<protos_<VERSION>_lhapdf>_home>/lib
  INSTALL_COMMAND ${MAKE} INSTALL_DIR=<INSTALL_DIR>/bin install
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf-<protos_<VERSION>_lhapdf>
)

foreach(v ${protos_native_version})
  LCG_add_test(protos-${v}.native-Protos-tW
    TEST_COMMAND ${CMAKE_COMMAND} -E make_directory protos/${v}/Red/tW
         COMMAND ${CMAKE_COMMAND} -E make_directory protos/${v}/events
         COMMAND ${CMAKE_COMMAND} -E copy_directory ${protos-${v}_home}/bin/Red/tW/input protos/${v}/Red/tW/input
         COMMAND ${CMAKE_COMMAND} -E make_directory protos/${v}/Red/tW/output
         COMMAND ${CMAKE_COMMAND} -E make_directory protos/${v}/Red/tW/plots
         COMMAND $ENV{SHELL} -c "sed -i -e 's/0 1 1                        ! IEVTOUT/1 1 1                        ! IEVTOUT/' protos/${v}/Red/tW/input/run.dat"
         COMMAND ${CMAKE_COMMAND} -E chdir protos/${v}/Red/tW ${protos-${v}_home}/bin/Red/tW/Protos-tW
         #to be unweighted by unw/Protos-unw, see https://twiki.cern.ch/twiki/bin/view/Sandbox/ProtosGenerator
    ENVIRONMENT ${library_path}=${lhapdf-${protos_${v}_lhapdf}_home}/lib:$ENV{${library_path}} 
                LHAPATH=${lhapdf-${protos_${v}_lhapdf}_home}/../share/lhapdf/PDFsets
    DEPENDS lhapdfsets
  )
endforeach()


#---pythia8------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia8
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "HEAD81" THEN
    SVN_REPOSITORY https://pythia8.hepforge.org/svn/pythia81/trunk --quiet
  ENDIF
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "HEAD$" THEN
    SVN_REPOSITORY https://pythia8.hepforge.org/svn/pythia82/trunk --quiet
  ENDIF
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "[0-9][0-9][0-9]" THEN
    URL ${gen_url}/pythia8<pythia8_<NATIVE_VERSION>_author>.tgz
  ENDIF
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "HEAD81" OR <pythia8_<NATIVE_VERSION>_author> MATCHES "^1[0-9][0-9]" THEN
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc=${HepMC_home} --enable-shared --lcgplatform=${LCG_platform}
  ENDIF
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "^2[0-9][0-9]" THEN
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc2=${HepMC_home} --with-<pythia8_<NATIVE_VERSION>_lhapdf_family>=<lhapdf-<pythia8_<NATIVE_VERSION>_lhapdf>_home> --with-boost=${Boost_home} --enable-shared
  ENDIF
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "HEAD$" THEN
    CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-hepmc2=${HepMC_home} --with-<pythia8_<NATIVE_VERSION>_lhapdf_family>=<lhapdf-<pythia8_<NATIVE_VERSION>_lhapdf>_home> --enable-shared
  ENDIF
  BUILD_COMMAND ${MAKE}
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "HEAD81" OR <pythia8_<NATIVE_VERSION>_author> MATCHES "^1[0-9][0-9]" THEN
    INSTALL_COMMAND $ENV{SHELL} -c "sed -i -e 's/cp -r/cp -rf/g' <SOURCE_DIR>/Makefile"
            COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ${MAKE} install
            COMMAND ${CMAKE_COMMAND} -E create_symlink sources/xmldoc <INSTALL_DIR>/../share/xmldoc
  ENDIF
  BUILD_IN_SOURCE 1
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "HEAD81" OR <pythia8_<NATIVE_VERSION>_author> MATCHES "^1[0-9][0-9]" THEN
    CONFIGURE_EXAMPLES_COMMAND <SOURCE_DIR>/examples/configure
                               --with-pythia8=<INSTALL_DIR>
                               --with-lhapdf=<lhapdf-<pythia8_<NATIVE_VERSION>_lhapdf>_home>/lib/archive
                               --with-fastjet=${fastjet_home}
    BUILD_EXAMPLES_COMMAND ${MAKE} -C <SOURCE_DIR>/examples main01 main03
    INSTALL_EXAMPLES_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
                     COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/examples cp bin/main01.exe bin/main03.exe main03.cmnd <INSTALL_DIR>/bin
    DEPENDS HepMC lhapdf-<pythia8_<NATIVE_VERSION>_lhapdf> fastjet
  ENDIF
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "HEAD$" OR <pythia8_<NATIVE_VERSION>_author> MATCHES "^2[0-9][0-9]" THEN
    DEPENDS HepMC lhapdf-<pythia8_<NATIVE_VERSION>_lhapdf>
  ENDIF
  IF <pythia8_<NATIVE_VERSION>_author> MATCHES "^2[0-9][0-9]" AND <pythia8_<NATIVE_VERSION>_lhapdf> VERSION_GREATER 5.9.9 THEN
    Boost
  ENDIF
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
    IF v MATCHES "HEAD81" OR v MATCHES "^1[0-9][0-9]" THEN
      PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
    ELSE
      PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
    ENDIF
  DEPENDS pythia8-${v}.build)

LCG_add_test(pythia8-${v}.native-main01
  TEST_COMMAND pythia8/tests/${v}/native-main01
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:$ENV{${library_path}}
    IF v MATCHES "HEAD81" OR v MATCHES "^1[0-9][0-9]" THEN
      PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
    ELSE
      PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
    ENDIF
  DEPENDS pythia8-${v}.build)

LCG_add_test(pythia8-${v}.genser-test1
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test1
  POST_COMMAND ${CMAKE_COMMAND} -E copy pythia8/tests/${v}/testi_pythia8.dat pythia8/tests/${v}/test_pythia8.dat
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    IF v MATCHES "HEAD81" OR v MATCHES "^1[0-9][0-9]" THEN
      PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
    ELSE
      PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
    ENDIF
  DEPENDS pythia8-${v}.build)

LCG_add_test(pythia8-${v}.genser-test2
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8_test2.cmnd pythia8/tests/${v}/.
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test2
  POST_COMMAND $ENV{SHELL} -c "cat pythia8/tests/${v}/testi_pythia8.dat >> pythia8/tests/${v}/test_pythia8.dat"
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    IF v MATCHES "HEAD81" OR v MATCHES "^1[0-9][0-9]" THEN
      PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
    ELSE
      PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
    ENDIF
  DEPENDS pythia8-${v}.build pythia8-${v}.genser-test1)

LCG_add_test(pythia8-${v}.genser-test3
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test3
  POST_COMMAND $ENV{SHELL} -c "cat pythia8/tests/${v}/testi_pythia8.dat >> pythia8/tests/${v}/test_pythia8.dat"
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    IF v MATCHES "HEAD81" OR v MATCHES "^1[0-9][0-9]" THEN
      PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
    ELSE
      PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
    ENDIF
  DEPENDS pythia8-${v}.build pythia8-${v}.genser-test1)

LCG_add_test(pythia8-${v}.genser-test4
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test4
  POST_COMMAND $ENV{SHELL} -c "cat pythia8/tests/${v}/testi_pythia8.dat >> pythia8/tests/${v}/test_pythia8.dat"
  ENVIRONMENT
    ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    IF v MATCHES "HEAD81" OR v MATCHES "^1[0-9][0-9]" THEN
      PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
    ELSE
      PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
    ENDIF
  DEPENDS pythia8-${v}.build pythia8-${v}.genser-test1)

LCG_add_test(pythia8-${v}.compare
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c pythia8/tests/${v}/.
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh pythia8 ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/reference.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests
  DEPENDS pythia8-${v}.genser-test2 pythia8-${v}.genser-test3 pythia8-${v}.genser-test4)

if(${v} MATCHES "^2[0-9][0-9]" OR ${v} MATCHES "HEAD$")

  LCG_add_test(pythia8-${v}.genser-test1-lhapdf
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ./pythia8_genser_test1_lhapdf
    POST_COMMAND ${CMAKE_COMMAND} -E copy pythia8/tests/${v}/testi_pythia8.dat pythia8/tests/${v}/test_pythia8_lhapdf.dat
    ENVIRONMENT
      ${library_path}=${pythia8-${v}_home}/lib:${HepMC_home}/lib:${lhapdf_home}/lib:${Boost_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
      LHAPDF_DATA_PATH=${lhapdf_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
      PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
    DEPENDS pythia8-${v}.build lhapdf6sets.download
  )

  LCG_add_test(pythia8-${v}.compare-lhapdf
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia8/tests/${v} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh pythia8_lhapdf ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/reference_lhapdf.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests
    DEPENDS pythia8-${v}.genser-test1-lhapdf pythia8-${v}.compare
  )

endif()

endforeach()


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
    LCG_add_test(lhapdf-${v}.native-testpdf
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

    LCG_add_test(lhapdf-${v}.genser-pythia8
      TEST_COMMAND lhapdf6/tests/pyt8/${v}/lhapdf6_pyt8
      BINARY_DIR lhapdf6/tests/pyt8/${v}
      SOURCE_DIR lhapdf6/tests/pyt8
      BUILD lhapdf6_pyt8
      BUILD_OPTIONS
       -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
       -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
       -DLHAPDF6_ROOT_DIR=${lhapdf-${v}_home}
       -DBOOST_ROOT=${Boost_home}
       -DBoost_INCLUDE_DIR=${Boost_home_include}
       -DYAMLCPP_ROOT_DIR=${yamlcpp_home}
       -DPYTHIA8_ROOT_DIR=${pythia8_home}
      ENVIRONMENT
        ${library_path}=${lhapdf-${v}_home}/lib:${pythia8_home}/lib:${Boost_home}/lib:${yamlcpp_home}/lib:$ENV{${library_path}}
        LHAPDF_DATA_PATH=${lhapdf-${v}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
        IF pythia8_work_version MATCHES "HEAD81" OR pythia8_work_version MATCHES "^1[0-9][0-9]" THEN
          PYTHIA8DATA=${pythia8_home}/xmldoc
        ELSE
          PYTHIA8DATA=${pythia8_home}/share/Pythia8/xmldoc
        ENDIF
      POST_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c .
           COMMAND ${CMAKE_COMMAND} -E copy testi_lhapdf6.dat test_lhapdf6.dat
           COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh lhapdf6 ${CMAKE_SOURCE_DIR}/generators/lhapdf6/tests/pyt8/reference.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/lhapdf6/tests/pyt8
      DEPENDS lhapdf6sets.download
    )
  endif()
endforeach()


# HepMC 3 test - hepmc3

foreach(hmc3variant hepmc3 hepmc3-cxx11)
foreach(v ${${hmc3variant}_native_version})
  LCG_add_test(${hmc3variant}-${v}.native-basic_tree
    TEST_COMMAND ${${hmc3variant}_home}/bin/basic_tree.exe
    ENVIRONMENT
      ${library_path}=${${hmc3variant}_home}/lib:$ENV{${library_path}}
  )

  LCG_add_test(${hmc3variant}-${v}.native-hepevt_wrapper_example
    TEST_COMMAND ${${hmc3variant}_home}/bin/hepevt_wrapper_example.exe
  )

 LCG_add_test(${hmc3variant}-${v}.native-pythia8_example
  PRE_COMMAND  ${CMAKE_COMMAND} -E copy ${${hmc3variant}_home}/bin/pythia8_ee_to_Z_to_tautau.conf .
  TEST_COMMAND ${${hmc3variant}_home}/bin/pythia8_example.exe pythia8_ee_to_Z_to_tautau.conf hepmc3-output.${v}.output
  ENVIRONMENT
    PYTHIA8DATA=${pythia8_home}/xmldoc
    ${library_path}=${${hmc3variant}_home}/lib:${pythia8_home}/lib:$ENV{${library_path}}
 )

endforeach()
endforeach()


#---vincia------------------------------------------------------------------------------------------

set(pythia8_v_home <pythia8-<vincia_<NATIVE_VERSION>_pythia8>_home>)

LCGPackage_Add(
  vincia
  URL ${gen_url}/vincia-<NATIVE_VERSION>.tgz
  CONFIGURE_COMMAND $ENV{SHELL} -c "cp -rf ${pythia8_v_home}/config.mk <SOURCE_DIR>/"
            COMMAND $ENV{SHELL} -c "sed -i.bak -e 's/make -C$(PYTHIA8)//g' -e 's/make -C$(PY8DIR)//g' <SOURCE_DIR>/Makefile" 
  BUILD_COMMAND make PYTHIA8=${pythia8_v_home} PY8DIR=${pythia8_v_home}
  INSTALL_COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/lib -DDST=<INSTALL_DIR>/lib -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
          COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/bin -DDST=<INSTALL_DIR>/bin -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
          COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/tunes -DDST=<INSTALL_DIR>/tunes -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
          COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/include -DDST=<INSTALL_DIR>/include -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
          COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/data -DDST=<INSTALL_DIR>/data -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
          COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/antennae -DDST=<INSTALL_DIR>/antennae -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
          COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR>/xmldoc -DDST=<INSTALL_DIR>/xmldoc -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
  BUILD_IN_SOURCE 1
  DEPENDS pythia8-<vincia_<VERSION>_pythia8>  
)

#---ThePEG------------------------------------------------------------------------------------------

LCGPackage_Add(
  thepeg
  URL ${gen_url}/ThePEG-<thepeg_<NATIVE_VERSION>_author>.tar.bz2
# UPDATE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> autoreconf --install --force
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
                                --with-hepmc=${HepMC_home}
                                IF <VERSION> VERSION_LESS 1.9.0 THEN
                                   --with-LHAPDF=<lhapdf-<thepeg_<NATIVE_VERSION>_lhapdf>_home>
                                ELSE
                                   --with-lhapdf=<lhapdf-<thepeg_<NATIVE_VERSION>_lhapdf>_home>
                                ENDIF
                                --with-gsl=${GSL_home} --without-javagui CFLAGS=-O2 CXXFLAGS=-O2 FFLAGS=-O2
  BUILD_COMMAND ${MAKE} all ${library_path}=<lhapdf-<thepeg_<NATIVE_VERSION>_lhapdf>_home>:<lhapdf-<thepeg_<NATIVE_VERSION>_lhapdf>_home>/lib:$ENV{${library_path}}
  INSTALL_COMMAND make install-strip ${library_path}=<lhapdf-<thepeg_<NATIVE_VERSION>_lhapdf>_home>:<lhapdf-<thepeg_<NATIVE_VERSION>_lhapdf>_home>/lib:$ENV{${library_path}}
  BUILD_IN_SOURCE 1
  DEPENDS HepMC GSL lhapdf-<thepeg_<NATIVE_VERSION>_lhapdf>
)

if (NOT shell_ext MATCHES "csh")
foreach(v ${thepeg_native_version})
  LCG_add_test(thepeg-${v}.genser-scripts-setupThePEG
    PRE_COMMAND ${CMAKE_COMMAND} -E make_directory thepeg/${v}
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir thepeg/${v} $ENV{SHELL} -c "source ${thepeg-${v}_home}/thepegenv-genser.sh
      setupThePEG ${thepeg-${v}_home}/share/ThePEG/MultiLEP.in"
    ENVIRONMENT LHAPDF_DATA_PATH=${lhapdf-${thepeg_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
    DEPENDS lhapdf6sets.download
  )
  LCG_add_test(thepeg-${v}.genser-scripts-runThePEG
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir thepeg/${v} $ENV{SHELL} -c "source ${thepeg-${v}_home}/thepegenv-genser.sh
      runThePEG MultiLEP.run"
    POST_COMMAND ${CMAKE_COMMAND} -E chdir thepeg/${v} cat MultiLEP.out
    DEPENDS thepeg-${v}.genser-scripts-setupThePEG
  )
endforeach()
endif()

#${CMAKE_SOURCE_DIR}/generators/thepeg/tests/MultiLEP.in

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
                          ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})

LCG_add_test(herwigpp-${v}.native-TVT 
			  TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${herwig++-${v}_home}/../share/sources/src/TVT.in 
                               COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N100 TVT.run -d1 
                          POST_COMMAND cat TVT.out
                               COMMAND cat TVT.log  
                          BINARY_DIR herwig++/tests
                          SOURCE_DIR herwig++/tests
                          ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})

LCG_add_test(herwigpp-${v}.genser-LHC-W
  TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${CMAKE_SOURCE_DIR}/generators/herwig++/tests/LHC-W.in --repo=${herwig++-${v}_home}/share/Herwig++/HerwigDefaults.rpo
       COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N50 LHC-W.run -d1
  POST_COMMAND cat LHC-W.out
       COMMAND cat LHC-W.log
  BINARY_DIR herwig++/tests
  SOURCE_DIR herwig++/tests
  ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
  LHAPDF_DATA_PATH=${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
  DEPENDS lhapdf6sets.download
)

# native herwig++ tests (not all of them are run)

LCG_add_test(herwigpp-${v}.native-LEP-VV 
      TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests make -j1 test-LEP-VV REPO=${herwig++-${v}_home}/share/Herwig++/HerwigDefaults.rpo
           COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests cat LEP-VV.log       
      ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}})
 
foreach(herwig-leptest LEP-VH LEP-VBF LEP-BB LEP-Quarks LEP-Leptons LEP-default LEP-Powheg)
LCG_add_test(herwigpp-${v}.native-${herwig-leptest}
      TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests make -j1 test-${herwig-leptest} REPO=${herwig++-${v}_home}/share/Herwig++/HerwigDefaults.rpo
           COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/generators/herwig++-${v}/src/herwig++/${v}/Tests cat ${herwig-leptest}.log       
      ENVIRONMENT ${library_path}=${herwig++-${v}_home}/lib:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:$ENV{${library_path}}
      DEPENDS herwigpp-${v}.native-LEP-VV)
endforeach()
endforeach()



#---tauola++------------------------------------------------------------------------------------------
LCGPackage_Add(
  tauola++
  URL ${gen_url}/TAUOLA.<NATIVE_VERSION>-LHC.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --with-pic --with-hepmc=${HepMC_home} --with-tau-spinner --with-lhapdf=<lhapdf-<tauola++_<NATIVE_VERSION>_lhapdf>_home> CFLAGS=-O2 CPPFLAGS=-I${Boost_home_include} FFLAGS=-O2 F77=${CMAKE_Fortran_COMPILER}
  INSTALL_COMMAND  make install
          COMMAND  ${CMAKE_COMMAND} -E create_symlink tauola++ <INSTALL_DIR>/../../../tauolapp
  IF NOT CMAKE_BUILD_TYPE MATCHES Deb THEN
          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=<INSTALL_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/StripLib.cmake
  ENDIF
  BUILD_IN_SOURCE 1
  DEPENDS HepMC lhapdf-<tauola++_<NATIVE_VERSION>_lhapdf>
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
       COMMAND ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh tauolapp ${CMAKE_SOURCE_DIR}/generators/tauolapp/tests/reference.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/tauolapp/tests
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
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir pythia6/tests/${v} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh pythia6 ${CMAKE_SOURCE_DIR}/generators/pythia6/tests/reference.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/pythia6/tests
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

if (NOT shell_ext MATCHES "csh")
LCG_add_test(agile-${v}.genser-scripts-pythia6
  TEST_COMMAND $ENV{SHELL} -c "source ${agile-${v}_home}/agileenv-genser.sh
    agile-runmc Pythia6:${pythia6_test_version} -o agile-scripts-hepmc-${v}.dat"
)
endif()

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

if (NOT shell_ext MATCHES "csh")
LCG_add_test(professor-${v}.genser-scripts-executable
  TEST_COMMAND $ENV{SHELL} -c "source ${professor-${v}_home}/professorenv-genser.sh
               prof-interpolate -h"
)
endif()

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
       COMMAND ${CMAKE_COMMAND} -E chdir photospp/tests/${v} ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh photospp ${CMAKE_SOURCE_DIR}/generators/photospp/tests/reference.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/photospp/tests
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

foreach(v ${evtgen_native_version})
  LCG_add_test(evtgen-${v}.genser-test TEST_COMMAND evtgen-${v}/tests/evtgen_test1 ${evtgen-${v}_home}/share/DECAY_2010.DEC ${evtgen-${v}_home}/share/evt.pdl ${CMAKE_CURRENT_SOURCE_DIR}/evtgen/tests/DDALITZ.DEC 10000
    BINARY_DIR evtgen-${v}/tests
    SOURCE_DIR evtgen/tests
    BUILD evtgen_test1
    BUILD_OPTIONS -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
                  -DMYADDMODULEPATH=${cmaketools_home}/modules
                  -DROOTSYS=${ROOT_home}
                  -DEVTGEN_ROOT_DIR=${evtgen-${v}_home} -DPYTHIA8_ROOT_DIR=${pythia8-${evtgen_${v}_pythia8}_home}
                  -DPHOTOSPP_ROOT_DIR=${photos++_home} -DTAUOLAPP_ROOT_DIR=${tauola++-${evtgen_${v}_tauola++}_home}
                  -DHEPMC_ROOT_DIR=${HepMC_home}
                  IF LCG_CPP11 THEN -DCMAKE_CXX_FLAGS=-std=c++11 ENDIF
    ENVIRONMENT ${library_path}=${evtgen-${v}_home}/lib:${photos++_home}/lib:${pythia8-${evtgen_${v}_pythia8}_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}} 
                PYTHIA8DATA=${pythia8-${evtgen_${v}_pythia8}_home}/xmldoc
  )

  LCG_add_test(evtgen-${v}.compare
    PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c evtgen-${v}/tests/.
        COMMAND ${CMAKE_COMMAND} -E copy evtgen-${v}/tests/testi.dat evtgen-${v}/tests/test_evtgen.dat
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir evtgen-${v}/tests ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh evtgen ${CMAKE_SOURCE_DIR}/generators/evtgen/tests/compare/reference.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/evtgen/tests
    DEPENDS evtgen-${v}.genser-test
    
  )
endforeach()


set (yoda_convert_scripts "aida" "flat")
if (EXISTS "${ROOT_home}/")
  list(APPEND yoda_convert_scripts "root")
endif()

if (NOT shell_ext MATCHES "csh")
 foreach(v ${yoda_native_version})
  foreach(f ${yoda_convert_scripts})
  LCG_add_test(yoda-${v}.genser-scripts-yoda2${f}
    PRE_COMMAND ${CMAKE_COMMAND} -E make_directory yoda/tests/${v}
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir yoda/tests/${v} $ENV{SHELL} -c "source ${yoda-${v}_home}/yodaenv-genser.sh
      yoda2${f} ${CMAKE_SOURCE_DIR}/generators/reference/sherpa_riv2_zjetsgenser.yoda"
  )
  endforeach()
 endforeach()
endif()


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
    BUILD_COMMAND ${MAKE} all ${library_path}=${Python_home}/lib:${pcre_home}/lib:${yamlcpp_home}/lib:${GSL_home}/lib:$ENV{${library_path}} PYTHONPATH=${cython_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH} SWIG_LIB=${swig_home}/share/swig/${swig_author_version} LIBRARY_PATH=${Python_home}/lib:${GSL_home}/lib
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

if (NOT shell_ext MATCHES "csh")
LCG_add_test(rivet-${v}.genser-scripts-source
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh"
)
LCG_add_test(rivet-${v}.genser-scripts-mkanalysis
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet-${v}_home}/rivetenv-genser.sh
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
      rivet-mkhtml -o rivet-mkhtml-${v} ${CMAKE_SOURCE_DIR}/generators/reference/pythia6_riv2_zjetsgenser.yoda ${CMAKE_SOURCE_DIR}/generators/reference/pythia8_riv2_zjetsgenser.yoda"
)
endif()
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

foreach (v ${blackhat_native_version})
LCG_add_test(blackhat-${v}.build
  BINARY_DIR blackhat/tests/${v}
  SOURCE_DIR blackhat/tests
  BUILD all
  BUILD_OPTIONS -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
                -DBLACKHAT_ROOT_DIR=${blackhat-${v}_home}
                -DQD_ROOT_DIR=${qd_home}
#  ENVIRONMENT ${library_path}=${blackhat-${v}_home}/lib:${qd_home}/lib:$ENV{${library_path}}
  )

LCG_add_test(blackhat-${v}.native-cpp_example
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir blackhat/tests/${v} ./cpp_example
  ENVIRONMENT ${library_path}=${blackhat-${v}_home}/lib:$ENV{${library_path}}
  DEPENDS blackhat-${v}.build
  )

LCG_add_test(blackhat-${v}.native-fortran_example
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir blackhat/tests/${v} ./fortran_example
  ENVIRONMENT ${library_path}=${blackhat-${v}_home}/lib/blackhat:${qd_home}/lib:$ENV{${library_path}}
  DEPENDS blackhat-${v}.build
  )
endforeach()

#---Sherpa------------------------------------------------------------------------------------------
LCGPackage_Add(
  sherpa
  URL ${gen_url}/SHERPA-MC-<sherpa_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=<lhapdf-<sherpa_<NATIVE_VERSION>_lhapdf>_home>
     --enable-hepmc2=${HepMC_home}
     --enable-openloops=.
     --enable-lhole
     --with-sqlite3=${sqlite_home}  "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0"
#Boost includes below are necessary only for sherpa 1 series
  BUILD_COMMAND ${MAKE} LIBRARY_PATH=<lhapdf-<sherpa_<NATIVE_VERSION>_lhapdf>_home>/lib CPPFLAGS=-I${Boost_home_include} CPATH=${Boost_home_include} 
  INSTALL_COMMAND make install LIBRARY_PATH=<lhapdf-<sherpa_<NATIVE_VERSION>_lhapdf>_home>/lib
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf-<sherpa_<NATIVE_VERSION>_lhapdf> HepMC sqlite
)

#---Sherpa with MPI support------------------------------------------------------------------------------------------
LCGPackage_Add(
  sherpa-openmpi
  URL ${gen_url}/SHERPA-MC-<sherpa-openmpi_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa-openmpi_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=<lhapdf-<sherpa-openmpi_<NATIVE_VERSION>_lhapdf>_home>
     --enable-hepmc2=${HepMC_home}
     --enable-blackhat=${blackhat_home}
     --enable-openloops=.
     --enable-lhole
     --enable-mpi
     --with-sqlite3=${sqlite_home}  "CFLAGS=-O2 -g0" "CXXFLAGS=-O2 -g0" "FFLAGS=-O2 -g0" PATH=${openmpi_home}/bin:$ENV{PATH} ${library_path}=${openmpi_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${openmpi_home}/lib
  BUILD_COMMAND ${MAKE} PATH=${openmpi_home}/bin:$ENV{PATH} LIBRARY_PATH=<lhapdf-<sherpa-openmpi_<NATIVE_VERSION>_lhapdf>_home>/lib ${library_path}=${openmpi_home}/lib:${blackhat_home}/lib:$ENV{${library_path}} CPPFLAGS=-I${Boost_home_include}
  INSTALL_COMMAND make install LIBRARY_PATH=<lhapdf-<sherpa-openmpi_<NATIVE_VERSION>_lhapdf>_home>/lib PATH=${openmpi_home}/bin:$ENV{PATH} ${library_path}=${openmpi_home}/lib:${blackhat_home}/lib:$ENV{${library_path}}
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf-<sherpa-openmpi_<NATIVE_VERSION>_lhapdf> HepMC sqlite openmpi blackhat
)


LCGPackage_Add(
  sherpa-mpich2
  URL ${gen_url}/SHERPA-MC-<sherpa-mpich2_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
     --enable-shared --enable-static --enable-binreloc --enable-analysis
     --enable-pythia --enable-hepevtsize=<sherpa-mpich2_<NATIVE_VERSION>_hepevt>
     --enable-lhapdf=<lhapdf-<sherpa-mpich2_<NATIVE_VERSION>_lhapdf>_home>
     --enable-hepmc2=${HepMC_home}
     --enable-blackhat=${blackhat_home}
     --enable-openloops=.
     --enable-lhole
     --enable-mpi   
     --with-sqlite3=${sqlite_home} "CFLAGS=-O2 -g0 -fPIC" "CXXFLAGS=-O2 -g0 -fPIC" "FFLAGS=-O2 -g0 -fPIC"
CC=mpicc CXX=mpic++  PATH=${mpich2_home}/bin:$ENV{PATH} ${library_path}=${mpich2_home}/lib:$ENV{${library_path}} LIBRARY_PATH=${mpich2_home}/lib
BUILD_COMMAND ${MAKE} PATH=${mpich2_home}/bin:$ENV{PATH} LIBRARY_PATH=<lhapdf-<sherpa-mpich2_<NATIVE_VERSION>_lhapdf>_home>/lib ${library_path}=${mpich2_home}/lib:${blackhat_home}/lib:$ENV{${library_path}} CPPFLAGS=-I${Boost_home_include}
  INSTALL_COMMAND make install LIBRARY_PATH=<lhapdf-<sherpa-mpich2_<NATIVE_VERSION>_lhapdf>_home>/lib PATH=${mpich2_home}/bin:$ENV{PATH} ${library_path}=${mpich2_home}/lib:${blackhat_home}/lib:$ENV{${library_path}} 
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf-<sherpa-mpich2_<NATIVE_VERSION>_lhapdf> HepMC sqlite mpich2 blackhat
)


set( v ${sherpa-mpich2_native_version})
LCG_add_test(sherpa-mpich2.native-LHC_Z
  PRE_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa-mpi/native-LHC_Z/${v}
      COMMAND ${CMAKE_COMMAND} -E make_directory sherpa-mpi/native-LHC_Z/${v}
      COMMAND $ENV{SHELL} -c  "cd ${HOME} && touch .mpd.conf &&  chmod 600 .mpd.conf"
 TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa-mpi/native-LHC_Z/${v} ${mpich2_home}/bin/mpd --daemon
    COMMAND ${mpich2_home}/bin/mpirun -n 5 ${sherpa-mpich2-${v}_home}/bin/Sherpa -f ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_Z.dat
    COMMAND ${mpich2_home}/bin/mpdallexit
  ENVIRONMENT
  ${library_path}=${sherpa-mpich2-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf-${sherpa_mpich2-${v}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${sqlite_home}/lib:${mpich2_home}/lib:$ENV{${library_path}}
    PATH=${sqlite_home}/bin:$ENV{PATH}
    PWD=.
)

# $PWD is needed because Sherpa uses this variable to know current directory
foreach(v ${sherpa_native_version})
LCG_add_test(sherpa-${v}.native-LHC_Z
  PRE_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa/native-LHC_Z/${v}
      COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/native-LHC_Z/${v}
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/native-LHC_Z/${v} ${sherpa-${v}_home}/bin/Sherpa -j20 -f ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_Z.dat
  ENVIRONMENT
  ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf-${sherpa_${v}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${sqlite_home}/lib:$ENV{${library_path}}
    PATH=${sqlite_home}/bin:$ENV{PATH}
    PWD=.
)

LCG_add_test(sherpa-${v}.genser-LHC_Z_lhapdf
  PRE_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa/genser-LHC_Z_lhapdf/${v}
      COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/genser-LHC_Z_lhapdf/${v}
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_Z_lhapdf.dat sherpa/genser-LHC_Z_lhapdf/LHC_Z_lhapdf.dat
      IF ${sherpa_${v}_lhapdf} VERSION_LESS 6.0 THEN
        COMMAND $ENV{SHELL} -c "sed -i -e 's/CT10/CT10.LHgrid/g' sherpa/genser-LHC_Z_lhapdf/LHC_Z_lhapdf.dat"
      ENDIF
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/genser-LHC_Z_lhapdf/${v} ${sherpa-${v}_home}/bin/Sherpa -f ${CMAKE_BINARY_DIR}/generators/sherpa/genser-LHC_Z_lhapdf/LHC_Z_lhapdf.dat
  ENVIRONMENT
    ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf-${sherpa_${v}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${sqlite_home}/lib:$ENV{${library_path}}
    LHAPDF_DATA_PATH=${lhapdf-${sherpa_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
    LHAPATH=${lhapdf-${sherpa_${v}_lhapdf}_home}/../share/PDFsets
    PATH=${sqlite_home}/bin:$ENV{PATH}
    PWD=.
    DEPENDS lhapdf6sets.download
)



LCG_add_test(sherpa-${v}.native-LHC_ZJets
  PRE_COMMAND ${CMAKE_COMMAND} -E remove_directory sherpa/native-LHC_ZJets/${v}
      COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/native-LHC_ZJets/${v}
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/native-LHC_ZJets/${v} ${sherpa-${v}_home}/bin/Sherpa -j20 -f ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_ZJets.dat
  ENVIRONMENT
    ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf-${sherpa_${v}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${sqlite_home}/lib:$ENV{${library_path}}
    PATH=${sqlite_home}/bin:$ENV{PATH}
    PWD=.
  
)
endforeach()

#---HepMCAnalysis------------------------------------------------------------------------------------
set(CLHEP_v_home <CLHEP-<hepmcanalysis_<NATIVE_VERSION>_CLHEP>_home>)

LCGPackage_Add(
  hepmcanalysis
  URL ${gen_url}/HepMCAnalysis-<hepmcanalysis_<NATIVE_VERSION>_author>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/hepmcanalysis/files <SOURCE_DIR>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${MAKE} HepMCdir=${HepMC_home} FastJetdir=${fastjet_home} ROOTSYS=${ROOT_home} CLHEPdir=${CLHEP_v_home} 
			${library_path}=${CLHEP_v_home}/lib:$ENV{${library_path}}
            LIBRARY_PATH=${fastjet_home}/lib:$ENV{LIBRARY_PATH}
            IF LCG_CPP11 THEN
              "CXXFLAGS=-fPIC -std=c++11"
            ENDIF
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/lib <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR>/include
  BUILD_IN_SOURCE 1
  DEPENDS HepMC fastjet ROOT CLHEP-<hepmcanalysis_<VERSION>_CLHEP>

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
  IF LCG_CPP11 THEN -DCMAKE_CXX_FLAGS=-std=c++11 ENDIF
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
  IF LCG_CPP11 THEN -DCMAKE_CXX_FLAGS=-std=c++11 ENDIF
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
  INSTALL_COMMAND make install FC=${CMAKE_Fortran_COMPILER} CC=${CMAKE_C_COMPILER} F77=${CMAKE_Fortran_COMPILER}
          IF NOT APPLE THEN
            COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/include ${CMAKE_COMMAND} -E create_symlink HERWIG65.INC herwig65.inc
          ENDIF
  BUILD_IN_SOURCE 1
)

foreach(v ${herwig_native_version})
LCG_add_test(herwig-${v}.build
  BINARY_DIR herwig/tests/${v}
  SOURCE_DIR herwig/tests
  BUILD all
  BUILD_OPTIONS -DCMAKE_MODULE_PATH=${CMAKE_SOURCE_DIR}/cmake/modules
                -DCMAKE_MODULE_PATH2=${cmaketools_home}/modules
                -DHERWIG_ROOT_DIR=${herwig-${v}_home}
                -DHEPMC_ROOT_DIR=${HepMC_home}
)
endforeach()

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
   if (NOT shell_ext MATCHES "csh")
    LCG_add_test(crmcold-${v}.genser-scripts
      TEST_COMMAND $ENV{SHELL} -c "source ${crmcold-${v}_home}/crmcoldenv-genser.sh
        crmc -T 1 -c ${crmcold-${v}_home}/crmc.param"
    )
   endif()
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
     IF LCG_CPP11 THEN
               -DCMAKE_CXX_FLAGS=-std=c++11
     ENDIF
    DEPENDS HepMC Boost ROOT
  )
  
foreach(v ${crmc_native_version})
 if (NOT shell_ext MATCHES "csh")
  LCG_add_test(crmc-${v}.genser-scripts
    TEST_COMMAND $ENV{SHELL} -c "source ${crmc-${v}_home}/crmcenv-genser.sh
      crmc -T 1 -c ${crmc-${v}_home}/crmc.param"
  )
 endif()
  LCG_add_test(crmc-${v}.native-crmc
    TEST_COMMAND ${crmc-${v}_home}/bin/crmc -T 1 -c ${crmc-${v}_home}/crmc.param
    ENVIRONMENT ${library_path}=${crmc-${v}_home}/lib:${ROOT_home}/lib:${HepMC_home}/lib:${Boost_home}/lib:$ENV{${library_path}}	
  )
endforeach()
endif()

#---FeynHiggs--------------------------------------------------------------------------------------
LCGPackage_Add(
 feynhiggs
 URL ${gen_url}/FeynHiggs-<feynhiggs_<NATIVE_VERSION>_author>.tar.gz
 CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
 BUILD_IN_SOURCE 1
)

#---chaplin--------------------------------------------------------------------------------------
LCGPackage_Add(
 chaplin
 URL ${gen_url}/chaplin-<chaplin_<NATIVE_VERSION>_author>.tar.gz
 CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
 BUILD_IN_SOURCE 1
)

#---powheg-box-v2--------------------------------------------------------------------------------------
if(NOT APPLE)    #  (installation fails on MacOSX)
 LCGPackage_Add(
  powheg-box-v2
  URL ${gen_url}/powheg-box-v2-<powheg-box-v2_<NATIVE_VERSION>_author>.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box-v2/files <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./distr-cleanup.sh
  CONFIGURE_COMMAND ./configure
    --prefix=<INSTALL_DIR>
    --fastjet=${fastjet_home}
    --lhapdf=<lhapdf-<powheg-box-v2_<NATIVE_VERSION>_lhapdf>_home>
    --chaplin=${chaplin_home}
    --feynhiggs=${feynhiggs_home}
  BUILD_COMMAND ${MAKE}
  BUILD_IN_SOURCE 1
  DEPENDS fastjet lhapdf-<powheg-box-v2_<NATIVE_VERSION>_lhapdf> chaplin feynhiggs
 )

foreach(v ${powheg-box-v2_native_version})
foreach(i WW Zj hvq)
  LCG_add_test(powheg-box-v2-${v}.native-${i}
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/tests/runtest.sh ${powheg-box-v2-${v}_home}/bin ${powheg-box-v2-${v}_home}/../share/sources ${i} powheg-box-v2 ${v}
    ENVIRONMENT
      ${library_path}=${lhapdf-${powheg-box-v2_${v}_lhapdf}_home}/lib:${fastjet_home}/lib:$ENV{${library_path}}
      LHAPATH=${lhapdfsets_home}/../share/PDFsets
      LHAPDF_DATA_PATH=${lhapdf-${powheg-box-v2_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
    DEPENDS lhapdf6sets.download
  )
endforeach()
endforeach()
endif()

#---powheg-box-------------------------------------------------------------------------------

if(NOT APPLE)    #  (installation fails on MacOSX)
 LCGPackage_Add(
  powheg-box
  URL ${gen_url}/powheg-box-<NATIVE_VERSION>.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/files <SOURCE_DIR>
         COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR> ./distr-cleanup.sh
  CONFIGURE_COMMAND ./configure  
    --prefix=<INSTALL_DIR>
    --fastjet=${fastjet_home}
    --lhapdf=<lhapdf-<powheg-box_<NATIVE_VERSION>_lhapdf>_home>
  BUILD_COMMAND ${MAKE} CPATH=${Boost_home_include} 
  BUILD_IN_SOURCE 1
  DEPENDS fastjet lhapdf-<powheg-box_<NATIVE_VERSION>_lhapdf>
 )

foreach(v ${powheg-box_native_version})
# WZ, Wp_Wp_J_J, VBF_Wp_Wp are skiped - example steering files do not work
foreach(i WW HJ W_ew-BW Wbb Wj HJJ ZZ W_ew-BMNNP Dijet gg_H VBF_H Z W hvq Zj ST_sch ST_tch ST_tch_4f)
  LCG_add_test(powheg-box-${v}.native-${i}
    TEST_COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/powheg-box/tests/runtest.sh ${powheg-box-${v}_home}/bin ${powheg-box-${v}_home}/../share/sources ${i} powheg-box ${v}
    ENVIRONMENT
      ${library_path}=${lhapdf-${powheg-box_${v}_lhapdf}_home}/lib:${fastjet_home}/lib:$ENV{${library_path}}
      LHAPATH=${lhapdfsets_home}/../share/PDFsets
      LHAPDF_DATA_PATH=${lhapdf-${powheg-box_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
    DEPENDS lhapdf6sets.download
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
                --with-LHAPDF=<lhapdf-<sacrifice_<NATIVE_VERSION>_lhapdf>_home> --with-photos=${photos++_home}
                --with-boost=${Boost_home} --with-MCUtils
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND ${MAKE} install 
  BUILD_IN_SOURCE 1
  DEPENDS pythia8-<sacrifice_<VERSION>_pythia8>  Boost HepMC lhapdf-<sacrifice_<NATIVE_VERSION>_lhapdf> photos++
)

foreach(v ${sacrifice_native_version})
if (NOT shell_ext MATCHES "csh")
LCG_add_test(sacrifice-${v}.genser-scripts
  TEST_COMMAND $ENV{SHELL} -c "source ${sacrifice-${v}_home}/sacrificeenv-genser.sh
    run-pythia  --collision-energy 8000 -i ${CMAKE_SOURCE_DIR}/generators/sacrifice/AU2-CT10.params -n 1000 --photos"
  ENVIRONMENT LHAPDF_DATA_PATH=${lhapdf-${sacrifice_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
  DEPENDS lhapdf6sets.download
)
endif()
LCG_add_test(sacrifice-${v}.genser-AU2-CT10
   TEST_COMMAND ${sacrifice-${v}_home}/bin/run-pythia  --collision-energy 8000 -i ${CMAKE_SOURCE_DIR}/generators/sacrifice/AU2-CT10.params -n 1000 --photos 
   ENVIRONMENT ${library_path}=${photos++_home}/lib:${lhapdf-${sacrifice_${v}_lhapdf}_home}/lib:${HepMC_home}/lib:${pythia8-${sacrifice_${v}_pythia8}_home}/lib:$ENV{${library_path}}
	       LHAPATH=${lhapdfsets_home}/../share/lhapdf/PDFsets
               LHAPDF_DATA_PATH=${lhapdf-${sacrifice_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
   DEPENDS lhapdf6sets.download
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
          COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/files/README_GENSER <INSTALL_DIR>/../share/
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

foreach(v ${madgraph5amc_native_version})

#LCG_add_test(madgraph5amc_testmanager
#  TEST_COMMAND ${Python_cmd} ${madgraph5amc-${v}_home}/tests/test_manager.py
#)

LCG_add_test(madgraph5amc-${v}.genser-zjetsLO
  PRE_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/LO
#        The two lines below will not work for madgraph5amc installed in readonly location
       COMMAND $ENV{SHELL} -c "echo set fastjet ${fastjet_home}/bin/fastjet-config > ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/cardsLO.dat"
       COMMAND $ENV{SHELL} -c "echo set lhapdf ${lhapdf_home}/bin/lhapdf-config >> ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/cardsLO.dat"
       COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/tests/cardsLO.dat >> ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/cardsLO.dat"
  TEST_COMMAND $ENV{SHELL} -c "cd ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/LO
           ${Python_cmd} ${madgraph5amc-${v}_home}/bin/mg5_aMC ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/cardsLO.dat
           MYPROC/bin/generate_events < ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/tests/cardsLO1"
)

LCG_add_test(madgraph5amc-${v}.genser-zjetsLOLHAPDF
  TEST_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/LOLHAPDF
       COMMAND $ENV{SHELL} -c "cd ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/LOLHAPDF
           ${Python_cmd} ${madgraph5amc-${v}_home}/bin/mg5_aMC ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/tests/cardsLO.dat
           sed -i.bck -e 's@.*lhapdf = lhapdf-config@ lhapdf = ${lhapdf_home}/bin/lhapdf-config@' MYPROC/Cards/me5_configuration.txt
           sed -i.bck -e '/= pdlabel/s@^.*$@ lhapdf = pdlabel@' -e '/= lhaid/s@^.*$@ 10800 = lhaid@' MYPROC/Cards/run_card.dat
           MYPROC/bin/generate_events < ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/tests/cardsLO1"
  ENVIRONMENT
     LHAPDF_DATA_PATH=${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
  DEPENDS lhapdf6sets.download madgraph5amc-${v}.genser-zjetsLO
)

LCG_add_test(madgraph5amc-${v}.genser-zjetsLO_hadronize
  PRE_COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8_test2.cmnd ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization
      COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/LO/MYPROC/Events/run_01/unweighted_events.lhe.gz ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/Zg_pythia8_mg.lhe.gz
      COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/Zg_pythia8_mg.lhe
      COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization gunzip Zg_pythia8_mg.lhe.gz
#       Old pythia8 does not accept lhe version 3.0:
      IF pythia8_work_version MATCHES "HEAD" OR pythia8_work_version VERSION_GREATER 204 THEN
        COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/Zg_pythia8_mg.lhe ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/Zg_pythia8.lhe
      ELSE
        COMMAND $ENV{SHELL} -c "cat ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/Zg_pythia8_mg.lhe | sed '/LesHouchesEvents/s/3.0/1.0/' > ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/Zg_pythia8.lhe"
      ENDIF
  TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization ${CMAKE_BINARY_DIR}/generators/pythia8/tests/${pythia8_work_version}/pythia8_genser_test2
  ENVIRONMENT
    ${library_path}=${pythia8-${pythia8_work_version}_home}/lib:${HepMC_home}/lib:$ENV{${library_path}}
    IF pythia8_work_version MATCHES "HEAD81" OR pythia8_work_version MATCHES "^1[0-9][0-9]" THEN
      PYTHIA8DATA=${pythia8_home}/xmldoc
    ELSE
      PYTHIA8DATA=${pythia8_home}/share/Pythia8/xmldoc
    ENDIF
  DEPENDS pythia8-${pythia8_work_version}.build madgraph5amc-${v}.genser-zjetsLOLHAPDF
)

LCG_add_test(madgraph5amc-${v}_compare
  TEST_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/chi.c ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/.
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/testi_pythia8.dat ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization/test_madgraph5amc.dat
       COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_BINARY_DIR}/generators/madgraph5amc/${v}/hadronization ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/compare/cmpr.sh madgraph5amc ${CMAKE_SOURCE_DIR}/generators/madgraph5amc/tests/reference.dat ${v} ${LCG_VERSION} ${LCG_platform} ${CMAKE_SOURCE_DIR}/generators/pythia8
  DEPENDS madgraph5amc-${v}.genser-zjetsLO_hadronize
)

endforeach()

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
if (NOT shell_ext MATCHES "csh")
LCG_add_test(jhu-${v}.genser-scripts
  TEST_COMMAND $ENV{SHELL} -c "source ${jhu-${v}_home}/jhuenv-genser.sh
    cd \$JHU_HOME
    JHUGen VegasNc0=100000 VegasNc1=500000 VegasNc2=100"
)
endif()
LCG_add_test(jhu-${v}.native-JHUGen
  PRE_COMMAND ${CMAKE_COMMAND} -E remove -f pdfs
      COMMAND ${CMAKE_COMMAND} -E create_symlink ${jhu-${v}_home}/pdfs pdfs
  TEST_COMMAND ${jhu-${v}_home}/bin/JHUGen VegasNc0=100000 VegasNc1=500000 VegasNc2=100)

LCG_add_test(jhu-${v}.native-testF
  TEST_COMMAND ${jhu-${v}_home}/bin/testF)

LCG_add_test(jhu-${v}.native-testC
  TEST_COMMAND ${jhu-${v}_home}/bin/testC)
endforeach()


#---LoopTools------------------------------------------------------------------------------------------------
LCGPackage_Add(
  looptools
  URL ${gen_url}/LoopTools-<VERSION>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND ${MAKE} install
  BUILD_IN_SOURCE 1
)


#--- gg2VV -----------------------------------------------------------------------------------

LCGPackage_Add(
  gg2VV
  URL ${gen_url}/gg2VV-<NATIVE_VERSION>.tar.bz2
  CONFIGURE_COMMAND <VOID> 
  BUILD_COMMAND ${CMAKE_COMMAND} -E chdir gg2VV $ENV{SHELL} -c "PATH=${omniorb_home}/bin:$ENV{PATH} TOPDIR=${CMAKE_BINARY_DIR}/generators/gg2VV-<NATIVE_VERSION>/src/gg2VV/<NATIVE_VERSION> LIB_TOPDIR=<INSTALL_DIR> LHAPDF_TOPDIR=${lhapdf_home} OMNIORB_TOPDIR=${omniorb_home} LOOPTOOLS_TOPDIR=${looptools_home} ${ftjam_home}/bin/jam "
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/bin
          COMMAND ${CMAKE_COMMAND} -E copy gg2VV/gg2VV <INSTALL_DIR>/bin
          COMMAND $ENV{SHELL} -c "chmod 755 <INSTALL_DIR>/bin/gg2VV"
  BUILD_IN_SOURCE 1
  DEPENDS ftjam looptools omniorb lhapdf-${lhapdf6_latest_version}
)

foreach(v ${gg2VV_native_version})
  LCG_add_test(gg2VV-${v}.native
    TEST_COMMAND ${gg2VV-${v}_home}/bin/gg2VV
    ENVIRONMENT
      LHAPDF_DATA_PATH=${lhapdf_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
      ${library_path}=${lhapdf_home}/lib:${omniorb_home}/lib:$ENV{${library_path}}
    TIMEOUT 3000
    DEPENDS lhapdf6sets.download
  )
endforeach()



#--- fastnlo_toolkit -------------------------------------------------------------------------------
LCGPackage_Add(
  fastnlo_toolkit
  URL ${gen_url}/fastnlo_toolkit-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND ./configure
      --prefix=<INSTALL_DIR>
      --with-lhapdf=<lhapdf-<fastnlo_toolkit_<NATIVE_VERSION>_lhapdf>_home>
      --with-fastjet=${fastjet_home}
      --with-yoda=${yoda_home}
  #    --enable-pyext   # need to specify swig package if this option is switched on!
  BUILD_COMMAND ${MAKE} CPATH=${Boost_home_include} 
  INSTALL_COMMAND ${MAKE} install
  BUILD_IN_SOURCE 1
  DEPENDS lhapdf-<fastnlo_toolkit_<NATIVE_VERSION>_lhapdf> yoda fastjet
)

# List of .tab files is available on http://fastnlo.hepforge.org/scenarios/tables-lhc.html

if (UNIX AND fastnlo_toolkit_native_version)

# CMS inclusive forward jets 2011 (anti-kT R=0.5; pT, eta); LO, NLO; RIVET_ID: CMS_2012_I1087342
set(fastnlo_toolkit_tabfile "fnl2222b_I1087342.tab")
LCG_add_test(fastnlo_toolkit.download
  TEST_COMMAND $ENV{SHELL} -c "curl http://fastnlo.hepforge.org/scenarios/tables-v21/${fastnlo_toolkit_tabfile}.gz | gzip -d | cat > ${fastnlo_toolkit_tabfile}")

if (NOT shell_ext MATCHES "csh")
foreach(v ${fastnlo_toolkit_native_version})
 foreach(fnlotest "example" "yodaout" "cppread")
  LCG_add_test(fastnlo_toolkit-${v}.native-fnlo-tk-${fnlotest}
  IF ${fastnlo_toolkit_${v}_lhapdf} VERSION_LESS 6.0 THEN
       TEST_COMMAND $ENV{SHELL} -c "source ${fastnlo_toolkit-${v}_home}/fastnlo_toolkitenv-genser.sh \n fnlo-tk-${fnlotest} ${fastnlo_toolkit_tabfile} CT10nnlo.LHgrid"
  ELSE
       TEST_COMMAND $ENV{SHELL} -c "source ${fastnlo_toolkit-${v}_home}/fastnlo_toolkitenv-genser.sh \n fnlo-tk-${fnlotest} ${fastnlo_toolkit_tabfile} CT10nnlo"
  ENDIF     
  ENVIRONMENT 
     LHAPDF_DATA_PATH=${lhapdf-${fastnlo_toolkit_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
     LHAPATH=${lhapdf-${fastnlo_toolkit_${v}_lhapdf}_home}/../share/PDFsets

  DEPENDS fastnlo_toolkit.download lhapdf6sets.download
  )
 endforeach()
endforeach()
endif(NOT shell_ext MATCHES "csh")
endif(UNIX AND fastnlo_toolkit_native_version)


### tests of generators using rivet 2

if(rivet2_work_version VERSION_EQUAL 2.2.0 OR rivet2_work_version VERSION_GREATER 2.2.0)
 LCG_add_test(rivet-tests.genser-buildanalysis
  TEST_COMMAND $ENV{SHELL} -c "source ${rivet2_home}/rivetenv.${shell_ext}
       rivet-buildplugin RivetGENSER_MC_ZJETS.so ${CMAKE_SOURCE_DIR}/generators/rivetgenser/GENSER_MC_ZJETS.cc"
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/rivetgenser/GENSER_MC_ZJETS.info ${CMAKE_BINARY_DIR}/generators
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/rivetgenser/GENSER_MC_ZJETS.plot ${CMAKE_BINARY_DIR}/generators
  ENVIRONMENT
    ${library_path}=${GSL_home}/lib:$ENV{${library_path}}
    LIBRARY_PATH=${fastjet_home}/lib:$ENV{LIBRARY_PATH}
    PATH=${Python_home}/bin:$ENV{PATH}
 )
endif()

foreach(v ${pythia8_native_version})
 if(rivet2_work_version VERSION_EQUAL 2.2.0 OR rivet2_work_version VERSION_GREATER 2.2.0)
 LCG_add_test(
  pythia8-${v}.genser-zjetsgenser-rivet
  PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/pythia8/tests/pythia8-zjets-rivet.params | sed \"s/Main:numberOfEvents.*/Main:numberOfEvents = ${rivettests_stat_size}/g\" | cat > ${CMAKE_BINARY_DIR}/generators/pythia8/tests/pythia8-${v}.zjetsgenser-rivet.params"
  TEST_COMMAND ${CMAKE_BINARY_DIR}/generators/pythia8/tests/${v}/pythia8 ${CMAKE_BINARY_DIR}/generators/pythia8/tests/pythia8-${v}.zjetsgenser-rivet.params pythia8-${v}.genser-zjetsgenser.hempc.dat
       COMMAND ${rivet2_home}/bin/rivet --show-analysis GENSER_MC_ZJETS
       COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a GENSER_MC_ZJETS -a MC_GENERIC -a MC_IDENTIFIED --histo-file=pythia8-${v}.genser-zjetsgenser-rivet.yoda pythia8-${v}.genser-zjetsgenser.hempc.dat
  ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:${pythia8-${v}_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              IF v MATCHES "HEAD81" OR v MATCHES "^1[0-9][0-9]" THEN
                PYTHIA8DATA=${pythia8-${v}_home}/xmldoc
              ELSE
                PYTHIA8DATA=${pythia8-${v}_home}/share/Pythia8/xmldoc
              ENDIF
              RIVET_ANALYSIS_PATH=${CMAKE_BINARY_DIR}/generators
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia8-${v}.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} pythia8 ${v} zjetsgenser ${LCG_VERSION} ${LCG_platform}
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjetsgenser-rivet.root ${CMAKE_BINARY_DIR}/generators/pythia8-${v}.genser-zjetsgenser-rivet.root "Path=XS,Z_pt,jet_mult,jet_mult_norm,jet1_pt,jet2_pt" "limit=0.05,0.1,0.1,0.04,0.1,0.1"
  TIMEOUT ${timeout}
  DEPENDS rivet-tests.genser-prepare_references rivet-tests.genser-buildanalysis pythia8-${v}.build
 )
 endif()
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
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages:${ROOT_home}/lib:$ENV{PYTHONPATH}
              AGILE_GEN_PATH=${agile_home}/../../..
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/pythia6.genser-ttbar-rivet.root ${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-ttbar-rivet.root "Path=XS,jet_HT,jet_mult" "limit=0.05,0.10,0.10"
  TIMEOUT ${timeout}
  DEPENDS rivet-tests.genser-prepare_references
 )

 LCG_add_test(
  pythia6-${v}.genser-zjetsgenser-rivet
  TEST_COMMAND pythia6/tests/${v}/pythia6_genser_outhepmc ${rivettests_stat_size} pythia6-${v}.genser-zjets.hepmc.dat
       COMMAND $ENV{SHELL} -c "cat pythia6-${v}.genser-zjets.hepmc.dat | sed 's/U MEV MM/U GEV MM/' > pythia6-${v}.genser-zjets.hepmc.datNEW"
       COMMAND $ENV{SHELL} -c "mv pythia6-${v}.genser-zjets.hepmc.datNEW pythia6-${v}.genser-zjets.hepmc.dat"
       COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a GENSER_MC_ZJETS -a MC_GENERIC -a MC_IDENTIFIED --histo-file=pythia6-${v}.genser-zjetsgenser-rivet.yoda pythia6-${v}.genser-zjets.hepmc.dat
  ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${pythia6-${v}_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              RIVET_ANALYSIS_PATH=${CMAKE_BINARY_DIR}/generators
  POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} pythia6 ${v} zjetsgenser ${LCG_VERSION} ${LCG_platform}
       COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/pythia6.genser-zjetsgenser-rivet.root ${CMAKE_BINARY_DIR}/generators/pythia6-${v}.genser-zjetsgenser-rivet.root "Path=XS,Z_pt,jet_mult,jet_mult_norm,jet1_pt,jet2_pt" "limit=0.05,0.1,0.1,0.04,0.1,0.1"
  DEPENDS pythia6-${v}.build rivet-tests.genser-prepare_references rivet-tests.genser-buildanalysis
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
   ENVIRONMENT ${library_path}=${Python_home}/lib:${herwig++-${v}_home}/lib/Herwig++:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
              PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
   POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
        COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-ttbar-rivet.root ${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-ttbar-rivet.root "Path=XS,jet_HT,jet_mult" "limit=0.05,0.10,0.10"
   DEPENDS rivet-tests.genser-prepare_references
   TIMEOUT ${timeout}
 )
  
 LCG_add_test(herwigpp-${v}.genser-zjetsgenser-rivet
   PRE_COMMAND $ENV{SHELL} -c "test -s ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-zjetsgenser-rivet.root"
       COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/herwig++/tests/LHC-zjets.in | sed '/HepMCFile:Filename/s/herwigpp_zjets.hepmc/herwigpp-${v}_zjets.hepmc/g' | sed 's/saverun LHC-zjets/saverun LHC-zjets-${v}/g' > ${CMAKE_BINARY_DIR}/generators/LHC-zjets-${v}.in"
   TEST_COMMAND ${herwig++-${v}_home}/bin/Herwig++ read ${CMAKE_BINARY_DIR}/generators/LHC-zjets-${v}.in
        COMMAND ${herwig++-${v}_home}/bin/Herwig++ run -N${rivettests_stat_size} LHC-zjets-${v}.run -d1
        COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a GENSER_MC_ZJETS -a MC_GENERIC -a MC_IDENTIFIED -H herwigpp-${v}.genser-zjetsgenser-rivet.yoda herwigpp-${v}_zjets.hepmc
        COMMAND cat LHC-zjets-${v}.out
        COMMAND cat LHC-zjets-${v}.log
        BINARY_DIR herwig++/tests
        SOURCE_DIR herwig++/tests
   ENVIRONMENT ${library_path}=${Python_home}/lib:${herwig++-${v}_home}/lib/Herwig++:${thepeg-${herwig++_${v}_thepeg}_home}/lib/ThePEG:${HepMC_home}/lib:${lhapdf-${thepeg_${herwig++_${v}_thepeg}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
               PYTHONPATH=${Python_home}/bin:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
               PATH=${Python_home}/bin:$ENV{PATH}
               LHAPATH=${lhapdfsets_home}/../share/lhapdf/PDFsets
               LHAPDF_DATA_PATH=${lhapdf-${herwig++_${v}_lhapdf}_home}/share/LHAPDF:${CMAKE_INSTALL_PREFIX}/lhapdf6sets/current/share/LHAPDF
               RIVET_ANALYSIS_PATH=${CMAKE_BINARY_DIR}/generators
   POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
        COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} herwigpp ${v} zjetsgenser ${LCG_VERSION} ${LCG_platform}
        COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-zjetsgenser-rivet.root ${CMAKE_BINARY_DIR}/generators/herwigpp-${v}.genser-zjetsgenser-rivet.root "Path=XS,Z_pt,jet_mult,jet_mult_norm,jet1_pt,jet2_pt" "limit=0.05,0.1,0.1,0.04,0.1,0.1"
   DEPENDS rivet-tests.genser-prepare_references lhapdf6sets.download rivet-tests.genser-buildanalysis
   TIMEOUT ${timeout}
 )
endforeach()

foreach(v ${sherpa_native_version})
 LCG_add_test(sherpa-${v}.genser-zjetsgenser-rivet
   PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHC_ZJets_riv2.dat | sed '/EVENT_OUTPUT/s/sherpa_zjets/sherpa-${v}_zjets/g' > ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.dat"
       COMMAND ${CMAKE_COMMAND} -E make_directory sherpa/zjets/${v}
   TEST_COMMAND ${CMAKE_COMMAND} -E chdir sherpa/zjets/${v} ${sherpa-${v}_home}/bin/Sherpa -f ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.dat -e ${rivettests_stat_size}
        COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a GENSER_MC_ZJETS -a MC_GENERIC -a MC_IDENTIFIED --histo-file=sherpa-${v}.genser-zjetsgenser-rivet.yoda sherpa/zjets/${v}/sherpa-${v}_zjets.hepmc2g
   ENVIRONMENT PATH=${Python_home}/bin:${rivet2_home}/bin:{yoda_home}/bin:$ENV{PATH}
               ${library_path}=${sherpa-${v}_home}/lib/SHERPA-MC:${HepMC_home}/lib:${lhapdf-${sherpa_${v}_lhapdf}_home}/lib:${fastjet_home}/lib:${GSL_home}/lib:${Python_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${yamlcpp_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
               PYTHONPATH=${Python_home}/bin:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:$ENV{PYTHONPATH}
               RIVET_ANALYSIS_PATH=${CMAKE_BINARY_DIR}/generators
               PWD=.
   POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
        COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} sherpa ${v} zjetsgenser ${LCG_VERSION} ${LCG_platform}
        COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/sherpa.genser-zjetsgenser-rivet.root ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjetsgenser-rivet.root "Path=XS,Z_pt,jet_mult,jet_mult_norm,jet1_pt,jet2_pt" "limit=0.05,0.1,0.1,0.04,0.1,0.1"
   DEPENDS rivet-tests.genser-prepare_references rivet-tests.genser-buildanalysis
   TIMEOUT ${timeout}
 )
endforeach()

#the pre_command for sherpa1 looks like this:
# PRE_COMMAND $ENV{SHELL} -c "cat ${CMAKE_SOURCE_DIR}/generators/sherpa/tests/LHCV1_ZJets_riv2.dat | 
# sed '/HEPMC2/s/sherpa_zjets/sherpa-${v}_zjets/g' > ${CMAKE_BINARY_DIR}/generators/sherpa-${v}.genser-zjets-rivet.dat"


foreach(v ${herwig_native_version})
 string(REGEX MATCH "6.[0-9][0-9][0-9]" v_test_version ${v})
 LCG_add_test(
   herwig-${v}.genser-zjets-rivet
   TEST_COMMAND ${CMAKE_COMMAND} -E echo available generators for the given AGILE_GEN_PATH:
        COMMAND ${agile_home}/bin/agile-runmc --list-gens
        COMMAND ${CMAKE_COMMAND} -E echo
        COMMAND ${agile_home}/bin/agile-runmc Herwig:${v_test_version} -o hepmcfile_herwig-${v}_zjetsagile.dat --paramfile ${CMAKE_SOURCE_DIR}/generators/agile_configs/herwig-zjets-8tev.params -n ${rivettests_stat_size}
        COMMAND ${rivet2_home}/bin/rivet -a MC_GENERIC -a MC_IDENTIFIED -a MC_XS -a MC_ZJETS -H herwig-${v}.genser-zjets-rivet.yoda hepmcfile_herwig-${v}_zjetsagile.dat
   ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
               ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${agile_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
               PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages:$ENV{PYTHONPATH}
               AGILE_GEN_PATH=${agile_home}/../../..
   POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwig-${v}.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
        COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/herwig.genser-zjets-rivet.root ${CMAKE_BINARY_DIR}/generators/herwig-${v}.genser-zjets-rivet.root "Path=XS,jet_HT" "limit=0.05,0.10"
   DEPENDS rivet-tests.genser-prepare_references 
   TIMEOUT ${timeout}
 )

 LCG_add_test(
   herwig-${v}.genser-zjetsgenser-rivet
   TEST_COMMAND herwig/tests/${v}/herwig_genser_outhepmc ${rivettests_stat_size} herwig-${v}.genser-zjets.hepmc.dat
        COMMAND $ENV{SHELL} -c "cat herwig-${v}.genser-zjets.hepmc.dat | sed 's/U MEV MM/U GEV MM/' > herwig-${v}.genser-zjets.hepmc.datNEW"
        COMMAND $ENV{SHELL} -c "mv herwig-${v}.genser-zjets.hepmc.datNEW herwig-${v}.genser-zjets.hepmc.dat"
        COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a GENSER_MC_ZJETS -a MC_GENERIC -a MC_IDENTIFIED --histo-file=herwig-${v}.genser-zjetsgenser-rivet.yoda herwig-${v}.genser-zjets.hepmc.dat
   ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
               ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${herwig-${v}_home}/lib:${yamlcpp_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
               PYTHONPATH=${Python_home}/bin:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
               RIVET_ANALYSIS_PATH=${CMAKE_BINARY_DIR}/generators
   POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwig-${v}.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
        COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} herwig ${v} zjetsgenser ${LCG_VERSION} ${LCG_platform}
        COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/herwig.genser-zjetsgenser-rivet.root ${CMAKE_BINARY_DIR}/generators/herwig-${v}.genser-zjetsgenser-rivet.root "Path=XS,Z_pt,jet_mult,jet_mult_norm,jet1_pt,jet2_pt" "limit=0.05,0.1,0.1,0.04,0.1,0.1"
   DEPENDS herwig-${v}.build rivet-tests.genser-prepare_references rivet-tests.genser-buildanalysis
   TIMEOUT ${timeout}
 )
endforeach()


foreach(v ${alpgen_native_version})
 LCG_add_test(
   alpgen-${v}.genser-zjetsgenser-rivet
   TEST_COMMAND ${CMAKE_COMMAND} -E echo available generators for the given AGILE_GEN_PATH:
        COMMAND ${agile_home}/bin/agile-runmc --list-gens
        COMMAND ${CMAKE_COMMAND} -E echo
        COMMAND ${CMAKE_COMMAND} -E chdir tmpalpgen/examples-${v} $ENV{SHELL} -c "${agile_home}/bin/agile-runmc AlpGenPythia6:${pythia6_test_version}:${v} -o hepmcfile_alpgen_zjets.dat --paramfile ${CMAKE_SOURCE_DIR}/generators/agile_configs/alpgen-zjets.params -n 1000 < inputalpgen3"
        COMMAND ${rivet2_home}/bin/rivet -a MC_XS -a GENSER_MC_ZJETS -a MC_GENERIC -a MC_IDENTIFIED -H alpgen-${v}.genser-zjetsgenser-rivet.yoda tmpalpgen/examples-${v}/hepmcfile_alpgen_zjets.dat
   ENVIRONMENT PATH=${agile_home}/bin:${Python_home}/bin:$ENV{PATH}
               ${library_path}=${Python_home}/lib:${GSL_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${HepMC_home}/lib:${fastjet_home}/lib:${yamlcpp_home}/lib:${agile_home}/lib:${HepMC_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
               PYTHONPATH=${Python_home}/bin:${agile_home}/lib/python${Python_config_version_twodigit}/site-packages:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
               AGILE_GEN_PATH=${agile_home}/../../..
               RIVET_ANALYSIS_PATH=${CMAKE_BINARY_DIR}/generators
   POST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/alpgen-${v}.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
        COMMAND ${CMAKE_SOURCE_DIR}/generators/reference/riv2html.sh ${rivet2_home} alpgen ${v} zjetsgenser ${LCG_VERSION} ${LCG_platform}
        COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/generators/reference/reference.py ${CMAKE_BINARY_DIR}/generators/alpgen.genser-zjetsgenser-rivet.root ${CMAKE_BINARY_DIR}/generators/alpgen-${v}.genser-zjetsgenser-rivet.root "Path=XS,Z_pt,jet_mult,jet_mult_norm,jet1_pt,jet2_pt" "limit=0.05,0.1,0.1,0.04,0.1,0.1"
   DEPENDS alpgen-${v}.native-examples rivet-tests.genser-buildanalysis rivet-tests.genser-prepare_references
 )
endforeach()


LCG_add_test(rivet-tests.genser-prepare_references
  PRE_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/alpgen_riv2_zjetsgenser.yoda ${CMAKE_BINARY_DIR}/generators/alpgen.genser-zjetsgenser-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/herwig_riv2_zjets.yoda ${CMAKE_BINARY_DIR}/generators/herwig.genser-zjets-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/herwig_riv2_zjetsgenser.yoda  ${CMAKE_BINARY_DIR}/generators/herwig.genser-zjetsgenser-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/sherpa_riv2_zjetsgenser.yoda ${CMAKE_BINARY_DIR}/generators/sherpa.genser-zjetsgenser-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/herwigpp_riv2_zjetsgenser.yoda ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-zjetsgenser-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/herwigpp_riv2_ttbar.yoda ${CMAKE_BINARY_DIR}/generators/herwigpp.genser-ttbar-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/pythia6_riv2_zjetsgenser.yoda ${CMAKE_BINARY_DIR}/generators/pythia6.genser-zjetsgenser-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/pythia6_riv2_ttbar.yoda ${CMAKE_BINARY_DIR}/generators/pythia6.genser-ttbar-rivet.yoda
       COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_SOURCE_DIR}/generators/reference/pythia8_riv2_zjetsgenser.yoda ${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjetsgenser-rivet.yoda
  TEST_COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/alpgen.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwig.genser-zjets-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwig.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/sherpa.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/herwigpp.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia6.genser-ttbar-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
       COMMAND ${CMAKE_COMMAND} -DAIDA2ROOT=${AIDA2ROOT} -DPython_cmd=${Python_cmd} -Dyoda_home=${yoda_home} -DINPUT=${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjetsgenser-rivet.yoda -P ${CMAKE_SOURCE_DIR}/cmake/scripts/yoda2root.cmake
  POST_COMMAND $ENV{SHELL} -c "test -s ${CMAKE_BINARY_DIR}/generators/pythia8.genser-zjetsgenser-rivet.root"
  ENVIRONMENT PATH=${Python_home}/bin:$ENV{PATH}
              ${library_path}=${Python_home}/lib:${rivet2_home}/lib:${yoda_home}/lib:${ROOT_home}/lib:$ENV{${library_path}}
              PYTHONPATH=${Python_home}/bin:${rivet2_home}/lib/python${Python_config_version_twodigit}/site-packages/:${yoda_home}/lib/python${Python_config_version_twodigit}/site-packages/:${ROOT_home}/lib:$ENV{PYTHONPATH}
)

LCG_add_test(debug-symbols-test 
  TEST_COMMAND ${CMAKE_SOURCE_DIR}/cmake/scripts/check_debug_symbols.sh ${CMAKE_INSTALL_PREFIX} ${LCG_BUILD_TYPE}
  LABELS Nightly
)

LCG_add_test(permissions-test
  TEST_COMMAND ${CMAKE_SOURCE_DIR}/cmake/scripts/check_permissions.sh ${CMAKE_INSTALL_PREFIX}
  LABELS Nightly Release
)

LCG_add_test(report.build_time
  TEST_COMMAND ${CMAKE_SOURCE_DIR}/cmake/scripts/report_build_time.sh ${CMAKE_BINARY_DIR}/timestamps
  LABELS Nightly Release
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
                            IF "3.0.0" VERSION_GREATER "2.0.0" THEN
                              COMMAND /bin/echo level 2
                            ENDIF
                           ENDIF
                           COMMAND /bin/echo test-command 3
                      POST_COMMAND /bin/echo post-command 1
                           COMMAND date 
  LABELS Nightly Release
)


