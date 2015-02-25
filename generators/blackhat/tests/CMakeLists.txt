cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia6-tests C CXX Fortran)

set(TEST_DIR ${BLACKHAT_ROOT_DIR}/../share/sources/examples)

set(CMAKE_Fortran_FLAGS        "-fPIC -g -fno-automatic -O2")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -g -fno-automatic -O2")

set(CMAKE_CXX_FLAGS        "-lgfortran -g -O2")
set(CMAKE_CXX_FLAGS_RELEASE        "-lgfortran -g -O2")

add_executable(cpp_example ${TEST_DIR}/cpp_example.cpp)
add_executable(fortran_example ${TEST_DIR}/fortran_example.f)

set(BLACKHAT_LIBRARY_DIR ${BLACKHAT_ROOT_DIR}/lib/blackhat)

#file (GLOB blackhat_libraries ${BLACKHAT_ROOT_DIR}/lib/blackhat/*.so)
#file (GLOB qd_libraries ${QD_ROOT_DIR}/lib/libqd.so)

file (GLOB test_files ${TEST_DIR}/*)
file (COPY ${test_files} DESTINATION ./)

target_link_libraries(cpp_example ${BLACKHAT_LIBRARY_DIR}/libInterface.so ${BLACKHAT_LIBRARY_DIR}/libassembly.so ${BLACKHAT_LIBRARY_DIR}/libOLA.so ${BLACKHAT_LIBRARY_DIR}/libCutPart.so ${BLACKHAT_LIBRARY_DIR}/libRatPart.so ${BLACKHAT_LIBRARY_DIR}/libratext.so ${BLACKHAT_LIBRARY_DIR}/libBH.so ${BLACKHAT_LIBRARY_DIR}/libAmpl_eval.so ${BLACKHAT_LIBRARY_DIR}/libRateval.so ${BLACKHAT_LIBRARY_DIR}/libCuteval.so ${BLACKHAT_LIBRARY_DIR}/libCut_wCI.so ${BLACKHAT_LIBRARY_DIR}/libBG.so ${BLACKHAT_LIBRARY_DIR}/libBHcore.so ${BLACKHAT_LIBRARY_DIR}/libIntegrals.so ${BLACKHAT_LIBRARY_DIR}/libSpinors.so ${QD_ROOT_DIR}/lib/libqd.so)

target_link_libraries(fortran_example ${BLACKHAT_LIBRARY_DIR}/libInterface.so ${BLACKHAT_LIBRARY_DIR}/libassembly.so ${BLACKHAT_LIBRARY_DIR}/libOLA.so ${BLACKHAT_LIBRARY_DIR}/libCutPart.so ${BLACKHAT_LIBRARY_DIR}/libRatPart.so ${BLACKHAT_LIBRARY_DIR}/libratext.so ${BLACKHAT_LIBRARY_DIR}/libBH.so ${BLACKHAT_LIBRARY_DIR}/libAmpl_eval.so ${BLACKHAT_LIBRARY_DIR}/libRateval.so ${BLACKHAT_LIBRARY_DIR}/libCuteval.so ${BLACKHAT_LIBRARY_DIR}/libCut_wCI.so ${BLACKHAT_LIBRARY_DIR}/libBG.so ${BLACKHAT_LIBRARY_DIR}/libBHcore.so ${BLACKHAT_LIBRARY_DIR}/libIntegrals.so ${BLACKHAT_LIBRARY_DIR}/libSpinors.so ${QD_ROOT_DIR}/lib/libqd.so)
