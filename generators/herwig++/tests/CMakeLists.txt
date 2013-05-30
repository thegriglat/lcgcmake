cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(herwigpp-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Herwigpp REQUIRED)
find_package(Thepeg REQUIRED)
find_package(HepMC REQUIRED)
find_package(GSL REQUIRED)

include_directories(${HERWIGPP_INCLUDE_DIR} ${GSL_INCLUDE_DIR} ${THEPEG_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR})

set(TESTS_DIR ${HERWIGPP_ROOT_DIR}/../share/sources/Tests)

add_executable(herwigpp_orig_test1 herwigpp_test1.cc herwigpp_test1.h)
target_link_libraries(herwigpp_orig_test1 ${HERWIGPP_LIBRARIES} ${THEPEG_LIBRARIES} ${HEPMC_LIBRARIES} ${GSL_LIBRARIES})
