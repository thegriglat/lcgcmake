cmake_minimum_required(VERSION 2.8 FATAL_ERROR)
project(yamlcpp-tests CXX)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH2})

message ("CMAKE_MODULE_PATH = ${CMAKE_MODULE_PATH}")
find_package(Yamlcpp REQUIRED)
include_directories(${YAMLCPP_INCLUDE_DIR})

add_executable(produce-yaml produce-yaml.cpp)
target_link_libraries(produce-yaml ${YAMLCPP_LIBRARIES})
