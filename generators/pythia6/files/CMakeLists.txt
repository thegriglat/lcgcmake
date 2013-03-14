cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
#----------------------------------------------------------------------------
project(pythia6 Fortran)
#----------------------------------------------------------------------------

#----------------------------------------------------------------------------
#---This CMakeList.txt file asumes that the Pythia6 file has been splitted
#   add prepared moving the files around
#----------------------------------------------------------------------------

#---Compilation and Link options----------------------------------------------
if(CMAKE_SYSTEM_NAME MATCHES Darwin)
  set(CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS "${CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS} -flat_namespace -single_module -undefined dynamic_lookup")
endif()

include_directories(include)

#---Select sources for the various libraries---------------------------------
file(GLOB pythia_sources ${PROJECT_SOURCE_DIR}/src/*.f)
file(GLOB pythia_dummy_sources ${PROJECT_SOURCE_DIR}/dummy/*.f)
file(GLOB pythia_pdfdummy_sources ${PROJECT_SOURCE_DIR}/pdfdummy/*.f)
set(rootinterface_sources
  ${PROJECT_SOURCE_DIR}/rootinterface/pythia6_common_address.c
  ${PROJECT_SOURCE_DIR}/rootinterface/tpythia6_called_from_cc.f
)

#---Add libraries------------------------------------------------------------

add_library(pythia6 SHARED ${pythia_sources})
add_library(pythia6_static STATIC ${pythia_sources})
set_target_properties(pythia6_static PROPERTIES OUTPUT_NAME pythia6)

add_library(pythia6_dummy SHARED ${pythia_dummy_sources})
add_library(pythia6_dummy_static STATIC ${pythia_dummy_sources})
set_target_properties(pythia6_dummy_static PROPERTIES OUTPUT_NAME pythia6_dummy)


add_library(pythia6_pdfdummy SHARED ${pythia_pdfdummy_sources})
add_library(pythia6_pdfdummy_static STATIC ${pythia_pdfdummy_sources})
set_target_properties(pythia6_pdfdummy_static PROPERTIES OUTPUT_NAME pythia6_pdfdummy)

add_library(rootinterface SHARED ${rootinterface_sources})
add_library(rootinterface_static STATIC ${rootinterface_sources})
set_target_properties(rootinterface_static PROPERTIES OUTPUT_NAME rootinterface)


#---Install build products---------------------------------------------------
install(TARGETS pythia6  pythia6_dummy  pythia6_pdfdummy rootinterface DESTINATION lib)
install(TARGETS pythia6_static  pythia6_dummy_static  pythia6_pdfdummy_static rootinterface_static DESTINATION lib)
install(DIRECTORY include/ DESTINATION include FILES_MATCHING PATTERN *.inc PATTERN *.f PATTERN .svn EXCLUDE)
