cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

include(ExternalProject)
set(LOCAL_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/LocalInstallArea)

#----------------------------------------------------------------------------------------------------
#---LCGPackage_Add macro  ---------------------------------------------------------------------------
#
#   This is a wrapper of the ExternalProject_Add function customized for LCG packages
#
#----------------------------------------------------------------------------------------------------
macro(LCGPackage_Add name)
  if(EXISTS ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${${name}_native_version}/${LCG_system})

    set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${${name}_native_version}/${LCG_system})
    add_custom_target(${name} COMMENT "${name} package already existing in ${${name}_home}")
    message("taget: ${name}")

  else()

    set(${name}_home ${LOCAL_INSTALL_PREFIX}/${${name}_directory_name}/${${name}_native_version}/${LCG_system})
    ExternalProject_Add( 
      ${name}
      INSTALL_DIR ${${name}_home}
      ${ARGN}
      LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
    )

    install(DIRECTORY ${${name}_home}/ DESTINATION ${${name}_directory_name}/${${name}_native_version}/${LCG_system})
    foreach(ph configure-out configure-err build-out build-err install-out install-err)
      install(FILES ${CMAKE_BINARY_DIR}/${name}-prefix/src/${name}-stamp/${name}-${ph}.log
            DESTINATION ${${name}_directory_name}/${${name}_native_version}/logs
            RENAME ${name}-${LCG_system}-${ph}.log)
    endforeach()
  endif()
endmacro()


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
  set(CLHEP_config_options  LDFLAGS="-Wl,--hash-style=sysv")
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

#---pythia8------------------------------------------------------------------------------------------
LCGPackage_Add(
  pythia8
  URL http://home.thep.lu.se/~torbjorn/pythia8/pythia8${pythia8_native_version}.tgz
  CONFIGURE_COMMAND ./configure --prefix <INSTALL_DIR> --lcgplatform=${LCG_TARGET} --enable-shared --with-hepmc=${HepMC-home}
  BUILD_IN_SOURCE 1
  INSTALL_COMMAND cmake -E copy_directory <SOURCE_DIR>/include  <INSTALL_DIR>/include
          COMMAND cmake -E copy_directory <SOURCE_DIR>/lib  <INSTALL_DIR>/lib
          COMMAND cmake -E copy_directory <SOURCE_DIR>/xmldoc  <INSTALL_DIR>/xmldoc
)
add_dependencies(pythia8 HepMC)

