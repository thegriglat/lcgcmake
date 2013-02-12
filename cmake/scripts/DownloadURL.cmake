# - Download a [compressed] file from the web when the standard URL option does not 
#   work on the ExternalProject
#   Parameters: url  - url of the file
#               source_dir - source directory
#               timeout - timeout in seconds
#               md5  - expected md5
#

if(timeout)
  set(timeout_args TIMEOUT ${timeout})
  set(timeout_msg "${timeout} seconds")
else()
  set(timeout_args "# no TIMEOUT")
  set(timeout_msg "none")
endif()
if(md5)
  set(md5_args EXPECTED_MD5 ${md5})
else()
  set(md5_args "# no EXPECTED_MD5")
endif()


if("${url}" MATCHES "^[a-z]+://")
  string(REGEX MATCH "[^/\\?]*$" fname "${url}")
  string(REPLACE ";" "-" fname "${fname}")
  set(file ${source_dir}/${fname})

  #---Downloading-------------------------------------------------------------------------------------
  message(STATUS "downloading...
     src='${url}'
     dst='${file}'
     timeout='${timeout_msg}'")

  file(DOWNLOAD "${url}" "${file}" SHOW_PROGRESS ${md5_args} ${timeout_args} STATUS status LOG log)

  list(GET status 0 status_code)
  list(GET status 1 status_string)
  if(NOT status_code EQUAL 0)
    message(FATAL_ERROR "error: downloading '${remote}' failed
    status_code: ${status_code}
    status_string: ${status_string}
    log: ${log}")
  endif()

  message(STATUS "downloading... done")

  #---extract file------------------------------------------------------------------------------------
  if(file MATCHES "(\\.|=)(gz|tgz|zip)$")

    get_filename_component(filename "${file}" ABSOLUTE)
    if(NOT EXISTS "${filename}")
      message(FATAL_ERROR "error: file to decompress does not exist: '${filename}'")
    endif()

    message(STATUS "decompressing... src='${filename}'")

    execute_process(COMMAND gzip -df  ${filename} RESULT_VARIABLE rv)

    if(NOT rv EQUAL 0)
      message(FATAL_ERROR "error: decompressing of '${filename}' failed")
    endif()

  else()

    message(STATUS "file is already de-compressed  src='${filename}'")

  endif()

endif()
