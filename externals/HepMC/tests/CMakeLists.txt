cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(hepmc-tests CXX)

find_package(HepMC REQUIRED)

set(TEST_DIR ${HEPMC_ROOT_DIR}/../share/sources/test/)

include_directories(${HEPMC_INCLUDE_DIR})

add_executable(hepmc_test_units ${TEST_DIR}/testUnits.cc)  
target_link_libraries(hepmc_test_units ${HEPMC_LIBRARIES})

add_executable(hepmc_test_flow ${TEST_DIR}/testFlow.cc)  
target_link_libraries(hepmc_test_flow ${HEPMC_LIBRARIES})

add_executable(hepmc_test_polarization ${TEST_DIR}/testPolarization.cc)  
target_link_libraries(hepmc_test_polarization ${HEPMC_LIBRARIES})

add_executable(hepmc_test_printbug ${TEST_DIR}/testPrintBug.cc)  
target_link_libraries(hepmc_test_printbug ${HEPMC_LIBRARIES})

add_executable(hepmc_test_simplevector ${TEST_DIR}/testSimpleVector.cc)  
target_link_libraries(hepmc_test_simplevector ${HEPMC_LIBRARIES})

