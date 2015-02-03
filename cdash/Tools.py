#!/usr/bin/env python
import os, sys,copy,shutil,time, datetime
import distutils.dir_util
from subprocess import *

def isWin():
    return sys.platform in ('win32',)

def isMac():
    return sys.platform in ('darwin',)

def isLinux():
    return sys.platform in ('linux32','linux2','linux')

def list_dirs(base):
    """Return a list of all directories in a given directory (not recursive)."""
    return [f for f in os.listdir(base) if os.path.isdir(os.path.join(base, f))]

def osSep():
    if isWin():
        return os.sep*2
    else:
        return os.sep
def cmdSep():
    if isWin():
        return "&&"
    else:
        return ";"

def rmCmd():
    if isWin():
        return "rmdir /q /s "
    else:
        return "rm -fr "

def copyCmd():
    if isWin():
        return "copy"
    else:
        return "cp"

def afsTop():
    if isWin():
        return os.environ['AFS']
    else:
        return "/afs"

def executeCmd(cmd):
    print "EXECUTING: "+cmd
    p=Popen(cmd,shell=True)
    p.wait()
    if p.stderr==None:
        return 0
    else: return 1

def setEnviron(key,value):
    os.environ[key]=value

def getEnviron(key):
    return os.environ[key]

def copyEnviron():
    return os.environ.copy()

def environUpdate(env):
    os.environ.update(env)

def removeEnviron(key):
    del os.environ[key]

def hasKey(key):
    return os.environ.has_key(key)
def keys():
    return os.environ.keys()
def chdir(folder):
    os.chdir(folder)

def shutilCopy(file1,file2):
    return shutil.copy(file1,file2)

def shutilCopytree(src, dst):
    return shutil.copytree(src, dst)
    
def pathExist(path):
    #print "PATH IS "+path
    return os.path.exists(path)

def urlExists(url):
    import urllib2
    try:
        f = urllib2.urlopen(urllib2.Request(url))
        return True
    except urllib2.HTTPError:
        return False

def isLink(link):
    return os.path.islink(link)

def isDir(dir):
    return os.path.isdir(dir)

def removePath(path):
    os.remove(path)

def expandVars(path):
    return os.path.expandvars(path)

def absPath(path):
    return os.path.abspath(path)

def pathDirName(path):
    return os.path.dirname(path)

def pathSepJoin(path):
    return os.sep.join(path)

def isFile(file):
    return os.path.isfile(file)

def makedirs(folder):

    try:
        distutils.dir_util.mkpath(folder)
    except Exception:
        pass
    
def listDir(dir):
    return os.listdir(dir)

def mkdir(folder):
    os.mkdir(folder)

def getCwd():
    return os.getcwd()

def pathJoin(*strings):
    i=0
    aux=""
    dim=len(strings)
    for string in strings:
        if string==None:
            string=""

        i=i+1
        aux+=os.path.join(string)
        if i!=dim:
            aux+=osSep()


    return aux

def pathSplit(path):
    return os.path.split(path)

def rename(name1,name2):
  os.rename(name1,name2)

def remove(rmove):
    os.remove(rmove)

def pathSep():
    return os.path.pathsep

def sepJoin(path):
    return os.sep.join(path)
def hasAfs():
    return isLinux()

def popen(cmd):
    return os.popen(cmd)

def pathAppend(new):
    os.sys.path.append(new)

def today():
    return datetime.date.today().strftime('%a')

def tomorrow():
    return datetime.date.fromtimestamp(time.time()+86400).strftime('%a')

def yesterday():
    return datetime.date.fromtimestamp(time.time()-86400).strftime('%a')
