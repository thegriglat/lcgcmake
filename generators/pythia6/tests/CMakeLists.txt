cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia6-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH2})

find_package(Pythia6 REQUIRED)
find_package(HepMC REQUIRED)

find_package(FastJet REQUIRED)

include_directories(${CMAKE_SOURCE_DIR}/../../pythia8/tests/analyserhepmc ${PYTHIA6_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${FASTJET_INCLUDE_DIR})

set(TEST_DIR ${PYTHIA6_ROOT_DIR}/../share/sources/examples)

add_executable(pythia6_orig_test1 ${TEST_DIR}/main78.cc)
target_link_libraries(pythia6_orig_test1 ${PYTHIA6_LIBRARIES} ${HEPMC_LIBRARY} ${HEPMC_fio_LIBRARY})

add_executable(pythia6_genser_test1 pythia6_genser_test1.cc ../../pythia8/tests/analyserhepmc/AnalyserHepMC.cc 
../../pythia8/tests/analyserhepmc/LeptonAnalyserHepMC.cc ../../pythia8/tests/analyserhepmc/JetInputHepMC.cc)
target_link_libraries(pythia6_genser_test1 ${PYTHIA6_LIBRARIES} ${HEPMC_LIBRARIES} ${HEPMC_fio_LIBRARY} ${FASTJET_LIBRARIES})

add_executable(pythia6_genser_outhepmc pythia6_genser_outhepmc.cc)
target_link_libraries(pythia6_genser_outhepmc ${PYTHIA6_LIBRARIES} ${HEPMC_LIBRARIES} ${HEPMC_fio_LIBRARY})
