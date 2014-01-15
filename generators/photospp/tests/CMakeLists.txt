cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(photospp-tests CXX)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules ${CMAKE_MODULE_PATH})

find_package(Photospp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

set(TEST_DIR ${PHOTOSPP_ROOT_DIR}/../share/sources/examples/)

include_directories(${PHOTOSPP_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${PYTHIA8_INCLUDE_DIRS})
add_definitions(-DPYTHIA8_VERSION=${PYTHIA8_VERSION})

add_executable(photospp_orig_test1 ${TEST_DIR}/photos_standalone_example.cxx)
target_link_libraries(photospp_orig_test1 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

add_executable(photospp_orig_test2 photos_hepevt_example.cxx)
target_link_libraries(photospp_orig_test2 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

add_executable(photospp_test1 photospp_test1.cc)
target_link_libraries(photospp_test1 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

add_executable(photospp_test2 photospp_test2.cc)
target_link_libraries(photospp_test2 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})
