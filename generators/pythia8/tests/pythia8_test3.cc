// main01.cc is a part of the PYTHIA event generator.
// Copyright (C) 2008 Torbjorn Sjostrand.
// PYTHIA is licenced under the GNU GPL version 2, see COPYING for details.
// Please respect the MCnet Guidelines, see GUIDELINES for details.
//
//#@# 1: Average charged multiplicity of QCD events at the LHC, pthat cut 20 GeV
//
#ifdef PYTHIA8NEWVERS
  #include "Pythia8/Pythia.h"
#else
  #include "Pythia.h"
#endif
using namespace Pythia8; 
int main() {
  // Generator. Process selection. LHC initialization. Histogram.
  Pythia pythia;
  pythia.readString("HardQCD:all = on");    
  pythia.readString("PhaseSpace:pTHatMin = 20.");  
  pythia.readString("Next:numberShowEvent = 0");
  pythia.readString("Tune:ee = 3");
  pythia.readString("Tune:pp = 5");

#ifdef PYTHIA8200
  pythia.readString("Beams:eCM = 14000.");
  pythia.init();
#else
  pythia.init( 2212, 2212, 14000.);
#endif

  Hist mult("charged multiplicity", 100, -0.5, 799.5);
  int ntotCharged = 0;
  const int nEvent=1000;
  int nCharged_sv[nEvent];
  // Begin event loop. Generate event. Skip if error. List first one.
  for (int iEvent = 0; iEvent < nEvent; ++iEvent) {
    if (!pythia.next()) continue;
    if (iEvent < 1) {pythia.info.list(); } 
    // Find number of all final charged particles and fill histogram.
    int nCharged = 0;
    for (int i = 0; i < pythia.event.size(); ++i) 
      if (pythia.event[i].isFinal() && pythia.event[i].isCharged()) 
        ++nCharged; 
    ntotCharged += nCharged;
    mult.fill( nCharged );
    nCharged_sv[iEvent] = nCharged;
  // End of event loop. Statistics. Histogram. Done.
  }
#ifdef PYTHIA8200
  pythia.stat();
#else
  pythia.statistics();  
#endif
  cout << mult; 
  ofstream testi("testi_pythia8.dat");
  double val, errval;
  val = (double)ntotCharged/(double)nEvent;
  errval = 0.;
  for (int iEvent = 0; iEvent < nEvent; ++iEvent) errval= errval + ((double)nCharged_sv[iEvent]-val)*((double)nCharged_sv[iEvent]-val);
  // 2.5 below is rather arbitrary to take into account that distr. not Gaussian
  errval=2.5*sqrt(errval/(double)nEvent)/sqrt((double)nEvent);
  testi << "pythia8_test3  1   " << val << " " << errval << " " << endl;
  return 0;
}
