// #@# p p- --> (Z -> e+ e- gammas),
// #@#
// #@# 1: average E(e+ + e-) / E(e+ + e- + gammas) ratio as given by PHOTOS EXP, multiple photon radiation


/**
 * Example of use of photos C++ interface. Pythia events are
 * generated first and photos used for FSR.
 */

//pythia header files
#if PYTHIA8_VERSION >= 180
  #include "Pythia8/Pythia.h"
  #include "Pythia8ToHepMC.h"
#else
  #include "Pythia.h"
  #include "HepMCInterface.h"
#endif

//PHOTOS header files
#include "Photos/Photos.h"
#include "Photos/PhotosHepMCEvent.h"
#include "Photos/Log.h"
typedef Photospp::Log Log; //We're using Photos version of Log class

using namespace std;
using namespace Pythia8;

bool ShowersOn=true;
unsigned long NumberOfEvents = 1000;

// Calculates energy ratio between (l + bar_l) and (l + bar_l + X)
double calculate_ratio(HepMC::GenEvent *evt, double *ratio_2)
{
	double ratio = 0.0;
	for(HepMC::GenEvent::particle_const_iterator p=evt->particles_begin();p!=evt->particles_end(); p++)
	{
		// Search for Z
		if( (*p)->pdg_id() != 23 ) continue;

		// Ignore this Z if it does not have at least two daughters
		if( !(*p)->end_vertex() || (*p)->end_vertex()->particles_out_size() < 2 ) continue;

		// Sum all daughters other than photons
		double sum = 0.0;
		for(HepMC::GenVertex::particle_iterator pp = (*p)->end_vertex()->particles_begin(HepMC::children);
		    pp != (*p)->end_vertex()->particles_end(HepMC::children);
		    ++pp)
		{
		   // (*pp)->print();
		   if( (*pp)->pdg_id() != 22 ) sum += (*pp)->momentum().e();
		}

		// Calculate ratio and ratio^2
		ratio    = sum     /   (*p)->momentum().e();
		*ratio_2 = sum*sum / ( (*p)->momentum().e() * (*p)->momentum().e() );

		// Assuming only one Z decay per event
		return ratio;
	}
	return 0.0;
}

int main(int argc,char **argv)
{

	// Initialization of pythia
#if PYTHIA8_VERSION >= 180
	HepMC::Pythia8ToHepMC ToHepMC;
#else
        HepMC::I_Pythia8 ToHepMC;
#endif
	Pythia pythia;
	Event& event = pythia.event;
	//pythia.settings.listAll();
	
        // suppress full listing of first events in pythia8 > 160
        //pythia.readString("Next:numberShowEvent = 0");

        pythia.readString("Next:numberShowEvent = 0");

	if(!ShowersOn)
	{
		//pythia.readString("HadronLevel:all = off");
		pythia.readString("HadronLevel:Hadronize = off");
		pythia.readString("SpaceShower:QEDshower = off");
		pythia.readString("SpaceShower:QEDshowerByL = off");
		pythia.readString("SpaceShower:QEDshowerByQ = off");
	}
	pythia.readString("PartonLevel:ISR = on");
	pythia.readString("PartonLevel:FSR = off");

        pythia.readString("WeakBosonAndParton:qqbar2gmZg = on");
        pythia.readString("WeakBosonAndParton:qg2gmZq = on");
        pythia.readString("PhaseSpace:pTHatMin = 19.");
	pythia.readString("23:onMode = off");
	pythia.readString("23:onIfAny = 11");
	
        //LHC initialization.
        if (!pythia.init( 2212, 2212, 14000.)) return 1;

        Photospp::Photos::setSeed( 1234 , 1234); 
	Photospp::Photos::initialize();

	// Turn on NLO corrections - only for Photos 3.2 or higher

	//Photospp::setMeCorrectionWtForZ(zNLO);
	//Photospp::maxWtInterference(4.0);
	//Photospp::iniInfo();

	Log::SummaryAtExit();
	cout.setf(ios::fixed);

	double ratio_exp   = 0.0, ratio_alpha   = 0.0;
	double ratio_exp_2 = 0.0, ratio_alpha_2 = 0.0;
	double buf = 0.0;

	Photospp::Photos::setDoubleBrem(true);
	Photospp::Photos::setExponentiation(true);
	Photospp::Photos::setInfraredCutOff(0.000001);
	
	Log::Info() << "---------------- First run - EXP ----------------" <<endl;

	// Begin event loop
	for(unsigned long iEvent = 0; iEvent < NumberOfEvents; ++iEvent)
	{
		if(iEvent%10000==0) Log::Info()<<"Event: "<<iEvent<<"\t("<<iEvent*(100./NumberOfEvents)<<"%)"<<endl;
		if (!pythia.next()) continue;

                // HepMC installed on CERN AFS by default have MeV as energy units
                // (ATLAS standard...), though default HepMC units are GeV. For
                // this reason, if the first line below is used, in pythia8
                // versions > 165 HepMC record will be in MeV
                // and we will have incorrect results

                //HepMC::GenEvent* hepmcevt = new HepMC::GenEvent();
                HepMC::GenEvent* HepMCEvt =
                  new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
		ToHepMC.fill_next_event(event, HepMCEvt);
		//HepMCEvt->print();

		//Log::LogPhlupa(1,3);

		// Call photos
		Photospp::PhotosHepMCEvent evt(HepMCEvt);
		evt.process();

		ratio_exp   += calculate_ratio(HepMCEvt,&buf);
		ratio_exp_2 += buf;

		//HepMCEvt->print();

		// Clean up
		delete HepMCEvt;
	}

	ratio_exp   = ratio_exp   / (double)NumberOfEvents;
	ratio_exp_2 = ratio_exp_2 / (double)NumberOfEvents;

	ratio_alpha   = ratio_alpha   / (double)NumberOfEvents;
	ratio_alpha_2 = ratio_alpha_2 / (double)NumberOfEvents;

	double err_exp   = sqrt( (ratio_exp_2   - ratio_exp   * ratio_exp  ) / (double)NumberOfEvents );
	double err_alpha = sqrt( (ratio_alpha_2 - ratio_alpha * ratio_alpha) / (double)NumberOfEvents );
	
	cout.precision(6);
	cout.setf(ios::fixed);
	cout << "********************************************************" << endl;
	cout << "* Z -> l + bar_l + gammas                              *" << endl;
	cout << "* E(l + bar_l) / E(l + bar_l + gammas) ratio           *" << endl;
	cout << "*                                                      *" << endl;
	cout << "* PHOTOS - EXP:          " << ratio_exp   <<" +/- "<<err_exp  <<"      *" << endl;
	cout << "* PHOTOS - ALPHA ORDER:  " << ratio_alpha <<" +/- "<<err_alpha<<"      *" << endl;
	cout << "********************************************************" << endl;

        // The output below is disabled because these results have no physical meaning
        // QED radiation is to be performed only simultaneously with QCD showering
        // This test is a technical test of photos++

        // ofstream testi("testi.dat");

        // testi << "photospp_test1 1  " << ratio_exp << "    " << err_exp << " " << std::endl;
        // testi << "photospp_test1 2  " << ratio_alpha  << "    " << err_alpha << " " << std::endl;

        // testi.close();
	
	Log::RedirectOutput(Log::Info());
        pythia.statistics();
        Log::RevertOutput();
}
