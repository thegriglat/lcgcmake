cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
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
