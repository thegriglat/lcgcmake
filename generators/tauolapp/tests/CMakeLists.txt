cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(tauolapp-tests CXX)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules ${CMAKE_MODULE_PATH})

find_package(Tauolapp REQUIRED)
find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

set(TEST_DIR ${TAUOLAPP_ROOT_DIR}/../share/sources/examples/)

include_directories(${TAUOLAPP_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${PYTHIA8_INCLUDE_DIRS})
add_definitions(-DPYTHIA8_VERSION=${PYTHIA8_VERSION})

add_executable(tauolapp_orig_test1 ${TEST_DIR}/taumain_stand_alone_example.cxx)
target_link_libraries(tauolapp_orig_test1 ${TAUOLAPP_INTERFACE_LIBRARY} ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES})

add_executable(tauolapp_orig_test2 ${TEST_DIR}/taummk_pythia_example.cxx)
target_link_libraries(tauolapp_orig_test2 ${TAUOLAPP_INTERFACE_LIBRARY} ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})

add_executable(tauolapp_orig_test3 ${TEST_DIR}/taumain_hepevt_example.cxx)
target_link_libraries(tauolapp_orig_test3 ${TAUOLAPP_INTERFACE_LIBRARY}  ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES})

add_executable(tauolapp_test1 tauolapp_test1.cc)
target_link_libraries(tauolapp_test1 ${TAUOLAPP_INTERFACE_LIBRARY}  ${TAUOLAPP_FORTRAN_LIBRARY} ${HEPMC_LIBRARIES} ${PYTHIA8_LIBRARIES})
