//#@# Vincia 1.0.24 test for  Z decays at LEP I
//#@# reference value - Vincia 1.0.24, 1000 events
//#@# 1: cross section in mb for  f fbar -> gamma*/Z0


// vincia01: 
// This is a simple test program to run Z decays at LEP I
// Copyright P. Skands (2010)

// PYTHIA and VINCIA include files
// (automatically defines and uses the Pythia and Vincia namespaces)
#include <Vincia.h>

// ROOT: include files for linking to ROOT, uncomment as necessary
// #include "TROOT.h"
// #include "TDirectory.h"
// #include "TFile.h"
// #include "TH1.h"
// #include "TH2.h"


//*******************************
//GENSER external variables
double my_xsec,my_error;
//*******************************

// Main Program
int main() {

  //************************************************************************
  // Define Pythia 8 generator with plug-in

  Pythia pythia; 
  VinciaPlugin vincia(&pythia,"vincia.in");

  // Everything from here on is normal Pythia8 
  // (with some slight extra functionality, such as post-run statistics from 
  // Vincia and checking whether all events have unit weights)

  // Select whether to plot shapes and jet rates too (slower running)
  bool   plotShapes = true;
  bool   plotJetRates = false;

  //************************************************************************

  // Shorthands
  Event& event = pythia.event;
  Settings& settings = pythia.settings;

  // Extract settings to be used in the main program.  
  double eCM       = settings.parm("Beams:eCM");
  int    nEvent    = settings.mode("Main:numberOfEvents");
  int    nShow     = settings.mode("Main:timesToShow");
  bool   vinciaOn  = settings.flag("Vincia");
  int    verbose   = settings.mode("Vincia:verbose");
  int    iEventPri = -1;

  //************************************************************************

  // Initialize
  pythia.init( 11, -11, eCM);

  // List changed settings
  pythia.settings.listChanged();

  // Check that Z0 decay channels set correctly.
  pythia.particleData.listChanged();
 
  //************************************************************************

  // Define a few PYTHIA utilities
  ClusterJet ktClu("Durham",2,2);
  Thrust Thr(1);
  Sphericity SphLin(1,2);

  //************************************************************************

  // Define PYTHIA histograms
  // Rootlink: to use ROOT instead, HIST -> TH1F ("tag",...)

  // Event weights
  Hist HnPN("Event weights", 5, -2.5, 2.5);
  // Number of quarks, partons, and charged particles
  double nQsum=0.0;
  double nPsum=0.0;
  double nCsum=0.0;
  Hist HnQuarks("nQuarks", 50, -0.5, 49.5);
  Hist HnPartons("nPartons", 100, -0.5, 99.5);
  Hist HnCharged("nCharged", 200, -1.0, 199.0);
  // Thrust
  int sBins=100;
  int sBinsCoarse=25;
  Hist Hthr("1-T",sBins, 0.0, 0.5);
  Hist HthrTail("1-T", sBinsCoarse, 0.0, 0.5);
  Hist HthrNorm("(1-T)*(1-T)", sBins, 0.0, 0.5);
  double wthr=sBins/0.5;
  double wthrCoarse=sBinsCoarse/0.5;
  // Event Shapes
  double wShape=sBins/1.0;
  Hist Hmaj("Major",sBins,0.0,1.0);
  Hist Hmin("Minor",sBins,0.0,1.0);
  Hist Hobl("Oblateness",sBins,0.0,1.0);
  Hist HistC("C",sBins,0.0,1.0);
  Hist HistD("D",sBins,0.0,1.0);
  Hist HistCNorm("C*(C)",sBins,0.0,1.0);
  Hist HistDNorm("D*(D)",sBins,0.0,1.0);

  // Optional: jet rates: Log10(Y)
  double nJetSum = 0.0;
  Hist HJet2ELog("2 jet exclusive fraction",100,-5.0,0.0);
  Hist HJet3ILog("3 jet inclusive fraction",100,-5.0,0.0);  
  Hist HJet3ELog("3 jet exclusive fraction",100,-5.0,0.0);  
  Hist HJet4ILog("4 jet inclusive fraction",100,-5.0,0.0);  
  Hist HJet4ELog("4 jet exclusive fraction",100,-5.0,0.0);  
  Hist HJet5ILog("5 jet inclusive fraction",100,-5.0,0.0);  
  Hist HJet5ELog("5 jet exclusive fraction",100,-5.0,0.0);  
    
  //************************************************************************

  // Make a histogram showing alphaS for this run.

  Hist alphaS("alpha_S vs log10(Q)",100,-1.0,2.0);
  double dlogQ = 3.0/100.0;
  for (int iQ=0;iQ<100;iQ++) {
    double logQ = -1.0 + (iQ+0.5)*dlogQ;
    double Q    = pow(10,logQ);
    double as   = vincia.shower.alphaS.alphaS(pow2(Q));
    if (as < 10.0) {
      if (verbose >= 5) cout<<" as("<<Q<<") = "<<as<<endl;
      alphaS.fill(logQ,as);
    }
  }

  //************************************************************************

  // EVENT GENERATION LOOP
  // Generation, event-by-event printout, analysis, and storage

  // Counter for negative-weight events
  double nNegative = 0.0;
  double nPositive = 0.0;
  double evwt=1.0;

  // Begin event loop
  for (int iEvent = 0; iEvent < nEvent; ++iEvent) {

    if (iEvent%(max(1,nEvent/max(nShow,1))) == 0)  
      cout << " Now begin event " << iEvent << endl;

    // Verbose 
    if (iEvent >= iEventPri && iEventPri >= 0) {
      verbose = 8;
      vincia.setVerbose(verbose);
    }

    if (!pythia.next()) continue;

    // Check for negative weights
    if (vinciaOn) evwt = vincia.weight();
    if (evwt < 0) nNegative += abs(evwt); 
    else nPositive += evwt;
    HnPN.fill(evwt,1.0);

    // Count FS charged hadrons, partons, and quarks
    int nc=0;
    int np=0;
    int nq=0;
    for (int i=1;i<event.size();i++) {
      // Count up final-state charged hadrons
      if (event[i].isCharged() && event[i].status() > 80) nc++;
      // Find last parton-level partons
      int iDau1 = event[i].daughter1();
      if (iDau1 == 0 || abs(event[iDau1].status()) > 80) {
	// Count up partons and quarks
	if (event[i].isQuark() || event[i].isGluon() ) np++;
	if (event[i].isQuark()) nq++;	
      }
    }
    HnQuarks.fill(0.5*nq,evwt);
    HnPartons.fill(1.0*np,evwt);
    HnCharged.fill(1.0*nc,evwt);
    nQsum += 0.5*nq;
    nPsum += np;
    nCsum += nc;

    // Histogram thrust 
    if (plotShapes) {
      Thr.analyze( event );
      Hthr.fill(1.0-Thr.thrust(),wthr*evwt);
      HthrTail.fill(1.0-Thr.thrust(),wthrCoarse*evwt);    
      HthrNorm.fill(1.0-Thr.thrust(),(1-Thr.thrust())*wthr*evwt);    
      Hmaj.fill(Thr.tMajor(),wShape*evwt);
      Hmin.fill(Thr.tMinor(),wShape*evwt);
      Hobl.fill(Thr.oblateness(),wShape*evwt);

      // Histogram Linear Sphericity values
      if (np >= 2.0) {
	SphLin.analyze( event );
	double evC=3*(SphLin.eigenValue(1)*SphLin.eigenValue(2)
		      + SphLin.eigenValue(2)*SphLin.eigenValue(3)
		      + SphLin.eigenValue(3)*SphLin.eigenValue(1));
	double evD=27*SphLin.eigenValue(1)*SphLin.eigenValue(2)
	  *SphLin.eigenValue(3);
	HistC.fill(evC,wShape*evwt);
	HistD.fill(evD,wShape*evwt);
	HistCNorm.fill(evC,evC*wShape*evwt);
	HistDNorm.fill(evD,evD*wShape*evwt);
      }
    }

    // Histogram Jet rates
    // (switch off for fast runs, slows down speed significantly)
    double ycutFix=0.001;
    ktClu.analyze(event,ycutFix,0.0);
    nJetSum += ktClu.size();    
    if (plotJetRates) {
      for (int ipt=10;ipt<90;ipt++) {
	double logy=-5.0+5.0*(ipt+0.5)/100.0;
	double ycut=pow(10,logy);
	ktClu.analyze(event,ycut,0.0);
	int njets=ktClu.size();
	if (njets<=2) HJet2ELog.fill(logy,evwt);
	if (njets>=3) HJet3ILog.fill(logy,evwt);
	if (njets==3) HJet3ELog.fill(logy,evwt); 
	if (njets>=4) HJet4ILog.fill(logy,evwt); 
	if (njets==4) HJet4ELog.fill(logy,evwt); 
	if (njets>=5) HJet5ILog.fill(logy,evwt); 
	if (njets==5) HJet5ELog.fill(logy,evwt); 
      }
    }

    // List the first few events
    if (iEvent < 1) event.list();
    
  }

  //************************************************************************

  // POST-RUN FINALIZATION 
  // Normalization, Statistics, Output

  //Normalize histograms to effective number of positive-weight events.
  double normFac=1.0/(nPositive-nNegative);
  if (plotShapes) {
    Hthr      *= normFac;
    HthrTail  *= normFac;
    HthrNorm  *= normFac;
    HistC     *= normFac;
    HistD     *= normFac;
    HistCNorm *= normFac;
    HistDNorm *= normFac;
    Hmaj      *= normFac;
    Hmin      *= normFac;
    Hobl      *= normFac;
  }
  HnQuarks    *= normFac;
  HnPartons   *= normFac;
  HnCharged   *= normFac;
  if (plotJetRates) {
    HJet2ELog *= normFac;
    HJet3ILog *= normFac;
    HJet3ELog *= normFac;
    HJet4ILog *= normFac;
    HJet4ELog *= normFac;
    HJet5ILog *= normFac;
    HJet5ELog *= normFac;
  }

  // Print a few histograms
  cout<<HnPartons<<endl;
  cout<<" ^N"<<endl;
  if (plotShapes) {    
    cout<<Hthr<<endl;
    cout<<" ^(1-T)"<<endl;
    cout<<HistC<<endl;
    cout<<" ^C"<<endl;
    cout<<HistD<<endl;
    cout<<" ^D"<<endl;
  }
  if (plotJetRates) cout<<HJet3ILog<<HJet4ILog<<HJet5ILog;

  cout<<endl;
  cout<<fixed;
  cout<< " <nGluonSplit> = "<<num2str(nQsum * normFac-1.0)<<endl;
  cout<< " <nPartons>    = "<<num2str(nPsum * normFac)<<endl;
  cout<< " <nCharged>    = "<<num2str(nCsum * normFac)<<endl;
  cout<< " <nJ(y=0.001)> = "<<num2str(nJetSum * normFac)<<endl;
  cout<<endl;

  // Print out Vincia internal histograms
  if (vinciaOn && verbose >= 3) vincia.printHistos();

  // Print out Vincia end-of-run information
  pythia.statistics();
  if (vinciaOn) vincia.printInfo();

  //Output tables of histograms to file?   
  /*
  HThr.table(mycout);
  HC.table(mycout);
  HD.table(mycout);
  if (plotJetRates) {
    HJet3ILog.table(mycout);
    HJet4ILog.table(mycout);
    HJet5ILog.table(mycout);
  }
  */



  //GENSER output
  cout<<"GENSER output"<<endl;
  cout<<"cross section  "<<my_xsec<<endl;
  cout<<"cross section error  "<<my_error<<endl;
  ofstream testi("testi.dat");
  testi << "vincia_test1  1   " << my_xsec  << "  " << my_error << endl;
  testi.close();


  // Done.
  return 0;
}


//--------------------------------------------------------------------------

// Print statistics on cross sections and number of events.

void ProcessLevel::statistics(bool reset, ostream& os) {

  // Special processing if two hard interactions selected.
  if (doSecondHard) { 
    statistics2(reset, os);
    return;
  } 
    
  // Header.
  os << "\n *-------  PYTHIA Event and Cross Section Statistics  ------"
     << "-------------------------------------------------------*\n"
     << " |                                                            "
     << "                                                     |\n" 
     << " | Subprocess                                    Code |       "
     << "     Number of events       |      sigma +- delta    |\n" 
     << " |                                                    |       "
     << "Tried   Selected   Accepted |     (estimated) (mb)   |\n"
     << " |                                                    |       "
     << "                            |                        |\n"
     << " |------------------------------------------------------------"
     << "-----------------------------------------------------|\n"
     << " |                                                    |       "
     << "                            |                        |\n";

  // Reset sum counters.
  long   nTrySum   = 0; 
  long   nSelSum   = 0; 
  long   nAccSum   = 0;
  double sigmaSum  = 0.;
  double delta2Sum = 0.;

  // Loop over existing processes.
  for (int i = 0; i < int(containerPtrs.size()); ++i) 
  if (containerPtrs[i]->sigmaMax() != 0.) {

    // Read info for process. Sum counters.
    long   nTry    = containerPtrs[i]->nTried();
    long   nSel    = containerPtrs[i]->nSelected();
    long   nAcc    = containerPtrs[i]->nAccepted();
    double sigma   = containerPtrs[i]->sigmaMC();
    double delta   = containerPtrs[i]->deltaMC(); 
    nTrySum       += nTry;
    nSelSum       += nSel;
    nAccSum       += nAcc; 
    sigmaSum      += sigma;
    delta2Sum     += pow2(delta);    

    // Print individual process info.
    os << " | " << left << setw(45) << containerPtrs[i]->name() 
       << right << setw(5) << containerPtrs[i]->code() << " | " 
       << setw(11) << nTry << " " << setw(10) << nSel << " " 
       << setw(10) << nAcc << " | " << scientific << setprecision(3) 
       << setw(11) << sigma << setw(11) << delta << " |\n";

    // Print subdivision by user code for Les Houches process.
    //if (containerPtrs[i]->code() == 9999) 
    //for (int j = 0; j < int(codeLHA.size()); ++j)
    //  os << " |    ... whereof user classification code " << setw(10) 
    //     << codeLHA[j] << " |                        " << setw(10) 
    //     << nEvtLHA[j] << " |                        | \n";
  }

  // Print summed process info.
  os << " |                                                    |       "
     << "                            |                        |\n"
     << " | " << left << setw(50) << "sum" << right << " | " << setw(11) 
     << nTrySum << " " << setw(10) << nSelSum << " " << setw(10) 
     << nAccSum << " | " << scientific << setprecision(3) << setw(11) 
     << sigmaSum << setw(11) << sqrtpos(delta2Sum) << " |\n";

  // Listing finished.
  os << " |                                                            "
     << "                                                     |\n"
     << " *-------  End PYTHIA Event and Cross Section Statistics -----"
     << "-----------------------------------------------------*" << endl;

  // Optionally reset statistics contants.
  if (reset) for (int i = 0; i < int(containerPtrs.size()); ++i) 
    containerPtrs[i]->reset();

  my_xsec=sigmaSum;
  my_error=sqrtpos(delta2Sum);

}
