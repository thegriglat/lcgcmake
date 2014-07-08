cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(LCGSoft C CXX Fortran)

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake/modules)
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE) # Default to a Release build
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build [Release MinSizeRel Debug RelWithDebInfo]" FORCE)
endif()

#---Definition options and teir default values ------------------------------------------------------------------------
set(LCG_INSTALL_POLICY separate CACHE STRING "'separate' or 'join' installation of packages")
set(LCG_SAFE_INSTALL   OFF      CACHE BOOL "Ensure that no overwites occurs at the installation area of packages")
set(LCG_IGNORE         ""       CACHE STRING "List of packages to be ignored from LCG_INSTALL_PREFIX (';' separated)")
set(LCG_INSTALL_PREFIX ""       CACHE PATH "Existing LCG installation path prefix.")
set(LCG_TARBALL_INSTALL   OFF   CACHE BOOL "Turn ON/OFF creation/installation of tarballs")
set(VALIDATION         OFF      CACHE BOOL "Enable validation settings.")

#---Report the values of the options-----------------------------------------------------------------------------------
message(STATUS "Target installation prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Existing LCG installations: ${LCG_INSTALL_PREFIX}")
message(STATUS "Safe installation: ${LCG_SAFE_INSTALL}")
message(STATUS "Source and binary tarball installation: ${LCG_TARBALL_INSTALL}")
message(STATUS "Validation mode: ${VALIDATION}")

include(${CMAKE_SOURCE_DIR}/toolchain.cmake)
include(lcgsoft-macros)

#---Define Global variables--------------------------------------------------------------------------------------------
find_program(env_cmd NAMES env)
mark_as_advanced(env_cmd)
set(EXEC ${env_cmd})
set(MAKE ${CMAKE_SOURCE_DIR}/cmake/scripts/make_verbose $(MAKE))

#---Enable (the defintion) of tests by default-------------------------------------------------------------------------
enable_testing()
include(CTest)

set(TESTLOGDIR "${PROJECT_BINARY_DIR}/tests")
if(NOT "$ENV{CXXFLAGS}" STREQUAL "")
  set(libtoolpatch CXX=$ENV{CXX}\ $ENV{CXXFLAGS})
endif()

add_subdirectory(externals)
add_subdirectory(gridexternals)
add_subdirectory(projects)
add_subdirectory(pyexternals)
add_subdirectory(generators)

LCG_create_dependency_files()
file(WRITE ${CMAKE_BINARY_DIR}/fail-logs.txt "")
