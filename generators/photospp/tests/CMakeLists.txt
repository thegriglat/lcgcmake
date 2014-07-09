cmake_minimum_required(VERSION 2.8 FATAL_ERROR) 
project(photospp-tests CXX)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules ${CMAKE_MODULE_PATH})

find_package(Photospp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

set(TEST_DIR ${PHOTOSPP_ROOT_DIR}/../share/sources/examples/)

include_directories(${PHOTOSPP_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${PYTHIA8_INCLUDE_DIRS})
add_definitions(-DPYTHIA8_VERSION=${PYTHIA8_VERSION})

add_executable(native-photos_standalone ${TEST_DIR}/photos_standalone_example.cxx)
target_link_libraries(native-photos_standalone ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

add_executable(native-photos_hepevt photos_hepevt_example.cxx)
target_link_libraries(native-photos_hepevt ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

add_executable(genser-test1 photospp_test1.cc)
target_link_libraries(genser-test1 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

add_executable(genser-test2 photospp_test2.cc)
target_link_libraries(genser-test2 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

add_executable(genser-test3 photospp_test3.cc)
target_link_libraries(genser-test3 ${PHOTOSPP_LIBRARIES} ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES})

