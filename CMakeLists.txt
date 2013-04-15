cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(LCGSoft C CXX Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

include(${CMAKE_SOURCE_DIR}/toolchain.cmake)
include(lcgsoft-macros)

add_subdirectory(externals)
add_subdirectory(projects)
add_subdirectory(generators)

add_subdirectory(pyexternals)