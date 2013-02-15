cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
project(pythia6 Fortran)

find_program(PERL_COMMAND perl)

#---Split the original source file--------------------------------------------
file(GLOB pythiafile  pythia-6.*.f)
execute_process(COMMAND ${PERL_COMMAND} ${PROJECT_SOURCE_DIR}/splitter.pl ${pythiafile}
                WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/)
                
set(dummy_files fhhiggscorr.f fhsetflags.f fhsetpara.f pyevwt.f pykcut.f pytaud.f pytime.f ssmssm.f sugra.f upevnt.f upinit.f upveto.f visaje.f)
file(COPY ${dummy_files} DESTINATION ${PROJECT_SOURCE_DIR}/dummy)
file(REMOVE ${dummy_files})

set(pdfdummy_files pdfset.f structm.f structp.f )
file(COPY ${pdfdummy_files} DESTINATION ${PROJECT_SOURCE_DIR}/pdfdummy)
file(REMOVE ${pdfdummy_files})

file(RENAME  dummy/upveto.f dummy/upveto.F)
file(RENAME  pyhepc.f pyhepc.F)
file(RENAME  pylist.f pylist.F)
file(RENAME  pyveto.f pyveto.F)

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


