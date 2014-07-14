#-----------------------------------------------------------------------
# LCG test driver
#   Script arguments: 
#     CMD command to be executed for the test
#     PRE command to be executed before the test command
#     POST command to be executed after the test command
#     OUT file to collect stdout
#     ERR file to collect stderr
#     ENV evironment VAR1=Value1;VAR2=Value2
#     CWD current working directory
#     TST test name (used to name output/error files)
#     TIM timeout 
#     DBG debug flag

#-----------------------------------------------------------------------
# Helper functions
#-----------------------------------------------------------------------
function(multi_execute_process command options)
  set(cmd "")
  set(sep "")
  foreach(arg IN LISTS command)
    if("x${arg}" STREQUAL "xCOMMAND")
      execute_process(COMMAND ${cmd} ${options} RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE stderr)
      file(APPEND ${TESTLOGDIR}/${TST}.log ${output})
      file(APPEND ${TESTLOGDIR}/${TST}.log ${stderr})
      message ("${output}")
      message ("${stderr}")
      if(result)
        set(msg "Command failed (${result}):\n")
        foreach(a IN LISTS cmd)
          set(msg "${msg} '${a}'")
        endforeach()
        message(FATAL_ERROR "${msg}")
      endif()
      set(cmd "")
      set(sep "")
    else()
      set(cmd "${cmd}${sep}${arg}")
      set(sep ";")
    endif()
  endforeach()
  execute_process(COMMAND ${cmd} ${options} RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE stderr)
  file(APPEND ${TESTLOGDIR}/${TST}.log ${output})
  file(APPEND ${TESTLOGDIR}/${TST}.log ${stderr})
  message ("${output}")
  message ("${stderr}")
  if(result)
    set(msg "Command failed (${result}):\n")
    foreach(a IN LISTS cmd)
      set(msg "${msg} '${a}'")
    endforeach()
    message(FATAL_ERROR "${msg}")
  endif()
endfunction()

#-----------------------------------------------------------------------
if(DBG)
  message(STATUS "ENV=${ENV}")
endif()

#-----------------------------------------------------------------------
# Message arguments
#
if(CMD)
  string(REPLACE "#" ";" _cmd ${CMD})
  if(DBG)
    set(_cmd gdb --args ${_cmd})
  endif()
endif()

if(PRE)
  string(REPLACE "#" ";" _pre ${PRE})
endif()

if(POST)
  string(REPLACE "#" ";" _post ${POST})
endif()

if(OUT)
  set(_out OUTPUT_FILE ${OUT})
endif()

if(ERR)
  set(_err ERROR_FILE ${ERR})
endif()

if(TIM)
  math(EXPR _timeout "${TIM} - 120")
else()
  math(EXPR _timeout "1500 - 120")
endif()

if(CWD)
  set(_cwd WORKING_DIRECTORY ${CWD})
endif()

#-----------------------------------------------------------------------
# Environment settings
#
if(ENV)
  string(REPLACE "@" "=" _env ${ENV})
  string(REPLACE "#" ";" _env ${_env})
  foreach(pair ${_env})
    string(REPLACE "=" ";" pair ${pair})
    list(GET pair 0 var)
    list(GET pair 1 val)
    set(ENV{${var}} ${val})
    if(DBG)
      message(STATUS "testdriver[ENV]:${var}==>${val}")
    endif()
  endforeach()
endif()

# Save PATH-like variables
execute_process(COMMAND $ENV{SHELL} -c "env | grep PATH > ${CMAKE_BINARY_DIR}/${TST}.env")

#-----------------------------------------------------------------------
# Execute pre command
#
if(PRE)
  multi_execute_process("${_pre}" "${_cwd}")
endif()

#-----------------------------------------------------------------------
# Execute test
#
if(CMD)
  multi_execute_process("${_cmd}" "${_out};${_err};${_cwd};TIMEOUT;${_timeout}")
endif()

#-----------------------------------------------------------------------
# Execute post test command
#
if(POST)
  multi_execute_process("${_post}" "${_cwd}")
endif()
