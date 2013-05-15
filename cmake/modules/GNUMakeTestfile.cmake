#include(CMakeParseArguments)
#=============================================================================
# Copyright 2010 Alexander Neundorf <neundorf@kde.org>
#
# Distributed under the OSI-approved BSD License (the "License");
# see accompanying file Copyright.txt for details.
#
# This software is distributed WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the License for more information.
#=============================================================================
# (To distribute this file outside of CMake, substitute the full
#  License text for the above reference.)

function(CMAKE_PARSE_ARGUMENTS prefix _optionNames _singleArgNames _multiArgNames)
  # first set all result variables to empty/FALSE
  foreach(arg_name ${_singleArgNames} ${_multiArgNames})
    set(${prefix}_${arg_name})
  endforeach(arg_name)

  foreach(option ${_optionNames})
    set(${prefix}_${option} FALSE)
  endforeach(option)

  set(${prefix}_UNPARSED_ARGUMENTS)

  set(insideValues FALSE)
  set(currentArgName)

  # now iterate over all arguments and fill the result variables
  foreach(currentArg ${ARGN})
    list(FIND _optionNames "${currentArg}" optionIndex)  # ... then this marks the end of the arguments belonging to this keyword
    list(FIND _singleArgNames "${currentArg}" singleArgIndex)  # ... then this marks the end of the arguments belonging to this keyword
    list(FIND _multiArgNames "${currentArg}" multiArgIndex)  # ... then this marks the end of the arguments belonging to this keyword

    if(${optionIndex} EQUAL -1  AND  ${singleArgIndex} EQUAL -1  AND  ${multiArgIndex} EQUAL -1)
      if(insideValues)
        if("${insideValues}" STREQUAL "SINGLE")
          set(${prefix}_${currentArgName} ${currentArg})
          set(insideValues FALSE)
        elseif("${insideValues}" STREQUAL "MULTI")
          list(APPEND ${prefix}_${currentArgName} ${currentArg})
        endif()
      else(insideValues)
        list(APPEND ${prefix}_UNPARSED_ARGUMENTS ${currentArg})
      endif(insideValues)
    else()
      if(NOT ${optionIndex} EQUAL -1)
        set(${prefix}_${currentArg} TRUE)
        set(insideValues FALSE)
      elseif(NOT ${singleArgIndex} EQUAL -1)
        set(currentArgName ${currentArg})
        set(${prefix}_${currentArgName})
        set(insideValues "SINGLE")
      elseif(NOT ${multiArgIndex} EQUAL -1)
        set(currentArgName ${currentArg})
        set(${prefix}_${currentArgName})
        set(insideValues "MULTI")
      endif()
    endif()

  endforeach(currentArg)

  # propagate the result variables to the caller:
  foreach(arg_name ${_singleArgNames} ${_multiArgNames} ${_optionNames})
    set(${prefix}_${arg_name}  ${${prefix}_${arg_name}} PARENT_SCOPE)
  endforeach(arg_name)
  set(${prefix}_UNPARSED_ARGUMENTS ${${prefix}_UNPARSED_ARGUMENTS} PARENT_SCOPE)

endfunction(CMAKE_PARSE_ARGUMENTS _options _singleArgs _multiArgs)


#----------------------------------------------------------------------------
# function LCGSOFT_ADD_TEST( <name> COMMAND cmd [arg1... ] 
#                           [ENVIRONMENT var1=val1 var2=val2 ...
#                           [DEPENDS test1 ...]
#                           [TIMEOUT seconds] 
#                           [PASSREGEX exp] [FAILREGEX epx]
#                           [LABELS label1 label2 ...])
#
function(LCGSOFT_ADD_TEST test)
  CMAKE_PARSE_ARGUMENTS(ARG "" "TIMEOUT;PASSREGEX;FAILREGEX;BUILD;TARGET" "COMMAND;ENVIRONMENT;DEPENDS;LABELS" ${ARGN})
  if(ARG_BUILD)
    add_test(${test}-build make -C ${ARG_BUILD} ${ARG_TARGET})
    set(ARG_DEPENDS ${ARG_DEPENDS} ${test}-build)
    add_test(${test} ${ARG_COMMAND})
  else()
    add_test(${test} ${ARG_COMMAND})
  endif()
  if(ARG_ENVIRONMENT)
    set(properties ${properties} ENVIRONMENT ${ARG_ENVIRONMENT})
  endif()
  if(ARG_TIMEOUT)
    set(properties ${properties} TIMEOUT ${ARG_TIMEOUT})
  endif()
  if(ARG_DEPENDS)
    set(properties ${properties} DEPENDS ${ARG_DEPENDS})
  endif()
  if(ARG_PASSREGEX)
    set(properties ${properties} PASS_REGULAR_EXPRESSION ${ARG_PASSREGEX})
  endif()
  if(ARG_FAILREGEX)
    set(properties ${properties} FAIL_REGULAR_EXPRESSION ${ARG_FAILREGEX})
   endif()
  if(ARG_LABELS)
    set(properties ${properties} LABELS ${ARG_LABELS})
  else()
    set(properties ${properties} LABELS Nightly)  
  endif()
  set_tests_properties(${test} PROPERTIES ${properties})
endfunction()


#-------------------------------------------------------------------------------

#set(BINDIR $ENV{G4WORKDIR}/bin/$ENV{G4SYSTEM})
#set(SRCDIR $ENV{G4INSTALL}/examples)
