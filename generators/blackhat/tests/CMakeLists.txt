cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(pythia6-tests C CXX Fortran)

set(TEST_DIR ${BLACKHAT_ROOT_DIR}/../share/sources/examples)

set(CMAKE_Fortran_FLAGS        "-fPIC -g -fno-automatic -O2")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -g -fno-automatic -O2")

set(CMAKE_CXX_FLAGS        "-lgfortran -g -O2")
set(CMAKE_CXX_FLAGS_RELEASE        "-lgfortran -g -O2")

add_executable(cpp_example ${TEST_DIR}/cpp_example.cpp)
add_executable(fortran_example ${TEST_DIR}/fortran_example.f)

file (GLOB blackhat_libraries ${BLACKHAT_ROOT_DIR}/lib/blackhat/*.so)
file (GLOB qd_libraries ${QD_ROOT_DIR}/lib/libqd.so)

file (GLOB test_files ${TEST_DIR}/*)
file (COPY ${test_files} DESTINATION ./)

target_link_libraries(cpp_example ${qd_libraries} ${blackhat_libraries})
target_link_libraries(fortran_example ${blackhat_libraries} ${qd_libraries})
