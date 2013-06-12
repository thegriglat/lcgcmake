cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia6-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Pythia6 REQUIRED)
find_package(HepMC REQUIRED)

include_directories(${PYTHIA6_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR})

set(TEST_DIR ${PYTHIA6_ROOT_DIR}/../share/sources/examples)

add_executable(pythia6_test1 ${TEST_DIR}/main78.cc)
target_link_libraries(pythia6_test1 ${PYTHIA6_LIBRARIES} ${HEPMC_LIBRARY} ${HEPMC_fio_LIBRARY})
