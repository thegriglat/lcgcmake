find_program(PERL_COMMAND perl)

#---Split the original source file--------------------------------------------

file(GLOB pyquen_files src/pyquen*.f)
execute_process(COMMAND ${PERL_COMMAND} splitter.pl ${pyquen_files})
file(REMOVE pyquen.f)
file(REMOVE ${pyquen_files})

#file(COPY luhepc.f DESTINATION examples)
#file(REMOVE luhepc.f)

file(GLOB pyquen_files *.f)
file(COPY ${pyquen_files} DESTINATION src)
file(REMOVE ${pyquen_files})


