cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules)

include(lcgsoft-macros)

add_subdirectory(externals)
add_subdirectory(generators)
add_subdirectory(projects)



