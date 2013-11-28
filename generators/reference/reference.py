#!/usr/bin/env python
import sys
from xml.dom import minidom
import yoda

def GetXS(YodaFile):
    """ Return MC_XS/XS from Yoda file as float"""
    for i in YodaFile:
        if '/MC_XS/XS' in i.annotations['Path']:
            return float(i.points()[0].y)
    print "Cannot found XS value in Yoda file"
    sys.exit(1)


def Check_XS(RefFile,TestFile,limit = 0.95):
    """ Compare two XS and return True if difference less than 'percent' %"""
    print "### Compare MC_XS/XS value ###"
    if limit == None: limit = 0.95
    RefValue = GetXS(yoda.read(RefFile))
    TestValue = GetXS(yoda.read(TestFile))
    print "Test value: " + str(TestValue) + " | Reference value: " + str(RefValue) + " | limit = " + str(limit)
    print str(1 - abs(TestValue - RefValue)/RefValue)
    if (1 - abs(TestValue - RefValue)/RefValue) >= limit:
        print "Success."
        sys.exit(0)
    else:
        print "Test failed."
        sys.exit(1)

def Check_Histos(RefFile, TestFile, component, limit = 0.9):
    """ Check Kolmogorov value between 'component' of Reference and Test file """
    print "### Do kolmogorov test to compare two TH1F ###"
    if limit == None: limit = 0.9
    try:
        import ROOT
    except:
        print "Cannot import ROOT"
        sys.exit(1)
    try:
        RefF = ROOT.TFile(RefFile)
        TestF = ROOT.TFile(TestFile)
    except:
        print "Cannot open ROOT files"
        sys.exit(1)
    try:
        RefHist  = RefF.Get(component)
        TestHist = TestF.Get(component)
    except:
        print "Cannot obtain " + component + " from files"
        sys.exit(1)
    hi = RefHist.KolmogorovTest(TestHist)
    print "Result: " + str(hi) + " | success if >= " + str(limit)
    if hi >= limit:
        print "Success."
        sys.exit(0)
    else:
        print "Test failed."
        sys.exit(1)

##
# Options are      
# $0 RefFile TestFile "Path=XS" "limit=0.05""key1=value1" "key2=value2" ...
# key=output,input
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
            print "Can't split key=value pair by symbol '='"
            sys.exit(1)
else:
    print "No Path option specified!"
    sys.exit(1)
if options.has_key('limit'):
    limit = float(options['limit'])
else:
    limit = None
if options['Path'] == 'XS':
    Check_XS(RefFile,TestFile,limit)
else:
    Check_Histos(RefFile,TestFile,options['Path'],limit)
