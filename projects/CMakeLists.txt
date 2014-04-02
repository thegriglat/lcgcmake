#--- General parameters ----------------------------------------------------------------------------
set(cmt_exec_cmd ${CMAKE_SOURCE_DIR}/cmake/scripts/exec-cmt-with-env)
set(Python_cmd ${Python_home}/bin/python)

#--- Check for lib64 -------------------------------------------------------------------------------
get_property(LIB64 GLOBAL PROPERTY FIND_LIBRARY_USE_LIB64_PATHS) 
if (${LIB64} STREQUAL "TRUE") 
    set(LIBSUFFIX 64) 
else() 
    set(LIBSUFFIX "") 
endif() 

#---Forward declarations----------------------------------------------------------------------------
LCGPackage_set_home(pythia8)

#---ROOT--------------------------------------------------------------------------------------------
string(REGEX MATCH "[0-9]+[.][0-9]+[.][0-9]+" ROOT_author_version ${ROOT_native_version})

if(LCG_TARGET MATCHES "mac.*-gcc(47|48)")
  LCGPackage_Add(
    ROOT
    IF <VERSION> VERSION_EQUAL v5-34-00-patches THEN
      GIT_REPOSITORY http://root.cern.ch/git/root.git GIT_TAG <VERSION>
      UPDATE_COMMAND <VOID>
    ELSE
      URL ftp://root.cern.ch/root/root_v${ROOT_author_version}.source.tar.gz
    ENDIF
    CONFIGURE_COMMAND ./configure --with-cc=${CMAKE_C_COMPILER}
                                  --with-cxx=${CMAKE_CXX_COMPILER}
                                  --with-ld=${CMAKE_CXX_COMPILER}
                                  --with-python-incdir=${Python_home}/include/python${Python_config_version_twodigit}
                                  --with-python-libdir=${Python_home}/lib
                                  --fail-on-missing
                                  --enable-builtin-pcre
                                  --enable-cintex
                                  --enable-explicitlink
                                  --enable-gdml
                                  --enable-genvector
                                  --enable-krb5
                                  --enable-mathmore
                                  --enable-minuit2
                                  --enable-mysql
                                  --enable-oracle
                                  --enable-python
                                  --enable-qt
                                  --enable-qtgsi
                                  --enable-reflex
                                  --enable-roofit
                                  --enable-table
                                  --enable-unuran
                                  --with-cint-maxstruct=36000
                                  --with-cint-maxtypedef=36000
                                  --with-cint-longline=4096
                                  --with-castor-incdir=${CASTOR_home}/include/shift
                                  --with-castor-libdir=${CASTOR_home}/lib${LIBSUFFIX}
                                  --with-dcap-libdir=${dcache_client_home}/lib
                                  --with-dcap-incdir=${dcache_client_home}/include
                                  --with-fftw3-incdir=${fftw_home}/include
                                  --with-fftw3-libdir=${fftw_home}/lib
                                  --with-gccxml=${GCCXML_home}
                                  --with-gfal-libdir=${gfal_home}/lib
                                  --with-gfal-incdir=${gfal_home}/include
                                  --with-gsl-incdir=${GSL_home}/include
                                  --with-gsl-libdir=${GSL_home}/lib
                                  --with-mysql-incdir=${mysql_home}/include
                                  --with-mysql-libdir=${mysql_home}/lib
                                  --with-oracle-incdir=${oracle_home}/include
                                  --with-oracle-libdir=${oracle_home}/lib
                                  --with-rfio-incdir=${CASTOR_home}/include/shift
                                  --with-rfio-libdir=${CASTOR_home}/lib${LIBSUFFIX}
                                  --disable-gviz   # compilation errors (see https://sft.its.cern.ch/jira/browse/ROOT-176)
    INSTALL_COMMAND  make dist
            COMMAND  $ENV{SHELL} -c "rm <SOURCE_DIR>/../root_v${ROOT_native_version}.source.tar.gz"
            COMMAND  ${CMAKE_COMMAND} -E make_directory <INSTALL_DIR>
            COMMAND  $ENV{SHELL} -c "tar -C <INSTALL_DIR> --strip=1 -xf <SOURCE_DIR>/../root_v${ROOT_native_version}*.tar.gz"
    BUILD_IN_SOURCE 1
    DEPENDS Python CASTOR dcap fftw gfal graphviz GSL mysql oracle Qt xrootd srm_ifce
  )
else()
 LCGPackage_Add(
    ROOT
    IF <VERSION> VERSION_EQUAL v5-34-00-patches OR <VERSION> VERSION_EQUAL HEAD THEN
      GIT_REPOSITORY http://root.cern.ch/git/root.git GIT_TAG <VERSION>
      UPDATE_COMMAND <VOID>
    ELSE
      URL ftp://root.cern.ch/root/root_v${ROOT_author_version}.source.tar.gz
    ENDIF
    CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
               -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
               -Dpython=ON -DPYTHON_EXECUTABLE=${Python_home}/bin/python
                           -DPYTHON_INCLUDE_DIR=${Python_home}/include/python${Python_config_version_twodigit}
                           -DPYTHON_LIBRARY=${Python_home}/lib/libpython${Python_config_version_twodigit}${CMAKE_SHARED_LIBRARY_SUFFIX}
#               -DGRAPHVIZ_DIR=${graphviz_home}
               -Dbuiltin_pcre=ON
               -Dcintex=ON
               -Dexceptions=ON
               -Dexplicitlink=ON
               -Dfftw3=ON -DFFTW_LIBRARY=${fftw_home}/lib/libfftw3${CMAKE_SHARED_LIBRARY_SUFFIX}
                          -DFFTW_INCLUDE_DIR=${fftw_home}/include
               -Dgdml=ON
               -Dgsl_shared=ON
               -Dkrb5=ON
               -Dgenvector=ON
               -Dldap=ON
               -Dmathmore=ON -DGSL_DIR=${GSL_home}
               -Dmemstat=ON
               -Dminuit2=ON
               -Dmysql=ON -DMYSQL_CONFIG_EXECUTABLE=${mysql_home}/bin/mysql_config
               -Dodbc=ON
               -Dopengl=ON
               -Dpgsql=OFF
               -Dqtgsi=ON
               -Dreflex=ON
               -Droofit=ON
               -Drfio=ON
               -Dssl=ON
               -Dtable=ON
               -Dunuran=ON
               -Dxft=ON
               -Dxml=ON
               -Dxrootd=ON -DXROOTD_ROOT_DIR=${xrootd_home}
               -DCINTMAXSTRUCT=36000
               -DCINTMAXTYPEDEF=36000
               -DCINTLONGLINE=4096
               IF LCG_CPP11 THEN
                   -Dc++11=ON
                   -Dcxx11=ON
               ENDIF   
               IF LCG_TARGET MATCHES x86_64-slc THEN
                   -Dcastor=ON -DCASTOR_DIR=${CASTOR_home}
                   -Ddcache=ON -DDCAP_DIR=${dcap_home}
                   -Dgfal=ON -DGFAL_DIR=${gfal_home}
                             -DSRM_IFCE_DIR=${srm_ifce_home}
               ENDIF
               IF LCG_TARGET MATCHES slc THEN
                   -Doracle=ON -DORACLE_HOME=${oracle_home}
                   -Dqt=ON -DQT_QMAKE_EXECUTABLE=${Qt_home}/bin/qmake
               ENDIF
               IF LCG_TARGET MATCHES "mac" AND NOT LCG_TARGET MATCHES "mac109" THEN
                   -Dqt=ON -DQT_QMAKE_EXECUTABLE=${Qt_home}/bin/qmake
               ENDIF
    DEPENDS Python fftw graphviz GSL mysql xrootd 
            IF LCG_TARGET MATCHES x86_64-slc THEN
                CASTOR dcap gfal srm_ifce
            ENDIF
            IF LCG_TARGET MATCHES slc THEN
                oracle Qt
            ENDIF
            IF LCG_TARGET MATCHES "mac" AND NOT LCG_TARGET MATCHES "mac109" THEN
                Qt
            ENDIF
  )
endif()
#---cmaketool----------------------------------------------------------------------------------------
LCGPackage_Add(
  cmaketools
  SVN_REPOSITORY  http://svn.cern.ch/guest/cmaketools/tags/${cmaketools_native_version}
  UPDATE_COMMAND <VOID>
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>
)

#---RELAX---------------------------------------------------------------------------------------------
LCGPackage_Add(
  RELAX
  SVN_REPOSITORY http://svn.cern.ch/guest/relax/tags/${RELAX_native_version}/relax
  UPDATE_COMMAND <VOID>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DCMAKE_MODULE_PATH=${cmaketools_home}/modules
             -DROOTSYS=${ROOT_home}
             -DGCCXML=${GCCXML_home}/bin/gccxml
             -DCLHEP_ROOT_DIR=${CLHEP_home}
             -DHEPMC_ROOT_DIR=${HepMC_home}
             -DHEPPDT_ROOT_DIR=${HepPDT_home}
  BUILD_COMMAND ${MAKE} ROOTSYS=${ROOT_home}
  DEPENDS cmaketools ROOT GCCXML CLHEP HepMC HepPDT
)

#---CMT-----------------------------------------------------------------------------------------------
LCGPackage_Add(
  cmt
  URL http://service-spi.web.cern.ch/service-spi/external/tarFiles/CMT-${cmt_native_version}.tar.gz
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>/CMT
          COMMAND ${CMAKE_COMMAND} -E chdir <INSTALL_DIR>/CMT/${cmt_native_version}/mgr ./INSTALL
  BUILD_IN_SOURCE 1
  BINARY_PACKAGE 1
)

#---LCGCMT--------------------------------------------------------------------------------------------
LCGPackage_Add(
  LCGCMT
  IF ${heptools_version} STREQUAL "68_root6" THEN
    SVN_REPOSITORY http://svn.cern.ch/guest/lcgsoft/tags/LCGCMT-cmake_root6/lcgcmt --quiet
  ELSE
    SVN_REPOSITORY http://svn.cern.ch/guest/lcgsoft/tags/LCGCMT-cmake/lcgcmt --quiet
  ENDIF
  UPDATE_COMMAND ${Python_cmd} ${CMAKE_SOURCE_DIR}/cmake/scripts/create_LCGCMT.py ${CMAKE_BINARY_DIR}/dependencies.json <SOURCE_DIR>/LCG_Configuration/cmt/requirements
  CONFIGURE_COMMAND <VOID>
  BUILD_COMMAND <VOID>
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> <INSTALL_DIR>/..
  DEPENDS Python
)

# environment variables needed for CMT based builds
#set( LCGCMT_pos "/afs/cern.ch/sw/lcg/app/releases/LCGCMT/LCGCMT_66") 
set(LCGCMT_pos "${LCGCMT_home}/.." )
set(CMTROOT ${cmt_home}/CMT/${cmt_native_version})

#---CORAL----------------------------------------------------------------------------------------------
LCGPackage_add(
  CORAL
  SVN_REPOSITORY http://svn.cern.ch/guest/lcgcoral/coral/tags/${CORAL_native_version} --quiet
  UPDATE_COMMAND <VOID>
  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/config/cmt ${cmt_exec_cmd} ${LCG_system} ${LCGCMT_pos} ${CMTROOT} cmt broadcast -global -select='/${CORAL_native_version}/' cmt config
  BUILD_COMMAND     ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/config/cmt ${cmt_exec_cmd} ${LCG_system} ${LCGCMT_pos} ${CMTROOT} cmt broadcast -global -select='/${CORAL_native_version}/' - cmt make --debug  all_groups
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/../${LCG_system} <INSTALL_DIR>
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/../include <INSTALL_DIR>/../include
  DEPENDS cmt LCGCMT Boost CppUnit sqlite XercesC oracle mysql QMtest tcmalloc Frontier_Client Python
)

#---COOL-----------------------------------------------------------------------------------------------
LCGPackage_add(
  COOL
  SVN_REPOSITORY http://svn.cern.ch/guest/lcgcool/cool/tags/${COOL_native_version} --quiet
  CONFIGURE_COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/config/cmt ${cmt_exec_cmd} ${LCG_system} ${LCGCMT_pos} ${CMTROOT} cmt broadcast -global -select='/${COOL_native_version}/' cmt config
  BUILD_COMMAND     ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/config/cmt ${cmt_exec_cmd} ${LCG_system} ${LCGCMT_pos} ${CMTROOT} cmt broadcast -global -select='/${COOL_native_version}/' - cmt make --debug  all_groups
  INSTALL_COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/../${LCG_system} <INSTALL_DIR>
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR>/../include <INSTALL_DIR>/../include
  DEPENDS LCGCMT CORAL ROOT
)


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


#---LCIO-----------------------------------------------------------------------------------------------
LCGPackage_add(
  LCIO
  SVN_REPOSITORY svn://svn.freehep.org/lcio/tags/<LCIO_native_version>
  CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
             -DLCIO_GENERATE_HEADERS=off 
             -DBUILD_ROOTDICT=ON
             -DROOT_DIR=${ROOT_home}             
  BUILD_COMMAND ${MAKE} ROOTSYS=${ROOT_home}
  DEPENDS ROOT
)
