cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(lhapdf-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Lhapdf REQUIRED)

set(TEST_DIR ${LHAPDF_ROOT_DIR}/../share/sources/examples/)
include_directories(${LHAPDF_INCLUDE_DIRS} ${LHAPDF_INCLUDE_DIR}/LHAPDF)

add_executable(native-CCTest1 ${TEST_DIR}/CCTest1.cc)
target_link_libraries(native-CCTest1 ${LHAPDF_LIBRARIES})

add_executable(native-CCTest3 ${TEST_DIR}/CCTest3.cc)
target_link_libraries(native-CCTest3 ${LHAPDF_LIBRARIES})

add_executable(native-CCTest4 ${TEST_DIR}/CCTest4.cc)
target_link_libraries(native-CCTest4 ${LHAPDF_LIBRARIES})
