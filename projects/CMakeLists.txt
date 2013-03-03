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
    CONFIGURE_COMMAND echo nothing is needed for configuration
    BUILD_COMMAND echo nothing is needed for build
    INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
)

#---RELAX---------------------------------------------------------------------------------------------
LCGPackage_Add(
  RELAX
  SVN_REPOSITORY http://svnweb.cern.ch/guest/relax/tags/${RELAX_native_version}/relax
  DEPENDS cmaketools ROOT CLHEP)
  
