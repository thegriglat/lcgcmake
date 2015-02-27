#!/usr/bin/env python

#
# Options are      
# $0 RefFile TestFile "Path=XS,W_mass" "limit=0.05,0.1"
# Calculation of chi2 using errors and probability is to be made.
#

import sys
import yoda
import re

def Check_Histos(RefFile, TestFile, component, limit = 0.9):
    """ Check Kolmogorov value between 'component' of Reference and Test file """
    print "### Do test to compare two TH1F (" + component + ") ###"
    try:
        import ROOT
    except:
        raise Exception("Cannot import ROOT")
    try:
        RefF = ROOT.TFile(RefFile)
        TestF = ROOT.TFile(TestFile)
    except:
        raise Exception("Cannot open ROOT files")
    try:
        RefHist  = RefF.Get(component)
        TestHist = TestF.Get(component)
    except:
        raise Exception("Cannot obtain " + component + " from files")
    if component == "XS":
        try:
            print "-- One bin histo, simply calculate chi2"
            ValueRef = RefHist.GetBinContent(1)
            ValueTest = TestHist.GetBinContent(1)
            ErrRef = RefHist.GetBinError(1)
            ErrTest = TestHist.GetBinError(1)
            chi2 = (ValueTest-ValueRef)*(ValueTest-ValueRef)/(ErrRef*ErrRef+ErrTest*ErrTest)
            print "chi2 =  " + str(chi2)
            hi = ROOT.TMath.Prob(chi2, 1)
        except:
            raise Exception("Cannot do Chi2Test!")
            return False
    else:
        try:
            ifnorm = re.match("(.*_norm)", component)
            if ifnorm:
                print "-- Normalized histos, taking into account integrals"
                hi = RefHist.KolmogorovTest(TestHist)
                ErrRef = ROOT.Double(0.0)
                ErrTest = ROOT.Double(0.0)
                ValueRef = RefHist.IntegralAndError(1, -1, ErrRef)
                ValueTest = TestHist.IntegralAndError(1, -1, ErrTest)
                chi2 = (ValueTest-ValueRef)*(ValueTest-ValueRef)/(ErrRef*ErrRef+ErrTest*ErrTest)
                print "chi2 =  " + str(chi2)
                hi = hi * ROOT.TMath.Prob(chi2, 1)
            else:
                hi = RefHist.KolmogorovTest(TestHist)
        except:
            raise Exception("Cannot do Kolmogorov test")
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
            raise Exception("Can't split key=value pair by symbol '=' in \'" + opt + "\'")
else:
    raise Exception("No options specified!")
if not options.has_key('Path') or not options.has_key('limit'):
    raise Exception("Path or limit option isn't specified.")

tests = []
if len(options['Path'].split(',')) != len(options['limit'].split(',')):
    raise Exception("Path and limit has different number of tests!")
else:
    for i in xrange(len(options['Path'].split(','))):
        tests.append((options['Path'].split(',')[i],float(options['limit'].split(',')[i])))

status = {'success':0,'failed':0}
for (Path,limit) in tests:  
    if Check_Histos(RefFile,TestFile,Path,limit):
        print Path,"check succeeded."
        status['success'] += 1
    else:
        print Path,"check failed."
        status['failed'] += 1

print "Total check: " + str(status['success'] + status['failed']) + ", success: " + str(status['success']) + ", failed: " + str(status['failed'])
if status['failed'] > 0:
    print("One or more checks are failed. Test failed.")
    sys.exit(1)
