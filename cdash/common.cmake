#---Utility Macros----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/macros.cmake)

#---Make sure that VERBOSE is OFF to avoid screwing up the build performance
unset(ENV{VERBOSE})

#---General Configuration---------------------------------------------------
GET_PWD(pwd)
GET_HOST(host)
GET_NCPUS(ncpu)
GET_CONFIGURATION_TAG(tag)
GET_CTEST_BUILD_NAME(CTEST_BUILD_NAME)

set(CTEST_BUILD_CONFIGURATION $ENV{BUILDTYPE})
set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})

#---Set the source and build directory--------------------------------------
set(CTEST_BUILD_PREFIX "$ENV{BUILD_PREFIX}")
set(CTEST_SOURCE_DIRECTORY "${CTEST_BUILD_PREFIX}/lcgcmake-$ENV{VERSION}")
set(CTEST_BINARY_DIRECTORY "${CTEST_BUILD_PREFIX}/${CTEST_BUILD_NAME}")

#---Set the install directory----------------------------------------------- 
# if $INSTALLDIR is given, use that one, otherwise derive from binary dir
if("$ENV{INSTALLDIR}" STREQUAL "")
  set(CTEST_INSTALL_DIRECTORY "${CTEST_BINARY_DIRECTORY}-install")
else()
  set(CTEST_INSTALL_DIRECTORY "$ENV{INSTALLDIR}")
endif()

#---Set the CTEST SITE according to the environment-------------------------
#if("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${host}")
#else()
#  set(CTEST_SITE "$ENV{CTEST_SITE}")
#  message( "Running build and test on ${host}" )
#endif()

#---CDash settings----------------------------------------------------------
set(CTEST_PROJECT_NAME "LCGSoft")
set(CTEST_NIGHTLY_START_TIME "01:00:00 UTC")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "cdash.cern.ch")
set(CTEST_DROP_LOCATION "/submit.php?project=LCGSoft")
set(CTEST_DROP_SITE_CDASH TRUE)

#---Custom CTest settings---------------------------------------------------
set(CTEST_CUSTOM_MAXIMUM_FAILED_TEST_OUTPUT_SIZE "1000000")
set(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE "100000")
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_ERRORS "256")
set(CTEST_TEST_TIMEOUT 1500)


