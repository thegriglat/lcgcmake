cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(tauolapp-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Tauolapp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

set(TEST_DIR ${TAUOLAPP_ROOT_DIR}/../share/sources/examples/)

include_directories(${TAUOLAPP_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${PYTHIA8_INCLUDE_DIR})

add_executable(tauolapp_orig_test1 ${TEST_DIR}/taumain_stand_alone_example.cxx)
target_link_libraries(tauolapp_orig_test1 ${TAUOLAPP_LIBRARIES} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})

add_executable(tauolapp_orig_test2 ${TEST_DIR}/taummk_pythia_example.cxx)
target_link_libraries(tauolapp_orig_test2 ${TAUOLAPP_LIBRARIES} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})

add_executable(tauolapp_orig_test3 ${TEST_DIR}/taumain_hepevt_example.cxx)
target_link_libraries(tauolapp_orig_test3 ${TAUOLAPP_LIBRARIES} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})
