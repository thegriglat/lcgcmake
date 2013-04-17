# Install the logfiles into the <INSTALL_DIR> area
# Parameters:
#    INSTALL_DIR Installation prefix
#    LOGS_DIR    Directory with log files
#    LCG_SYSTEM  LCG configuration name
#

file(GLOB logs ${LOGS_DIR}/*.log ${LOGS_DIR}/*.cmake)

foreach(log ${logs})
  file(COPY ${logs} DESTINATION ${INSTALL_DIR})
endforeach()

