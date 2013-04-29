include(ExternalProject)
include(CMakeParseArguments)

#----------------------------------------------------------------------------------------------------
#---LCGPackage_Add macro  ---------------------------------------------------------------------------
#
#   This is a wrapper of the ExternalProject_Add function customized for LCG packages
#
#     o supports the fallback to a central release area to avoid building already existing projects
#     o automatically adds the log files to the install area  
#     o automatically adds the sources to the install area
#     o automatically creates a binary tarball
#     o automatically strips rpath from .so files 
#     o supports bundle (python) packages collecting many targets into one dir
#        - denoted with the switch "BUNDLE_PACKAGE"
#     o supports pure binary package installations
#        - denoted with the switch "BINARY_PACKAGE"
#     o For every target it sets ${name}_home, ${name}_exists and ${name}_dependencies 
#     o It uses ${name}_native_version which has to be set externally     
#
#----------------------------------------------------------------------------------------------------
macro(LCGPackage_Add name)

  CMAKE_PARSE_ARGUMENTS(ARG "" "DEST_NAME;BUNDLE_PACKAGE;BINARY_PACKAGE"
                            "DEPENDS;CONFIGURE_EXAMPLES_COMMAND;BUILD_EXAMPLES_COMMAND;INSTALL_EXAMPLES_COMMAND;TEST_COMMAND" ${ARGN})
  
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

    #---Check if the package is already existing in the installation area(s)
    if(NOT ARG_BUNDLE_PACKAGE AND EXISTS ${LCG_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})

      set(${name}_home ${LCG_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      add_custom_target(${targetname} ALL COMMENT "${targetname} package already existing in LCG install area ${${name}_home}")
      add_custom_target(clean-${targetname} COMMENT "${targetname}: nothing to be clean!")

    elseif(NOT ARG_BUNDLE_PACKAGE AND EXISTS ${LCG_INSTALL_PREFIX}/../app/releases/${${name}_directory_name}/${version}/${LCG_system})
      get_filename_component(_path ${LCG_INSTALL_PREFIX} PATH)
      set(${name}_home ${_path}/app/releases/${${name}_directory_name}/${version}/${LCG_system})
      if(${name} STREQUAL ROOT)  # ROOT in LCG installations is special
        set(ROOT_home ${ROOT_home}/root) 
      endif()
      add_custom_target(${targetname} ALL COMMENT "${targetname} package already existing in LCG install area ${${name}_home}")
      add_custom_target(clean-${targetname} COMMENT "${targetname}: nothing to be clean!")

    else()
      #---Replace patterns for multiversion cases-----------------------------------------------------
      string(REPLACE <NATIVE_VERSION> ${version} ARGUMENTS "${ARG_UNPARSED_ARGUMENTS}")
      string(REPLACE <VOID> "" ARGUMENTS "${ARGUMENTS}")
      string(REGEX MATCHALL "<[^ <>(){}]+>" vars ${ARGUMENTS})
      foreach(var ${vars})
        string(REPLACE "<" "" v ${var})
        string(REPLACE ">" "" v ${v})
        if(DEFINED ${v})
           string(REPLACE ${var} ${${v}} ARGUMENTS "${ARGUMENTS}")
        endif()
      endforeach()

      #---Set home and install name-------------------------------------------------------------------
      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      if(ARG_DEST_NAME)
        set(dest_name ${ARG_DEST_NAME})
        set(dest_version ${${ARG_DEST_NAME}_native_version})
        set(curr_name ${name})
      else()
        set(dest_name ${name})
        set(dest_version ${version})
        set(curr_name)
      endif()
      
      #---Check if a patch file exists and apply it by default---------------------------------------
      if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${name}-${version}.patch AND NOT ARGUMENTS MATCHES PATCH_COMMAND)
        list(APPEND ARGUMENTS PATCH_COMMAND patch -p0 -i ${CMAKE_CURRENT_SOURCE_DIR}/${name}-${${name}_native_version}.patch)
      endif()

      #---We cannot use the argument INSTALL_DIR becuase cmake itself will create the directory 
      #   unconditionaly before make is executed. So, we replace <INSTALL_DIR> before passing the
      #   arguments to ExternalPreject_Add().
      string(REPLACE <INSTALL_DIR> ${${dest_name}_home} ARGUMENTS "${ARGUMENTS}")

      #---Add the external project -------------------------------------------------------------------
      ExternalProject_Add(
        ${targetname}
        PREFIX ${targetname}
        SOURCE_DIR ${targetname}/src/${name}/${version}
        "${ARGUMENTS}"
        TEST_COMMAND ${ARG_TEST_COMMAND}
        LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1 )

      #---Handle dependencies-----(should not be needed after CMake 2.8.11)-----------------------------
      set(${targetname}_dependencies "")
      if(ARG_DEPENDS)
         foreach(dep ${ARG_DEPENDS})
           if(NOT TARGET ${dep})
             message(SEND_ERROR "Package ${name} declared a dependency to non existing package ${dep}")
           endif()
            list(APPEND ${targetname}_dependencies ${dep})
         endforeach()
         add_dependencies(${targetname} ${ARG_DEPENDS})
      endif()

      #--- prepare a name containing the full dependencies
      #--- and a hash as a unique id for the build product
      set(${name}_expanded_dependencies)
      LCG_append_depends(${name} ${name}_expanded_dependencies)
      list(SORT ${name}_expanded_dependencies)
      foreach(p ${${name}_expanded_dependencies})
        list(APPEND ${name}_full_version ${p}=${${p}_native_version})
      endforeach()
      string(SHA1 targethash "${${name}_expanded_dependencies}" )

      #---Adding extra step to copy the sources in /share/sources-------------------------------------
      if(NOT ARG_BINARY_PACKAGE) 
        ExternalProject_Add_Step(${targetname} install_sources COMMENT "Installing sources for '${targetname}' and create source tarball"
          COMMAND ${CMAKE_COMMAND} -E copy_directory <SOURCE_DIR> ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}/share/sources/${curr_name}
          COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/../distribution/${name}
          COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/../.. ${CMAKE_COMMAND} -E tar cfz ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/../distribution/${name}/${name}-${version}-src.tgz ${name}
          DEPENDERS configure
          DEPENDEES update patch)
      endif()

      #---Adding extra step to build the binary tarball-----------------------------------------------
      if(NOT ARG_DEST_NAME)  # Only if is not installed grouped with other packages
        get_filename_component(n_name ${${name}_directory_name} NAME)
        ExternalProject_Add_Step(${targetname} package COMMENT "Creating binary tarball for '${targetname}'"
                  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/../distribution/${name}
                  COMMAND ${CMAKE_COMMAND} -E chdir ${${dest_name}_home}/../../..
                  ${CMAKE_COMMAND} -E tar cfz ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/../distribution/${name}/${name}-${version}-${LCG_system}-${targethash}.tgz ${n_name}/${version}/${LCG_system}
          DEPENDEES strip_rpath)
      endif()
      #---Adding extra step to copy the log files----------------------------------------------------
      ExternalProject_Add_Step(${targetname} install_logs COMMENT "Installing log files for '${targetname}'"
          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=${${dest_name}_home}/logs -DLOGS_DIR=${CMAKE_CURRENT_BINARY_DIR}/${targetname}/src/${targetname}-stamp  
                                   -P ${CMAKE_SOURCE_DIR}/cmake/scripts/InstallLogFiles.cmake
          DEPENDEES install)

      #---Remove the rpath from all shared objects----------------------------------------------------
      ExternalProject_Add_Step(${targetname} strip_rpath COMMENT "Removing rpath from '${targetname}'"
        COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=${${dest_name}_home}
                                 -P ${CMAKE_SOURCE_DIR}/cmake/scripts/RemoveRPath.cmake
        DEPENDEES install)


      #---Add extra steps eventually------------------------------------------------------------------
      set(current_dependee install)
      if(ARG_TEST_COMMAND)
        set(testdepender DEPENDERS test)
      endif()
      if(ARG_CONFIGURE_EXAMPLES_COMMAND)
        ExternalProject_Add_Step(${targetname} configure_examples COMMENT "Configure examples for '${targetname}'"
          COMMAND  ${ARG_CONFIGURE_EXAMPLES_COMMAND}
          ${testdepender}
          DEPENDEES ${current_dependee})
        set(current_dependee configure_examples)
      endif()
      if(ARG_BUILD_EXAMPLES_COMMAND)
        ExternalProject_Add_Step(${targetname} build_examples COMMENT "Build examples for '${targetname}'"
          COMMAND  ${ARG_BUILD_EXAMPLES_COMMAND}
          ${testdepender}
          DEPENDEES ${current_dependee})
        set(current_dependee build_examples)
      endif()
      if(ARG_INSTALL_EXAMPLES_COMMAND)
        ExternalProject_Add_Step(${targetname} install_examples COMMENT "Install examples for '${targetname}'"
          COMMAND  ${ARG_INSTALL_EXAMPLES_COMMAND}
          ${testdepender}
          DEPENDEES ${current_dependee})
        set(current_dependee install_examples)
      endif()

      #---Adding clean targets--------------------------------------------------------------------------
      add_custom_target(clean-${targetname} COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/${targetname}
                                            COMMAND ${CMAKE_COMMAND} -E remove_directory ${${name}_home})
    endif()
    
    if(nvers GREATER 1)
      add_dependencies(${name} ${targetname})
      add_dependencies(clean-${name} clean-${targetname})
    endif()
  endforeach()

  #--- export the latest ${name}_home variable to the other subdirectories
  set(${name}_home ${${name}_home} PARENT_SCOPE)

  #--- mark that the target exists
  set(${name}_exists 1 PARENT_SCOPE)

  #--- export the dependencies to the outside files 
  set(${targetname}_dependencies ${${targetname}_dependencies} PARENT_SCOPE)

endmacro()

#----------------------------------------------------------------------------------------------------
# LCGPackage_create_dependency_file function 
#  o creates json and dot files containing the dependency tree
#  o uses ${name}_dependencies, ${name}_exists and ${targetname}_native_version
#----------------------------------------------------------------------------------------------------
function(LCG_create_dependency_files)
  set(dotfile ${CMAKE_BINARY_DIR}/dependencies.dot)
  set(jsonfile ${CMAKE_BINARY_DIR}/dependencies.json)
  file(WRITE ${dotfile} "digraph lcgcmake {\n")
  file(WRITE ${jsonfile} "{\n")
  foreach(targetname  ${LCG_externals} ${LCG_projects})
    if(NOT ${targetname}_exists)
      MESSAGE("WARNING: ${targetname} has a version (${${targetname}_native_version}), but no target defined.")
    endif()
    # clean up things dot doesn't understand
    # eventually replace with REGEX REPLACE
    string(REPLACE "+" "p" cleaned_name ${targetname})
    string(REPLACE "-" "_" cleaned_name ${cleaned_name})
    string(REPLACE "-" "_" cleaned_name ${cleaned_name})
    file(APPEND ${dotfile} "_${cleaned_name}_ [label=\"${targetname}\"];\n")
    set(json_string "'${targetname}' : {'version': '${${targetname}_native_version}', 'dependencies' : [")
    foreach(dep ${${targetname}_dependencies})
      string(REPLACE "+" "p" cleaned_dep ${dep})
      set(json_string "${json_string} '${dep}',")
      file(APPEND ${dotfile} "_${cleaned_name}_ -> _${cleaned_dep}_;\n")
    endforeach()
    set(json_string "${json_string} ]}")
    file(APPEND ${jsonfile} ${json_string},\n)
  endforeach()
  file(APPEND ${dotfile} "}\n")
  file(APPEND ${jsonfile} "}\n")
  message("Wrote package dependency information to ${dotfile} and ${jsonfile}.")
endfunction()

# Helper function to expand dependencies from further dependencies
function(LCG_append_depends name var)
  list(APPEND ${var} ${name})
  foreach(p ${${name}_dependencies})
    LCG_append_depends(${p} ${var})
  endforeach()
  list(REMOVE_DUPLICATES ${var})
  set(${var} ${${var}} PARENT_SCOPE)
endfunction()

# Helper macro to define the home of a package
macro( LCGPackage_set_home name)
   set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${${name}_native_version}/${LCG_system})
endmacro()