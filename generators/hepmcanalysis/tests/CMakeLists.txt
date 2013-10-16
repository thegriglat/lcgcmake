cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(hepmcanalysis-tests CXX)

#list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/../../../cmake/modules)
list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_SEARCHPATH1})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_SEARCHPATH2})


find_package(Hepmcanalysis REQUIRED)
find_package(HepMC REQUIRED)
find_package(ROOT REQUIRED)
find_package(FastJet REQUIRED)
find_package(CLHEP REQUIRED)
find_package(Pythia6 REQUIRED)
find_package(Lhapdf REQUIRED)


include_directories(${CLHEP_INCLUDE_DIR} ${HEPMC_INCLUDE_DIR} ${ROOT_INCLUDE_DIR} {PYTHIA6_INCLUDE_DIR} ${FASTJET_INCLUDE_DIR} ${HEPMCANALYSIS_INCLUDE_DIR} )

set(TEST_DIR ${HEPMCANALYSIS_ROOT_DIR}/../share/sources/examples/)

add_executable(hepmcanalysis_test_hepmcreader ${TEST_DIR}/hepmcreader/reader.cc)
target_link_libraries(hepmcanalysis_test_hepmcreader  
${CLHEP_MAIN_LIBRARY} ${HEPMC_LIBRARY} ${FASTJET_LIBRARY} ${ROOT_Core_LIBRARY} ${HEPMCANALYSIS_LIBRARY} )

add_executable(hepmcanalysis_test_pythia6   ${TEST_DIR}/pythia6/pythia6.cc)
target_link_libraries(hepmcanalysis_test_pythia6  
${CLHEP_MAIN_LIBRARY} ${HEPMC_LIBRARY} ${HEPMC_fio_LIBRARY} ${LHAPDF_LIBRARY} ${PYTHIA6_dummy_LIBRARY} ${PYTHIA6_LIBRARY} 
${ROOT_Core_LIBRARY} ${FASTJET_LIBRARY}  ${HEPMCANALYSIS_LIBRARY} ${PYTHIA6_LIBRARY_DIR}/pydata.o  )

