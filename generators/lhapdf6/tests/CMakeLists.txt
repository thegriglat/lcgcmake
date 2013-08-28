cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(lhapdf6-tests CXX)

set(CMAKE_VERBOSE_MAKEFILE ON)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Lhapdf6 REQUIRED)
find_package(Boost REQUIRED)

message(STATUS "compiling executable, include dirs obtained as ${LHAPDF6_INCLUDE_DIRS}")

set(TEST_DIR ${LHAPDF6_ROOT_DIR}/../share/sources/examples/)
include_directories(${LHAPDF6_INCLUDE_DIRS}
                    ${BOOST_INCLUDE_DIRS})

add_executable(lhapdf6_orig_test1 ${TEST_DIR}/testpdf.cc)
target_link_libraries(lhapdf6_orig_test1 ${LHAPDF6_LIBRARIES} ${BOOST_LIBRARIES} ${YAMLLIB})
