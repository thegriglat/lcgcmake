#---Python--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "slc" OR LCG_TARGET MATCHES "ubuntu")
  set(Python_config_options --enable-shared "LDFLAGS=-Wl,-rpath,'$$ORIGIN/../lib'")
elseif(LCG_TARGET MATCHES "mac")
  string(REGEX REPLACE "([0-9]+)([0-9])" \\1.\\2 macvers ${LCG_HOST_OSVERS})
  set(Python_config_options --enable-shared MACOSX_DEPLOYMENT_TARGET=${macvers} LDFLAGS=-L/opt/local/lib)
else()
  set(Python_config_options --enable-shared)
endif()
if(LCG_TARGET MATCHES "slc6")
  set(Python_config_options --disable-ipv6 ${Python_config_options})
endif()
LCGPackage_Add(
  Python
  URL http://python.org/ftp/python/${Python_native_version}/Python-${Python_native_version}.tgz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR> --enable-unicode=ucs4 ${Python_config_options}
)

#---Boost--------------------------------------------------------------------------------------------
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "# \n")  # Start with an empty config file
if(APPLE)
  set(Boost_toolset darwin)
  set(Boost_bootstrap_options --with-python-root=${Python_home})
else()
  set(Boost_toolset gcc)
  set(Boost_bootstrap_options --with-python=${Python_home}/bin/python)
endif()
set(Boost_jam_options -j4 variant=release --layout=versioned)
set(Boost_compile_options)
if(LCG_TARGET MATCHES i686)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : :  <linkflags>-m32 <compileflags>-m32 ;\n")
elseif(LCG_TARGET MATCHES "gcc([0-9]+)")
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : ${CMAKE_CXX_COMPILER} ;\n")
endif()
string(REPLACE "." "_" Boost_file_version ${Boost_config_version})

LCGPackage_Add(
  Boost
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/boost_${Boost_file_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh ${Boost_bootstrap_options}
  BUILD_COMMAND <SOURCE_DIR>/b2 ${Boost_jam_options} ${Boost_compile_options}
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
  URL http://mirror.switch.ch/ftp/mirror/gnu/gsl/gsl-${GSL_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix <INSTALL_DIR> ${GSL_config_options} CC=${CMAKE_C_COMPILER} CFLAGS=-O2
  BUILD_IN_SOURCE 1 )

#---CLHEP--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "slc")
  set(CLHEP_config_options  LDFLAGS=-Wl,--hash-style=sysv)
endif()

LCGPackage_Add(
  CLHEP
  URL http://proj-clhep.web.cern.ch/proj-clhep/DISTRIBUTION/tarFiles/clhep-${CLHEP_native_version}.tgz
  PATCH_COMMAND patch -p0 -i ${CMAKE_CURRENT_SOURCE_DIR}/CLHEP-${CLHEP_native_version}.patch
  CONFIGURE_COMMAND <SOURCE_DIR>/CLHEP/configure --prefix <INSTALL_DIR> ${CLHEP_config_options}
)

#---HepMC--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES i686)
   set(HepMC_config_options --build=i686-unknown-linux-gnu)
endif()
LCGPackage_Add(
  HepMC
  URL http://lcgapp.cern.ch/project/simu/HepMC/download/HepMC-${HepMC_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix <INSTALL_DIR> --with-momentum=MEV 
                                           --with-length=MM ${HepMC_config_options}  CXX=${CMAKE_CXX_COMPILER}
)

#---HepPDT-------------------------------------------------------------------------------------------
LCGPackage_Add(
  HepPDT
  URL http://lcgapp.cern.ch/project/simu/HepPDT/download/HepPDT-${HepPDT_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix <INSTALL_DIR>  CXX=${CMAKE_CXX_COMPILER}
)

#---Swig--------------------------------------------------------------------------------------------
LCGPackage_Add(
  swig
  URL http://prdownloads.sourceforge.net/swig/swig-${swig_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
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
  BUILD_IN_SOURCE 1
  DEPENDS Python
)

#---XercesC-------------------------------------------------------------------------------------------
LCGPackage_Add(
  XercesC
  URL http://mirror.switch.ch/mirror/apache/dist//xerces/c/3/sources/xerces-c-<XercesC_<NATIVE_VERSION>_author>.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
)

#---tbb-----------------------------------------------------------------------------------------------
if(CMAKE_CXX_COMPILER_ID MATCHES Clang)
  set(tbb_build_options)       # Use default compiler
else()
  set(tbb_build_options CPLUS=${CMAKE_CXX_COMPILER} CONLY=${CMAKE_C_COMPILER})
endif()

LCGPackage_Add(
  tbb
  URL http://threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb${tbb_native_version}oss_src.tgz
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
  INSTALL_COMMAND mkdir -p <INSTALL_DIR>/lib
          COMMAND make -j1 -C lib/uuid install
  BUILD_IN_SOURCE 1
)

#---CppUnit--------------------------------------------------------------------------------------------
LCGPackage_Add(
  CppUnit
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/cppunit-<CppUnit_<NATIVE_VERSION>_author>.tar.gz
  PATCH_COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/CppUnit-${CppUnit_native_version}.patch
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR>
            COMMAND echo to ignore the status code
  BUILD_IN_SOURCE 1
)

#---tcmalloc--------------------------------------------------------------------------------------------
if(NOT APPLE) # There are problems building on MacOSX
  if(LCG_TARGET MATCHES "x86_64")
    set(tcmalloc_config_options "--enable-frame-pointers")
  endif()
  LCGPackage_Add(
    tcmalloc
    URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/google-perftools-${tcmalloc_native_version}.tar.gz
    PATCH_COMMAND patch -p1 -i ${CMAKE_CURRENT_SOURCE_DIR}/tcmalloc-${tcmalloc_native_version}.patch
    CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> ${tcmalloc_config_options}
    BUILD_IN_SOURCE 1
  )
else()
  add_custom_target(tcmalloc ALL COMMENT "Dummy tcmalloc target")
endif()

#---graphviz--------------------------------------------------------------------------------------------
set(graphviz_config_opts -with-pic -enable-swig=no --with-qt=no)
if(LCG_TARGET MATCHES "i686")
  list(APPEND graphviz_config_opts --build=i686-unknown-linux-gnu)
endif()
if(LCG_TARGET MATCHES mac108)
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
  INSTALL_COMMAND mkdir -p <INSTALL_DIR>/lib
          COMMAND cp <SOURCE_DIR>/libBLAS.a <INSTALL_DIR>/lib/.
  BUILD_IN_SOURCE 1

)

#---lapack------------------------------------------------------------------------------------------------
LCGPackage_Add(
  lapack
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lapack-${lapack_native_version}.tgz
  UPDATE_COMMAND ${CMAKE_COMMAND} -E touch <SOURCE_DIR>/make.inc
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND make FORTRAN=${CMAKE_Fortran_COMPILER} 
                     "OPTS=-O3 -fPIC"  "DRVOPTS=-O3 -fPIC" "NOOPT=-fPIC"
                     LOADER=${CMAKE_Fortran_COMPILER} TIMER=INT_ETIME
                     ARCH=ar ARCHFLAGS=cr RANLIB=ranlib
                     BLASLIB=${blas_home}/lib/libBLAS.a LAPACKLIB=libLAPACK.a
                     SHELL=/bin/sh
                     TMGLIB=tmglib.a EIGSRCLIB=eigsrc.a LINSRCLIB=linsrc.a
                     lapacklib
  INSTALL_COMMAND mkdir -p <INSTALL_DIR>/lib
          COMMAND cp <SOURCE_DIR>/libLAPACK.a <INSTALL_DIR>/lib/.
  BUILD_IN_SOURCE 1
)

#---Qt---------------------------------------------------------------------------------------------------
#set_append LCG_qt_extra_config_opts " -qt-xcb "
# target-slc&target-i686 "-no-phonon-backend -no-multimedia -platform linux-g++ -arch i386"
# target-darwin&target-x86_64 "-no-framework -D MSG=MSGqtmac -arch x86_64"
# target-darwin&target-i386 "-no-framework -D MSG=MSGqtmac -arch i386"

LCGPackage_Add(
  Qt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/qt-everywhere-opensource-src-${Qt_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure ${Qt_extra_config_opts} -no-separate-debug-info -release --prefix=<INSTALL_DIR> 
                    -nomake examples -nomake demos --opensource --confirm-license
  BUILD_IN_SOURCE 1
)


