#---Python--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "slc" OR LCG_TARGET MATCHES "ubuntu")
  set(Python_config_options --enable-shared "LDFLAGS=-Wl,-rpath,'$$ORIGIN/../lib'")
elseif(LCG_TARGET MATCHES "mac")
  string(REGEX REPLACE "([0-9]+)([0-9])" \\1.\\2 macvers ${LCG_HOST_OSVERS})
  set(Python_config_options --enable-shared MACOSX_DEPLOYMENT_TARGET=${macvers} LDFLAGS=-L/usr/local/lib)
else()
  set(Python_config_options --enable-shared)
endif()
if(LCG_TARGET MATCHES "slc6")
  set(Python_config_options --disable-ipv6 ${Python_config_options})
endif()
LCGPackage_Add(
  Python
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/Python-${Python_native_version}.tgz
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
if(LCG_TARGET MATCHES i686 AND LCG_CPP11)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : :  <linkflags>-m32 <compileflags>-m32 -std=gnu++0x;\n")
elseif(LCG_TARGET MATCHES i686)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : :  <linkflags>-m32 <compileflags>-m32 ;\n")
elseif(LCG_TARGET MATCHES "gcc([0-9]+)" AND LCG_CPP11)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using ${Boost_toolset} : : ${CMAKE_CXX_COMPILER} <compileflags>-std=gnu++0x;\n")
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
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gsl-${GSL_native_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix <INSTALL_DIR> ${GSL_config_options} CC=${CMAKE_C_COMPILER} CFLAGS=-O2
  BUILD_IN_SOURCE 1 )

#---CLHEP--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "slc")
  set(CLHEP_config_options  LDFLAGS=-Wl,--hash-style=sysv)
endif()
LCGPackage_Add(
  CLHEP
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/clhep-<NATIVE_VERSION>.tgz
  CONFIGURE_COMMAND <SOURCE_DIR>/CLHEP/configure --prefix <INSTALL_DIR> ${CLHEP_config_options}
)

#---CLHEP2--------------------------------------------------------------------------------------------
LCGPackage_Add(
  CLHEP2
  URL http://proj-clhep.web.cern.ch/proj-clhep/DISTRIBUTION/tarFiles/clhep-<NATIVE_VERSION>.tgz
  CONFIGURE_COMMAND ${CMAKE_COMMAND} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> -DCMAKE_BUILD_TYPE=Release <SOURCE_DIR>/CLHEP
)

#---HepMC--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES i686)
   set(HepMC_config_options --build=i686-unknown-linux-gnu)
endif()
LCGPackage_Add(
  HepMC
  URL http://lcgapp.cern.ch/project/simu/HepMC/download/HepMC-${HepMC_native_version}.tar.gz
  CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -Dmomentum:STRING=MEV
             -Dlength:STRING=MM
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
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libBLAS.a <INSTALL_DIR>/lib/.
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
  INSTALL_COMMAND ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>/lib
          COMMAND ${CMAKE_COMMAND} -E copy <SOURCE_DIR>/libLAPACK.a <INSTALL_DIR>/lib/.
  BUILD_IN_SOURCE 1
  DEPENDS blas
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
                    -nomake examples -nomake demos --opensource --confirm-license -fast
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
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --enable-debug=no --enable-symbols=no ${coin3d_config_opts}
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
  BUILD_IN_SOURCE 1
)

#---Frontier_Client--------------------------------------------------------------------------------------
LCGPackage_Add(
  Frontier_Client
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/frontier_client__${Frontier_Client_native_version}__src.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND make dist EXPAT_DIR=${expat_home} LD_LIBRARY_PATH=${expat_home}/lib:$ENV{LD_LIBRARY_PATH}
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/dist <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  DEPENDS expat
)

#---lcov-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  lcov
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lcov-${lcov_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND  <VOID>
  INSTALL_COMMAND make install PREFIX=<INSTALL_DIR>
          COMMAND ${CMAKE_COMMAND} -E rename <INSTALL_DIR>/usr/bin <INSTALL_DIR>/bin
          COMMAND ${CMAKE_COMMAND} -E rename <INSTALL_DIR>/usr/share/man <INSTALL_DIR>/man 
          COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/usr/share
          COMMAND ${CMAKE_COMMAND} -E remove_directory <INSTALL_DIR>/usr/
  BUILD_IN_SOURCE 1
)

#---soqt-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  soqt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/SoQt-${soqt_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR> --enable-debug=no --enable-symbols=no --with-coin=${coin3d_home} --with-qt=${Qt_home}
  BUILD_COMMAND  make CONFIG_QTLIBS='-lQt3Support -lQtCore' QTDIR=${Qt_home} COINDIR=${coin3d_home} 
  BUILD_IN_SOURCE 1
  DEPENDS coin3d Qt
)

#---sqlite-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  sqlite
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/sqlite-autoconf-${sqlite_native_version}.tar.gz
  CONFIGURE_COMMAND ./configure --prefix=<INSTALL_DIR>
  BUILD_COMMAND  make 
  BUILD_IN_SOURCE 1
#  DEPENDS Python
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

#---oracle-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  oracle
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/oracle-${oracle_native_version}.tar.gz
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
  DEPENDS libunwind
)

#---valgrind--------------------------------------------------------------------------------------------
LCGPackage_Add(
  valgrind
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/valgrind-${valgrind_native_version}.tar.bz2
  CONFIGURE_COMMAND chmod +x ./configure 
            COMMAND ./configure --prefix=<INSTALL_DIR> 
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
