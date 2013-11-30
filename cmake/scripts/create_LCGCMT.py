#!/usr/bin/env python
# This file creates LCG_Configuration/cmt/requirements from
# dependencies.json as created from lcgcmake

import sys

def handle_single_package(packageinfo):
    """create lines like 'macro vdt_config_version "0.3.6"' from given single package information."""
    # we do not list the generator packages in the LCGCMT exposed file
    if "MCGenerators" in packageinfo["dest_directory"] or "lhapdfsets" == packageinfo["name"]:
      return None  
    else:
      result = 'macro %s_config_version "%s"' %(packageinfo["name"],packageinfo["version"])
      # TODO: three special handlings we should get rid of if possible
      if packageinfo["name"] == "Boost":
        result += '\nmacro Boost_file_version "%s"' %(packageinfo["version"][0:4].replace(".","_"))
      elif packageinfo["name"] == "Python":
        result += '\nmacro Python_config_version_twodigit "%s"' %(packageinfo["version"][0:3])
      elif packageinfo["name"] == "expat":
        result = result.replace("expat","Expat")
      return result


##########################
if __name__ == "__main__":

  input_filename = sys.argv[1]
  output_filename = sys.argv[2] 

  # read in json file
  dependencies = open(input_filename).read()
  releaseinfo = eval(dependencies)

  # translate 
  results = []
  for package in releaseinfo["packages"].itervalues():
    result = handle_single_package(package)
    if result: results.append(result)
  results.sort()

  final_content = """
# This is an auto-generated CMT file containing the LCG package versions

package LCG_Configuration

use LCG_Platforms

include_path none

apply_tag ROOT_GE_5_15
apply_tag ROOT_GE_5_19

macro LCG_config_version   "%s"

%s
""" %(releaseinfo["description"]["version"],"\n".join(results))

  # now save the result
  out = open(output_filename, "w")  
  out.write(final_content)
  out.close()
