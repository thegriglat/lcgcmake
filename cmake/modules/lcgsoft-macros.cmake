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

  CMAKE_PARSE_ARGUMENTS(ARG "" "" "DEPENDS" ${ARGN})   # This special handling is needed until CMake 2.8.11 is released
  
  set(targetname ${name})
  set(versionindex 1)
  
  #---Loop over all versions of the package----------------------------------------------------------
  foreach( version ${${name}_native_version} )

    #---Check if the package is already existing in the installation area
    if(EXISTS ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})

      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      add_custom_target(${targetname} ALL COMMENT "${targetname} package already existing in ${${name}_home}")
    
    else()

      set(${name}_home ${LOCAL_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})

      #---Replace patterns for multiversion cases-----------------------------------------------------
      string(REPLACE <NATIVE_VERSION> ${version} ARGUMENTS "${ARG_UNPARSED_ARGUMENTS}")

      ExternalProject_Add(
        ${targetname}
        PREFIX ${targetname}
        INSTALL_DIR ${${name}_home}
        ${ARGUMENTS}
        LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1 )

      if(ARG_DEPENDS)
         add_dependencies(${targetname} ${ARG_DEPENDS})
      endif()

      #---Installation from local installation area to CMAKE_INSTALL_PREFIX---------------------------
      install(DIRECTORY ${${name}_home}/ DESTINATION ${${name}_directory_name}/${version}/${LCG_system})
      foreach(ph configure-out configure-err build-out build-err install-out install-err)
        install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${targetname}/src/${targetname}-stamp/${targetname}-${ph}.log
              DESTINATION ${${name}_directory_name}/${version}/logs
              RENAME ${name}-${LCG_system}-${ph}.log)
      endforeach()

    endif()

    set(targetname ${name}_${versionindex})
    math(EXPR versionindex ${versionindex}+1)
    
  endforeach()

  #--- export the latest ${name}_home variable to the other subdirectories
  set(${name}_home ${${name}_home} PARENT_SCOPE)

endmacro()

