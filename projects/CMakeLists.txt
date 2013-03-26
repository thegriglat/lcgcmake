#---ROOT--------------------------------------------------------------------------------------------
LCGPackage_Add(
  ROOT
  URL ftp://root.cern.ch/root/root_v${ROOT_native_version}.source.tar.gz
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} 
             -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR> 
             -Dpython=ON -DPYTHON_EXECUTABLE=${Python_home}/bin/python
                         -DPYTHON_INCLUDE_DIR=${Python_home}/include/python${Python_config_version_twodigit}
                         -DPYTHON_LIBRARY=${Python_home}/lib/libpython${Python_config_version_twodigit}${CMAKE_SHARED_LIBRARY_SUFFIX}
  DEPENDS Python
)

#---cmaketool----------------------------------------------------------------------------------------
LCGPackage_Add(
  cmaketools
  SVN_REPOSITORY  http://svnweb.cern.ch/guest/cmaketools/trunk
  PATCH_COMMAND patch -p0 -t -N -i  ${CMAKE_CURRENT_SOURCE_DIR}/cmaketools.patch
  UPDATE_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
)

#---RELAX---------------------------------------------------------------------------------------------
LCGPackage_Add(
  RELAX
  SVN_REPOSITORY http://svnweb.cern.ch/guest/relax/tags/${RELAX_native_version}/relax
  UPDATE_COMMAND <VOID>
  PATCH_COMMAND patch -p0 -i ${CMAKE_CURRENT_SOURCE_DIR}/${RELAX_native_version}.patch
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
             -DROOTSYS=${ROOT_home}
             -DGCCXML=${GCCXML_home}/bin/gccxml
             -DCLHEP_ROOT_DIR=${CLHEP_home}
             -DHEPMC_ROOT_DIR=${HepMC_home}
             -DHEPPDT_ROOT_DIR=${HepPDT_home}
  BUILD_COMMAND make ROOTSYS=${ROOT_home}
  DEPENDS cmaketools ROOT GCCXML CLHEP HepMC HepPDT
)

#---LCGCMT--------------------------------------------------------------------------------------------
LCGPackage_Add(
  LCGCMT
  DOWNLOAD_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND mkdir -p <INSTALL_DIR>)

  
#---GaudiDeps------------------------------------------------------------------------------------------
set(GAUDI-dependencies AIDA Boost Python GSL ROOT QMtest CLHEP HepMC HepPDT RELAX 
                       GCCXML tbb XercesC uuid LCGCMT CppUnit tcmalloc)
foreach(dep ${GAUDI-dependencies})
  if(TARGET install-${dep})
    list(APPEND GAUDI-installs install-${dep})
  endif()
endforeach()

add_custom_target(GAUDI-externals
                 COMMENT "Target to build all externals packages needed by Gaudi"
                 DEPENDS ${GAUDI-dependencies})

add_custom_target(install-GAUDI-externals
                 COMMENT "Target to install all externals packages needed by Gaudi"
                 DEPENDS ${GAUDI-installs} )

