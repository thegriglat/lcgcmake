cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
project(pythia6 Fortran)

file(GLOB pythia_sources ${PROJECT_SOURCE_DIR}/*.f)
list(REMOVE_ITEM pythia_sources ${pythiafile})
file(GLOB pythia_dummy_sources ${PROJECT_SOURCE_DIR}/dummy/*.f)
file(GLOB pythia_pdfdummy_sources ${PROJECT_SOURCE_DIR}/pdfdummy/*.f)


add_library(pythia6_dummy SHARED ${pythia_dummy_sources})
add_library(pythia6_pdfdummy SHARED ${pythia_pdfdummy_sources})
add_library(pythia6 SHARED ${pythia_sources})
target_link_libraries(pythia6 pythia6_dummy pythia6_pdfdummy)


#----------------------------------------------------------------------------
# Install the executable to 'bin' directory under CMAKE_INSTALL_PREFIX
#
install(TARGETS pythia6  pythia6_dummy  pythia6_pdfdummy DESTINATION lib)


