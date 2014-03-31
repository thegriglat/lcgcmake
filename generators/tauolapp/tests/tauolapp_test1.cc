// #@# p p --> (Z -> tau+ tau-)  (W -> tau nutaubar) X,
// #@#
// #@# tau --> X,
// #@#
// #@# 1: average E(hadron(s))/E(tau) as given by PYTHIA
// #@# 2: average E(hadron(s))/E(tau) as given by TAUOLA

/**
 * Example of use of tauola C++ interface. Pythia events are
 * generated with a stable tau. Taus are subsequently decayed via
 * tauola.
 *
 * @author Nadia Davidson, Mikhail Kirsanov
 * @date 05 July 2010
 * @modified by Mikhail Kirsanov 22.04.2012: take all hadrons
 */

#include "Tauola/Log.h"
#include "Tauola/Plots.h"
#include "Tauola/Tauola.h"
#include "Tauola/TauolaHepMCEvent.h"

//pythia header files
#if PYTHIA8_VERSION >= 180
  #include "Pythia8/Pythia.h"
  #include "Pythia8ToHepMC.h"
#else
  #include "Pythia.h"
  #include "HepMCInterface.h"
#endif

#include "HepMC/IO_AsciiParticles.h"

using namespace std;
using namespace Pythia8; 

double hratio(HepMC::GenEvent* HepMCEvt, double* hratio2)
{
  double rat=0., rat2=0.;
  int nhadrmode=0;
  for ( HepMC::GenEvent::particle_iterator p = HepMCEvt->particles_begin();
        p != HepMCEvt->particles_end(); ++p ){
    if(abs((*p)->pdg_id()) == 15 && (*p)->end_vertex() ) {
      double ehadr=0.;
      int ihadrmode=0;
      for ( HepMC::GenVertex::particle_iterator des =
            (*p)->end_vertex()->particles_begin(HepMC::children);
            des !=
            (*p)->end_vertex()->particles_end(HepMC::children);
                                                           ++des ) {
        if( abs((*des)->pdg_id()) > 100 ) {
          ehadr += (*des)->momentum().e();
          ihadrmode = 1;
        }
      }
      rat += ehadr / (*p)->momentum().e();
      rat2 += ehadr*ehadr / ( (*p)->momentum().e()*(*p)->momentum().e() );
      nhadrmode += ihadrmode;
    }
  }
  if(nhadrmode) {
    rat = rat / (double)nhadrmode;
    rat2 = rat2 / (double)nhadrmode;
  }
  *hratio2 = rat2;
  return rat;
}


int main(int argc, char* argv[])
{
  Tauolapp::Log::SummaryAtExit();
  // Initialisation of pythia
#if PYTHIA8_VERSION >= 180
  HepMC::Pythia8ToHepMC ToHepMC;
#else
  HepMC::I_Pythia8 ToHepMC;
#endif
  Pythia pythia;
  
  // suppress full listing of first events in pythia8 > 160
  pythia.readString("Next:numberShowEvent = 0");
  
  //HepMC::IO_AsciiParticles ascii_io("example_PythiaParticle.dat",std::ios::out);
  //HepMC::IO_AsciiParticles ascii_io1("cout",std::ios::out);
  
  int NumberOfEvents = 500;
  if(argc>2) NumberOfEvents = atoi(argv[2]);
  
  int ShowersOn = 1;
  if(argc>1) ShowersOn = atoi(argv[1]);
  if(!ShowersOn)
  {
    //pythia.readString("HadronLevel:all = off");
    pythia.readString("HadronLevel:Hadronize = off");
    pythia.readString("SpaceShower:QEDshower = off");
    pythia.readString("SpaceShower:QEDshowerByL = off");
    pythia.readString("SpaceShower:QEDshowerByQ = off");
    pythia.readString("PartonLevel:ISR = off");
    pythia.readString("PartonLevel:FSR = off");
  }
  pythia.readString("WeakDoubleBoson:ffbar2ZW = on");

  //pythia.readString("HiggsSM:gg2H = on");
  //pythia.readString("25:m0 = 200.");
  //pythia.readString("25:onMode = off");
  //pythia.readString("25:onIfAny = 23");

  pythia.readString("23:onMode = off"); 
  pythia.readString("23:onIfAny = 15");
  pythia.readString("24:onMode = off");
  pythia.readString("24:onIfAny = 15");
  //pythia.readString("23:onIfMatch = 15 -15");
  
  //proton proton collisions
  if (! pythia.init( -2212, -2212, 14000.0)) return 1;
  
  //Set up TAUOLA
  //   Tauola::setSameParticleDecayMode(19);     //19 and 22 contains K0
  //   Tauola::setOppositeParticleDecayMode(19); // 20 contains eta
  if(argc>4){
    Tauolapp::Tauola::setSameParticleDecayMode(atoi(argv[4]));
    Tauolapp::Tauola::setOppositeParticleDecayMode(atoi(argv[4]));
  }
  if(argc>5){
    Tauolapp::Tauola::setHiggsScalarPseudoscalarMixingAngle(atof(argv[5]));
    Tauolapp::Tauola::setHiggsScalarPseudoscalarPDG(25);
  }
  Tauolapp::Tauola::initialise();
  // our default is GEV and MM, that will be outcome  units after TAUOLA
  // if HepMC unit variables  are correctly set. 
  // with the following coice you can fix the units for final outcome:
  //  Tauola::setUnits(Tauola::GEV,Tauola::MM); 
  //  Tauola::setUnits(Tauola::MEV,Tauola::CM); 
  Tauolapp::Tauola::setEtaK0sPi(0,0,0); // switches to decay eta K0_S and pi0 1/0 on/off. 
  //Tauola::setTauLifetime(0.0); //new tau lifetime in mm
  //Tauola::spin_correlation.setAll(false);
  //  Log::LogDebug(true);

  // Event loop with pythia only -------------------------------------
  Tauolapp::Log::Info() << "Running event loop with pythia only..." << endl;

  double rats=0., rats2=0.;

  for (int iEvent = 0; iEvent < NumberOfEvents; ++iEvent) {
    if (iEvent % 100 == 0) Tauolapp::Log::Info() << "Event: " << iEvent << endl;
    if (!pythia.next()) continue;

    // Convert event record to HepMC
    #ifdef HEPMC_HAS_UNITS
      // explicitly specify units
      HepMC::GenEvent* HepMCEvt = new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
    #else
      HepMC::GenEvent* HepMCEvt = new HepMC::GenEvent();
    #endif

    ToHepMC.fill_next_event(pythia, HepMCEvt);

    double rat2;
    rats += hratio(HepMCEvt, &rat2);
    rats2 += rat2;

    //clean up HepMC event
    delete HepMCEvt;  
  }

  rats = rats / (double)NumberOfEvents;
  rats2 = rats2 / (double)NumberOfEvents;

  double rpyt = rats;
  double erpyt = sqrt( (rats2 - rats*rats)/ (double)NumberOfEvents );

  // Event loop with pythia and tauola -----------------------------------
  Tauolapp::Log::Info() << "Running event loop with pythia and tauola..." << endl;

  //Tauola is currently set to undecay taus. Otherwise, uncomment this line.
  pythia.particleData.readString("15:mayDecay = off");

  rats=0.; rats2=0.;

  for (int iEvent = 0; iEvent < NumberOfEvents; ++iEvent) {
    if (iEvent % 100 == 0) Tauolapp::Log::Info() << "Event: " << iEvent << endl;
    if (!pythia.next()) continue;

    // Convert event record to HepMC
    #ifdef HEPMC_HAS_UNITS
      // explicitly specify units
      HepMC::GenEvent* HepMCEvt = new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
    #else
      HepMC::GenEvent* HepMCEvt = new HepMC::GenEvent();
    #endif
    
    ToHepMC.fill_next_event(pythia, HepMCEvt);

    //ascii_io << HepMCEvt;
    //if(iEvent < 2) {
    //  cout << endl << "Event record before tauola:" << endl << endl;
    //  ascii_io1 << HepMCEvt;
    //}

    //run TAUOLA on the event
    Tauolapp::TauolaHepMCEvent * t_event = new Tauolapp::TauolaHepMCEvent(HepMCEvt);
    //Since we let Pythia decay taus, we have to undecay them first.
    //t_event->undecayTaus();
    //ascii_io << HepMCEvt;

    t_event->decayTaus();

    //ascii_io << HepMCEvt;
    //if(iEvent < 2) {
    //  cout << endl << "Event record after tauola:" << endl << endl;
    //  ascii_io1 << HepMCEvt;
    //}

    delete t_event;
    Tauolapp::Log::Debug(5) << "helicites =  " << Tauolapp::Tauola::getHelPlus() << " "
                  << Tauolapp::Tauola::getHelMinus()
                  << " electroweak wt= " << Tauolapp::Tauola::getEWwt() << endl;

    //print some events at the end of the run
    //if(iEvent>=NumberOfEvents-5){
    //  Log::RedirectOutput(Log::Info());
    //  pythia.event.list();
    //  HepMCEvt->print();
    //  Log::RevertOutput();
    //}

    double rat2;
    rats += hratio(HepMCEvt, &rat2);
    rats2 += rat2;

    //clean up HepMC event
    delete HepMCEvt;
  }

  rats = rats / (double)NumberOfEvents;
  rats2 = rats2 / (double)NumberOfEvents;
  double ertau = sqrt( (rats2 - rats*rats)/ (double)NumberOfEvents );

  cout.precision(6);
  cout << "******************************************************" << endl;
  cout << "* f + fbar  -> Z0 + W+/-                             *" << endl;
  cout << "* with Z0 -> tau+ tau- and W+/- -> tau+/- nutau      *" << endl;
  cout << "* E(hadrons) / E(TAU) ratio                          *" << endl;
  cout << "*   pythia = " << rpyt << "     tauola = " << rats 
       << "          *" << endl;
  cout << "* erpythia = " << erpyt << " ertauola = " << ertau 
       << "        *" << endl;
  cout << "******************************************************" << endl;

  ofstream testi("testi.dat");

  testi << "tauolapp_test1 1  " << rpyt << "    " << erpyt << " " << std::endl;
  testi << "tauolapp_test1 2  " << rats << "    " << ertau << " " << std::endl;

  testi.close();

  Tauolapp::Log::RedirectOutput(Tauolapp::Log::Info());
  pythia.statistics();
  Tauolapp::Log::RevertOutput();
}
