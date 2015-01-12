#!/usr/bin/env python

import os, sys

# name-hash; package name; version; hash; full directory name; comma separated dependencies

def write_log(filename, add_str) :
	with open(filename, 'a') as diagfile:
				diagfile.write(add_str)

#########################
if __name__ == "__main__":

  prefix = "/afs/cern.ch/sw/lcg/releases/"
  options = sys.argv
  numparam = len(options)
  if numparam < 4:
    print '''Please provide as command line parameters:
	first parameter - directory for output file
	second parameter - platform (e.g. x86_64-slc6-gcc48-opt)
	third parameter - version of toolchain (e.g. 70root6)
	fourth parameter (optional) - put a directory if releseases are not in /afs/cern.ch/sw/lcg/releases/
	
Example: . x86_64-slc6-gcc48-opt 70
The output file will be like: test_LCG_70_plt_x86_64-slc6-gcc48-opt.txt
'''
    sys.exit(1)  
  elif numparam == 4:
    name, thedir, platform, version = options
  elif numparam == 5:
	  name, thedir, platform, version, prefix = options
	  if not os.path.isdir(prefix):
		  print "Usage : %s - last parameter is a wrong directory" % os.path.basename(options[0])
		  sys.exit(1) 	  
  else :
	print "Usage : %s - too much of parameters" % os.path.basename(options[0])
	sys.exit(1) 
  
  test_output = '''Start test
%s %s %s %s
''' %(name, thedir, platform, version)
  filename = "%s/test_LCG_%s_plt_%s.txt" %(thedir, version, platform)
  with open(filename, 'w+') as diagfile:
	  diagfile.write(test_output)
	  
  if not os.path.isfile("%s/LCG_%s/LCG_generators_%s.txt" %(prefix,version,platform)) :
	  print "You put wrong platform or version, or such release does not exists or LCG_generators_%s.txt does not exists" %platform
	  write_log(filename, "You put wrong platform or version, or such release does not exists or LCG_generators_%s.txt does not exists.\nChecking not finished.\n" %platform)
	  sys.exit(2)

  lcgfile = open("%s/LCG_%s/LCG_generators_%s.txt" %(prefix,version,platform), "r")
  links = ""
  linksMC = ""
  directories = ""
  directoriesMC = ""

  for line in lcgfile.readlines():
			nsplit = len(line.split(";"))
			if nsplit < 5 :
				continue
			sname, shash, sversion, sdestination, sdependencies = line.split(";")
			sname = sname.strip()
			shash = shash.strip()
			sversion = sversion.strip()
			sdestination = sdestination.strip()
			sdependencies = sdependencies.strip()
			#check that MCGenerator's links exist:
			if not (os.path.isdir("%s/LCG_%s/MCGenerators/%s/%s/%s" %(prefix,version,sname,sversion,platform)) or os.path.isdir("%s/LCG_%s/%s" %(prefix,version,sdestination))):
				linksMC += line
			#check that MCGenerator's linked directories exist:
			if not (os.path.isdir(prefix + "MCGenerators/%s/%s-%s/%s" %(sname,sversion,shash,platform)) or os.path.isdir("%s/LCG_%s/%s" %(prefix,version,sdestination))) :
				directoriesMC += line
  
  if not os.path.isfile("%s/LCG_%s/LCG_externals_%s.txt" %(prefix,version,platform)) :
	  print "You put wrong platform or version, or such release does not exists or LCG_externals_%s.txt does not exists" %platform
	  write_log(filename, "You put wrong platform or version, or such release does not exists or LCG_externals_%s.txt does not exists.\nChecking not finished.\n" %platform)
	  sys.exit(2)
  lcgfile = open("%s/LCG_%s/LCG_externals_%s.txt" %(prefix,version,platform), "r")

  for line in lcgfile.readlines():
	  nsplit = len(line.split(";"))
	  if nsplit < 5 :
		continue
	  sname, shash, sversion, sdestination, sdependencies = line.split(";")
	  sname = sname.strip()
	  shash = shash.strip()
	  sversion = sversion.strip()
	  sdestination = sdestination.strip()
	  sdependencies = sdependencies.strip()
		
		#check that links exist:
	  if not (os.path.isdir("%s/LCG_%s/%s/%s/%s" %(prefix,version,sname,sversion,platform)) or os.path.isdir("%s/LCG_%s/%s" %(prefix,version,sdestination))):
			links += line

		#check that linked directories exist:
	  if not (os.path.isdir(prefix + "%s/%s-%s/%s" %(sname,sversion,shash,platform)) or os.path.isdir("%s/LCG_%s/%s" %(prefix,version,sdestination))):
			directories += line
  
  text_output = "\n****************\nAbsent External Links:\n\n" + links + "\n****************\nAbsent or wrong External Directories:\n\n" + directories
  text_output += "\n****************\nAbsent MCGenerator's Links:\n\n" + linksMC + "\n****************\nAbsent or wrong MCGenerator's Directories:\n\n" + directoriesMC 
  text_output += '''
***********************************
CHECKING FINISHED
***********************************
'''
  write_log(filename, text_output)
  print text_output
