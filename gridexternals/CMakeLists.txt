#---CASTOR-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  CASTOR
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/CASTOR-${CASTOR_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

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

#---dcap------------------------------------------------------------------------------------------------
LCGPackage_Add(
  dcap
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/dcap-${dcap_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---dm-util-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  dm-util
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/dm-util-${dm-util_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---dpm---------------------------------------------------------------------------------------------------
LCGPackage_Add(
  dpm
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/dpm-${dpm_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
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

#---FTS--------------------------------------------------------------------------------------------------
LCGPackage_Add(
  FTS
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/FTS-${FTS_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---FTS3--------------------------------------------------------------------------------------------------
LCGPackage_Add(
  FTS3
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/FTS3-${FTS3_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
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

#---gridftp_ifce-----------------------------------------------------------------------------------------
LCGPackage_Add(
  gridftp_ifce
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gridftp-ifce-${gridftp_ifce_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---gridsite---------------------------------------------------------------------------------------------
LCGPackage_Add(
  gridsite
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/gridsite-${gridsite_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---is_ifce---------------------------------------------------------------------------------------------
LCGPackage_Add(
  is_ifce
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/is-ifce-${is_ifce_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---lb--------------------------------------------------------------------------------------------------
LCGPackage_Add(
  lb
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/lb-${lb_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---WMS-------------------------------------------------------------------------------------------------
LCGPackage_Add(
  WMS
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/WMS-${WMS_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
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

#---srm_ifce---------------------------------------------------------------------------------------------
LCGPackage_Add(
  srm_ifce
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/srm_ifce-${srm_ifce_native_version}-${LCG_ARCH}-${LCG_OS}${LCG_OSVERS}.tar.gz
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
