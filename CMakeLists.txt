cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(LCGSoft C CXX Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE) # Default to a Release build
  set(CMAKE_BUILD_TYPE Release CACHE STRING "Choose the type of build [Release MinSizeRel Debug RelWithDebInfo]" FORCE)
endif()

include(${CMAKE_SOURCE_DIR}/toolchain.cmake)
include(lcgsoft-macros)

add_subdirectory(externals)
add_subdirectory(projects)
add_subdirectory(generators)
add_subdirectory(gridexternals)
add_subdirectory(pyexternals)
