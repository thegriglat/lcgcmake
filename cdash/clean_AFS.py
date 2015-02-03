#!/usr/bin/env python
import sys, time
import Tools as tools
# ================================================================================
# This script removes the build results from AFS for the given day and slot
# --------------------------------------------------------------------------------

AFS_BASE = "/afs/cern.ch/sw/lcg/app/nightlies/"

##########################
if __name__ == "__main__":
    from optparse import OptionParser
    parser = OptionParser()

    parser.add_option("-d", "--day", dest="weekday", help="for which day of the week to clean ", default = "today")

    (options, args) = parser.parse_args()
    if len(args)!=1:
        print "Please provide a slot name!"
        sys.exit(-2)
    slot = args[0]

    day_option = options.weekday

    if day_option=="tomorrow":
        day = tools.tomorrow()
    elif day_option=="today":
        day = tools.today()
    elif day_option=="yesterday":
        day = tools.yesterday()
    elif day_option in ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]:
        day = day_option
    else:
        print "--day option value %s not recognized." %day_option
        sys.exit(-2) 

    print "Cleaning log files and build artifacts of slot '%s' for day %s" %(slot,day) 
    start_time = time.time()
    
    # go to slot directory in AFS and remove slot/day/* 
    dir = tools.pathJoin(AFS_BASE,slot,day)
    files = tools.listDir(dir)
    for item in files:
        fullpath = tools.pathJoin(dir,item)
        tools.executeCmd('rm -fr %s' %fullpath)
                    
    delta_time = time.time() - start_time

    print "\n===> cleaning finished for day", day, 'at', time.ctime()
    print   "     cleaning took "+str(delta_time)+" sec. ("+time.strftime("%H:%M:%S",time.gmtime(delta_time))+")"
