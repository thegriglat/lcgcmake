cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(LCGSoft C CXX Fortran)

list(INSERT CMAKE_MODULE_PATH 0 ${CMAKE_SOURCE_DIR}/cmake/modules)
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE) # Default to a Release build
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build [Release MinSizeRel Debug RelWithDebInfo]" FORCE)
endif()

if(NOT LCG_INSTALL_POLICY) # Default to separate installation of packages
  set(LCG_INSTALL_POLICY separate)
endif()

#---Installation pathes------------------------------------------------------------------------------------------------
set(LCG_INSTALL_PREFIX "" CACHE PATH "Existing LCG installation path prefix.")
message(STATUS "Target installation prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "Existing LCG installations: ${LCG_INSTALL_PREFIX}")


include(${CMAKE_SOURCE_DIR}/toolchain.cmake)
include(lcgsoft-macros)

#---Define Global variables--------------------------------------------------------------------------------------------
set(EXEC ${CMAKE_SOURCE_DIR}/cmake/scripts/exec-with-env)
set(MAKE ${CMAKE_SOURCE_DIR}/cmake/scripts/make_verbose $(MAKE))

#---Enable (the defintion) of tests by default-------------------------------------------------------------------------
enable_testing()
include(CTest)

add_subdirectory(externals)
add_subdirectory(gridexternals)
add_subdirectory(projects)
add_subdirectory(pyexternals)
add_subdirectory(generators)

LCG_create_dependency_files()
