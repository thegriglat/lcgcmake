include(ExternalProject)
include(CMakeParseArguments)

set(LOCAL_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/LocalInstallArea)

#----------------------------------------------------------------------------------------------------
#---LCGPackage_Add macro  ---------------------------------------------------------------------------
#
#   This is a wrapper of the ExternalProject_Add function customized for LCG packages
#
#----------------------------------------------------------------------------------------------------
macro(LCGPackage_Add name)
  CMAKE_PARSE_ARGUMENTS(ARG "" "" "DEPENDS" ${ARGN})
  if(EXISTS ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${${name}_native_version}/${LCG_system})

    set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${${name}_native_version}/${LCG_system})
    add_custom_target(${name} ALL COMMENT "${name} package already existing in ${${name}_home}")
    
  else()

    set(${name}_home ${LOCAL_INSTALL_PREFIX}/${${name}_directory_name}/${${name}_native_version}/${LCG_system})
    ExternalProject_Add( 
      ${name}
      INSTALL_DIR ${${name}_home}
      ${ARG_UNPARSED_ARGUMENTS}
      LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
    )
    if(ARG_DEPENDS)
      add_dependencies(${name} ${ARG_DEPENDS})
    endif()

    install(DIRECTORY ${${name}_home}/ DESTINATION ${${name}_directory_name}/${${name}_native_version}/${LCG_system})
    foreach(ph configure-out configure-err build-out build-err install-out install-err)
      install(FILES ${CMAKE_BINARY_DIR}/${name}-prefix/src/${name}-stamp/${name}-${ph}.log
            DESTINATION ${${name}_directory_name}/${${name}_native_version}/logs
            RENAME ${name}-${LCG_system}-${ph}.log)
    endforeach()
  endif()

endmacro()

