cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(hijing-tests Fortran)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Hijing REQUIRED)

add_executable(hijing_orig_test1 ${HIJING_ROOT_DIR}/../share/sources/examples/example_1.f)
#add_executable(hijing_genser_test1 hijing_test1.F)
target_link_libraries(hijing_orig_test1 ${HIJING_LIBRARIES})

