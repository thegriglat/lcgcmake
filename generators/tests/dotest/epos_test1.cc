//#@# 1: Average multiplicity at 7 TeV
//
// May be in future should take the main program code from the installation
// leaving here only PrintTestEvent

#include "crmchep.h"

#ifndef __WITHOUTBOOST__
namespace io = boost::iostreams;
#endif
using namespace std;

void TestEvent(HepMC::IO_HEPEVT& hepevtio)
{

#ifdef HEPMC_HAS_UNITS
  HepMC::GenEvent* evt = new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
#else
  HepMC::GenEvent* evt = new HepMC::GenEvent();
#endif
  
  const bool res = hepevtio.fill_next_event(evt); // here hepevt_ a COMMON fortran block gets read in
  if (! res) {
    delete evt;
    throw std::runtime_error("!!!Could not read next event");
  }
        
  //        evt->print( std::cout );

  double Mul2=0.;
  double Pla2=0.;
  double egy2=0.;
  for (HepMC::GenEvent::particle_const_iterator p = evt->particles_begin(); p != evt->particles_end(); ++p)
     {
       if( (*p)->status()==1){
         ++Mul2;
         double eta=(*p)->momentum().pseudoRapidity();
         double pt=(*p)->momentum().perp();
         if(abs(eta)<10000){
           MeanPseudorapidity=MeanPseudorapidity+eta;
           ErrorMeanPseudorapidity=ErrorMeanPseudorapidity+eta*eta;}
         MeanPt=MeanPt+pt;
         ErrorMeanPt=ErrorMeanPt+pt*pt;
         if( abs(eta) < 0.5 )++Pla2;
         egy2=egy2+(*p)->momentum().e();
       }
     }

  TotalEnergy=TotalEnergy+egy2;
  ErrorTotalEnergy=ErrorTotalEnergy+egy2*egy2;
  Multiplicity=Multiplicity+Mul2;
  ErrorMultiplicity=ErrorMultiplicity+Mul2*Mul2;
  PlateauHeight=PlateauHeight+Pla2;
  ErrorPlateauHeight=ErrorPlateauHeight+Pla2*Pla2;

  // we also need to delete the created event from memory
  delete evt;

  return;
}

void AddEvent(const int nEvent, HepMC::IO_HEPEVT& hepevtio, HepMC::IO_GenEvent& ascii_out)
{

#ifdef HEPMC_HAS_UNITS
  HepMC::GenEvent* evt = new HepMC::GenEvent(HepMC::Units::GEV, HepMC::Units::MM);
#else
  HepMC::GenEvent* evt = new HepMC::GenEvent();
#endif
  
  const bool res = hepevtio.fill_next_event(evt); // here hepevt_ a COMMON fortran block gets read in
  if (! res) {
    delete evt;
    throw std::runtime_error("!!!Could not read next event");
  }

#ifdef HEPMC_HAS_CROSS_SECTION
  // set cross section information for this event
  HepMC::GenCrossSection theCrossSection;
  theCrossSection.set_cross_section(double(hadr5_.sigineaa));
  evt->set_cross_section(theCrossSection);
#endif

  // provide optional pdf set id numbers for CMSSW to work
  //flavour of partons and stuff. hope it's optional
  HepMC::PdfInfo pdf(0, 0, 0, 0, 0, 0, 0);
  evt->set_pdf_info(pdf);

  //Setting heavy ion infromation
  //      int   Ncoll_hard          // Number of hard scatterings
  //      int   Npart_proj          // Number of projectile participants
  //      int   Npart_targ          // Number of target participants
  //      int   Ncoll               // Number of NN (nucleon-nucleon) collisions
  //      int   spectator_neutrons           // Number of spectator neutrons
  //      int   spectator_protons            // Number of spectator protons
  //      int   N_Nwounded_collisions        // Number of N-Nwounded collisions
  //      int   Nwounded_N_collisions        // Number of Nwounded-N collisons
  //      int   Nwounded_Nwounded_collisions // Number of Nwounded-Nwounded collisions
  //      float impact_parameter        // Impact Parameter(fm) of collision
  //      float event_plane_angle       // Azimuthal angle of event plane
  //      float eccentricity            // eccentricity of participating nucleons
  //                                        in the transverse plane
  //                                        (as in phobos nucl-ex/0510031)
  //      float sigma_inel_NN           // nucleon-nucleon inelastic
  //                                        (including diffractive) cross-section

  HepMC::HeavyIon ion(-1, //cevt_.koievt, // FIXME
                      cevt_.npjevt,
                      cevt_.ntgevt,
                      cevt_.kolevt,
                      cevt_.npnevt + cevt_.ntnevt,
                      cevt_.nppevt + cevt_.ntpevt,
                      -1, //c2evt_.ng1evt, //FIXME
                      -1, //c2evt_.ng2evt, //FIXME
                      -1, //c2evt_.ikoevt, //FIXME
                      cevt_.bimevt,
                      cevt_.phievt,
                      c2evt_.fglevt,
                      hadr5_.sigineaa); //FIXME
  evt->set_heavy_ion(ion);

  // add some information to the event
  evt->set_event_number(nEvent);

  //an integer ID uniquely specifying the signal process (i.e. MSUB in Pythia)
  //evt->set_signal_process_id(20);

  //DEBUG OUTPUT
  // for (HepMC::GenEvent::particle_const_iterator p = evt->particles_begin(); p != evt->particles_end(); ++p)
  //   {
  //     (*p)->print();
  //   }

  // write the event out to the ascii file
  ascii_out << evt;
  // we also need to delete the created event from memory
  delete evt;
  return;
}

int main(int argc, char **argv)
{
  setbuf(stdout,NULL); /* set output to unbuffered */

  if (!GetOptions(argc,argv))
    throw std::runtime_error("!!!Executed without options");


  if ( gTest ) {
    gNCollision=500;
    gFirstEventNumber=0;
    gSeed=123;
    gBeamID=1;
    gTargetID=1;
    gHEModel=0;
    gBeamMomentum=3500;
    gTargetMomentum=-3500;  
  }


#ifndef __WITHOUTBOOST__
  boost::filesystem::path oldFile(gOutfileName);
  boost::filesystem::remove(oldFile); //FIXME currently truncate does not seem to work properly in boost
  io::filtering_ostream out; //top to bottom order
  if (gCompression)
    out.push(io::gzip_compressor(io::zlib::best_compression));
  out.push(io::file_descriptor_sink(gOutfileName),ios_base::trunc);
#else
  ofstream out(gOutfileName.c_str());
#endif

  // Instantiate an IO strategy for reading from HEPEVT.
  HepMC::IO_HEPEVT hepevtio;
  // Instantiate an IO strategy to write the data to file
  HepMC::IO_GenEvent ascii_out(out);


  //We need to explicitly pass this information to the
  //  HEPEVT_Wrapper.
  HepMC::HEPEVT_Wrapper::set_max_number_entries(gMaxParticles); //as used in crmc-aaa.f!!!
  HepMC::HEPEVT_Wrapper::set_sizeof_real(8); //as used in crmc-aaa.f!!!

  //This is just for initialisation
  crmc_init_f_(gSeed,gBeamMomentum,gTargetMomentum,gBeamID,
               gTargetID,gHEModel,gParamFileName.c_str());

  int iColl;
  for (iColl = gFirstEventNumber; iColl < gFirstEventNumber+gNCollision; ++iColl)
    {
      if (iColl % 1000 == 0)
        cout << " ==[crmc]==> Collision number " << iColl+1 << endl;

      // loop over collisions
      crmc_f_(gNParticles,gImpactParameter,
              gPartID[0],gPartPx[0],gPartPy[0],gPartPz[0],
              gPartEnergy[0],gPartMass[0]);

      //ids are being converted to particle data group-Ids here
      //vector<int> vecPartIds(gPartID, gPartID+gNParticles);
      //transform(vecPartIds.begin(), vecPartIds.end(), vecPartIds.begin(), IdToPdg);

      if ( gTest ) {
        if(!HepMC::HEPEVT_Wrapper::check_hepevt_consistency(std::cout))
          HepMC::HEPEVT_Wrapper::print_hepevt(std::cout);
        //Use events to test simulations
        TestEvent(hepevtio);
      }else{
        //write event to a HepMC file
        AddEvent(iColl, hepevtio, ascii_out);
      }
    }
  cout << " ==[crmc]==> Finished! " << gNCollision << " event(s) simulated." << endl;
  if ( gTest ) PrintTestEvent() ;
  return EXIT_SUCCESS;
}

/*************************************************************
 *
 *   GetOptions()  - reads command line options
 *
 **************************************************************/
bool GetOptions(int argc, char **argv){
  int c;
  ostringstream help;
  help << " crmc -s [random seed] -n [nCollisions]" << std::endl;
  help << "      -m [0=EPOS LHC, 1=EPOS 1.99"
#ifdef __QGSJET01__
       << ", 2=QGSJET01"
#endif
#ifdef __GHEISHA__
       << ", 3=Gheisha"
#endif
#ifdef __PYTHIA__
       << ", 4=Pythia 6.115"
#endif
#ifdef __HIJING__
       << ", 5=Hijing 1.38"
#endif
#ifdef __SIBYLL__
       << ", 6=Sibyll 2.1"
#endif
#ifdef __QGSJETII__
       << ", 7=QGSJETII-03"
#endif
#ifdef __Phojet__
       << ", 8=Phojet"
#endif
       << "]" << std::endl;
  help << "      -p [beam's momentum/(GeV/c)]" << std::endl;
  help << "      -P [target's momentum/(GeV/c)" << std::endl;
  help << "      -b [beam's id:   1=p, 12=C, 120=pi+, 207=Pb]" << std::endl;
  help << "      -t [target's id: 1=p, 12=C, 120=pi+, 207=Pb]" << std::endl;
  help << "      -c [path/filename of parameter/setup file]" << std::endl;
  help << "      -f [path/filename of output file]" << std::endl;
  help << "      -n [Number of events to simulate]" << std::endl;
  help << "      -N [Number of first event]" << std::endl;
  help << "      -T [Test mode for checkings 0/1 (default:0)]" << std::endl;
#ifndef __WITHOUTBOOST__
  help << "      -z [Compression 0/1 (default:0)]" << std::endl;
#endif

  while ((c = getopt (argc, argv, "s:m:p:P:b:t:c:f:n:N:T:z:h")) != -1)
    switch (c)
      {
      case 's':
        gSeed=atoi(optarg);
        break;
      case 'm':
        gHEModel=atoi(optarg);
        break;
      case 'p':
        gBeamMomentum=atof(optarg);
        break;
      case 'P':
        gTargetMomentum=atof(optarg);
        break;
      case 'b':
        gBeamID=atoi(optarg);
        break;
      case 't':
        gTargetID=atoi(optarg);
        break;
      case 'c':
        gParamFileName=optarg;
        break;
      case 'f':
        gOutfileName=optarg;
        break;
      case 'n':
        gNCollision=atoi(optarg);
        break;
      case 'N':
        gFirstEventNumber=atoi(optarg);
        break;
      case 'T':
        gTest=atoi(optarg);
        break;
      case 'z':
        gCompression=atoi(optarg);
        break;
      case 'h':
        cout << help.str() << endl;
        exit(0);
      default:
        cout << help.str() << endl;
        return false;
      }

  if ( gTest ) {
  cout << "\n          >> crmc test mode (pp@7TeV) <<\n\n" << endl;
  }else{
  cout << "\n          >> crmc with HepMC output <<\n\n"
       << "  beam id:                    " << gBeamID << "\n"
       << "  target id:                  " << gTargetID << "\n"
       << "  beam momentum:              " << gBeamMomentum << "\n"
       << "  target momentum:            " << gTargetMomentum << "\n\n"

       << "  number of collisions:       " << gNCollision << "\n"
#ifndef __WITHOUTBOOST__
       << "  use compression:            " << (gCompression?std::string("yes"):std::string("no")) << "\n"
#endif
       << "  output file name:           " << gOutfileName << "\n"
       << "  parameter file name:        " << gParamFileName << "\n"
       << "  HE model:                   " << gHEModel;
  if ( gHEModel == 0 )
    cout << " (EPOS LHC) \n";
  else if ( gHEModel == 1 )
    cout << " (EPOS 1.99) \n";
  else if ( gHEModel == 2 )
    cout << " (QGSJET01) \n";
  else if ( gHEModel == 3 )
    cout << " (Gheisha)\n ";
  else if ( gHEModel == 4 )
    cout << " (Pythia)\n ";
  else if ( gHEModel == 5 )
    cout << " (Hijing)\n ";
  else if ( gHEModel == 6 )
    cout << " (Sibyll)\n ";
  else if ( gHEModel == 7 )
    cout << " (QGSJETII) \n";
  else if ( gHEModel == 8 )
    cout << " (Phojet) \n";
  else
    {
      cout << " (unknown) \n";
      return false;
    }
  cout << endl;
  }
  cout.setf(ios::showpoint);
  cout.setf(ios::fixed);
  cout.precision(3);
  return true;
}

void PrintTestEvent()
{

  if(gBeamID<20 && gTargetID<20)
  crmc_xsection_f_(xsigtot,xsigine,xsigela,xsigdd,xsigsd
                   ,xsloela,xsigtotaa,xsigineaa,xsigelaaa);

  if(Multiplicity > 0){

    ErrorMeanPseudorapidity=sqrt(max(0.,ErrorMeanPseudorapidity
                                     -MeanPseudorapidity*MeanPseudorapidity/Multiplicity)
                                 /(max(Multiplicity-1.,Multiplicity)*Multiplicity));
    MeanPseudorapidity=MeanPseudorapidity/Multiplicity;
    ErrorMeanPt=sqrt(max(0.,ErrorMeanPt
                                     -MeanPt*MeanPt/Multiplicity)
                     /(max(Multiplicity-1.,Multiplicity)*Multiplicity));
    MeanPt=MeanPt/Multiplicity;
    ErrorMultiplicity=sqrt(max(0.,ErrorMultiplicity
                                     -Multiplicity*Multiplicity/gNCollision)
                           /(max(gNCollision-1.,double(gNCollision))*gNCollision));
    Multiplicity=Multiplicity/gNCollision;
    ErrorPlateauHeight=sqrt(max(0.,ErrorPlateauHeight
                                     -PlateauHeight*PlateauHeight/gNCollision)
                            /(max(gNCollision-1.,double(gNCollision))*gNCollision));
    PlateauHeight=PlateauHeight/gNCollision;
    ErrorTotalEnergy=sqrt(max(0.,ErrorTotalEnergy
                                     -TotalEnergy*TotalEnergy/gNCollision)
                            /(max(gNCollision-1.,double(gNCollision))*gNCollision));
    TotalEnergy=TotalEnergy/gNCollision;
    

    cout << "\n          >> Test output <<\n\n"
         << "  Total Cross Section (mb):    " << xsigtot << "\n"
         << "  Elastic Cross Section (mb):  " << xsigela << "\n"
         << "  Inelastic Cross Section (mb):" << xsigine << "\n" ;
    if((gBeamID>1 || gTargetID>1) && gBeamID<20 && gTargetID<20)
    cout << "  Inel. AA Cross Section (mb): " << xsigineaa << "\n" ;
    cout << endl;
    cout << "  Energy (GeV):                " << TotalEnergy
         <<                           " +/- " << ErrorTotalEnergy << "\n"
         << "  Multiplicity:                " << Multiplicity 
         <<                           " +/- " << ErrorMultiplicity << "\n"
         << "  PlateauHeight:               " << PlateauHeight 
         <<                           " +/- " << ErrorPlateauHeight << "\n"
         << "  MeanPseudorapidity:          " << MeanPseudorapidity 
         <<                           " +/- " << ErrorMeanPseudorapidity << "\n"
         << "  MeanPt (GeV/c):              " << MeanPt 
         <<                           " +/- " << ErrorMeanPt << "\n";
    cout << endl;
    
    ofstream testi("testi.dat");
    double val, errval;
  
    val = Multiplicity;

    errval = ErrorMultiplicity;
    testi << "epos_test1  1   " << val << " " << errval << " " << endl;

  }else{

    cout << "Error during test : no particles !" << endl;

  }

}

