cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(starlight-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Starlight REQUIRED)

include_directories(${STARLIGHT_INCLUDE_DIR})

add_executable(starlight_genser_test1 starlight_test0.F)
target_link_libraries(starlight_genser_test1 ${STARLIGHT_LIBRARIES})

