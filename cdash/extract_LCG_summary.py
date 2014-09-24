#!/usr/bin/env python
import os, sys

# name-hash; package name; version; hash; full directory name; comma separated dependencies
#  COMPILER: GNU 4.8.1, HOSTNAME: lcgapp07.cern.ch, HASH: 9ccc5, DESTINATION: CASTOR, NAME: CASTOR, VERSION: 2.1.13-6,

class PackageInfo(object):
  
   def __init__(self,name,destination,hash,version,directory,dependencies):
     self.name = name
     self.destination = destination
     self.hash = hash
     self.version = version
     self.directory = directory
     self.dependencies = dependencies
     if name == destination:
        self.is_subpackage = False
     else:
        self.is_subpackage = True

   def compile_summary(self):
     #create dependency string 
     if self.is_subpackage:
        return ""    
     dependency_string = ",".join(self.dependencies)
     return "%s; %s; %s; %s; %s" %(self.name, self.hash, self.version, self.directory, dependency_string)

def create_package_from_file(directory, filename, packages):
   content = open(filename).read()
   name = content.split(" NAME:")[1].split(",")[0].lstrip()
   destination = content.split(" DESTINATION:")[1].split(",")[0].lstrip()
   hash = content.split(" HASH:")[1].split(",")[0].lstrip()
   version = content.split(" VERSION:")[1].split(",")[0]
   directory = directory
   # now handle the dependencies properly
   dependency_list = content.rstrip(',\n').split(" VERSION:")[1].split(",")[1:]
   dependencies = set()
   for dependency in dependency_list:
       dependencies.add(dependency)
   # TODO: hardcoded meta-packages
   if name in ["pytools","pyanalysis","pygraphics"]:
     dependencies = set()
   if name == "ROOT":
     dependencies.discard("pythia8")
   #ignore CLHEP 2.X
   if name == "CLHEP" and version.lstrip().startswith("2"):
      pass
   if name == "hepmc3":
      pass
   else:
     packages[name] = PackageInfo(name,destination,hash,version,directory,dependencies)


#########################
if __name__ == "__main__":

  options = sys.argv
  if len(options) != 4:
    print "Please provide DIR, PLATFORM and LCG_version as command line parameters"
    sys.exit()  
  name, thedir, platform, version = options

  packages = {}
  # collect all .buildinfo_<name>.txt files
  for root, dirs, files in os.walk(thedir):
      for afile in files:
          if afile.endswith('.txt') and afile.startswith(".buildinfo") and platform in root:
              fullname = os.path.join(root, afile)
              a = open(fullname).read() 
              create_package_from_file(root,fullname,packages)

  print packages             
  # now compile entire dependency lists
  # every dependency of a subpackage is forwarded to the real package
  for name,package in packages.iteritems():
     if package.is_subpackage == True:
        packages[package.destination].dependencies.update(package.dependencies) 

  # now remove all subpackages in dependencies and replace them by real packages
  for name, package in packages.iteritems():
    if package.is_subpackage == False:
      for dep in package.dependencies:
        if packages.has_key(dep):
          if packages[dep].is_subpackage:
            package.dependencies.remove(dep)
            package.dependencies.add(packages[dep].destination)
    # make sure that a meta-package doesn't depend on itself   
    package.dependencies.discard(name)    

  # write out the files to disk
  # first the externals
  thefile = open(thedir+"/LCG_externals_%s.txt" %platform, "w")
  thefile.write( "PLATFORM: %s\nVERSION: %s\n" %(platform, version) ) 
  for name,package in packages.iteritems():
      result = package.compile_summary()
      if result != "" and "MCGenerators" not in result: #TODO: HACK
        thefile.write(result+"\n")
  thefile.close()
  # then the generators
  thefile = open(thedir+"/LCG_generators_%s.txt" %platform, "w")
  thefile.write( "PLATFORM: %s\nVERSION: %s\n" %(platform, version) )
  for name,package in packages.iteritems():
     result = package.compile_summary()
     if result != "" and "MCGenerators" in result: #TODO: HACK
       thefile.write(result+"\n")
  thefile.close()
