STRING (REPLACE ".yoda" ".aida" AIDA ${INPUT})
execute_process ( COMMAND ${Python_cmd} ${yoda_home}/bin/yoda2aida ${INPUT} ${AIDA})
execute_process ( COMMAND ${AIDA2ROOT} --thisto -s ${AIDA} RESULT_VARIABLE rv)


