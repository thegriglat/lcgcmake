cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(mctester-tests CXX)

#list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_SEARCHPATH1})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_SEARCHPATH2})


find_package(Mctester REQUIRED)
find_package(HepMC REQUIRED)
find_package(ROOT REQUIRED)
find_package(Pythia8 REQUIRED)


include_directories(${HEPMC_INCLUDE_DIR} ${ROOT_INCLUDE_DIR} ${PYTHIA8_INCLUDE_DIRS} ${MCTESTER_INCLUDE_DIR} )
add_definitions(-DPYTHIA8_VERSION=${PYTHIA8_VERSION})

set(TEST_DIR ${MCTESTER_ROOT_DIR}/../share/sources/examples-C++)

add_executable(mctester_test_pyt8 ${TEST_DIR}/pythia/pythia_test.cc)
target_link_libraries(mctester_test_pyt8 ${HEPMC_LIBRARY} ${PYTHIA8_LIBRARIES} ${ROOT_Core_LIBRARY} ${MCTESTER_LIBRARIES} )
