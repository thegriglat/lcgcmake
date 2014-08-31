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
set (dependency_split_pattern "([^-]+)-(.+)")

macro(LCGPackage_Add name)

  #---If version is not defined (package not mentioned in toolchain) skip the whole macro------------
  if(DEFINED ${name}_native_version)  # If version is not defined skip

  #---Create ${name} global target-------------------------------------------------------------------
  add_custom_target(${name} ALL)
  add_custom_target(clean-${name})
  if(LCG_SAFE_INSTALL)
    add_custom_target(cleanmore-${name})
  endif()
  
  #---Loop over all versions of the package----------------------------------------------------------
  foreach( version ${${name}_native_version} )
  
    #---Replace conditional, expand macros and parse all the arguments-------------------------------
    LCG_expand_version_patterns(${version} ARGUMENTS "${ARGN}")
    LCG_replace_conditional_args(ARGUMENTS "${ARGUMENTS}")
    CMAKE_PARSE_ARGUMENTS(ARG "" "DEST_NAME;BUNDLE_PACKAGE;BINARY_PACKAGE"
    "DEPENDS;CONFIGURE_EXAMPLES_COMMAND;BUILD_EXAMPLES_COMMAND;INSTALL_EXAMPLES_COMMAND;TEST_COMMAND" "${ARGUMENTS}")
    string(REPLACE <VOID> "" ARGUMENTS "${ARG_UNPARSED_ARGUMENTS}")

    #---Handle multi-version packages----------------------------------------------------------------
    set(targetname ${name}-${version})
    
    #---Handle dependencies--------------------------------------------------------------------------
    set(${targetname}_dependencies "")
    if(ARG_DEPENDS)
      foreach(dep ${ARG_DEPENDS})
        if(NOT TARGET ${dep} AND NOT DEFINED ${dep}_home)
          if(DEFINED ${dep}_native_version)
            message(SEND_ERROR "Package '${name}' declares a dependency to the package '${dep}' that has not been defined. "
                               "Add a call to 'LCGPackage_set_home(${dep})' to forward declare it.")
          else()
            message(SEND_ERROR "Package '${name}' depends on package '${dep}' that has no declared version in toolchain file. "
                               "Add a call to 'LCG_external_package(${dep} <version>)' in ${CMAKE_TOOLCHAIN_FILE}.")
          endif()
        endif()
        list(APPEND ${targetname}_dependencies ${dep})
      endforeach()
    endif()
#---Get list of dependencies as package-version
    if(ARG_DEPENDS)
      set (${targetname}-dependencies)
      foreach(dep ${ARG_DEPENDS})
        if(dep MATCHES "${dependency_split_pattern}")
          list (APPEND ${targetname}-dependencies "${CMAKE_MATCH_1}-${CMAKE_MATCH_2}")
        else()
          list(GET ${dep}_native_version -1 dep_vers)
          list(APPEND ${targetname}-dependencies "${dep}-${dep_vers}")
        endif()
      endforeach()
    endif()
    #---Get the expanded list of dependencies with their versions-------------------------------------
    LCG_get_full_version(${targetname} ${version} ${name}_full_version)

    string(SHA1 longtargethash "${${name}_full_version}" )
    string(SUBSTRING "${longtargethash}" 0 5 targethash )
    set(${targetname}_hash ${targethash})

    #---Deal with deatination name (bundle packages)--------------------------------------------------
    if(ARG_DEST_NAME)
      set(dest_name ${ARG_DEST_NAME})
      set(dest_version ${${ARG_DEST_NAME}_native_version})
      set(curr_name ${name})
      # Remember all used destinations to avoid checking the existance of install area
      list(APPEND dest_all_names ${ARG_DEST_NAME})
    else()
      set(dest_name ${name})
      set(dest_version ${version})
      set(curr_name)
    endif()

    #---Install path----------------------------------------------------------------------------------
    set(install_path ${${dest_name}_directory_name}/${dest_version}/${LCG_system})

    #---Check if the version file is already existing in the installation area(s)---------------------
    #   The checking is different for bundled packages (i.e. ARG_DEST_NAME)
    set(${targetname}_version_checked 0)
    set(${targetname}_version_file ${LCG_INSTALL_PREFIX}/${install_path}/version.txt)
    if(EXISTS ${${targetname}_version_file})
      file(STRINGS ${${targetname}_version_file} full_version)
      if(full_version STREQUAL ${${name}_full_version} OR  ARG_DEST_NAME)
        set(${targetname}_version_checked 1)
      endif()
    endif()

    #---Package to be ignord from LCG_INSTALL_PREFIX
    list(FIND LCG_IGNORE ${name} lcg_ignore)

    #---Check if the package is already existing in the installation area(s)
    if(lcg_ignore EQUAL -1 AND
       (${${targetname}_version_checked} OR (EXISTS ${LCG_INSTALL_PREFIX}/${install_path} AND NOT EXISTS ${LCG_INSTALL_PREFIX}/${install_path}/version.txt)) )
      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${install_path})
      set(${targetname}_home ${${name}_home})
      add_custom_target(${targetname} ALL COMMAND ${CMAKE_COMMAND} -E make_directory  ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}
                                          COMMAND ${CMAKE_COMMAND} -E create_symlink ${LCG_INSTALL_PREFIX}/${install_path} ${CMAKE_INSTALL_PREFIX}/${install_path}
                                          DEPENDS ${${targetname}-dependencies}
                                          COMMENT "${targetname} package already existing in ${LCG_INSTALL_PREFIX}/${install_path}. Making a soft-link.")
      add_custom_target(clean-${targetname} COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_INSTALL_PREFIX}/${install_path}
                                            COMMENT "Deleting soft-link for package ${targetname}")

    elseif(lcg_ignore EQUAL -1 AND EXISTS ${LCG_INSTALL_PREFIX}/../app/releases/${install_path})
      get_filename_component(_path ${LCG_INSTALL_PREFIX} PATH)
      set(_path ${_path}/app/releases/${install_path})
      if(${name} STREQUAL ROOT)  # ROOT in LCG installations is special
        set(_path ${_path}/root)
      endif()
      set(${name}_home ${_path})
      set(${targetname}_home ${${name}_home})
      add_custom_target(${targetname} ALL COMMENT "${targetname} package already existing in ${_path}. Using it directly.")
      add_custom_target(clean-${targetname} COMMENT "${targetname} nothing to be done")

    else()

      #---Set home and install name-------------------------------------------------------------------
      set(${name}_home            ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      set(${name}-${version}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
      set(${targetname}_dest_name ${dest_name} PARENT_SCOPE)     
      
      #---Remove previous sym-links------------------------------------------------------------------
      if(IS_SYMLINK ${${name}_home})
        file(REMOVE ${${name}_home})
      endif()
      
      #---Check if a patch file exists and apply it by default---------------------------------------
      if(NOT ARGUMENTS MATCHES PATCH_COMMAND)
        if(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/patches/${name}-${version}.patch)
          # old version of `patch` makes uncopyable backup files (on SLC5 and MAC)
          # http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=558485
          if(${LCG_OS}${LCG_OSVERS} STRGREATER slc5)
            set(patch_backup_opt -b)
          else()
            set(patch_backup_opt)
          endif()
          
          list(APPEND ARGUMENTS PATCH_COMMAND patch -l -p0 ${patch_backup_opt} -i ${CMAKE_CURRENT_SOURCE_DIR}/patches/${name}-${version}.patch)
        endif()
      endif()

      #---We cannot use the argument INSTALL_DIR becuase cmake itself will create the directory 
      #   unconditionaly before make is executed. So, we replace <INSTALL_DIR> before passing the
      #   arguments to ExternalPreject_Add().
      string(REPLACE <INSTALL_DIR> ${${dest_name}_home} ARGUMENTS "${ARGUMENTS}")
      string(REPLACE <INSTALL_DIR> ${${dest_name}_home} ARG_TEST_COMMAND_BIS "${ARG_TEST_COMMAND}")

      #---Add the external project -------------------------------------------------------------------
      ExternalProject_Add(
        ${targetname}
        PREFIX ${targetname}
        SOURCE_DIR ${targetname}/src/${name}/${version}
        "${ARGUMENTS}"
        TEST_COMMAND ${ARG_TEST_COMMAND_BIS}
        LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1 )
        
      if(ARG_DEPENDS)
        add_dependencies(${targetname} ${${targetname}-dependencies})
      endif()

      #--Prioritize the update and patch command------------------------------------------------------
      if(ARGUMENTS MATCHES UPDATE_COMMAND AND ARGUMENTS MATCHES PATCH_COMMAND)
        ExternalProject_Get_Property(${targetname} stamp_dir)
        add_custom_command(APPEND
          OUTPUT ${stamp_dir}/${targetname}-patch
          DEPENDS ${stamp_dir}/${targetname}-update)
      endif()
      
      #---Add a step to check if the <INSTALL_DIR> already exists and fail eventually-----------------
      if(LCG_SAFE_INSTALL)
        #--- Add the extra check step only if it is not installed somewhere else
        list(FIND dest_all_names ${dest_name} indx)
        if(indx EQUAL -1)
          ExternalProject_Add_Step(${targetname} check_install_dir
                                   COMMAND test ! -d ${${dest_name}_home}
                                   COMMENT "Checking that install directory '${${dest_name}_home}' does not exists.\n"
                                   DEPENDERS download)
        endif()
      endif()

      #---Adding extra step to copy the sources in /share/sources-------------------------------------	
      if(NOT ARG_BINARY_PACKAGE) 
         if (LCG_TARBALL_INSTALL) 
          ExternalProject_Add_Step(${targetname} install_sources
              COMMENT "Installing sources for '${targetname}' and create source tarball"
              COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}
              COMMAND lockfile -l 300 ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}/lock.txt
              COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}/share/sources/${curr_name} -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
              COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/../distribution/${name}
              COMMAND ${CMAKE_COMMAND} -E chdir <SOURCE_DIR>/../.. ${CMAKE_COMMAND} -E tar cfz ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/../distribution/${name}/${name}-${version}-src.tgz ${name}
	      COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}/lock.txt
          DEPENDERS configure
          DEPENDEES update patch)
         else()
	   ExternalProject_Add_Step(${targetname} install_sources
              COMMENT "Installing sources for '${targetname}'"
              COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}
              COMMAND lockfile -l 300 ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}/lock.txt
              COMMAND ${CMAKE_COMMAND} -DSRC=<SOURCE_DIR> -DDST=${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}/share/sources/${curr_name} -P ${CMAKE_SOURCE_DIR}/cmake/scripts/copy.cmake
              COMMAND ${CMAKE_COMMAND} -E remove -f ${CMAKE_INSTALL_PREFIX}/${${dest_name}_directory_name}/${dest_version}/lock.txt
          DEPENDERS configure
          DEPENDEES update patch)
         endif()
      endif()

      # record the revision number of lcgcmake
      execute_process(COMMAND svnversion  ${CMAKE_SOURCE_DIR} 
                      OUTPUT_VARIABLE lcgcmakerevision
      )
      string(REPLACE "\n" "" lcgcmakerevision "${lcgcmakerevision}")

     #---Compile information needed for the build description file (installed alongside version.txt)
     set(buildinfostring " COMPILER: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION},")
     site_name(hostname)
     set(buildinfostring "${buildinfostring} HOSTNAME: ${hostname},")
     set(buildinfostring "${buildinfostring} SVNREVISION: ${lcgcmakerevision},")
     set(buildinfostring "${buildinfostring} HASH: ${targethash},")    
     set(buildinfostring "${buildinfostring} DESTINATION: ${dest_name},")
     set(buildinfostring "${buildinfostring} NAME: ${name},")
     set(buildinfostring "${buildinfostring} VERSION: ${version},")
     foreach(dep ${ARG_DEPENDS})
       # dependent package may have the form name-version
       if(dep MATCHES "${dependency_split_pattern}")
         set(buildinfostring "${buildinfostring}${CMAKE_MATCH_1}-${${dep}_hash},")
       else()
         list(GET ${dep}_native_version -1 vers)
         set(buildinfostring "${buildinfostring}${dep}-${${dep}-${vers}_hash},")
       endif()
     endforeach()  
     set(${dest_name}_buildinfo "${buildinfostring}")

      #---Adding extra step to copy the log files and version file--------------------------------------
      ExternalProject_Add_Step(${targetname} install_logs COMMENT "Installing log and version files for '${targetname}'"
          COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=${${dest_name}_home}/logs -DLOGS_DIR=${CMAKE_CURRENT_BINARY_DIR}/${targetname}/src/${targetname}-stamp
                                   -P ${CMAKE_SOURCE_DIR}/cmake/scripts/InstallLogFiles.cmake
          COMMAND ${CMAKE_COMMAND} -DNAME=${name} -DINSTALL_DIR=${${dest_name}_home} -DBUILDINFO=${${dest_name}_buildinfo} -P ${CMAKE_SOURCE_DIR}/cmake/scripts/InstallBuildinfoFile.cmake
          DEPENDEES install)

      #---Add extra steps eventually------------------------------------------------------------------
      set(current_dependee install)
      if(ARG_TEST_COMMAND)
        set(testdepender DEPENDERS test)
      endif()
      if(ARG_CONFIGURE_EXAMPLES_COMMAND)
        string(REPLACE <INSTALL_DIR> ${${dest_name}_home} ARG_CONFIGURE_EXAMPLES_COMMAND_BIS "${ARG_CONFIGURE_EXAMPLES_COMMAND}")
        ExternalProject_Add_Step(${targetname} configure_examples COMMENT "Configure examples for '${targetname}'"
          COMMAND  ${ARG_CONFIGURE_EXAMPLES_COMMAND_BIS}
          ${testdepender}
          DEPENDEES ${current_dependee})
        set(current_dependee configure_examples)
      endif()
      if(ARG_BUILD_EXAMPLES_COMMAND)
        string(REPLACE <INSTALL_DIR> ${${dest_name}_home} ARG_BUILD_EXAMPLES_COMMAND_BIS "${ARG_BUILD_EXAMPLES_COMMAND}")
        ExternalProject_Add_Step(${targetname} build_examples COMMENT "Build examples for '${targetname}'"
          COMMAND  ${ARG_BUILD_EXAMPLES_COMMAND_BIS}
          ${testdepender}
          DEPENDEES ${current_dependee})
        set(current_dependee build_examples)
      endif()
      if(ARG_INSTALL_EXAMPLES_COMMAND)
        string(REPLACE <INSTALL_DIR> ${${dest_name}_home} ARG_INSTALL_EXAMPLES_COMMAND_BIS "${ARG_INSTALL_EXAMPLES_COMMAND}")
        ExternalProject_Add_Step(${targetname} install_examples COMMENT "Install examples for '${targetname}'"
          COMMAND  ${ARG_INSTALL_EXAMPLES_COMMAND_BIS}
          ${testdepender}
          DEPENDEES ${current_dependee})
        set(current_dependee install_examples)
      endif()
      
      #---Remove the rpath from all shared objects----------------------------------------------------
      ExternalProject_Add_Step(${targetname} strip_rpath COMMENT "Removing rpath from '${targetname}'"
        COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=${${dest_name}_home} -DCHECK_PATH=${CMAKE_SOURCE_DIR}/cmake/scripts/check_relative_rpath.sh 
                                 -P ${CMAKE_SOURCE_DIR}/cmake/scripts/RemoveRPath.cmake
        DEPENDEES ${current_dependee})

      #---Adding extra step to build the binary tarball-----------------------------------------------
      if (LCG_TARBALL_INSTALL)	
      	if(NOT ARG_DEST_NAME)  # Only if is not installed grouped with other packages
       	 get_filename_component(n_name ${${name}_directory_name} NAME)
       	 ExternalProject_Add_Step(${targetname} package COMMENT "Creating binary tarball and version.txt file for '${targetname}'"
                  COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/../distribution/${name}
                  COMMAND ${CMAKE_COMMAND} -DINSTALL_DIR=${${dest_name}_home} -DFULL_VERSION=${${name}_full_version} -P ${CMAKE_SOURCE_DIR}/cmake/scripts/InstallVersionFile.cmake
                  COMMAND ${CMAKE_COMMAND} -E chdir ${${dest_name}_home}/../../..
                  ${CMAKE_TAR} -czf ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/../distribution/${name}/${name}-${version}-${LCG_system}.tgz ${n_name}/${version}/${LCG_system}
          DEPENDEES strip_rpath install_logs)
      	endif()
      endif()	
  
      #---Process and copy environment scripts --------------------------------------------------------
      # Available variables in template:
      # - <package>_version = version of installed package and its dependencies
      # - <package>_home    = home of installed package and its dependencies
      # - gcc_source        = path to setup.sh of gcc
      # - platform          = target platform
      get_filename_component(gcc_source "${CMAKE_C_COMPILER}" PATH)
      # Set different file name template for generators and externals
      if (${${targetname}_home} MATCHES ".*MCGenerators.*")
        set(output_name "${name}env-genser.sh")
      else()
        set(output_name "${name}-env.sh")
      endif()
      if (EXISTS "${CMAKE_SOURCE_DIR}/generators/environment/${name}.template")
        # use template if it exists
        set (template_name "${CMAKE_SOURCE_DIR}/generators/environment/${name}.template")
        set (_args "-D${name}_version=${version}" "-D${name}_home=${${name}_home}")
      else()
        # else use common template
        # Available variables
        # - this_package      = name of installed package
        # - this_version      = version of installed package
        # - dependencies      = space-separated list of dependencies
        set (template_name "${CMAKE_SOURCE_DIR}/generators/environment/common.template")
        string(REPLACE ";" " " deps "${${targetname}-dependencies}")
        set (_args "-Dthis_package=${name}" "-Dthis_version=${version}" "-Ddependencies='${deps}'")
      endif()
      # Common variables
      list(APPEND _args "-DTARGET=${${name}_home}/${output_name}" "-DTEMPLATE=${template_name}" "-Dgcc_source=${gcc_source}/../setup.sh" "-Dplatform=${LCG_platform}")
      # process dependencies
      foreach(dep ${${targetname}-dependencies})
        if(dep MATCHES "${dependency_split_pattern}")
          list (APPEND _args "-D${CMAKE_MATCH_1}_version=${CMAKE_MATCH_2}")
          list (APPEND _args "-D${CMAKE_MATCH_1}_home=${${CMAKE_MATCH_1}-${CMAKE_MATCH_2}_home}")
        endif()
      endforeach()
      ExternalProject_Add_Step(${targetname} setup_environment COMMENT "Installing environment for ${name}"
          COMMAND ${CMAKE_COMMAND} ${_args} -P ${CMAKE_SOURCE_DIR}/cmake/scripts/provide-environment.cmake
          DEPENDEES install_logs
      )

      #---Adding clean targets--------------------------------------------------------------------------
      if(LCG_SAFE_INSTALL)
        add_custom_target(clean-${targetname} COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/${targetname}
                                              COMMENT "Removing directory '${CMAKE_CURRENT_BINARY_DIR}/${targetname}'")
        add_custom_target(cleanmore-${targetname} COMMAND ${CMAKE_COMMAND} -E remove_directory ${${name}_home}
                                                  COMMENT "Removing directory '${${name}_home}'")
        add_dependencies(cleanmore-${targetname} clean-${targetname})
      else()
        add_custom_target(clean-${targetname} COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_CURRENT_BINARY_DIR}/${targetname}
                                              COMMAND ${CMAKE_COMMAND} -E remove_directory ${${name}_home}
                                              COMMENT "Removing directores '${CMAKE_CURRENT_BINARY_DIR}/${targetname}' and '${${name}_home}'")
      endif()
    endif()
    
    add_dependencies(${name} ${targetname})
    add_dependencies(clean-${name} clean-${targetname})
    if(LCG_SAFE_INSTALL)
      add_dependencies(cleanmore-${name} cleanmore-${targetname})
    endif()

    set(${name}-${version}_home ${${name}_home} PARENT_SCOPE)
    set(${targetname}_dependencies ${${targetname}_dependencies} PARENT_SCOPE)
    set(${targetname}_hash ${${targetname}_hash} PARENT_SCOPE)    

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

  #---End if the main if --------------------------------------------------------------------------
  endif(DEFINED ${name}_native_version)

endmacro()

#----------------------------------------------------------------------------------------------------
# LCGPackage_create_dependency_file function 
#  o creates json and dot files containing the dependency tree
#  o uses 
#      ${name}_dependencies
#      ${name}_exists
#      ${targetname}_dest_name
#      ${targetname}_hash
#      ${targetname}_native_version
#  o TODO: does not work with multi-version packages yet
#----------------------------------------------------------------------------------------------------
function(LCG_create_dependency_files)
  set(firstdep 1)

  set(dotfile ${CMAKE_BINARY_DIR}/dependencies.dot)
  set(jsonfile ${CMAKE_BINARY_DIR}/dependencies.json)
  set(sumfile ${CMAKE_BINARY_DIR}/LCG_${LCG_VERSION}_${LCG_system}.txt)
  file(WRITE ${dotfile} "digraph lcgcmake {\n")
  file(WRITE ${jsonfile} "{\n")
  file(WRITE ${sumfile} "# name-hash; package name; version; hash; full directory name; comma separated dependencies\n")
  file(APPEND ${sumfile} "COMPILER: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}\n")
  # add release and platform info
  file(APPEND ${jsonfile} "'description': {\n")
  file(APPEND ${jsonfile} "'version': '${LCG_VERSION}',\n")
  file(APPEND ${jsonfile} "'platform': '${LCG_system}'\n")
  file(APPEND ${jsonfile} "},\n")
  #
  file(APPEND ${jsonfile} "'packages': {\n")
  foreach(name  ${LCG_externals} ${LCG_projects})
    if(NOT ${name}_exists)
      MESSAGE("WARNING: ${name} has a version (${${name}_native_version}), but no target defined.")
    else()
      # clean up things dot doesn't understand
      # eventually replace with REGEX REPLACE
      string(REPLACE "+" "p" cleaned_name ${name})
      string(REPLACE "-" "_" cleaned_name ${cleaned_name})
      string(REPLACE "-" "_" cleaned_name ${cleaned_name})
      foreach(version ${${name}_native_version})
        set(targetname ${name}-${version})
        file(APPEND ${dotfile} "_${cleaned_name}_ [label=\"${cleaned_name}-${${targetname}_hash}\"];\n")
        set(json_string "'${name}-${${targetname}_hash}' : {'name': '${name}', 'version': '${version}', 'hash': '${${targetname}_hash}','dest_name':'${${targetname}_dest_name}', 'dest_directory':'${${${targetname}_dest_name}_directory_name}' ,'dependencies' : [")
        set(sum_string "${name}-${${targetname}_hash}\;${name}\;${version}\;${${targetname}_hash}\;${${${targetname}_dest_name}_directory_name}\;")
        set(firstdep 1)
        foreach(dep ${${targetname}_dependencies})
          string(REPLACE "+" "p" cleaned_dep ${dep})
          IF (firstdep EQUAL 1)
              SET (sum_prefix "")
              SET (firstdep 0)
            ELSE()
              SET (sum_prefix ",")
          ENDIF()
          # dependent package may have the form name-version
          if(dep MATCHES "${dependency_split_pattern}")
            set(json_string "${json_string} '${CMAKE_MATCH_1}-${${dep}_hash}',")
            set(sum_string "${sum_string}${sum_prefix}${CMAKE_MATCH_1}-${${dep}_hash}")
          else()
            list(GET ${dep}_native_version -1 vers)
            set(json_string "${json_string} '${dep}-${${dep}-${vers}_hash}',")
            set(sum_string "${sum_string}${sum_prefix}${dep}-${${dep}-${vers}_hash}")
       endif()
          file(APPEND ${dotfile} "_${cleaned_name}_ -> _${cleaned_dep}_;\n")
        endforeach()
        set(json_string "${json_string} ]}")
        file(APPEND ${jsonfile} ${json_string},\n)
        file(APPEND ${sumfile} ${sum_string}\n)
      endforeach()
    endif()
  endforeach()
  file(APPEND ${dotfile} "}\n")
  file(APPEND ${jsonfile} "} }\n")
  message("Wrote package dependency information to ${dotfile}, ${jsonfile} and ${sumfile}.")
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
      string(REPLACE -${version} "" p ${p})     # Remove the version from the package name
      list(APPEND _full_version ${p}=${version})
    else()
      if(p MATCHES "(.+)-(.+)")
        list(APPEND _full_version ${CMAKE_MATCH_1}=${CMAKE_MATCH_2})
      else()
        list(GET ${p}_native_version -1 vers)    # Last version in case of multi-version wins !!
        list(APPEND _full_version ${p}=${vers})
      endif()
    endif()
  endforeach()
  string(REPLACE ";" "/" _full_version "${_full_version}")
  set(${var} ${_full_version} PARENT_SCOPE)
endfunction()


#---------------------------------------------------------------------------------------------------
# Helper macro to define the home of a package
#   o The home depends on the installation policy LCG_INSTALL_POLICY (collapsed, separatewithid, separate) 
#   o In case of 'separatewithid' it assumes all dependencies to be known beforehand already  
#---------------------------------------------------------------------------------------------------
macro( LCGPackage_set_home name)
  foreach( version ${${name}_native_version} )
    LCGPackage_set_install_path( name )
    if(LCG_INSTALL_POLICY MATCHES separate) 
      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${${name}_directory_name}/${version}/${LCG_system})
    elseif(LCG_INSTALL_POLICY MATCHES collapsed)
      set(${name}_home ${CMAKE_INSTALL_PREFIX}/${LCG_system})
    else()
      message(FATAL_ERROR "LCG_INSTALL_POLICY not set or not recognized.")
    endif()
  endforeach()
endmacro()

macro( LCGPackage_set_install_path name)
  foreach( version ${${name}_native_version} )
    set(${name}_install_path ${${name}_directory_name}/${version}/${LCG_system})
  endforeach()
endmacro()

#---------------------------------------------------------------------------------------------------
# Helper function to expand patterns that depend of the package version 
#   o First standard patterns like <VOID> <VERSION> are tried
#   o Then any available variable is also tried for max of 3 iterations
#---------------------------------------------------------------------------------------------------
function(LCG_expand_version_patterns version outvar input)
  string(REPLACE <NATIVE_VERSION> ${version} result "${input}")
  string(REPLACE <VERSION> ${version} result "${result}")
  #string(REPLACE <VOID> "" result "${result}")
  set(knownvars SOURCE_DIR INSTALL_DIR)
  foreach(iter 1 2 3)  # 3 nested replacements
    string(REGEX MATCHALL "<[^ <>(){}]+>" vars ${result})
    foreach(var ${vars})
      string(REPLACE "<" "" v ${var})
      string(REPLACE ">" "" v ${v})
      list(FIND knownvars ${v} index)
      if(DEFINED ${v})
        string(REPLACE ${var} ${${v}} result "${result}")
      elseif(iter EQUAL 3 AND index EQUAL -1 AND NOT v STREQUAL VOID)
        message(FATAL_ERROR " Could not resolve variable '<${v}>' in 'LCGPackage_Add':\n ${result}")
      endif()
    endforeach()
  endforeach()
  set(${outvar} "${result}" PARENT_SCOPE)
endfunction()

#---------------------------------------------------------------------------------------------------
# Helper function to substibute conditional code in arguments 
#   o Expession like IF <condition> THEN <arguments1> [ELSE <arguments2> ] ENDIF gets
#     replaced by <arguments1> or <argummens2> depending on the conditioon
#---------------------------------------------------------------------------------------------------
function(LCG_replace_conditional_args outvar input)
  while(1)
    set(pattern)
    set(flag 0)
    foreach(a IN LISTS input)
      if(a STREQUAL IF)
        set(flag 1)
        list(APPEND pattern "${a}")
      elseif(a STREQUAL ENDIF)
        list(APPEND pattern "${a}")
        break()
      elseif(flag)
        list(APPEND pattern "${a}")
      endif()
    endforeach()
    if(pattern)
      if("${pattern}" MATCHES "IF;(.+);THEN;(.+);ELSE;(.+);ENDIF")
        set(condition "${CMAKE_MATCH_1}")
        set(casetrue  "${CMAKE_MATCH_2}")
        set(casefalse "${CMAKE_MATCH_3}")
      elseif("${pattern}"  MATCHES "IF;(.+);THEN;(.+);ENDIF")
        set(condition "${CMAKE_MATCH_1}")
        set(casetrue  "${CMAKE_MATCH_2}")
        set(casefalse "")
      else()
        message(FATAL_ERROR "Unsupported IF...THEN...ELSE..ENDIF construct: '${pattern}'")
      endif()
      if(${condition})
        set(value "${casetrue}")
      else()
        set(value "${casefalse}")
      endif()
      string(REPLACE "${pattern}" "${value}" input "${input}")
    else()
      set(${outvar} "${input}" PARENT_SCOPE)
      return()
    endif()
  endwhile()
endfunction()

#-----------------------------------------------------------------------
# function LCG_add_test(<name> TEST_COMMAND cmd [arg1... ]
#                           [PRE_COMMAND cmd [arg1...]] 
#                           [POST_COMMAND cmd [arg1...]]
#                           [OUTPUT outfile] [ERROR errfile]
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
  LCG_replace_conditional_args(ARGN "${ARGN}")  
  cmake_parse_arguments(ARG
    "DEBUG" 
    "TIMEOUT;BUILD;OUTPUT;ERROR;SOURCE_DIR;BINARY_DIR;PROJECT;PASSREGEX;FAILREGEX;WORKING_DIRECTORY" 
    "TEST_COMMAND;PRE_COMMAND;POST_COMMAND;ENVIRONMENT;DEPENDS;LABELS;BUILD_OPTIONS"
    ${ARGN})

  if(NOT CMAKE_GENERATOR MATCHES Makefiles)
    set(_cfg $<CONFIGURATION>/)
  endif()
  
  #- Handle TEST_COMMAND argument
  list(LENGTH ARG_TEST_COMMAND _len)
  if(_len LESS 1)
    if(NOT ARG_BUILD)
      message(FATAL_ERROR "LCG_ADD_TEST: command is mandatory (without build)")
    endif()
  else()
    list(GET ARG_TEST_COMMAND 0 _prg)
    list(REMOVE_AT ARG_TEST_COMMAND 0)
    if(NOT IS_ABSOLUTE ${_prg})
      set(_prg ${CMAKE_CURRENT_BINARY_DIR}/${_cfg}${_prg})
    elseif(EXISTS ${_prg})
    else()
      get_filename_component(_path ${_prg} PATH)
      get_filename_component(_file ${_prg} NAME)
      set(_prg ${_path}/${_cfg}${_file})
    endif()
    set(_cmd ${_prg} ${ARG_TEST_COMMAND})
    string(REPLACE ";" "#" _cmd "${_cmd}")
  endif()

  set(_command ${CMAKE_COMMAND} -DTST=${test} -DCMD:STRING=${_cmd})

  #- Handle PRE and POST commands
  if(ARG_PRE_COMMAND)
    set(_pre ${ARG_PRE_COMMAND})
    string(REPLACE ";" "#" _pre "${_pre}")
    set(_command ${_command} -DPRE:STRING=${_pre})
  endif()
  if(ARG_POST_COMMAND)
    set(_post ${ARG_POST_COMMAND})
    string(REPLACE ";" "#" _post "${_post}")
    set(_command ${_command} -DPOST:STRING=${_post})
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
  set(_command ${_command} -DTESTLOGDIR=${TESTLOGDIR} -P ${_driver})

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
      --output-log ${TESTLOGDIR}/${test}.log
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


