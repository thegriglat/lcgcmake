#!/usr/bin/env python

"""\
%prog aidafile [aidafile2 ...]"

Verify in the ROOT user manual what needs to be setup for use of ROOT with python

For example, additional setup steps such as this may be required:
 setup setenv PYTHONDIR /usr
 setenv PATH $ROOTSYS/bin:$PYTHONDIR/bin:$PATH
 setenv LD_LIBRARY_PATH $ROOTSYS/lib:$PYTHONDIR/lib/python2.6:$LD_LIBRARY_PATH
 setenv PYTHONPATH $ROOTSYS/lib:$PYTHONDIR/lib/python2.6
"""

import sys
if sys.version_info[:3] < (2,4,0):
    print "rivet scripts require Python version >= 2.4.0... exiting"
    sys.exit(1)


import os, array

try:
    from ROOT import ROOT, TGraphAsymmErrors, TGraph2DErrors, TH1F, TH2F, TFile
except:
    sys.stderr.write("Couldn't find PyROOT module. If ROOT is installed, PyROOT probably is too, but it's not currently accessible\n")
    foundpyroot = False
    if os.environ.has_key("ROOTSYS"):
        ROOTSYS = os.environ["ROOTSYS"]
        ROOTLIBDIR = os.path.join("ROOTSYS", "lib")
        if os.path.exists(ROOTLIBDIR):
            from glob import glob
            if glob(os.path.join(ROOTLIBDIR, "libPyROOT.*")) and glob(os.path.join(ROOTLIBDIR, "ROOT.py")):
                foundpyroot = True
    if foundpyroot:
        sys.stderr.write("It looks like you want to put %s in your LD_LIBRARY_PATH and PYTHONPATH shell variables.\n" % ROOTLIBDIR)
    else:
        sys.stderr.write("You should make sure that the directory containing libPyROOT and ROOT.py is in your LD_LIBRARY_PATH and PYTHONPATH shell variables.\n")
    sys.stderr.write("You can test if PyROOT is properly set up by calling 'import ROOT' at the interactive Python shell\n")
    sys.exit(1)

## Try to load faster but non-standard cElementTree module
try:
    import xml.etree.cElementTree as ET
except ImportError:
    try:
        import cElementTree as ET
    except ImportError:
        try:
            import xml.etree.ElementTree as ET
        except:
            sys.stderr.write("Can't load the ElementTree XML parser: please install it!\n")
            sys.exit(1)


class Histo:

  def __init__(self, nDim):
    self._points = []
    self.name    = ""
    self.title   = ""
    self._nDim   = nDim

  def addPoint(self, dp):
    if dp.dimensionality() != self._nDim:
      er = "Tried to add a datapoint of dimensionality " + str(dp.dimensionality()) + " to a histogram of dimensionality " + str(self._nDim)
      sys.stderr.write(er)
      sys.exit(1)
    self._points.append(dp)

  def numPts(self):
    return len(self._points)

  def asTGraph(self):
    tg = TGraph()
    tg.SetName(self.name)
    tg.SetTitle(self.title)
    return tg

  def asHisto(self):
    tg = self.asTGraph()
    histo = tg.Histogram().Clone()
    return histo

  @staticmethod
  def equalFloats(left, right, precision=1.e-6):

    try:
      test = abs((left - right) / (left + right))
      return test < precision
    except ZeroDivisionError:
      if left * right < 0.:
        return False
      else:
        return True

    return False


class Histo2D(Histo):

  def __init__(self):
    Histo.__init__(self,3)

  def asTGraph(self):
    xs = array.array("d", [])
    ex = array.array("d", [])
    ys = array.array("d", [])
    ey = array.array("d", [])
    zs = array.array("d", [])
    ez = array.array("d", [])

    for pt in self._points:
      x   = pt.mean(0)
      erx = pt.er(0)
      y   = pt.mean(1)
      ery = pt.er(1)
      z   = pt.mean(2)
      erz = pt.er(2)

      xs.append(x)
      ex.append(erx)
      ys.append(y)
      ey.append(ery)
      zs.append(z)
      ez.append(erz)

    if self.numPts() == 0:
      tg = TGraph2DErrors()
      er = "Tried to create TGraph2DErrors called " + self.name + " with zero datapoints"
    else:
      tg = TGraph2DErrors(self.numPts(), xs, ys, zs, ex, ey, ez)
    tg.SetTitle(self.title)
    tg.SetName(self.name.replace("-", "_"))
    return tg

  def asTHisto(self):

    if self.numPts() == 0:
      histo = TH2F()
      histo.SetName(self.name)
      return histo

    tmpXEdges = []
    tmpYEdges = []

    for pt in self._points:
      tmpXEdges.append(pt.lowEdge(0))
      tmpXEdges.append(pt.highEdge(0))
      tmpYEdges.append(pt.lowEdge(1))
      tmpYEdges.append(pt.highEdge(1))

    sortedX = sorted(tmpXEdges)
    sortedY = sorted(tmpYEdges)

    xBinEdges = array.array("d", [sortedX[0]])
    yBinEdges = array.array("d", [sortedY[0]])

    for edge in sortedX:
      if not Histo.equalFloats(edge, xBinEdges[-1]):
        xBinEdges.append(edge)

    for edge in sortedY:
      if not Histo.equalFloats(edge, yBinEdges[-1]):
        yBinEdges.append(edge)

    histo = TH2F(self.name, self.title, len(xBinEdges)-1, xBinEdges, len(yBinEdges)-1, yBinEdges)
    histo.Sumw2()

    for pt in self._points:
      bin = histo.FindBin(pt.value(0), pt.value(1))
      histo.SetBinContent(bin, pt.value(2))
      histo.SetBinError(bin, pt.er(2))

    return histo


class Histo1D(Histo):
  def __init__(self):
    Histo.__init__(self,2)

  def asTGraph(self):
    xerrminus = array.array("d", [])
    xerrplus  = array.array("d", [])
    xval      = array.array("d", [])
    yval      = array.array("d", [])
    yerrminus = array.array("d", [])
    yerrplus  = array.array("d", [])

    for pt in self._points:
      x      = pt.value(0)
      xplus  = pt.erUp(0)
      xminus = pt.erDn(0)

      y      = pt.value(1)
      yplus  = pt.erUp(1)
      yminus = pt.erDn(1)

      xval.append(x)
      xerrminus.append(xminus)
      xerrplus.append(xplus)
      yval.append(y)
      yerrminus.append(yminus)
      yerrplus.append(yplus)

    tg = TGraphAsymmErrors(self.numPts(), xval, yval, xerrminus, xerrplus, yerrminus, yerrplus)
    tg.SetTitle(self.title)
    tg.SetName(self.name.replace("-", "_"))
    return tg

  def asTHisto(self):

    if self.numPts() == 0:
      histo = TH1F()
      histo.SetName(self.name)
      return histo

    binEdges = array.array("d", [])
    binEdges.append(self._points[0].lowEdge(0))

    bin = 0
    binNumbers = []

    for pt in self._points:
      lowEdge = pt.lowEdge(0)
      highEdge = pt.highEdge(0)
      if not Histo1D.equalFloats(lowEdge, binEdges[-1]):
        binEdges.append(lowEdge)
        bin = bin + 1

      bin = bin + 1
      binEdges.append(highEdge)
      binNumbers.append(bin)

    histo = TH1F(self.name, self.title, self.numPts(), binEdges)
    histo.Sumw2()

    for i, pt in enumerate(self._points):
      histo.SetBinContent(binNumbers[i], pt.value(1))
      histo.SetBinError(binNumbers[i], pt.er(1))

    return histo


class DataPoint:

  def __init__(self):
    self._dims   = 0
    self._coords = []
    self._erUps  = []
    self._erDns  = []

  def setCoord(self, val, up, down):
    self._dims = self._dims + 1
    self._coords.append(val)
    self._erUps.append(up)
    self._erDns.append(down)

  def dimensionality(self):
    return self._dims

  def th(self, dim):
    th = "th"
    if dim == 1:
      th = "st"
    elif dim == 2:
      th = "nd"
    elif dim == 3:
      th = "rd"
    return th

  def checkDimensionality(self, dim):
    if dim >= self.dimensionality():
      er = "Tried to obtain the " + str(dim) + self.th(dim) + " dimension of a " + str(self.dimensionality()) + " dimension DataPoint"
      sys.stderr.write(er)
      sys.exit(1)

  def value(self, dim):
    self.checkDimensionality(dim)
    return self._coords[dim]

  def erUp(self, dim):
    self.checkDimensionality(dim)
    return self._erUps[dim]

  def erDn(self, dim):
    self.checkDimensionality(dim)
    return self._erDns[dim]

  def mean(self, dim):
    val = self.value(dim) + 0.5 * (self.erUp(dim) - self.erDn(dim))
    return val

  def er(self, dim):
    ee = 0.5 * (self.erUp(dim) + self.erDn(dim))
    return ee

  def lowEdge(self, dim):
    return self.value(dim) - self.erDn(dim)

  def highEdge(self, dim):
    return self.value(dim) + self.erUp(dim)

def mkHistoFromDPS(dps):

  dim = dps.get("dimension")

  is3D = False
  if dim == "3":
      myhist = Histo2D()
      is3D = True
  else:
      myhist = Histo1D()

  myhist.name = dps.get("name")
  myhist.title = dps.get("title")
  myhist.path = dps.get("path")

  points = dps.findall("dataPoint")
  numbins = len(points)

  for ptNum, point in enumerate(points):
      dp = DataPoint()
      for d, m in enumerate(point.findall("measurement")):
          val  = float(m.get("value"))
          down = float(m.get("errorMinus"))
          up = float(m.get("errorPlus"))
          dp.setCoord(val, up, down)
      myhist.addPoint(dp)

  return myhist


##################################


from optparse import OptionParser
parser = OptionParser(usage=__doc__)
parser.add_option("-s", "--smart-output", action="store_true", default=True,
                  help="Write to output files with names based on the corresponding input filename",
                  dest="SMARTOUTPUT")
parser.add_option("-m", "--match", action="append",
                  help="Only write out histograms whose $path/$name string matches these regexes",
                  dest="PATHPATTERNS")
parser.add_option("-g", "--tgraph", action="store_true", default=True,
                  help="Store output as ROOT TGraphAsymmErrors or TGraph2DErrors",
                  dest="TGRAPH")
parser.add_option("-t", "--thisto", action="store_false",
                  help="Store output as ROOT TH1 or TH2",
                  dest="TGRAPH")

opts, args = parser.parse_args()
if opts.PATHPATTERNS is None:
    opts.PATHPATTERNS = []

if len(args) < 1:
    sys.stderr.write("Must specify at least one AIDA histogram file\n")
    sys.exit(1)

for aidafile in args:

    tree = ET.parse(aidafile)
    histos = []

    for dps in tree.findall("dataPointSet"):
        useThisDps = True
        if len(opts.PATHPATTERNS) > 0:
            useThisDps = False
            dpspath = os.path.join(dps.get("path"), dps.get("name"))
            for regex in opts.PATHPATTERNS:
                if re.compile(regex).search(dpspath):
                    useThisDps = True
                    break
        if useThisDps:
          histos.append(mkHistoFromDPS(dps))
    if len(histos) > 0:
        if opts.SMARTOUTPUT:
            outfile = os.path.dirname(aidafile) + "/" + os.path.basename(aidafile).replace(".aida", ".root")
            out = TFile(outfile,"RECREATE")
            for h in sorted(histos):
                if opts.TGRAPH:
                  h.asTGraph().Write()
                else:
                  h.asTHisto().Write()

            out.Close()
        else:
            sys.stderr.write("ROOT objects must be written to a file")
