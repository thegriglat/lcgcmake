#---Utility Macros----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/macros.cmake)

#---Make sure that VERBOSE is OFF to avoid screwing up the build performance
unset(ENV{VERBOSE})

#---General Configuration---------------------------------------------------
GET_PWD(pwd)
GET_HOST(host)
GET_NCPUS(ncpu)
GET_CONFIGURATION_TAG(tag)

#---Set the source and build directory--------------------------------------
set(CTEST_SOURCE_DIRECTORY "$ENV{SOURCE}")
set(CTEST_BINARY_DIRECTORY "$ENV{BINARY}")

#---Set the CTEST SITE according to the environment-------------------------
if("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${host}")
else()
  set(CTEST_SITE "$ENV{CTEST_SITE}")
  message( "Running build and test on ${host}" )
endif()

#---------------------------------------------------------------------------

list(APPEND CMAKE_CONFIGURATION_TYPES Release Debug RelWithDebInfo MinSizeRel TestRelease Maintainer)
set(TypeRelease opt)
set(TypeDebug   dbg)
set(TypeRelWithDebInfo optd)
set(TypeMinSizeRel optm)

set(CTEST_BUILD_NAME ${tag}-${Type$ENV{BUILDTYPE}})
set(CTEST_BUILD_CONFIGURATION $ENV{BUILDTYPE})
set(CTEST_CONFIGURATION_TYPE ${CTEST_BUILD_CONFIGURATION})

#---CDash settings----------------------------------------------------------
set(CTEST_PROJECT_NAME "LCGSoft")
set(CTEST_NIGHTLY_START_TIME "01:00:00 UTC")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "cdash.cern.ch")
set(CTEST_DROP_LOCATION "/submit.php?project=LCGSoft")
set(CTEST_DROP_SITE_CDASH TRUE)


