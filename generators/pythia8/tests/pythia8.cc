// Pythia8 wrapper (based on example main32.cc from Pythia8 distribution)

#ifdef PYTHIA8NEWVERS
  #include "Pythia8/Pythia.h"
  #include "Pythia8/Pythia8ToHepMC.h"
#else
  #include "Pythia.h"
  #include "HepMCInterface.h"
#endif

#include "HepMC/GenEvent.h"
// Following line to be used with HepMC 2.04 onwards.
#include "HepMC/Units.h"
#include "HepMC/IO_GenEvent.h"
using namespace Pythia8;


int main(int argc, char* argv[])
{
#ifdef PYTHIA8NEWVERS 
  HepMC::Pythia8ToHepMC ToHepMC;
#else
  HepMC::I_Pythia8 ToHepMC;
#endif

  // Check that correct number of command-line arguments
  if (argc != 3) {
    cerr << " Unexpected number of command-line arguments. \n You are"
         << " expected to provide one input and one output file name. \n"
         << " Program stopped! " << endl;
    return 1;
  }
  
  // Check that the provided input name corresponds to an existing file.
  ifstream is(argv[1]);  
  if (!is) {
    cerr << " Command-line file " << argv[1] << " was not found. \n"
         << " Program stopped! " << endl;
    return 1;
  }
  
  // Confirm that external files will be used for input and output.
  cout << " PYTHIA settings will be read from file " << argv[1] << endl;
  cout << " HepMC events will be written to file " << argv[2] << endl;

  // Interface for conversion from Pythia8::Event to HepMC one. 
  //  ToHepMC.set_crash_on_problem();
  // Specify file where HepMC events will be stored.
  HepMC::IO_GenEvent ascii_io(argv[2], std::ios::out);
 
  // Generator. 
  Pythia pythia;

  // Read in commands from external file.
  pythia.readFile(argv[1]);    

  // Extract settings to be used in the main program.
  int    nEvent    = pythia.mode("Main:numberOfEvents");
  int    nShow     = pythia.mode("Main:timesToShow");
  int    nAbort    = pythia.mode("Main:timesAllowErrors");
  bool   showCS    = pythia.flag("Main:showChangedSettings");
  bool   showAS    = pythia.flag("Main:showAllSettings");
  bool   showCPD   = pythia.flag("Main:showChangedParticleData");
  bool   showAPD   = pythia.flag("Main:showAllParticleData");
 
  // Initialization. Beam parameters set in .cmnd file.
  if (! pythia.init()) return 1;

  // List settings.
  if (showCS) pythia.settings.listChanged();
  if (showAS) pythia.settings.listAll();

  // List particle data.  
  if (showCPD) pythia.particleData.listChanged();
  if (showAPD) pythia.particleData.listAll();

  // Begin event loop.
  int nPace  = max(1, nEvent / max(1, nShow) );
  int iAbort = 0;
  
  for (int iEvent = 0; iEvent < nEvent; ++iEvent) {
    if (nShow > 0 && iEvent%nPace == 0) 
      cout << " Now begin event " << iEvent << endl;

    // Generate event. 
    if (!pythia.next()) {

      // If failure because reached end of file then exit event loop.
      if (pythia.info.atEndOfFile()) {
        cout << " Aborted since reached end of Les Houches Event File\n"; 
        break; 
      }
      
      // record failure and skip the event
      iAbort++;
      continue;

      // First few failures write off as "acceptable" errors, then quit.
      //if (++iAbort < nAbort) continue;
      //cout << " Event generation aborted prematurely, owing to error!\n"; 
      //return 1;
    }

    // Construct new empty HepMC event
      HepMC::GenEvent* hepmcevt = new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM); 
    
    // Fill HepMC event, including PDF info.
    ToHepMC.fill_next_event( pythia, hepmcevt );
    
    // Write the HepMC event to file. Done with it.
    ascii_io << hepmcevt;
    delete hepmcevt;
  }
  
  // End of event loop. Statistics. 
  pythia.statistics();

  // Done.
  return 0;
}

