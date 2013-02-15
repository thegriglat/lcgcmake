find_program(PERL_COMMAND perl)

#---Split the original source file--------------------------------------------
file(GLOB pythiafile  pythia-6.*.f)
execute_process(COMMAND ${PERL_COMMAND} splitter.pl ${pythiafile})

set(dummy_files fhhiggscorr.f fhsetflags.f fhsetpara.f pyevwt.f pykcut.f pytaud.f pytime.f ssmssm.f sugra.f upevnt.f upinit.f upveto.f visaje.f)
file(COPY ${dummy_files} DESTINATION dummy)
file(REMOVE ${dummy_files})

set(pdfdummy_files pdfset.f structm.f structp.f )
file(COPY ${pdfdummy_files} DESTINATION pdfdummy)
file(REMOVE ${pdfdummy_files})

file(GLOB src_files *.f)
list(REMOVE_ITEM src_files ${pythiafile})
file(COPY ${src_files} DESTINATION src)
file(REMOVE ${src_files})

file(RENAME  dummy/upveto.f dummy/upveto.F)
file(RENAME  src/pyhepc.f src/pyhepc.F)
file(RENAME  src/pylist.f src/pylist.F)
file(RENAME  src/pyveto.f src/pyveto.F)
