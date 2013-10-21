#!/usr/bin/env python

#TODO: migrate to a proper usage of exceptions
#      introduce an AFSVolume class 

import os, sys

global fsCmd

fsCmd = '/usr/bin/fs'
afsAdmCmd = '/usr/bin/afs_admin'
vosCmd = '/usr/sbin/vos'

afsVerbose = -1

# --------------------------------------------------------------------------------
#
def available():
    if not os.path.exists(fsCmd):
        raise str("ERROR: command '"+fsCmd+"' not found, unable to use AFS!")
    return True

# --------------------------------------------------------------------------------
#
def getVolumeSize(path):
    if not available() : return None
    sin, sout, serr = os.popen3(fsCmd + " lq " + path)
    if sout:
        for line in sout.readlines():
            # print "got:"+line[:-1]
            words = line.split()
            volname = words[0].split('.')
            if ( words[0][:8] == "p.sw.lcg" ) : return words[2]
            if ( words[0][:7] == "q.swlcg"  ) : return words[2]
    if serr:
        errLines = serr.readlines()
        if errLines and len(errLines)>0 :
            if afsVerbose > 0 : print "err:", errLines
    if afsVerbose > 0 : print "AFS.getVolumeSize> ERROR: no volume found for ", path
    return 0

# --------------------------------------------------------------------------------
#
def getVolume(path):
    if not available() : return None
    sin, sout, serr = os.popen3(fsCmd + " lq " + path)
    if sout:
        for line in sout.readlines():
            # print "got:"+line[:-1]
            words = line.split()
            volname = words[0].split('.')
            if ( words[0][:8] == "p.sw.lcg" ) : return words[0]
            if ( words[0][:7] == "q.swlcg"  ) : return words[0]
    if serr:
        errLines = serr.readlines()
        if errLines and len(errLines)>0 :
            if afsVerbose > 0 : print "err:", errLines
    if afsVerbose > 0 : print "AFS.getVolume> ERROR: no volume found for ", path
    return None

# --------------------------------------------------------------------------------
#
def getQuota(path):
    if not available() : return (-1,-1,-1)
    sin, sout, serr = os.popen3(fsCmd + " lq " + path)
    if sout:
        for line in sout.readlines():
            # print "got:"+line[:-1]
            words = line.split()
            volname = words[0].split('.')
            if ( (words[0][:8] == "p.sw.lcg") or
                 (words[0][:7] == "q.swlcg" ) ) :
                quota, used, percent = int(words[1]), int(words[2]), int(words[3].split("%")[0])
                return quota, used, percent
    if serr:
        errLines = serr.readlines()
        if errLines and len(errLines)>0 :
            if afsVerbose > 0 : print "err:", errLines
    if afsVerbose > 0 : print "AFS.getQuota> ERROR: no volume found for ", path
    return (-1,-1,-1)

# --------------------------------------------------------------------------------
#
def setQuota(path, newQuota):
    if not available() : return
    if not path :
        print "AFS.setQuota> ERROR: no path given !"
        return
    if not newQuota or int(newQuota) < 0:
        print "AFS.setQuota> ERROR: no quota (or negative) given !"
        return
    sin, sout, serr = os.popen3(afsAdmCmd + " set_quota " + path + " " + str(int(newQuota)) )
    if sout:
        for line in sout.readlines():
            # print "got:"+line[:-1]
            words = line.split()
            volname = words[0].split('.')
    if serr:
        errLines = serr.readlines()
        if errLines and len(errLines)>0 : print "err:", errLines
    return 

# --------------------------------------------------------------------------------
#
def doVosRelease(path):
    if not available() : return
    if not path :
        print "AFS.doVosRelease> ERROR: no path given !"
        return
    vol = getVolume(path)
    sin, sout, serr = os.popen3(afsAdmCmd + " vos_release " + vol )
    if sout:
        for line in sout.readlines():
            # print "got:"+line[:-1]
            words = line.split()
            volname = words[0].split('.')
    if serr:
        errLines = serr.readlines()
        if errLines and len(errLines)>0 : print "err:", errLines
    return 

# --------------------------------------------------------------------------------
#
def removeVolume(path):
    if not available() : return
    if not path :
        print "AFS.removeVolume> ERROR: no path given !"
        return
    cmd = afsAdmCmd + " delete " + path
    # print "going to execute:'"+cmd+"'"
    sin, sout, serr = os.popen3(cmd)
    if sout:
        for line in sout.readlines():
            # print "got:"+line[:-1]
            pass
    if serr:
        errLines = serr.readlines()
        if errLines and len(errLines)>0 : print "err:", errLines
    return 

# --------------------------------------------------------------------------------
#               
def copy_ACL(from_path, to_path):
    cmd = "%s copyacl -fromdir %s -todir %s " %(fsCmd, from_path, to_path)
    sin, sout, serr = os.popen3(cmd)
    if sout:
        for line in sout.readlines():
            # print "got:"+line[:-1]
            pass
    if serr:
	errLines = serr.readlines()
        if errLines and len(errLines)>0 : print "err:", errLines
    return  

# --------------------------------------------------------------------------------
#
def create(path, vol, size=5000):
    if not available() : return
    if not path :
        print "AFS.create> ERROR: no path given !"
        return
    if not vol :
        print "AFS.create> ERROR: no volume given !"
        return
        
    #print "creating volume "+vol+" of size "+str(size)+" and mounting at:", path,
    cmd = afsAdmCmd + " create -q " + str(size) + " " + path + " " + vol
    # print "going to execute:'"+cmd+"'"
    sin, sout, serr = os.popen3(cmd)
    if sout:
        err = False
        lines = sout.readlines()
        for line in lines:
            if line.find("ERROR") != -1: err = True
            pass
        if err:
            print lines
        else : print "...DONE"
    if serr:
        errLines = serr.readlines()
        if errLines and len(errLines)>0 : print "err:", errLines
    return 

# --------------------------------------------------------------------------------
#
def getNumberOfReplicas(path):
    path = path.replace("/cern.ch","/.cern.ch")
    volume = getVolume(path)
    if volume == None:
        print "  The path %s has a malformed volume" %(path)
        return 0
    sin, sout, serr = os.popen3(vosCmd + " exa " + volume)
    line = sout.readline()
    while "number of sites" not in line:
        line = sout.readline()
        if line == "": break
    number = int(line.split()[4])
    return number - 1 # do not count the r/w volume

# --------------------------------------------------------------------------------

def isReplicated(path):
    if not available() : return
    return (getNumberOfReplicas > 0)

# --------------------------------------------------------------------------------
#
def replicateVolume(path):
    path = path.replace("/cern.ch","/.cern.ch")
    volume = getVolume(path) 
    cmd = afsAdmCmd + " create_replica " + volume
    sin, sout, serr = os.popen3(cmd)
    if serr:
	errLines = serr.readlines()
        if errLines and len(errLines)>0 : print "err:", errLines
    return

# --------------------------------------------------------------------------------
#
def deleteVolumeReplicas(path):
    path = path.replace("/cern.ch","/.cern.ch")
    volume = getVolume(path) 
    cmd = afsAdmCmd + " delete_replica " + volume
    sin, sout, serr = os.popen3(cmd)
    if serr:
	errLines = serr.readlines()
        if errLines and len(errLines)>0 : print "err:", errLines
    return


