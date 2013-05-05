find_program(PERL_COMMAND perl)

#---Split the original source file--------------------------------------------

file(GLOB jetset_files jetset/jetset*.f)
execute_process(COMMAND ${PERL_COMMAND} splitter.pl ${jetset_files})
file(REMOVE ${jetset_files})

file(COPY luhepc.f DESTINATION examples)
file(REMOVE luhepc.f)

file(GLOB jetset_files *.f)
file(COPY ${jetset_files} DESTINATION jetset)
file(REMOVE ${jetset_files})


