find_program(PERL_COMMAND perl)

#---Split the original source file--------------------------------------------
file(GLOB pythiafile  pythia-6.*.f)
execute_process(COMMAND ${PERL_COMMAND} ${CMAKE_SOURCE_DIR}/../pythia6/splitter.pl ${pythiafile}
                WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}/../pythia6/)
                
set(dummy_files fhhiggscorr.f fhsetflags.f fhsetpara.f pyevwt.f pykcut.f pytaud.f pytime.f ssmssm.f sugra.f upevnt.f upinit.f upveto.f visaje.f)
file(COPY ../pythia6/${dummy_files} DESTINATION ${PROJECT_SOURCE_DIR}/../pythia6/dummy)
file(REMOVE ../pythia6/${dummy_files})

set(pdfdummy_files pdfset.f structm.f structp.f )
file(COPY ../pythia6/${pdfdummy_files} DESTINATION ${PROJECT_SOURCE_DIR}../pythia6//pdfdummy)
file(REMOVE ../pythia6/${pdfdummy_files})

file(RENAME  dummy/upveto.f dummy/upveto.F)
file(RENAME  pyhepc.f pyhepc.F)
file(RENAME  pylist.f pylist.F)
file(RENAME  pyveto.f pyveto.F)
