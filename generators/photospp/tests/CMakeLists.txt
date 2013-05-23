cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(photospp-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Photospp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

set(TEST_DIR ${PHOTOSPP_ROOT_DIR}/../share/sources/examples/)

include_directories(${PHOTOSPP_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${PYTHIA8_INCLUDE_DIR})

add_executable(photospp_orig_test1 ${TEST_DIR}/photos_standalone_example.cxx)
target_link_libraries(photospp_orig_test1 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})

add_executable(photospp_orig_test2 ${TEST_DIR}/photos_hepevt_example.cxx)
target_link_libraries(photospp_orig_test2 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})
