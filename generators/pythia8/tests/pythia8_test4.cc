// #@# p p --> (Z -> tau+ tau-)  (W -> tau nutaubar) X,
// #@#
// #@# tau --> nu hadron(s),
// #@#
// #@# 1: average E(hadron(s))/E(tau) as given by PYTHIA

//pythia header files
#ifdef PYTHIA8NEWVERS
  #include "Pythia8/Pythia.h"
  #include "Pythia8/Pythia8ToHepMC.h"
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
  // Initialisation of pythia
#ifdef PYTHIA8NEWVERS
  HepMC::Pythia8ToHepMC ToHepMC;
#else
  HepMC::I_Pythia8 ToHepMC;
#endif
  Pythia pythia;
  
  // suppress full listing of first events in pythia8 > 160
  pythia.readString("Next:numberShowEvent = 0");
  
  //HepMC::IO_AsciiParticles ascii_io("example_PythiaParticle.dat",std::ios::out);
  //HepMC::IO_AsciiParticles ascii_io1("cout",std::ios::out);
  
  int NumberOfEvents = 1000;
  if(argc>3) NumberOfEvents = atoi(argv[3]);
  
  bool ShowersOn = true;
  if(argc>2) ShowersOn = atoi(argv[2]);
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
  //pythia.readFile(argv[1]);

  //pythia.readString("WeakSingleBoson:ffbar2gmZ = on");

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
  pythia.init( -2212, -2212, 14000.0); //proton proton collisions

  // Event loop -----------------------------------------------------

  double rats=0., rats2=0.;

  for (int iEvent = 0; iEvent < NumberOfEvents; ++iEvent) {
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

  cout.precision(6);
  cout << "******************************************************" << endl;
  cout << "* f + fbar  -> Z0 + W+/-                             *" << endl;
  cout << "* with Z0 -> tau+ tau- and W+/- -> tau+/- nutau      *" << endl;
  cout << "* E(hadrons) / E(TAU) ratio                          *" << endl;
  cout << "*   pythia = " << rpyt
       << "          *" << endl;
  cout << "* erpythia = " << erpyt
       << "        *" << endl;
  cout << "******************************************************" << endl;

  ofstream testi("testi_pythia8.dat");
  testi << "pythia8_test4 1  " << rpyt << "    " << erpyt << " " << std::endl;

  pythia.statistics();
}
