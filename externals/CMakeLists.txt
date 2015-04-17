#---sqlite-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  sqlite
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/sqlite-autoconf-${sqlite_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make
  BUILD_IN_SOURCE 1
#  DEPENDS Python
)

if(APPLE)
  execute_process(COMMAND sw_vers -productVersion
                  COMMAND cut -d . -f 1-2
                  OUTPUT_VARIABLE MACOSX_VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
#---odcb-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  libiodbc
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/libiodbc-${libiodbc_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make
  INSTALL_COMMAND make install -i
  BUILD_IN_SOURCE 1
)
#---jemalloc-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  jemalloc
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/jemalloc-${jemalloc_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
)
#---gmp-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  gmp
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gmp-${gmp_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
)

#---vectorclass------------------------------------------------------------------------------------------------
LCGPackage_Add(
  vectorclass
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/vectorclass-${vectorclass_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)


#---odcb-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  libaio
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/libaio-${libaio_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND  <VOID>
  INSTALL_COMMAND make prefix=<INSTALL_DIR> install
  BUILD_IN_SOURCE 1
)
#---openldap-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  openldap
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/openldap-${openldap_native_version}.tgz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make
  INSTALL_COMMAND make install -i
  BUILD_IN_SOURCE 1
)
#---postgresql-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  postgresql
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/postgresql-${postgresql_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make -i 
  INSTALL_COMMAND make -i install
  BUILD_IN_SOURCE 1
)
#---cfitsio-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  cfitsio
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/cfitsio${cfitsio_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
)
#---globus-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  globus
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/globus_toolkit-${globus_native_version}-${LCG_ARCH}-unknown-linux-gnu-Build-16.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)
#---gsoap-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  gsoap
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gsoap_${gsoap_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make
  INSTALL_COMMAND make install
  BUILD_IN_SOURCE 1
)

#---csgi-gsoap-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  cgsigsoap
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/CGSI-gSOAP-${cgsigsoap_native_version}.el6.${LCG_ARCH}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1

)

#---PythonFWK (only for MAC) --------------------------------------------------------------------------------------------
LCGPackage_set_home(Python)
if (APPLE)
  set(Python_config_options MACOSX_DEPLOYMENT_TARGET=${MACOSX_VERSION})
  LCGPackage_Add(
    PythonFWK
    URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Python-${Python_native_version}.tgz
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> DYNLOADFILE=dynload_shlib.o 
                                             --enable-framework=<INSTALL_DIR>/Library/Frameworks 
                                             --exec-prefix=<INSTALL_DIR>/Library/Frameworks/Python.framework/Versions/Current 
                                             --enable-unicode=ucs4 ${Python_config_options}
    BUILD_COMMAND ${MAKE} -j1
    INSTALL_COMMAND ${MAKE} -j1 install
	          COMMAND rm -rf <INSTALL_DIR>/bin
    DEST_NAME Python
  )
endif()

if(APPLE)
  set(library_path DYLD_LIBRARY_PATH)
else()
  set(library_path LD_LIBRARY_PATH)
endif()



#---Python--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "slc" OR LCG_TARGET MATCHES "cc" OR LCG_TARGET MATCHES "ubuntu")
  set(Python_config_options --enable-shared "LDFLAGS=-Wl,-rpath,'$$ORIGIN/../lib'")
elseif(LCG_TARGET MATCHES "mac")
  set(Python_config_options --enable-shared MACOSX_DEPLOYMENT_TARGET=${MACOSX_VERSION} LDFLAGS=-L/usr/local/lib)
  set(Python_deps PythonFWK)
else()
  set(Python_config_options --enable-shared)
endif()
if(LCG_TARGET MATCHES "slc6")
  set(Python_config_options --disable-ipv6 ${Python_config_options})
endif()
if(LCG_TARGET MATCHES "icc" AND LCG_TARGET MATCHES "slc6")
  set(Python_config_options --disable-ipv6 --without-gcc --with-cxx-main=${CMAKE_CXX_COMPILER}  ${Python_config_options})
endif()

LCGPackage_Add(
  Python
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Python-${Python_native_version}.tgz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --enable-unicode=ucs4 ${Python_config_options} CPPFLAGS=-I${sqlite_home}/include
  INSTALL_COMMAND ${MAKE} -j1 install
          COMMAND ${CMAKE_SOURCE_DIR}/externals/Python_postinstall.sh <INSTALL_DIR> 
  DEPENDS ${Python_deps} sqlite
)

#---Boost--------------------------------------------------------------------------------------------
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "# \n")  # Start with an empty config file
if(APPLE)
  set(Boost_toolset darwin)
  if(Boost_config_version VERSION_GREATER 1.54.0)
    set(Boost_bootstrap_options --with-python-root=${Python_home} --without-libraries=log)
  else()
    set(Boost_bootstrap_options --with-python-root=${Python_home})
  endif()
else()
  set(Boost_toolset gcc)
  set(Boost_bootstrap_options --with-python=${Python_home}/bin/python)
  if(LCG_TARGET MATCHES "icc" AND LCG_TARGET MATCHES "slc6")
    set(Boost_toolset intel-linux)
  else()
    set(Boost_toolset gcc)
  endif()
endif()

if(CMAKE_BUILD_TYPE STREQUAL Debug)
  set(Boost_jam_options -j4 variant=debug   --layout=versioned)
else()
  set(Boost_jam_options -j4 variant=release --layout=versioned)
endif()

set(Boost_compile_options)
if(LCG_TARGET MATCHES i686 AND LCG_CPP11)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : :  <linkflags>-m32 <compileflags>-m32 -std=gnu++0x ;\n")
elseif(LCG_TARGET MATCHES i686)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : :  <linkflags>-m32 <compileflags>-m32 ;\n")
elseif(LCG_TARGET MATCHES "gcc([0-9]+)" AND LCG_CPP11)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : ${CMAKE_CXX_COMPILER} : <compileflags>-std=gnu++0x ;\n")
elseif(LCG_TARGET MATCHES "gcc([0-9]+)")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : ${CMAKE_CXX_COMPILER} ;\n")
endif()

string(REPLACE "." "_" Boost_file_version ${Boost_config_version})

LCGPackage_Add(
  Boost
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/boost_${Boost_file_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh ${Boost_bootstrap_options} --with-toolset=${Boost_toolset}
  BUILD_COMMAND <SOURCE_DIR>/b2 ${Boost_jam_options} ${Boost_compile_options} --debug-configuration 
                --toolset=${Boost_toolset} --user-config=${CMAKE_CURRENT_BINARY_DIR}/user-config.jam
  INSTALL_COMMAND <SOURCE_DIR>/b2 ${Boost_jam_options} ${Boost_compile_options} --toolset=${Boost_toolset}
                --prefix=<INSTALL_DIR> install --user-config=${CMAKE_CURRENT_BINARY_DIR}/user-config.jam
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

#---GSL----------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "x86_64|slc")
  set(GSL_config_options -with-pic)
endif()

LCGPackage_Add(
  GSL
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gsl-${GSL_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix <INSTALL_DIR> ${GSL_config_options} CC=${CMAKE_C_COMPILER} CFLAGS=-O2
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND ${MAKE} install
          COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/GSL_postinstall.sh <INSTALL_DIR>
  BUILD_IN_SOURCE 1 )

#---CLHEP--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "slc")
  set(CLHEP_config_options  LDFLAGS=-Wl,--hash-style=sysv)
endif()
LCGPackage_Add(
  CLHEP
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/clhep-<NATIVE_VERSION>.tgz
  IF <VERSION> VERSION_LESS 2.1.0 THEN
    CONFIGURE_COMMAND <SOURCE_DIR>/CLHEP/configure --prefix <INSTALL_DIR> ${CLHEP_config_options}
  ELSE
    CONFIGURE_COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
                                       -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} 
                                       <SOURCE_DIR>/CLHEP
  ENDIF
)
#---EIGEN----------------------------------------------------
LCGPackage_Add(
  eigen
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/eigen-<eigen_native_version>.tar.gz

  CONFIGURE_COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} <SOURCE_DIR>
  INSTALL_COMMAND ${MAKE} install				       
)

#---Vc-------------------------------------------------------
LCGPackage_Add(
  Vc
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Vc-<Vc_native_version>.tar.gz

  CONFIGURE_COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>  <SOURCE_DIR>
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND ${MAKE} install
)


#---Davix--------------------------------------------------------------------------------------------
LCGPackage_Add(
  Davix
  URL http://grid-deployment.web.cern.ch/grid-deployment/dms/lcgutil/tar/davix/davix-<NATIVE_VERSION>.tar.gz
  CONFIGURE_COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
                                       -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                                       -DBOOST_ROOT:PATHNAME=${Boost_home}
                                       -DBOOST_INCLUDEDIR=${Boost_home}/include
                                       -DBOOST_LIBRARYDIR=${Boost_home}/lib 
                                       -DBoost_NO_BOOST_CMAKE=True
                                       <SOURCE_DIR>
  DEPENDS Boost
)

#---HepMC--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES i686)
  set(HepMC_config_options --build=i686-unknown-linux-gnu)
endif()
if( ${HepMC_native_version} VERSION_EQUAL githead)
  set(HepMC_source_command GIT_REPOSITORY http://git.cern.ch/pub/HepMC UPDATE_COMMAND <VOID>) 
else()
  set(HepMC_source_command URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/HepMC-${HepMC_native_version}.tar.gz)
endif()

LCGPackage_set_home(cmaketools)

LCGPackage_Add(
  HepMC
  ${HepMC_source_command}
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -Dmomentum:STRING=MEV
             -Dlength:STRING=MM
             -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
  BUILD_COMMAND ${MAKE}
)

foreach(v ${HepMC_native_version})
  LCG_add_test(HepMC-${v}.test
    TEST_COMMAND ${CMAKE_COMMAND} -E chdir ${PROJECT_BINARY_DIR}/externals/HepMC-${v}/src/HepMC-${v}-build/test ctest
  )
endforeach()


#set(hepmc3_source_command GIT_REPOSITORY https://:@git.cern.ch/kerberos/hepmc3)
if( hepmc3_native_version MATCHES "githead")
  set(hepmc3_source_command GIT_REPOSITORY http://git.cern.ch/cernpub/hepmc3)
else()
  set(hepmc3_source_command URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/MCGeneratorsTarFiles/hepmc3-${hepmc3_native_version}.tgz)
endif()

if(heptools_version MATCHES geantv)
  set (hepmc3_options -DROOT_DIR=${ROOT_home}/cmake -DHEPMC_ENABLE_CPP11=ON)
endif()

#---Forward declarations----------------------------------------------------------------------------
LCGPackage_set_home(pythia8)

LCGPackage_Add(
  hepmc3
  ${hepmc3_source_command}
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DBOOST_ROOT=${Boost_home}
             -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DHEPMC_BUILD_EXAMPLES=ON
             -DPYTHIA8_ROOT_DIR=${pythia8_home}
	     ${hepmc3_options}
  BUILD_COMMAND ${MAKE}
  DEPENDS Boost pythia8
)

LCGPackage_Add(
  hepmc3-cxx11
  ${hepmc3_source_command}
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DHEPMC_ENABLE_CPP11=ON
             -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DHEPMC_BUILD_EXAMPLES=ON
             -DPYTHIA8_ROOT_DIR=${pythia8_home}
  BUILD_COMMAND ${MAKE}
  DEPENDS pythia8
)


#---HepPDT-------------------------------------------------------------------------------------------
LCGPackage_Add(
  HepPDT
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/HepPDT-${HepPDT_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix <INSTALL_DIR>  CXX=${CMAKE_CXX_COMPILER}
)

#---pcre----------------------------------------------------------------------------------------------
LCGPackage_Add(
  pcre
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pcre-<VERSION>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)

#---Swig--------------------------------------------------------------------------------------------
LCGPackage_Add(
  swig
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/swig-<VERSION>.tar.gz
  IF <VERSION> VERSION_LESS 2.0.0 THEN
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
  ELSE
    CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --with-pcre-prefix=${pcre_home} PCRE_LIBS=${pcre_home}/lib/libpcre.a
    BUILD_COMMAND ${MAKE} CPPFLAGS=-I${pcre_home}/include
    INSTALL_COMMAND ${MAKE} install
    DEPENDS pcre
  ENDIF
 )

#---FastJet-----------------------------------------------------------------------------------------
LCGPackage_Add(
  fastjet
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/fastjet-${fastjet_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --enable-shared --enable-allplugins
)

#---AIDA--------------------------------------------------------------------------------------------
LCGPackage_Add(
  AIDA
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/aida-${AIDA_native_version}-src.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
)

#---QMtest--------------------------------------------------------------------------------------------
LCGPackage_Add(
  QMtest
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/qmtest-${QMtest_config_version}.tar.gz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/qm/test/classes echo need to change some files
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND ${Python_home}/bin/python setup.py build
  INSTALL_COMMAND ${Python_home}/bin/python setup.py install --prefix=<INSTALL_DIR>
          COMMAND ${CMAKE_SOURCE_DIR}/externals/qmtest_postinstall.sh <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

#---XercesC-------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "i686")
  set (xerces_config_opts --disable-sse2)
endif()
#if((heptools_version MATCHES experimental) OR (heptools_version MATCHES dev2) OR (heptools_version MATCHES dev3) OR (heptools_version MATCHES dev4) )
#  set(xerces_config_opts LIBS=-lc)
#endif()


LCGPackage_Add(
  XercesC
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/xerces-c-<XercesC_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> ${xerces_config_opts}
#  BUILD_COMMAND ${MAKE}
#  INSTALL_COMMAND ${MAKE} install
#  BUILD_IN_SOURCE 1 
)

#---tbb-----------------------------------------------------------------------------------------------
if(CMAKE_CXX_COMPILER_ID MATCHES Clang)
  set(tbb_build_options)       # Use default compiler
else()
  set(tbb_build_options CPLUS=${CMAKE_CXX_COMPILER} CONLY=${CMAKE_C_COMPILER})
endif()

LCGPackage_Add(
  tbb
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/tbb${tbb_native_version}oss_src.tgz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND make ${tbb_build_options}
  INSTALL_COMMAND ${CMAKE_COMMAND} -Dinstall_dir=<INSTALL_DIR> -Dsource_dir=<SOURCE_DIR> -P ${CMAKE_SOURCE_DIR}/cmake/scripts/InstallTBB.cmake 
  BUILD_IN_SOURCE 1
)

#---GCCXML--------------------------------------------------------------------------------------------
if(APPLE)
  set(GCCXML_config_options -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++) # problems compiling with clang
endif()
LCGPackage_Add(
  GCCXML
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gccxml-${GCCXML_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> ${GCCXML_config_options}
  INSTALL_COMMAND ${MAKE} -j1 install
          COMMAND ${CMAKE_SOURCE_DIR}/externals/GCCXML_postinstall.sh <INSTALL_DIR>
)
#---SAS--------------------------------------------------------------------------------------------
LCGPackage_Add(
  sas
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/SAS-${sas_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DLLVM_DEV_DIR=/afs/cern.ch/sw/lcg/external/llvm/3.5/x86_64-slc6
  BUILD_COMMAND make
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy_directory ./lib <INSTALL_DIR>/lib

)

#---uuid--------------------------------------------------------------------------------------------
if(APPLE)
  set(uuid_config_options  --enable-bsd-shlibs --build=x86_64-apple-darwin10.8.0)
else()
  set(uuid_config_options  --enable-elf-shlibs )
endif()

LCGPackage_Add(
  uuid
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/e2fsprogs-${uuid_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> ${uuid_config_options}
  BUILD_COMMAND make -j1 -C lib/uuid
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib
          COMMAND make -j1 -C lib/uuid install
  BUILD_IN_SOURCE 1
)

#---CppUnit--------------------------------------------------------------------------------------------
LCGPackage_Add(
  CppUnit
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/cppunit-<CppUnit_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> ${libtoolpatch}
            COMMAND echo to ignore the status code
  BUILD_IN_SOURCE 1
)

#---graphviz--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES mac108)
  set (graphviz_config_opts -with-pic -enable-swig=no --with-qt=no --with-included-ltdl)
else ()
  set(graphviz_config_opts -with-pic -enable-swig=no --with-qt=no )
endif()
if(LCG_TARGET MATCHES "i686")
  list(APPEND graphviz_config_opts --build=i686-unknown-linux-gnu)
endif()
if (LCG_TARGET MATCHES "icc" AND LCG_TARGET MATCHES "slc6")
   set(graphviz_config_opts CC=gcc CXX=g++)
endif()
if(LCG_OS STREQUAL mac AND LCG_OSVERS VERSION_EQUAL 108)
  set(graphviz_build_opts CFLAGS=-I/usr/X11/include)
endif()
LCGPackage_Add(
  graphviz
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/graphviz-${graphviz_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> ${graphviz_config_opts}
  BUILD_COMMAND make ${graphviz_build_opts}
  BUILD_IN_SOURCE 1
)

#---mysql------------------------------------------------------------------------------------------------
LCGPackage_Add(
  mysql
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/mysql-${mysql_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
             -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
)

#---blas------------------------------------------------------------------------------------------------
LCGPackage_Add(
  blas
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/blas-${blas_native_version}.tgz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND make FORTRAN=${CMAKE_Fortran_COMPILER}  "OPTS=-O3 -fPIC"  BLASLIB=libBLAS.a
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libBLAS.a <INSTALL_DIR>/lib/.
  BUILD_IN_SOURCE 1

)
#---gtest------------------------------------------------------------------------------------------------
LCGPackage_Add(
  gtest
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gtest-${gtest_native_version}.zip
  CONFIGURE_COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -Dgtest_build_samples=ON <SOURCE_DIR> 
  BUILD_COMMAND make
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libgtest.a <INSTALL_DIR>/lib/.	
	  COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libgtest_main.a <INSTALL_DIR>/lib/.	 
	  COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/include <INSTALL_DIR> 
  BUILD_IN_SOURCE 1
  DEPENDS Python 
)


#---lapack------------------------------------------------------------------------------------------------
if (LCG_TARGET MATCHES "icc" AND LCG_TARGET MATCHES "slc6")
   set(lapack_fortran_compiler  gfortran )
else()
   set(lapack_fortran_compiler ${CMAKE_Fortran_COMPILER} )
endif()

LCGPackage_Add(
  lapack
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lapack-${lapack_native_version}.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E touch <SOURCE_DIR>/make.inc
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND make FORTRAN=${lapack_fortran_compiler} 
                     "OPTS=-O3 -fPIC"  "DRVOPTS=-O3 -fPIC" "NOOPT=-fPIC"
                     LOADER=${lapack_fortran_compiler} TIMER=INT_ETIME
                     ARCH=ar ARCHFLAGS=cr RANLIB=ranlib
                     BLASLIB=${blas_home}/lib/libBLAS.a LAPACKLIB=libLAPACK.a
                     SHELL=/bin/sh
                     TMGLIB=tmglib.a EIGSRCLIB=eigsrc.a LINSRCLIB=linsrc.a
                     lapacklib
 INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib
         COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libLAPACK.a <INSTALL_DIR>/lib/.
  BUILD_IN_SOURCE 1
  DEPENDS blas
)

#---Qt---------------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES mac)
  set(Qt_extra_config_opts -no-pch)
endif()
if(LCG_TARGET MATCHES "icc" AND LCG_TARGET MATCHES "slc6")
  set(Qt_extra_config_opts -platform linux-icc -L/afs/cern.ch/sw/IntelSoftware/linux/x86_64/xe2013/composer_xe_2013_sp1.1.106/compiler/lib/intel64)
endif()

LCGPackage_Add(
  Qt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/qt-everywhere-opensource-src-${Qt_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure ${Qt_extra_config_opts} -no-separate-debug-info -release --prefix=<INSTALL_DIR> 
                    -nomake examples -nomake demos --opensource --confirm-license -fast -qt3support
  INSTALL_COMMAND ${MAKE} -j1 install
          COMMAND ${CMAKE_SOURCE_DIR}/externals/Qt_postinstall.sh <INSTALL_DIR> 
  BUILD_IN_SOURCE 1
)
#---Qt5---------------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES mac)
  set(Qt5_extra_config_opts -no-pch)
endif()
if(LCG_TARGET MATCHES "icc" AND LCG_TARGET MATCHES "slc6")
  set(Qt5_extra_config_opts -platform linux-icc -L/afs/cern.ch/sw/IntelSoftware/linux/x86_64/xe2013/composer_xe_2013_sp1.1.106/compiler/lib/intel64)
endif()

LCGPackage_Add(
  Qt5
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/qt-everywhere-opensource-src-${Qt5_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure ${Qt5_extra_config_opts} -no-separate-debug-info -release --prefix=<INSTALL_DIR>
                    -nomake examples -nomake tests --opensource --confirm-license -qt-xcb
  INSTALL_COMMAND ${MAKE} -j1 install
          COMMAND ${CMAKE_SOURCE_DIR}/externals/Qt_postinstall.sh <INSTALL_DIR>
  BUILD_IN_SOURCE 1
)


#---qwt--------------------------------------------------------------------------------------------------
LCGPackage_Add(
  qwt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/qwt-${qwt_native_version}.tar.bz2
  CONFIGURE_COMMAND ${Qt_home}/bin/qmake QWT_INSTALL_PREFIX=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS Qt
)
#---coin3d-----------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "mac")
  set(coin3d_config_opts --without-framework)
endif()

LCGPackage_Add(
  coin3d
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Coin-${coin3d_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --enable-debug=no --enable-symbols=no ${coin3d_config_opts} ${libtoolpatch}
  BUILD_COMMAND  make
  BUILD_IN_SOURCE 1
)

#---doxygen----------------------------------------------------------------------------------------------
LCGPackage_Add(
  doxygen
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/doxygen-${doxygen_native_version}.src.tar.gz
  CONFIGURE_COMMAND ./configure --dot ${graphviz_home}/bin/dot --prefix <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS graphviz
)

#---expat------------------------------------------------------------------------------------------------
LCGPackage_Add(
  expat
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/expat-${expat_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR>
  BUILD_COMMAND ${MAKE} CFLAGS=-fPIC
  BUILD_IN_SOURCE 1
)

#---pacparser------------------------------------------------------------------------------------------------
LCGPackage_Add(
  pacparser
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/pacparser-${pacparser_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND  make -j1 -C src
  INSTALL_COMMAND make -j1 PREFIX=<INSTALL_DIR> -C src install
  BUILD_IN_SOURCE 1
)



#---Frontier_Client--------------------------------------------------------------------------------------
# Frontier_Client depends on additional package - pacparser
# starting on version 2.8.6

set(dep_Frontier_Client expat)
if( ${Frontier_Client_native_version} VERSION_GREATER 2.8.6 )
      set(dep_Frontier_Client expat pacparser)
endif()

LCGPackage_Add(
  Frontier_Client
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/frontier_client__${Frontier_Client_native_version}__src.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND make -j1 dist PACPARSER_DIR=${pacparser_home} EXPAT_DIR=${expat_home} ${library_path}=${expat_home}/lib:$ENV{${library_path}}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/dist <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS ${dep_Frontier_Client}
)

#---lcov-------------------------------------------------------------------------------------------------
if(NOT APPLE) # There are problems building on MacOSX
  LCGPackage_Add(
    lcov
    URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lcov-${lcov_native_version}.tar.gz
    CONFIGURE_COMMAND <VOID>
    BUILD_COMMAND  <VOID>
    INSTALL_COMMAND make install PREFIX=<INSTALL_DIR>
          COMMAND ${CMAKE_COMMAND} -E copy_directory <INSTALL_DIR>/usr/bin <INSTALL_DIR>/bin
          COMMAND ${CMAKE_COMMAND} -E copy_directory <INSTALL_DIR>/usr/share/man <INSTALL_DIR>/man 
          COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/usr/share
          COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/usr/
    BUILD_IN_SOURCE 1
  ) 
endif()

#---soqt-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  soqt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/SoQt-${soqt_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --enable-debug=no --enable-symbols=no --with-coin=${coin3d_home} --with-qt=${Qt_home} QTDIR=${Qt_home}
  BUILD_COMMAND  make CONFIG_QTLIBS='-lQt3Support -lQtCore' QTDIR=${Qt_home} COINDIR=${coin3d_home} 
  BUILD_IN_SOURCE 1
  DEPENDS coin3d Qt
)

#---libtool----------------------------------------------------------------------------------------------
LCGPackage_Add(
  libtool
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/libtool-${libtool_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)

#---libunwind--------------------------------------------------------------------------------------------
LCGPackage_Add(
  libunwind
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/libunwind-${libunwind_native_version}.tar.gz
  CONFIGURE_COMMAND autoreconf -i
            COMMAND ./configure --prefix=<INSTALL_DIR> CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER}
  BUILD_COMMAND  make CFLAGS=-fPIC
  BUILD_IN_SOURCE 1
)
#---tcmalloc--------------------------------------------------------------------------------------------
if(NOT APPLE) # There are problems building on MacOSX
  if(LCG_TARGET MATCHES "x86_64")
    set(tcmalloc_config_options "--enable-frame-pointers")
  endif()
  if(LCG_TARGET MATCHES "ubuntu")
    set(tcmalloc_config_options ${tcmalloc_config_options} "CXXFLAGS=-fpermissive")
  endif()
  LCGPackage_Add(
    tcmalloc
    IF <VERSION> VERSION_GREATER 2.0 THEN
      URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gperftools-${tcmalloc_native_version}.tar.gz
    ELSE
      URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/google-perftools-${tcmalloc_native_version}.tar.gz
    ENDIF
    CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> ${tcmalloc_config_options}
    BUILD_IN_SOURCE 1
  )
else()
  add_custom_target(tcmalloc ALL COMMENT "Dummy tcmalloc target")
endif()

#---neurobayes-------------------------------------------------------------------------------------------
LCGPackage_Add(
  neurobayes
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/neurobayes-${neurobayes_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---neurobayes_expert------------------------------------------------------------------------------------
LCGPackage_Add(
  neurobayes_expert
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/neurobayes_expert-${neurobayes_expert_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---openmpi-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  openmpi
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/openmpi-${openmpi_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND ${MAKE} 
  BUILD_IN_SOURCE 1
)


LCGPackage_Add(
  mpich2
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/mpich2-${mpich2_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --enable-shared --enable-sharedlibs=gcc --with-pm=mpd "CFLAGS=-O2 -g0 -fPIC"
  BUILD_COMMAND ${MAKE} all
  BUILD_IN_SOURCE 1
)




#---oracle-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  oracle
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/oracle-${oracle_native_version}-${LCG_ARCH}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---fftw------------------------------------------------------------------------------------------------
LCGPackage_Add(
  fftw
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/fftw-${fftw_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>  --enable-shared
  BUILD_COMMAND make CFLAGS=-fPIC
  BUILD_IN_SOURCE 1
)

#---igprof----------------------------------------------------------------------------------------------
LCGPackage_Add(
  igprof
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/igprof-${igprof_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
             -DUNWIND_INCLUDE_DIR:PATH=${libunwind_home}/include
             -DUNWIND_LIBRARY:FILEPATH=${libunwind_home}/lib/libunwind.so
             "-DCMAKE_CXX_FLAGS=-Wno-unused-variable -Wno-error=unused-result"
  DEPENDS libunwind
)

#---valgrind--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES mac108)
  set (valgrind_build_opts CFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future)
endif()
LCGPackage_Add(
  valgrind
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/valgrind-${valgrind_native_version}.tar.bz2
  CONFIGURE_COMMAND chmod +x ./configure 
            COMMAND ./configure --prefix=<INSTALL_DIR> 
  BUILD_COMMAND make ${valgrind_build_opts}
  BUILD_IN_SOURCE 1
)

#---vdt-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  vdt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/vdt-${vdt_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  BUILD_IN_SOURCE 1
)

# Depends on KDE; bad idea to have it as part of the externals
#---kcachegrind------------------------------------------------------------------------------------------
#LCGPackage_Add(
#  kcachegrind
#  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/kcachegrind-${kcachegrind_native_version}.tar.gz
#  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
#  BUILD_IN_SOURCE 1
#)


#---xqilla----------------------------------------------------------------------------------------------
set(xqilla_CXXFLAGS "${CMAKE_CXX_FLAGS} -fpermissive")
LCGPackage_Add(
  xqilla
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/XQilla-${xqilla_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> 
                                --with-xerces=${XercesC_home} 
                                --disable-rpath
  BUILD_COMMAND make CXXFLAGS=${xqilla_CXXFLAGS}
  BUILD_IN_SOURCE 1
  DEPENDS XercesC
)

#---xrootd----------------------------------------------------------------------------------------------
LCGPackage_Add(
  xrootd
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/xrootd-${xrootd_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DENABLE_PERL=FALSE -DENABLE_FUSE=FALSE -DENABLE_CRYPTO=TRUE -DENABLE_KRB5=TRUE -DENABLE_READLINE=TRUE
)


#---ftjam------------------------------------------------------------------------------------------------
LCGPackage_Add(
  ftjam
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/ftjam-${ftjam_native_version}.zip
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND ${MAKE}
  INSTALL_COMMAND ${MAKE} install
  BUILD_IN_SOURCE 1
)

#---omniORB------------------------------------------------------------------------------------------------
LCGPackage_Add(
  omniorb
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/omniORB-${omniorb_native_version}.tar.bz2
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND ${MAKE} CPPFLAGS=-I${Python_home}/include
  INSTALL_COMMAND ${MAKE} install
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

