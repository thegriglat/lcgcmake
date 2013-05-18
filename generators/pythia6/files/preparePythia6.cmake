find_program(PERL_COMMAND perl)

#---Split the original source file--------------------------------------------
file(GLOB pythiafile  pythia-6.*.f)
execute_process(COMMAND ${PERL_COMMAND} splitter.pl ${pythiafile})

set(dummy_files fhhiggscorr.f fhsetflags.f fhsetpara.f pyevwt.f pykcut.f pytaud.f pytime.f ssmssm.f sugra.f upevnt.f upinit.f upveto.f visaje.f)
file(COPY ${dummy_files} DESTINATION dummy)
file(COPY ${pythiafile} DESTINATION orig)
file(REMOVE ${dummy_files})

set(pdfdummy_files pdfset.f structm.f structp.f )
file(COPY ${pdfdummy_files} DESTINATION pdfdummy)
file(REMOVE ${pdfdummy_files})

file(GLOB src_files *.f)
list(REMOVE_ITEM src_files ${pythiafile})
file(COPY ${src_files} DESTINATION src)
file(REMOVE ${src_files})

#---helper function-----------------------------------------------------------
function(replace_hepevt_by_include infile outfile)
  file(READ ${infile} file_text)
  string(REGEX REPLACE "PARAMETER[ ]*[(][ ]*NMXHEP[ ]*=.* SAVE[ ]*/HEPEVT/"   "INCLUDE 'hepevt.inc'" file_text ${file_text})
  file(WRITE ${outfile} ${file_text})
endfunction()

#---Call the function for a set of files--------------------------------------
foreach(file dummy/upveto.f src/pyhepc.f src/pylist.f src/pyveto.f)
  file(RENAME ${file} ${file}.orig)
  replace_hepevt_by_include(${file}.orig ${file})
endforeach()

# use HEPEVT_SIZE parameter:
configure_file(include/hepevt.inc.in include/hepevt.inc @ONLY)
