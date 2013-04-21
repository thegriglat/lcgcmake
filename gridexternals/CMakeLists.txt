#---cream------------------------------------------------------------------------------------------------
LCGPackage_Add(
  cream
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/cream-${cream_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---epel-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  epel
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/epel-${epel_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)


#---gfal-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  gfal
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gfal-${gfal_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---gfal2------------------------------------------------------------------------------------------------
LCGPackage_Add(
  gfal2
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gfal2-${gfal2_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)


#---lcgdmcommon------------------------------------------------------------------------------------------
LCGPackage_Add(
  lcgdmcommon
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lcgdmcommon-${lcgdmcommon_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---lcginfosites-----------------------------------------------------------------------------------------
LCGPackage_Add(
  lcginfosites
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lcginfosites-${lcginfosites_native_version}-noarch.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---lfc-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  lfc
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lfc-${lfc_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---voms-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  voms
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/voms-${voms_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)
