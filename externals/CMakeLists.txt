#---Python--------------------------------------------------------------------------------------------
if(LCG_TARGET MATCHES "slc")
  set(Python_config_options "LDFLAGS=-Wl,-rpath,'$$ORIGIN/../lib'")
endif()
LCGPackage_Add(
  Python
  URL http://python.org/ftp/python/${Python_native_version}/Python-${Python_native_version}.tgz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --enable-shared --prefix=<INSTALL_DIR> --enable-unicode=ucs4 ${Python_config_options}
)

#---Boost--------------------------------------------------------------------------------------------
set(Boost_jam_options -j12 variant=release --layout=versioned)
set(Boost_compile_options)
if(APPLE)
  set(Boost_toolset darwin)
else()
  set(Boost_toolset gcc)
endif()

string(REPLACE "." "_" Boost_file_version ${Boost_config_version})

file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using python : ${Python_config_version_twodigit} : ${Python_home} ;\n")
if(LCG_TARGET MATCHES i686)
  file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "using gcc : : :  <linkflags>-m32 <compileflags>-m32 ;")
endif()

LCGPackage_Add(
  Boost
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/boost_${Boost_file_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh
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
  CONFIGURE_COMMAND <SOURCE_DIR>/CLHEP/configure --prefix <INSTALL_DIR> ${CLHEP_config_options} CC=${CMAKE_C_COMPILER}
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
  URL http://fastjet.fr/repo/fastjet-${fastjet_native_version}.tar.gz
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
  URL http://mirror.switch.ch/mirror/apache/dist//xerces/c/3/sources/xerces-c-${XercesC_config_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --prefix=<INSTALL_DIR>
)

#---TBB-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  TBB
  URL http://threadingbuildingblocks.org/sites/default/files/software_releases/source/tbb${TBB_native_version}oss_src.tgz
  CONFIGURE_COMMAND <VOID>
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


