cmake_minimum_required(VERSION 2.8)

#---Common Geant4 CTest script----------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/common.cmake)

set(CTEST_UPDATE_COMMAND  "svn")
set(CTEST_CHECKOUT_COMMAND "svn co svn+ssh://svn.cern.ch/reps/lcgsoft/trunk/lcgcmake ${CTEST_SOURCE_DIRECTORY}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "make -k -j${ncpu} GSL") 

#---CTest commands----------------------------------------------------------
ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

ctest_start(Experimental)
ctest_update()
ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY} 
                SOURCE  ${CTEST_SOURCE_DIRECTORY}
                OPTIONS "-DCMAKE_INSTALL_PREFIX=${CTEST_BINARY_DIRECTORY}-install")
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
ctest_submit()




