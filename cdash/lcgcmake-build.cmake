cmake_minimum_required(VERSION 2.8)

#---Common Geant4 CTest script----------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/common.cmake)

set(CTEST_UPDATE_COMMAND  "svn")
if(NOT EXISTS ${CTEST_SOURCE_DIRECTORY})
  set(CTEST_CHECKOUT_COMMAND "svn co http://svn.cern.ch/guest/lcgsoft/$ENV{VERSION}/lcgcmake ${CTEST_SOURCE_DIRECTORY}")
endif()
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "make -k -j${ncpu} $ENV{TARGET}")

set(CTEST_BUILD_NAME $ENV{LCG_VERSION}-${CTEST_BUILD_NAME})

#---Notes to be attached to the build---------------------------------------
set(CTEST_NOTES_FILES ${CTEST_NOTES_FILES} ${CTEST_SOURCE_DIRECTORY}/cmake/toolchain/heptools-$ENV{LCG_VERSION}.cmake)
set(CTEST_NOTES_FILES ${CTEST_NOTES_FILES} ${CTEST_BINARY_DIRECTORY}/dependencies.json)

#---CTest commands----------------------------------------------------------
#ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})

if("$ENV{CLEAN_INSTALLDIR}" STREQUAL "true")
  file(REMOVE_RECURSE ${CTEST_INSTALL_DIRECTORY})
endif()

if("$ENV{TEST_LABELS}" STREQUAL "")
  set(CTEST_LABELS Nightly)
else()
  set(CTEST_LABELS $ENV{TEST_LABELS})
endif()
set(ignore $ENV{LCG_IGNORE})
set(ignore "${ignore}")
set(options -DLCG_VERSION=$ENV{LCG_VERSION}
            -DCMAKE_INSTALL_PREFIX=${CTEST_INSTALL_DIRECTORY}
            -DPDFsets=$ENV{PDFSETS}
            -DLCG_INSTALL_PREFIX=$ENV{LCG_INSTALL_PREFIX}
            -DLCG_SAFE_INSTALL=ON
            -DLCG_IGNORE=${ignore}
            -DCMAKE_VERBOSE_MAKEFILE=ON
            -DLCG_TARBALL_INSTALL=$ENV{LCG_TARBALL_INSTALL} )

set(lcg_ignore ${})
# The build mode drives the name of the slot in cdash
ctest_start($ENV{MODE} TRACK $ENV{MODE})
ctest_update()
ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY} 
                SOURCE  ${CTEST_SOURCE_DIRECTORY}
                OPTIONS "${options}")
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
if(NOT $ENV{MODE} STREQUAL "Release")
  ctest_test(PARALLEL_LEVEL ${ncpu} INCLUDE_LABEL "${CTEST_LABELS}")
endif()
file(STRINGS ${CTEST_BINARY_DIRECTORY}/fail-logs.txt logs)
ctest_upload(FILES ${logs})
ctest_submit()




