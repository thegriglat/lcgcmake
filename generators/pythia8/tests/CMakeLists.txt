cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia8-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)

find_package(Pythia8 REQUIRED)
find_package(HepMC REQUIRED)

include_directories(${PYTHIA8_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR})


add_executable(pythia8_test1 pythia8_test1.cc)
target_link_libraries(pythia8_test1 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_test2 pythia8_test2.cc)
target_link_libraries(pythia8_test2 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_test3 pythia8_test3.cc)
target_link_libraries(pythia8_test3 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})

add_executable(pythia8_test4 pythia8_test4.cc)
target_link_libraries(pythia8_test4 ${PYTHIA8_LIBRARIES} ${HEPMC_LIBRARIES})
