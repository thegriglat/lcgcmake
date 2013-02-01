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
  
  #---Check if this is a muli-version package or not-------------------------------------------------
  list(LENGTH ${name}_native_version nvers)
  if(nvers GREATER 1)
    add_custom_target(${name} ALL COMMENT "Multi-version package ${name} global target")
    add_custom_target(clean-${name} COMMENT "Clean a multi-version package ${name}")
  endif()
  
  #---Loop over all versions of the package----------------------------------------------------------
  foreach( version ${${name}_native_version} )
  
    if(nvers GREATER 1)
      set(targetname ${name}-${version})
    else()
      set(targetname ${name})
    endif()

    #---Check if the package is already existing in the installation area
    if(EXISTS ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})

      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      add_custom_target(${targetname} ALL COMMENT "${targetname} package already existing in ${${name}_home}")
      add_custom_target(clean-${targetname} COMMENT "${targetname}: nothing to be clean!")

    else()

      set(${name}_home ${LOCAL_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})

      #---Replace patterns for multiversion cases-----------------------------------------------------
      string(REPLACE <NATIVE_VERSION> ${version} ARGUMENTS "${ARG_UNPARSED_ARGUMENTS}")
      
      #---Add the external project -------------------------------------------------------------------

      ExternalProject_Add(
        ${targetname}
        PREFIX ${targetname}
        INSTALL_DIR ${${name}_home}
        ${ARGUMENTS}
        LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1 )

      #---Adding extra step to copy the sources in /share/sources-------------------------------------
      ExternalProject_Add_Step(${targetname} install_sources COMMENT "Installing sources for ${targetname}"
        COMMAND  ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${LOCAL_INSTALL_PREFIX}/${${name}_directory_name}/${version}/share/sources
        DEPENDERS build
        DEPENDEES update)
        

      #---Adding clean targets--------------------------------------------------------------------------
      add_custom_target(clean-${targetname} COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/${targetname}
                                            COMMAND ${CMAKE_COMMAND} -E remove_directory ${${name}_home})

      #---Handle dependencies-----(should not be needed after CMake 2.8.11)-----------------------------
      if(ARG_DEPENDS)
         foreach(dep ${ARG_DEPENDS})
           if(NOT TARGET ${dep})
             message(SEND_ERROR "Package ${name} declared a dependency to non existing package ${dep}")
           endif()
         endforeach()
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
    
    if(nvers GREATER 1)
      add_dependencies(${name} ${targetname})
      add_dependencies(clean-${name} clean-${targetname})
    endif()

  endforeach()

  #--- export the latest ${name}_home variable to the other subdirectories
  set(${name}_home ${${name}_home} PARENT_SCOPE)

endmacro()

