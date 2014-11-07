// -*- C++ -*-
#include "Rivet/Analysis.hh"
#include "Rivet/Projections/FinalState.hh"
#include "Rivet/Projections/ZFinder.hh"
#include "Rivet/Projections/FastJets.hh"
/// @todo Include more projections as required, e.g. ChargedFinalState, FastJets, ZFinder...

namespace Rivet {

  using namespace Cuts;


  class GENSER_MC_ZJETS : public Analysis {
  public:

    /// Constructor
    GENSER_MC_ZJETS()
      : Analysis("GENSER_MC_ZJETS")
    {    }


  public:

    /// @name Analysis methods
    //@{

    /// Book histograms and initialise projections before the run
    void init() {

      FinalState fs;
      Cut cut = etaIn(-2.4,2.4) & (pT >= 25.0*GeV);
//      ZFinder zfinder(fs, -2.4, 2.4, 25*GeV, PID::ELECTRON, 65*GeV, 115*GeV, 0.3, ZFinder::CLUSTERNODECAY, ZFinder::TRACK);
      ZFinder zfinder(fs, cut, PID::ELECTRON, 65*GeV, 115*GeV, 0.3, ZFinder::CLUSTERNODECAY, ZFinder::TRACK);
      addProjection(zfinder, "ZFinder");
      ZFinder zfinder1(fs, cut, PID::MUON, 65*GeV, 115*GeV, 0.3, ZFinder::CLUSTERNODECAY, ZFinder::TRACK);
      addProjection(zfinder1, "ZFinder1");

      FastJets jetpro(zfinder.remainingFinalState(), FastJets::ANTIKT, 0.5);
      addProjection(jetpro, "Jets");
      FastJets jetpro1(zfinder1.remainingFinalState(), FastJets::ANTIKT, 0.5);
      addProjection(jetpro1, "Jets1");


      _h_Z_pt = bookHisto1D("Z_pt", logspace(10, 10., 1000.));
      _h_jet_mult = bookHisto1D("jet_mult", 10, -0.5, 9.5);
      _h_jet_mult_norm = bookHisto1D("jet_mult_norm", 10, -0.5, 9.5);
      _h_jet1_pt = bookHisto1D("jet1_pt", logspace(10, 10., 1000.));
      _h_jet2_pt = bookHisto1D("jet2_pt", logspace(10, 10., 1000.));

    }


    /// Perform the per-event analysis
    void analyze(const Event& event) {
      const double weight = event.weight();

      const ZFinder& zfinder = applyProjection<ZFinder>(event, "ZFinder");
      const ZFinder& zfinder1 = applyProjection<ZFinder>(event, "ZFinder1");
      if (zfinder.bosons().size() != 1 && zfinder1.bosons().size() != 1) vetoEvent;
      double zpt;
      if (zfinder.bosons().size() == 1) {
        const FourMomentum& zmom = zfinder.bosons()[0].momentum();
        zpt = zmom.pt();
      }
      if (zfinder1.bosons().size() == 1) {
        const FourMomentum& zmom = zfinder1.bosons()[0].momentum();
        zpt = zmom.pt();
      }

      _h_Z_pt->fill(zpt, weight);

      Jets jets = applyProjection<FastJets>(event, "Jets").jetsByPt(20*GeV);
      if (zfinder1.bosons().size() == 1)
        jets = applyProjection<FastJets>(event, "Jets1").jetsByPt(20*GeV);

      _h_jet_mult->fill((double)(jets.size()), weight);
      _h_jet_mult_norm->fill((double)(jets.size()), weight);

      if (jets.size() > 0) { 
        _h_jet1_pt->fill(jets[0].pt(), weight);
        //_h_Z_jet1_deta->fill(zmom.eta()-jets[0].eta(), weight);
        //_h_Z_jet1_dR->fill(deltaR(zmom, jets[0].momentum()), weight);
      }

      if (jets.size() > 1) {
        _h_jet2_pt->fill(jets[1].pt(), weight);
      }

    }


    /// Normalise histograms etc., after the run
    void finalize() {

      scale(_h_jet_mult_norm, crossSection()/sumOfWeights());

      // normalize(_h_YYYY); // normalize to unity

    }

    //@}


  private:

    // Data members like post-cuts event weight counters go here


  private:

    /// @name Histograms
    //@{
    Histo1DPtr _h_Z_pt;
    Histo1DPtr _h_jet_mult;
    Histo1DPtr _h_jet_mult_norm;
    Histo1DPtr _h_jet1_pt;
    Histo1DPtr _h_jet2_pt;
    //@}

  };



  // The hook for the plugin system
  DECLARE_RIVET_PLUGIN(GENSER_MC_ZJETS);

}
