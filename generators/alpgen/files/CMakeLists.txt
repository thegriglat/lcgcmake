cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
#----------------------------------------------------------------------------
project(alpgen Fortran)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#---This CMakeList.txt file asumes that the Pythia6 file has been splitted
#   add prepared moving the files around
#----------------------------------------------------------------------------

#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif()


#---Select sources for the various libraries---------------------------------

file(GLOB alpgen_sources ${PROJECT_SOURCE_DIR}/alplib/Acp.f 
${PROJECT_SOURCE_DIR}/alplib/Acp.f ${PROJECT_SOURCE_DIR}/alplib/Aint.f ${PROJECT_SOURCE_DIR}/alplib/alpgen.f ${PROJECT_SOURCE_DIR}/alplib/alppdf.f 
${PROJECT_SOURCE_DIR}/alplib/alputi.f ${PROJECT_SOURCE_DIR}/alplib/Asu3.f)

file(GLOB alpgen_alpsho_sources ${PROJECT_SOURCE_DIR}/alplib/alpsho.f)

#---Add libraries------------------------------------------------------------


add_library(alpgen SHARED ${alpgen_sources})
add_library(alpgen_static STATIC ${alpgen_sources})
set_target_properties(alpgen_static PROPERTIES OUTPUT_NAME alpgen)


add_library(alpsho SHARED ${alpgen_alpsho_sources})
add_library(alpsho_static STATIC ${alpgen_alpsho_sources})
set_target_properties(alpsho_static PROPERTIES OUTPUT_NAME alpsho)

file(GLOB alpgen_herlib_sources ${PROJECT_SOURCE_DIR}/herlib/atoher.f)

add_library(atoher_static SHARED ${alpgen_herlib_sources})
add_library(atoher  STATIC ${alpgen_herlib_sources})
set_target_properties(atoher_static PROPERTIES OUTPUT_NAME atoher)

#---Install build products---------------------------------------------------
install(TARGETS alpgen alpsho atoher DESTINATION lib)
install(TARGETS alpgen_static alpsho_static atoher_static DESTINATION lib)
