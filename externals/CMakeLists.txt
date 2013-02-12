#---Boost--------------------------------------------------------------------------------------------
# TODO add the dependency to Python

set(Boost_jam_options -j12 variant=release --layout=versioned)
set(Boost_compile_options -j4)
if(APPLE)
  set(Boost_toolset darwin)
else()
  set(Boost_toolset gcc)
endif()
string(REPLACE "." "_" Boost_file_version ${Boost_config_version})
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/user-config.jam "")

LCGPackage_Add(
  Boost
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/boost_${Boost_file_version}.tar.gz
  CONFIGURE_COMMAND <SOURCE_DIR>/bootstrap.sh
  BUILD_COMMAND <SOURCE_DIR>/b2 -j 4 ${Boost_jam_opts} ${Boost_compile_options}
                --toolset=${Boost_toolset} --user-config=${CMAKE_CURRENT_BINARY_DIR}/user-config.jam
  INSTALL_COMMAND <SOURCE_DIR>/b2 -j 4 --prefix=<INSTALL_DIR> install
  BUILD_IN_SOURCE 1
)

#---Python--------------------------------------------------------------------------------------------
LCGPackage_Add(
  Python
  URL http://python.org/ftp/python/${Python_native_version}/Python-${Python_native_version}.tgz
  CONFIGURE_COMMAND <SOURCE_DIR>/configure --enable-shared --prefix=<INSTALL_DIR> --enable-unicode=ucs4
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

