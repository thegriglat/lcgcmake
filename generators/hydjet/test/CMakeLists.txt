cmake_minimum_required(VERSION 2.6 FATAL_ERROR)

add_test (test_hydjet sh ${CMAKE_CURRENT_SOURCE_DIR}/runtest.sh ${CMAKE_CURRENT_SOURCE_DIR} ${hydjet_home}/../../../ ${hydjet_native_version})
