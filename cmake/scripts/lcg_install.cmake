execute_process(COMMAND ${CMAKE_COMMAND} -DCOMPONENT=${component} 
                       -P ${CMAKE_BINARY_DIR}/cmake_install.cmake
                OUTPUT_QUIET RESULT_VARIABLE rc)

if(_rc)
  message(FATAL_ERROR "Error installing ${component} [code: ${rc}]")
endif()
