# Arguments:
#   base_url
#   pdf_sets - string with coma separated list of PDF sets
#   dst_dir

# convert string to list
string(REPLACE "," ";" pdf_list ${pdf_sets})

message(STATUS "Base url: ${base_url}")
message(STATUS "PDF sets: ${pdf_sets}")
message(STATUS "Destination: ${dst_dir}")

foreach(i IN LISTS pdf_list)
  set(src ${base_url}/${i}.tar.gz)
  set(dst ${dst_dir}/${i}.tar.gz)
  set(pdf ${dst_dir}/${i})
  
  message(STATUS "Downloading: ${src} to ${dst}")
  
  if(EXISTS ${pdf}/)
    message(STATUS "INFO: PDF set already downloaded - skip")
  else()
    file(DOWNLOAD "${src}" "${dst}" SHOW_PROGRESS STATUS status)
    
    list(GET status 0 code)
    if(NOT code EQUAL 0)
      message(FATAL_ERROR "ERROR: failed to download file ${src}")
    else()
      execute_process(COMMAND tar -C ${dst_dir} -zxf ${dst} RESULT_VARIABLE code)
      
      if(NOT code EQUAL 0)
        file(REMOVE ${pdf})
        message(FATAL_ERROR "ERROR: failed to decompress file ${dst}")
      else()
        # download and decompless finished successfully, remove PDF tarball
        file(REMOVE ${dst})
        message(STATUS "INFO: PDF set ${i} is installed to ${pdf}/")
      endif()
    endif()
  endif()
endforeach()
