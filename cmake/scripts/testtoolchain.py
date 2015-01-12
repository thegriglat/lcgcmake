#!/usr/bin/env python
"""
Test of completness of releases in acordance with toolchain
<andrei.kazymov@cern.ch>
2014/12/25

Version 1.1

"""
import os, sys

def write_log(filename, add_output):
	with open(filename, 'a') as diagfile:
		diagfile.write("\n" + add_output)
	  	
def LCG_line_parser(templine) :
	templine = templine.partition("(")[2].partition(")")[0].rstrip()
	param_list = templine.split()
	global text_print
	global text_output
	 
	if len(param_list) == 2 :
		sname = param_list[0].strip()
		sversion = param_list[1].strip()
		if not sname == "LCGCMT" :
			if os.path.isdir(prefix + "LCG_%s/%s/%s/%s" %(version,sname,sversion,platform)) :
				pass #write_log(filename, sname+" "+sversion)
			elif os.path.isdir(prefix + "LCG_%s/%s/%s_python2.7/%s" %(version,sname,sversion,platform)):
				text_print += "\n%s, %s, \tThe path %sLCG_%s/%s/%s_python2.7/%s \tis a real link." %(sname,sversion,prefix,version,sname,sversion,platform)
				text_output += "\n%s \t%s \tDirectory was wrong. The path %s" %(sname,sversion,prefix) + "LCG_%s/%s/%s_python2.7/%s \tis a real link." %(version,sname,sversion,platform)
			else :
				text_print += "\n%s, %s, \tThe link is absent: " %(sname, sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sname,sversion,platform)
				text_output += "\n%s \t%s \tThe link is absent: " %(sname,sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sname,sversion,platform)
	else: 
		if len(param_list) > 2:
			sname = param_list[0].strip()
			sversion = param_list[1].strip()
			sdest = param_list[2].strip()
			if sdest.find("$") > -1 :
				sdest = sdest.replace("${MCGENPATH}","MCGenerators")
				if os.path.isdir(prefix + "LCG_%s/MCGenerators/%s/%s/%s" %(version,sname,sversion,platform)) or os.path.isdir(prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)):
					pass #write_log(filename, sname+" "+sversion+" "+sdest)
				else:
					text_output += "\n%s \t%s \tThe link is absent: " %(sname,sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)
					text_print += "\n%s, %s \tThe link is absent: " %(sname, sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)
			elif sdest.find("author") > -1 :
				if os.path.isdir(prefix + "LCG_%s/%s/%s/%s" %(version,sname,sversion,platform)) or os.path.isdir(prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)):
					pass #write_log(filename, sname+" "+sversion+" "+sdest)
				else:
					text_output += "\n%s \t%s \tThe link is absent: " %(sname,sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sname,sversion,platform)
					text_print += "\n%s, %s \tThe link is absent: " %(sname, sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sname,sversion,platform)
			else:
				if os.path.isdir(prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)) or os.path.isdir(prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)) :
					pass #write_log(filename, sname+" "+sversion+" "+sdest)
				else:
					text_output += "\n%s \t%s \tThe link is absent: " %(sname,sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)
					text_print += "\n%s, %s \tThe link is absent: " %(sname, sversion) + prefix + "LCG_%s/%s/%s/%s" %(version,sdest,sversion,platform)


#**************************************************	
if __name__ == '__main__':

  prefix = "/afs/cern.ch/sw/lcg/releases/"
  options = sys.argv
  numparam = len(options)
  if numparam < 5 :
	print ''' Usage: you need 4 or 5 parameters to enter:
	first parameter - directory to toolchains
	second parameter - directory for output file
	third parameter - platform (e.g. x86_64-slc6-gcc48-opt)
	fourth parameter - version of toolchain (e.g. 70)
	fifth parameter (optional) - put a directory if releseases are not in /afs/cern.ch/sw/lcg/releases/
	
	***************************************
	the file like: tlchn_LCG70_x86_64-slc6-gcc48-opt.txt will be created in a directory pointed out by second parameter.
	
	Example of command (.... - here should be a correct path):
	python /..../testtoolchain.py /..../lcgcmake/cmake/toolchain . i686-slc6-gcc48-dbg 70
	'''
	sys.exit(1)
  elif numparam == 5:
    module, thedir, theoutdir, platform, version = options
  elif numparam == 6:
	module, thedir, theoutdit, platform, version, prefix = options
	if not os.path.isdir(prefix):
		  print "Usage : %s - last parameter is a wrong directory" % os.path.basename(options[0])
		  sys.exit(1) 
  else :
	print "Usage : %s - too many parameters" % os.path.basename(options[0])
	sys.exit(1)  
  print module, thedir, platform, version
  
  filename =theoutdir + "/tlchn_LCG%s_%s.txt" %(version, platform)
  if not os.path.isfile("%s/heptools-%s.cmake" %(thedir,version)):
		  print "You put a wrong toolchain: %s/heptools-%s.cmake - there is no such file." %(thedir,version)
		  sys.exit(1)
		  
  text_print = ""
  text_output = '''Start testtoolchain. 
Toolchain version: ''' + version +''' platform: ''' + platform + '''
  
************************************************************
below is a list of packages with absent or wrong links:
************************************************************
''' 
  with open(filename , 'w+') as diagfile:
	  diagfile.write(text_output)

  toolchainfile = open("%s/heptools-%s.cmake" %(thedir,version), "r")
  if platform.find("i686") > -1 :
	  architec = "i686"
  else :
	  architec = "x86_64"	  
  os_ver = "slc" + platform.split("slc")[1].split("-")[0]
  gcc_ver = "gcc" + platform.split("gcc")[1].split("-")[0]
  dbg = 0
  if platform.find("dbg") > -1:
	  dbg = 1
  
  #print "\n" + architec, os_ver, gcc_ver, dbg, version + "\n"
  level_of_if = 0
  level_if_i686 = -1
  analyze_line_i686 = 1
  
  text_output = ""
  for line in toolchainfile :
	templine = line.strip()
	if templine.split("(")[0].strip() == "if" :
		#write_log("******************  if statement ***************************")
		if templine.find("STREQUAL") > -1 :
			if templine.split("STREQUAL")[1].split(")")[0].strip() == "i686" :
				if templine.strip().split("(")[1].split(" ")[0] == "NOT" :
					#write_log("******************  if NOT ***************************")
					level_if_i686 = level_of_if
					analyze_line_i686 = 0
		
		level_of_if += 1		
	if templine.strip() == "endif()" :
		level_of_if -= 1
		if level_if_i686 == level_of_if :
			level_if_i686 = -1
			analyze_line_i686 = 1
		#write_log("******************  endif statement ************************" + str(level_if_i686))
	if (templine.split("_")[0] == "LCG") and analyze_line_i686 :
		LCG_line_parser(templine)
  
  text_output += '''
***********************************
CHECKING FINISHED
***********************************
'''
  write_log(filename, text_output)
  
  text_print += '''
***********************************
CHECKING FINISHED
***********************************
'''
  print text_print
		
