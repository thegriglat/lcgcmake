// main14.cc is a part of the PYTHIA event generator.
// Copyright (C) 2014 Torbjorn Sjostrand.
// PYTHIA is licenced under the GNU GPL version 2, see COPYING for details.
// Please respect the MCnet Guidelines, see GUIDELINES for details.

// Comparison with some PYTHIA 6.413 cross sections process by process.
// Several processes have been left out to keep reasonable execution time.
// Some processes are not handled absolutely identically, so minor
// systematic differences may occur in addition to the statistical ones.
// (For some MSSM Higgs processes 6.413 has been modified to use
// running quark masses in loops, like 8.1, to allow proper comparison.)
// Subruns  0 -  5 : QCD jets
//          6 - 10 : prompt photons.
//         11 - 12 : t-channel gamma/Z/W exchange.
//         13 - 23 : gamma*/Z^0/W^+-, singly, in pairs or with parton
//         24 - 25 : onia.
//         26 - 30 : top.
//         31 - 40 : Standard Model Higgs.
//         41 - 45 : MSSM Higgses (trivial couplings).
//         46 - 47 : Z' and W'
//         48 - 51 : Left-right-symmetric scenario.
//         52 - 52 : Leptoquark.
//         53 - 55 : Excited fermions (compositeness).
//         56 - 56 : excited Graviton (RS extra dimensions).

#include "Pythia8/Pythia.h"
#include <iostream>
#include <fstream>
using namespace std;
using namespace Pythia8;

#include <iostream>      // for cout and cin
#include <map>
#include <stdio.h>

void dumpXSec(map<string, double> map2write)
{

  ofstream myfile;
  myfile.open ("xsec_pythia8.dat");
   // use const_iterator to walk through elements of pairs
   for ( std::map< string, double >::const_iterator iter = map2write.begin();
             iter != map2write.end(); ++iter )
                   myfile << iter->first << '\t' << iter->second << scientific << '\n';

  myfile.close();
  return;

}

map<string, double> openXSec(string filename)
{
  map<string, double> mapProcXsec;

  ifstream  myfile;
  myfile.open (filename.c_str());

  if (! myfile.good() ) { cout << " Please probvide valid file. Exiting.... "; exit(1); }

  string process;
  double xsec;
  while (!myfile.eof()) {
 	 myfile >> process >> xsec;
	 mapProcXsec[process]=xsec;
  }

  myfile.close();

  return mapProcXsec;

}




int main(int argc, char *argv[]){

string refFile="xsec_pythia6_ref.dat";

  if( argc == 1 )
      cout << "No reference filename provided; default xsec_pythia6_ref.dat will be used "  << endl;
   else if ( argc == 2 ){
      cout << "You provided new reference file! File is "  << argv[1] << endl;
      refFile=argv[1];	
   }
   else if( argc > 2 )
      {
      cout << "Please provide reference filename or do not specify any input"  << endl;
      return 1;	
      }
       


  map<string, double> mapProcXsecRef;
  map<string, double> mapProcXsec;
  
  mapProcXsecRef=openXSec(refFile);

  // First and last process to test: can run from 0 through 40.
  int iFirst = 0;
  int iLast  = 56;

  // Statistics. Pythia6 run was with 10000, so no point to use more.
  int nEvent = 10000;

  // Normally one subprocess word per subrun, but exceptions exist.
  int nSub[100];
  for (int i = 0; i < 100; ++i) nSub[i] = 1;
  nSub[1] = 3;
  nSub[5] = 3;
  // Starting positions in subprocess words list, recursively defined.
  int iBeg[101] = { 0 };
  for (int i = 0; i < 100; ++i) iBeg[i + 1] = iBeg[i] + nSub[i];
  // List of subprocess words.
  string processes[61] = { 
    "HardQCD:gg2gg", 
    "HardQCD:gg2qqbar",
    "HardQCD:gg2ccbar",  
    "HardQCD:gg2bbbar",
    "HardQCD:qg2qg" ,
    "HardQCD:qq2qq", 
    "HardQCD:qqbar2gg", 
    "HardQCD:qqbar2qqbarNew",
    "HardQCD:qqbar2ccbar", 
    "HardQCD:qqbar2bbbar", 
    "PromptPhoton:qg2qgamma",
    "PromptPhoton:qqbar2ggamma", 
    "PromptPhoton:gg2ggamma",
    "PromptPhoton:ffbar2gammagamma", 
    "PromptPhoton:gg2gammagamma",
    "WeakBosonExchange:ff2ff(t:gmZ)", 
    "WeakBosonExchange:ff2ff(t:W)",
    "WeakSingleBoson:ffbar2gmZ", 
    "WeakSingleBoson:ffbar2W",
    "WeakDoubleBoson:ffbar2gmZgmZ", 
    "WeakDoubleBoson:ffbar2ZW",
    "WeakDoubleBoson:ffbar2WW", 
    "WeakBosonAndParton:qqbar2gmZg",
    "WeakBosonAndParton:qg2gmZq", 
    "WeakBosonAndParton:ffbar2gmZgm",
    "WeakBosonAndParton:qqbar2Wg", 
    "WeakBosonAndParton:qg2Wq",
    "WeakBosonAndParton:ffbar2Wgm", 
    "Charmonium:all", 
    "Bottomonium:all",
    "Top:gg2ttbar",  
    "Top:qqbar2ttbar",  
    "Top:qq2tq(t:W)",
    "Top:ffbar2ttbar(s:gmZ)", 
    "Top:ffbar2tqbar(s:W)",
    "HiggsSM:ffbar2H", 
    "HiggsSM:gg2H", 
    "HiggsSM:ffbar2HZ",
    "HiggsSM:ffbar2HW", 
    "HiggsSM:ff2Hff(t:ZZ)", 
    "HiggsSM:ff2Hff(t:WW)",
    "HiggsSM:qg2Hq", 
    "HiggsSM:gg2Hg(l:t)", 
    "HiggsSM:qg2Hq(l:t)",
    "HiggsSM:qqbar2Hg(l:t)", 
    "HiggsBSM:allH1", 
    "HiggsBSM:allH2",
    "HiggsBSM:allA3", 
    "HiggsBSM:allH+-", 
    "HiggsBSM:allHpair",
    "NewGaugeBoson:ffbar2gmZZprime", 
    "NewGaugeBoson:ffbar2Wprime",
    "LeftRightSymmmetry:ffbar2ZR", 
    "LeftRightSymmmetry:ffbar2WR",
    "LeftRightSymmmetry:ffbar2HLHL", 
    "LeftRightSymmmetry:ffbar2HRHR",
    "LeptoQuark:all", 
    "ExcitedFermion:dg2dStar",
    "ExcitedFermion:qq2dStarq", 
    "ExcitedFermion:qqbar2eStare",
    "ExtraDimensionsG*:all" };

  // Generator.
  Pythia pythia;

  // Standard set of masses for comparison with Fortran code.
  pythia.readString("5:m0  = 4.2");
  pythia.readString("6:m0  = 175.");
  pythia.readString("23:m0 = 91.2");
  pythia.readString("24:m0 = 80.");

  // Same kinematics cuts as Fortran code.
  pythia.readString("PhaseSpace:pTHatMin = 20.");
  pythia.readString("6:mMin = 20.");
  pythia.readString("23:mMin = 20.");
  pythia.readString("24:mMin = 20.");
  pythia.readString("25:mMin = 20.");
  pythia.readString("32:mMin = 400.");
  pythia.readString("34:mMin = 400.");
  pythia.readString("42:mMin = 50.");
  pythia.readString("5000039:mMin = 50.");

  // Also same renormalization and factorization scale.
  pythia.readString("SigmaProcess:renormScale2 = 3");
  pythia.readString("SigmaProcess:factorScale2 = 3");

  // Switch off unnecessary parts.
  pythia.readString("PartonLevel:all = off");
  pythia.readString("ProcessLevel:resonanceDecays = off");

  // No printing of settings, particle data or events.
  pythia.readString("Init:showProcesses = off");
  pythia.readString("Init:showChangedSettings = off");
  pythia.readString("Init:showChangedParticleData = off");
  pythia.readString("Next:numberCount = 0");
  pythia.readString("Next:numberShowInfo = 0");
  pythia.readString("Next:numberShowProcess = 0");
  pythia.readString("Next:numberShowEvent = 0");

  // Debug: show information on cross section maximum and violation.
  //pythia.readString("PhaseSpace:showSearch = on");
  //pythia.readString("PhaseSpace:showViolation = on");

  // Loop over processes.

  cout << " comparison between current version and reference file - " << refFile << endl;

  for (int iProc = iFirst; iProc <= iLast; ++iProc) {
//    cout << "\n Begin subrun number " << iProc << " : ";

    // Switch off previous process(es) and switch on new one(s).
    if (iProc > iFirst) for (int i = iBeg[iProc - 1]; i < iBeg[iProc]; ++i)
      pythia.readString( processes[i] + " = off" );
    for (int i = iBeg[iProc]; i < iBeg[iProc + 1]; ++i) {
      pythia.readString( processes[i] + " = on" );
 //     if (i > iBeg[iProc]) cout << " + ";
  //    cout << processes[i];
    }
//    cout << endl;

    // Switch between SM and MSSM Higgs scenario.
    if (iProc <= 40) {
      pythia.readString("Higgs:useBSM = off");
      pythia.readString("25:m0 = 200.");
    } else {
      pythia.readString("Higgs:useBSM = on");
      pythia.readString("25:m0 = 115.");
      pythia.readString("35:m0 = 300.");
      pythia.readString("36:m0 = 300.");
      pythia.readString("37:m0 = 320.");
      // With default option Higgs:clipWings = on need to reset mass range.
      pythia.readString("25:mMin = 50.");
      pythia.readString("25:mMax = 0.");
    }

    // Initialize for LHC.
    pythia.readString("Beams:eCM = 14000.");
    pythia.init();

    // Debug: show initialized resonance data first time around.
    //if (iProc == iFirst) pythia.particleData.listChanged(true);

    // Generate events to get cross section statistics.
    for (int iEvent = 0; iEvent < nEvent; ++iEvent) pythia.next();
 
    // Show statistics.
    //pythia.stat();
    double sigma = pythia.info.sigmaGen();

    mapProcXsec[processes[iProc]]=sigma;
    string wmessage = "";
    if ( fabs(1.-sigma / mapProcXsecRef[processes[iProc]])> 0.05) wmessage = "WARNING";
    if ( fabs(1.-sigma / mapProcXsecRef[processes[iProc]])> 0.3 ) wmessage = "LARGE DEVIATION";
    printf ( "XS of %30s is %E and it was %E in ref. file and ratio is %f %10s \n",  
         processes[iProc].c_str(), sigma, mapProcXsecRef[processes[iProc]], sigma / mapProcXsecRef[processes[iProc]], wmessage.c_str() );

  // End of loop over processes.
  }

   dumpXSec(mapProcXsec);

  // Done.
  return 0;
}
