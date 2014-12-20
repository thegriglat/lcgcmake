#!/usr/bin/env python
import os, platform, string, re

arch = platform.machine()

system = platform.system()

#---Determine the OS and version--------------------------------------
if system == 'Darwin' :
   osvers = 'mac' + string.join(platform.mac_ver()[0].split('.')[:2],'')
elif system == 'Linux' :
   dist = platform.linux_distribution()
   if re.search('SLC', dist[0]):
      osvers = 'slc' + dist[1].split('.')[0]
   elif re.search('Ubuntu', dist[0]):
      osvers = 'ubuntu' + dist[1].split('.')[0]
   elif re.search('Fedora', dist[0]):
      osvers = 'fedora' + dist[1].split('.')[0]
   else:
      osvers = 'linux' + string.join(platform.linux_distribution()[1].split('.')[:2],'')
elif system == 'Windows':
   osvers = win + platform.win32_ver()[0]
else:
   osvers = 'unk-os'

#---Determine the compiler and version--------------------------------
if os.getenv('COMPILER'):
  compiler = os.getenv('COMPILER')
else:
  if os.getenv('CC'):
    ccommand = os.getenv('CC')
  elif system == 'Windows':
    ccommand = 'cl'
  elif system == 'Darwin':
    ccommand = 'clang'
  else:
    ccommand = 'gcc'
  if ccommand == 'cl':
    versioninfo = os.popen(ccommand).read()
    patt = re.compile('.*Version ([0-9]+)[.].*')
    mobj = patt.match(versioninfo)
    compiler = 'vc' + str(int(mobj.group(1))-6)
  elif ccommand == 'gcc':
     versioninfo = os.popen(ccommand + ' -dumpversion').read()
     patt = re.compile('([0-9]+)\\.([0-9]+)')
     mobj = patt.match(versioninfo)
     compiler = 'gcc' + mobj.group(1) + mobj.group(2)
  elif ccommand == 'clang':
     versioninfo = os.popen4(ccommand + ' -v')[1].read()
     patt = re.compile('.*version ([0-9]+)[.]([0-9]+)')
     mobj = patt.match(versioninfo)
     compiler = 'clang' + mobj.group(1) + mobj.group(2)
  elif ccommand == 'icc':
     versioninfo = os.popen(ccommand + ' -dumpversion').read()
     patt = re.compile('([0-9]+)')
     mobj = patt.match(versioninfo)
     compiler = 'icc' + mobj.group(1) + mobj.group(2)
  else:
     compiler = 'unk-cmp'

print '%s-%s-%s' %  (arch, osvers, compiler)
