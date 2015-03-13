cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(blackhat-tests C CXX Fortran)

find_package(Blackhat REQUIRED)

set(TEST_DIR ${BLACKHAT_ROOT_DIR}/../share/sources/examples)

set(CMAKE_Fortran_FLAGS        "-fPIC -g -fno-automatic -O2")
set(CMAKE_Fortran_FLAGS_RELEASE        "-fPIC -g -fno-automatic -O2")

set(CMAKE_CXX_FLAGS        "-lgfortran -g -O2")
set(CMAKE_CXX_FLAGS_RELEASE        "-lgfortran -g -O2")

add_executable(cpp_example ${TEST_DIR}/cpp_example.cpp)
add_executable(fortran_example ${TEST_DIR}/fortran_example.f)

file (GLOB test_files ${TEST_DIR}/*)
file (COPY ${test_files} DESTINATION ./)

target_link_libraries(cpp_example ${BLACKHAT_LIBRARIES} ${QD_ROOT_DIR}/lib/libqd.so)

target_link_libraries(fortran_example ${BLACKHAT_LIBRARIES} ${QD_ROOT_DIR}/lib/libqd.so)
