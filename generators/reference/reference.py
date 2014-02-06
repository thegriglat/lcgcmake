#!/usr/bin/env python

#
# Options are      
# $0 RefFile TestFile "Path=XS,W_mass" "limit=0.95,0.9"
#

import sys
from xml.dom import minidom
import yoda

def Exit(status,message):
    print message
    sys.exit(status)

def GetXS(YodaFile):
    """ Return MC_XS/XS from Yoda file as float"""
    for i in YodaFile:
        if '/MC_XS/XS' in i.annotations['Path']:
            return float(i.points()[0].y)
    Exit(1,"Cannot found XS value in Yoda file")


def Check_XS(RefFile,TestFile,limit = 0.95):
    """ Compare two XS and return True if difference less than 'percent' %"""
    print "### Compare MC_XS/XS value ###"
    if limit == None: limit = 0.95
    RefValue = GetXS(yoda.read(RefFile, asdict=False))
    TestValue = GetXS(yoda.read(TestFile, asdict=False))
    print "Test value: " + str(TestValue) + " | Reference value: " + str(RefValue) + " | limit = " + str(limit)
    if (1 - abs(TestValue - RefValue)/RefValue) >= limit:
        return True
    else:
        return False

def Check_Histos(RefFile, TestFile, component, limit = 0.9):
    """ Check Kolmogorov value between 'component' of Reference and Test file """
    print "### Do kolmogorov test to compare two TH1F (" + component + ") ###"
    if limit == None: limit = 0.9
    try:
        import ROOT
    except:
        Exit(1,"Cannot import ROOT")
    try:
        RefF = ROOT.TFile(RefFile)
        TestF = ROOT.TFile(TestFile)
    except:
        Exit(1,"Cannot open ROOT files")
    try:
        RefHist  = RefF.Get(component)
        TestHist = TestF.Get(component)
    except:
        Exit(1,"Cannot obtain " + component + " from files")
    try:
        hi = RefHist.KolmogorovTest(TestHist)
    except:
        print "Cannot do Kolmogorov test"
        return False
    print "Result: " + str(hi) + " | success if >= " + str(limit)
    if hi >= limit:
        return True
    else:
        return False

RefFile = sys.argv[1]
TestFile = sys.argv[2]
options = {}
if len(sys.argv) >= 3:
    for opt in sys.argv[3:]:
        try:
            key,value = opt.split("=")
            options[key] = value
        except:
            print opt
            Exit(1,"Can't split key=value pair by symbol '=' in \'" + opt + "\'")
else:
    Exit(1,"No options specified!")
if not options.has_key('Path') or not options.has_key('limit'):
    Exit(1,"Path or limit option isn't specified.")

tests = []
if len(options['Path'].split(',')) != len(options['limit'].split(',')):
    Exit(1,"Path and limit has different number of tests!")
else:
    for i in xrange(len(options['Path'].split(','))):
        tests.append((options['Path'].split(',')[i],float(options['limit'].split(',')[i])))

status = {'success':0,'failed':0}
for (Path,limit) in tests:  
    if Path == 'XS' and len(tests) == 1:
        if Check_XS(RefFile,TestFile,limit):
            print "XS check is succeed."
            status['success'] += 1
        else:
            print "XS check is failed."
            status['failed'] += 1
    else:
        if Check_Histos(RefFile,TestFile,Path,limit):
            print Path,"check is succeed."
            status['success'] += 1
        else:
            print Path,"check is failed."
            status['failed'] += 1

print "Totat check: " + str(status['success'] + status['failed']) + ", success: " + str(status['success']) + ", failed: " + str(status['failed'])
if status['failed'] > 0:
    Exit(1,"One or more checks are failed. Test failed.")
