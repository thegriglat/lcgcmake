cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(lhapdf-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Lhapdf REQUIRED)

set(TEST_DIR ${LHAPDF_ROOT_DIR}/../share/examples/)
include_directories(${LHAPDF_INCLUDE_DIR} ${LHAPDF_ROOT_DIR}/include/LHAPDF/ ${LHAPDFSETS_ROOT_DIR}/include/)

#add_executable(lhapdf_genser_test1 lhapdf_test1.f)
add_executable(lhapdf_genser_test1 ${TEST_DIR}/CCTest1.cc)
target_link_libraries(lhapdf_genser_test1 ${LHAPDF_LIBRARIES})
