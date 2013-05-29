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

    #---Handle multi-version packages----------------------------------------------------------------
    if(nvers GREATER 1)
      set(targetname ${name}-${version})
    else()
      set(targetname ${name})
    endif()
    
    #---Handle dependencies--------------------------------------------------------------------------
    set(${targetname}_dependencies "")
    if(ARG_DEPENDS)
      foreach(dep ${ARG_DEPENDS})
        if(NOT TARGET ${dep} AND NOT DEFINED ${dep}_home)
          message(SEND_ERROR "Package' ${name}' has declared a dependency to the package '${dep}' that has not yet been defined. "
                             "Add a call to 'LCGPackage_set_home(${dep})' to forward declare it.")
        endif()
        list(APPEND ${targetname}_dependencies ${dep})
      endforeach()
    endif()
    #---Get the expanded list of dependencies with their versions-------------------------------------
    LCG_get_full_version(${name} ${version} ${name}_full_version)

    #---Install path----------------------------------------------------------------------------------
    set(install_path ${${name}_directory_name}/${version}/${LCG_system})

    #---Check if the version file is already existing in the installation area(s)---------------------
    set(${targetname}_version_checked 0)
    set(${targetname}_version_file ${LCG_INSTALL_PREFIX}/${install_path}/version.txt)
    if(EXISTS ${${targetname}_version_file})
      file(READ ${${targetname}_version_file} full_version)
      if(full_version STREQUAL ${${name}_full_version})
        set(${targetname}_version_checked 1)
      endif()
    endif()

    #---Check if the package is already existing in the installation area(s)
    if((NOT ARG_BUNDLE_PACKAGE AND ${${targetname}_version_checked}) OR
       (NOT ARG_BUNDLE_PACKAGE AND EXISTS ${LCG_INSTALL_PREFIX}/${install_path} AND NOT EXISTS ${LCG_INSTALL_PREFIX}/${install_path}/version.txt))
      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${install_path})
      add_custom_target(${targetname} ALL COMMAND ${CMAKE_COMMAND} -E make_directory  ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}
                                          COMMAND ${CMAKE_COMMAND} -E create_symlink ${LCG_INSTALL_PREFIX}/${install_path} ${CMAKE_INSTALL_PREFIX}/${install_path}
                                          COMMENT "${targetname} package already existing in ${LCG_INSTALL_PREFIX}/${install_path}. Making a soft-link.")
      add_custom_target(clean-${targetname} COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_INSTALL_PREFIX}/${install_path}
                                            COMMENT "Deleting soft-link for package ${targetname}")

    elseif(NOT ARG_BUNDLE_PACKAGE AND EXISTS ${LCG_INSTALL_PREFIX}/../app/releases/${install_path})
      get_filename_component(_path ${LCG_INSTALL_PREFIX} PATH)
      set(_path ${_path}/app/releases/${install_path})
      if(${name} STREQUAL ROOT)  # ROOT in LCG installations is special
        set(_path ${_path}/root)
      endif()
      set(${name}_home ${_path})
      add_custom_target(${targetname} ALL COMMENT "${targetname} package already existing in ${_path}. Using it directly.")
      add_custom_target(clean-${targetname} COMMENT "${targetname} nothing to be done")

    else()
      #---Replace patterns for multiversion cases-----------------------------------------------------
      string(REPLACE <NATIVE_VERSION> ${version} ARGUMENTS "${ARG_UNPARSED_ARGUMENTS}")
      string(REPLACE <VOID> "" ARGUMENTS "${ARGUMENTS}")
      foreach(iter 1 2 3)  # 3 nested replacements
        string(REGEX MATCHALL "<[^ <>(){}]+>" vars ${ARGUMENTS})
        foreach(var ${vars})
          string(REPLACE "<" "" v ${var})
          string(REPLACE ">" "" v ${v})
          if(DEFINED ${v})
             string(REPLACE ${var} ${${v}} ARGUMENTS "${ARGUMENTS}")
          endif()
        endforeach()
      endforeach()

      #---Set home and install name-------------------------------------------------------------------
      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      set(${targetname}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      if(ARG_DEST_NAME)
        set(dest_name ${ARG_DEST_NAME})
        set(dest_version ${${ARG_DEST_NAME}_native_version})
        set(curr_name ${name})
      else()
        set(dest_name ${name})
        set(dest_version ${version})
        set(curr_name)
      endif()
      
      #---Remove previous sym-links------------------------------------------------------------------
      if(IS_SYMLINK ${${name}_home})
        file(REMOVE {${name}_home})
      endif()
      
      #---Check if a patch file exists and apply it by default---------------------------------------
      if(NOT ARGUMENTS MATCHES PATCH_COMMAND)
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${name}-${version}.patch)
          list(APPEND ARGUMENTS PATCH_COMMAND patch -p0 -i ${CMAKE_CURRENT_SOURCE_DIR}/${name}-${version}.patch)
        elseif(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${name}-${version}.patch)
          list(APPEND ARGUMENTS PATCH_COMMAND patch -p0 -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${name}-${version}.patch)
        endif()
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
        
      if(ARG_DEPENDS)
        add_dependencies(${targetname} ${ARG_DEPENDS})
      endif()

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
        string(SHA1 targethash "${${name}_full_version}" )
        ExternalProject_Add_Step(${targetname} package COMMENT "Creating binary tarball and version.txt file for '${targetname}'"
                  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/../distribution/${name}
                  COMMAND ${CMAKE_COMMAND} -E chdir ${${dest_name}_home}/../../..
                  ${CMAKE_COMMAND} -E tar cfz ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/../distribution/${name}/${name}-${version}-${LCG_system}-${targethash}.tgz ${n_name}/${version}/${LCG_system}
                  COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=${${dest_name}_home} -DFULL_VERSION=${${name}_full_version} -P ${CMAKE_SOURCE_DIR}/cmake/scripts/InstallVersionFile.cmake
          DEPENDEES strip_rpath)
      endif()
      #---Adding extra step to copy the log files and version file--------------------------------------
      ExternalProject_Add_Step(${targetname} install_logs COMMENT "Installing log and version files for '${targetname}'"
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

    set(${targetname}_home ${${name}_home} PARENT_SCOPE)

  endforeach()
  
  #---Prepare 'group' targets------------------------------------------------------------------------
  get_filename_component(group ${CMAKE_CURRENT_SOURCE_DIR} NAME)
  if(NOT TARGET ${group})
    add_custom_target(${group} COMMENT "Grouping ${group} global target")
    add_custom_target(clean-${group} COMMENT "Clean group target ${group}")
  endif()
  add_dependencies(${group} ${name})
  add_dependencies(clean-${group} clean-${name})

  #--- export the latest ${name}_home variable to the other subdirectories---------------------------
  set(${name}_home ${${name}_home} PARENT_SCOPE)

  #--- mark that the target exists-------------------------------------------------------------------
  set(${name}_exists 1 PARENT_SCOPE)

  #--- export the dependencies to the outside files--------------------------------------------------
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

#----------------------------------------------------------------------------------------------------
# Helper function to expand dependencies from further dependencies
#----------------------------------------------------------------------------------------------------
function(LCG_append_depends name var)
  list(APPEND ${var} ${name})
  foreach(p ${${name}_dependencies})
    LCG_append_depends(${p} ${var})
  endforeach()
  list(REMOVE_DUPLICATES ${var})
  set(${var} ${${var}} PARENT_SCOPE)
endfunction()

#----------------------------------------------------------------------------------------------------
# Helper function to get the full version (inclusing the version of all expanded dependencies)
#----------------------------------------------------------------------------------------------------
function(LCG_get_full_version name version var)
  set(_expanded_dependencies)
  set(_full_version)
  LCG_append_depends(${name} _expanded_dependencies)
  list(SORT _expanded_dependencies)
  foreach(p ${_expanded_dependencies})
    if(p STREQUAL ${name})
      list(APPEND _full_version ${p}=${version})
    else()
      list(APPEND _full_version ${p}=${${p}_native_version})
    endif()
  endforeach()
  string(REPLACE ";" "/" _full_version "${_full_version}")
  set(${var} ${_full_version} PARENT_SCOPE)
endfunction()

#---------------------------------------------------------------------------------------------------
# Helper macro to define the home of a package
#---------------------------------------------------------------------------------------------------
macro( LCGPackage_set_home name)
  foreach( version ${${name}_native_version} )
    set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
  endforeach()
endmacro()


#-----------------------------------------------------------------------
# function LCG_add_test(<name> COMMAND cmd [arg1... ] 
#                           [PRECMD cmd [arg1...]] [POSTCMD cmd [arg1...]]
#                           OUTPUT outfile] [ERROR errfile]
#                           [WORKING_DIRECTORY directory]
#                           [ENVIRONMENT var1=val1 var2=val2 ...
#                           [DEPENDS test1 ...]
#                           [TIMEOUT seconds] 
#                           [DEBUG]
#                           [SOURCE_DIR dir] [BINARY_DIR dir]
#                           [BUILD target] [PROJECT project]
#                           [BUILD_OPTIONS options]
#                           [PASSREGEX exp] [FAILREGEX epx]
#                           [LABELS label1 label2 ...])
#
function(LCG_add_test test)
  cmake_parse_arguments(ARG
    "DEBUG" 
    "TIMEOUT;BUILD;OUTPUT;ERROR;SOURCE_DIR;BINARY_DIR;PROJECT;PASSREGEX;FAILREGEX;WORKING_DIRECTORY" 
    "COMMAND;PRECMD;POSTCMD;ENVIRONMENT;DEPENDS;LABELS;BUILD_OPTIONS"
    ${ARGN})

  if(NOT CMAKE_GENERATOR MATCHES Makefiles)
    set(_cfg $<CONFIGURATION>/)
  endif()
  
  #- Handle COMMAND argument
  list(LENGTH ARG_COMMAND _len)
  if(_len LESS 1)
    if(NOT ARG_BUILD)
      message(FATAL_ERROR "LCG_ADD_TEST: command is mandatory (without build)")
    endif()
  else()
    list(GET ARG_COMMAND 0 _prg)
    list(REMOVE_AT ARG_COMMAND 0)
    if(NOT IS_ABSOLUTE ${_prg})
      set(_prg ${CMAKE_CURRENT_BINARY_DIR}/${_cfg}${_prg})
    elseif(EXISTS ${_prg})
    else()
      get_filename_component(_path ${_prg} PATH)
      get_filename_component(_file ${_prg} NAME)
      set(_prg ${_path}/${_cfg}${_file})
    endif()
    set(_cmd ${_prg} ${ARG_COMMAND})
    string(REPLACE ";" "#" _cmd "${_cmd}")
  endif()

  set(_command ${CMAKE_COMMAND} -DTST=${test} -DCMD=${_cmd})

  #- Handle PRE and POST commands
  if(ARG_PRECMD)
    set(_pre ${ARG_PRECMD})
    string(REPLACE ";" "#" _pre "${_pre}")
    set(_command ${_command} -DPRE=${_pre})
  endif()
  if(ARG_POSTCMD)
    set(_post ${ARG_POSTCMD})
    string(REPLACE ";" "#" _post "${_post}")
    set(_command ${_command} -DPOST=${_post})
  endif()

  #- Handle OUTPUT, ERROR, DEBUG arguments
  if(ARG_OUTPUT)
    set(_command ${_command} -DOUT=${ARG_OUTPUT})
  endif()

  if(ARG_ERROR)
    set(_command ${_command} -DERR=${ARG_ERROR})
  endif()

  if(ARG_DEBUG)
    set(_command ${_command} -DDBG=ON)
  endif()
  
  if(ARG_WORKING_DIRECTORY)
    set(_command ${_command} -DCWD=${ARG_WORKING_DIRECTORY})
  endif()
  
  if(ARG_TIMEOUT)
    set(_command ${_command} -DTIM=${ARG_TIMEOUT})
  endif()

  #- Handle ENVIRONMENT argument
  if(ARG_ENVIRONMENT)
    string(REPLACE ";" "#" _env "${ARG_ENVIRONMENT}")
    string(REPLACE "=" "@" _env "${_env}")
    set(_command ${_command} -DENV=${_env})
  endif()

  #- Locate the test driver
  set(_driver ${CMAKE_SOURCE_DIR}/cmake/scripts/TestDriver.cmake)
  if(NOT EXISTS ${_driver})
    message(FATAL_ERROR "LCG_ADD_TEST: TestDriver.cmake not found!")
  endif()
  set(_command ${_command} -P ${_driver})

  #- Now we can actually add the test
  if(ARG_BUILD)
    if(ARG_SOURCE_DIR)
      if(NOT IS_ABSOLUTE ${ARG_SOURCE_DIR})
        set(ARG_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/${ARG_SOURCE_DIR})
      endif()
    else()
      set(ARG_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
    endif()
    if(ARG_BINARY_DIR)
      if(NOT IS_ABSOLUTE ${ARG_BINARY_DIR})
        set(ARG_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/${ARG_BINARY_DIR})
      endif()
    else()
      set(ARG_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
    endif()
    if(NOT ARG_PROJECT)
       if(NOT PROJECT_NAME STREQUAL "LCGSoft")
         set(ARG_PROJECT ${PROJECT_NAME})
       else()
         set(ARG_PROJECT ${ARG_BUILD})
       endif()
    endif() 
    add_test(NAME ${test} COMMAND ${CMAKE_CTEST_COMMAND}
      --build-and-test  ${ARG_SOURCE_DIR} ${ARG_BINARY_DIR}
      --build-generator ${CMAKE_GENERATOR}
      --build-makeprogram ${CMAKE_MAKE_PROGRAM}
      --build-target ${ARG_BUILD}
      --build-project ${ARG_PROJECT}
      --build-config $<CONFIGURATION>
      --build-noclean
      --build-options ${ARG_BUILD_OPTIONS}
      --test-command ${_command} )
    set_property(TEST ${test} PROPERTY ENVIRONMENT Geant4_DIR=${CMAKE_BINARY_DIR})
    if(ARG_FAILREGEX)
      set_property(TEST ${test} PROPERTY FAIL_REGULAR_EXPRESSION "warning:|(${ARG_FAILREGEX})")
    else()
      set_property(TEST ${test} PROPERTY FAIL_REGULAR_EXPRESSION "warning:")      
    endif()
  else()
    add_test(NAME ${test} COMMAND ${_command})
    if(ARG_FAILREGEX)
      set_property(TEST ${test} PROPERTY FAIL_REGULAR_EXPRESSION ${ARG_FAILREGEX})
    endif()
  endif()

  #- Handle TIMOUT and DEPENDS arguments
  if(ARG_TIMEOUT)
    set_property(TEST ${test} PROPERTY TIMEOUT ${ARG_TIMEOUT})
  endif()

  if(ARG_DEPENDS)
    set_property(TEST ${test} PROPERTY DEPENDS ${ARG_DEPENDS})
  endif()

  if(ARG_PASSREGEX)
    set_property(TEST ${test} PROPERTY PASS_REGULAR_EXPRESSION ${ARG_PASSREGEX})
  endif()
  
  if(ARG_LABELS)
    set_property(TEST ${test} PROPERTY LABELS ${ARG_LABELS})
  else()
    set_property(TEST ${test} PROPERTY LABELS Nightly)  
  endif()
endfunction()


