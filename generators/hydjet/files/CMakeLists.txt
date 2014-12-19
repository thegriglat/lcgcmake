cmake_minimum_required(VERSION 2.6 FATAL_ERROR)

add_definitions(-DCMAKE_Fortran_FLAGS=                "${CMAKE_Fortran_FLAGS} -fPIC  -O2")
add_definitions(-DCMAKE_Fortran_FLAGS_DEBUG=          "${CMAKE_Fortran_FLAGS_DEBUG} -fPIC -g -fno-automatic")
add_definitions(-DCMAKE_Fortran_FLAGS_MINSIZEREL=     "${CMAKE_Fortran_FLAGS_MINSIZEREL} -fPIC -Os -DNDEBUG -fno-automatic")
add_definitions(-DCMAKE_Fortran_FLAGS_RELEASE=        "${CMAKE_Fortran_FLAGS_RELEASE} -fPIC -O2 -DNDEBUG -fno-automatic")
add_definitions(-DCMAKE_Fortran_FLAGS_RELWITHDEBINFO= "${CMAKE_Fortran_FLAGS_RELWITHDEBINFO} -fPIC -O2 -g -fno-automatic")

project(hydjet Fortran)

#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif()

#---Select sources for the various libraries---------------------------------
file(GLOB hydjet_sources hydjet*.f)
file(GLOB jetset_sources jetset_73.f)

#---Add libraries------------------------------------------------------------
add_library(hydjet SHARED ${hydjet_sources})
add_library(hydjet_static STATIC ${hydjet_sources})
set_target_properties(hydjet_static PROPERTIES OUTPUT_NAME hydjet)

add_library(jetset73hydjet SHARED ${jetset_sources})
add_library(jetset73hydjet_static STATIC ${jetset_sources})
set_target_properties(jetset73hydjet_static PROPERTIES OUTPUT_NAME jetset73hydjet)

#---Install build products---------------------------------------------------
install(TARGETS hydjet jetset73hydjet  DESTINATION lib)
install(TARGETS hydjet_static  jetset73hydjet_static  DESTINATION lib)
