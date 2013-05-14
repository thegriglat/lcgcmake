//--------------------------------------------------------------------------
#ifdef  _WIN32  // This version is for Windows MS Visual C++ only.
#ifndef HERWIG_WRAPPER_H
#define HERWIG_WRAPPER_H

//////////////////////////////////////////////////////////////////////////
// Matt.Dobbs@Cern.CH, April 2002
// Wrapper for FORTRAN version of Herwig
//
// _WIN32 by Anton.Karneyeu@cern.ch (August 2008)
//
//////////////////////////////////////////////////////////////////////////
// 

#include <ctype.h>

//--------------------------------------------------------------------------
// HERWIG Common Block Declarations

//        COMMON/HWPROC/EBEAM1,EBEAM2,PBEAM1,PBEAM2,IPROC,MAXEV
struct HWPROC_DEF {
	double EBEAM1,EBEAM2,PBEAM1,PBEAM2;
        int IPROC,MAXEV;
};


//        CHARACTER*8 PART1,PART2
//        COMMON/HWBMCH/PART1,PART2
struct HWBMCH_DEF {
	char PART1[8],PART2[8];
};


//  COMMON/HWEVNT/AVWGT,EVWGT,GAMWT,TLOUT,WBIGST,WGTMAX,WGTSUM,WSQSUM,
//       & IDHW(NMXHEP),IERROR,ISTAT,LWEVT,MAXER,MAXPR,NOWGT,NRN(2),NUMER,
//       & NUMERU,NWGTS,GENSOF
const int herwig_hepevt_size = 4000;
struct HWEVNT_DEF {
	double AVWGT,EVWGT,GAMWT,TLOUT,WBIGST,WGTMAX,WGTSUM,WSQSUM;
	int IDHW[herwig_hepevt_size],IERROR,ISTAT,LWEVT,MAXER,MAXPR;
	int NOWGT,NRN[2],NUMER,NUMERU,NWGTS;
	int GENSOF; //Beware! in F77 this is logical
};


//  C Basic parameters (and quantities derived from them)
//        COMMON/HWPRAM/AFCH(16,2),ALPHEM,B1LIM,BETAF,BTCLM,CAFAC,CFFAC,
//       & CLMAX,CLPOW,CLSMR(2),CSPEED,ENSOF,ETAMIX,F0MIX,F1MIX,F2MIX,GAMH,
//       & GAMW,GAMZ,GAMZP,GEV2NB,H1MIX,PDIQK,PGSMX,PGSPL(4),PHIMIX,PIFAC,
//       & PRSOF,PSPLT(2),PTRMS,PXRMS,QCDL3,QCDL5,QCDLAM,QDIQK,QFCH(16),QG,
//       & QSPAC,QV,SCABI,SWEIN,TMTOP,VFCH(16,2),VCKM(3,3),VGCUT,VQCUT,
//       & VPCUT,ZBINM,EFFMIN,OMHMIX,ET2MIX,PH3MIX,GCUTME,
//       & IOPREM,IPRINT,ISPAC,LRSUD,LWSUD,MODPDF(2),NBTRY,NCOLO,NCTRY,
//       & NDTRY,NETRY,NFLAV,NGSPL,NSTRU,NSTRY,NZBIN,IOP4JT(2),NPRFMT,
//       & AZSOFT,AZSPIN,CLDIR(2),HARDME,NOSPAC,PRNDEC,PRVTX,SOFTME,ZPRIME,
//       & PRNDEF,PRNTEX,PRNWEB

struct HWPRAM_DEF {
	double AFCH[2][16],ALPHEM,B1LIM,BETAF,BTCLM,CAFAC,CFFAC,
	    CLMAX,CLPOW,CLSMR[2],CSPEED,ENSOF,ETAMIX,F0MIX,F1MIX,F2MIX,GAMH,
	    GAMW,GAMZ,GAMZP,GEV2NB,H1MIX,PDIQK,PGSMX,PGSPL[4],PHIMIX,PIFAC,
	    PRSOF,PSPLT[2],PTRMS,PXRMS,QCDL3,QCDL5,QCDLAM,QDIQK,QFCH[16],QG,
	    QSPAC,QV,SCABI,SWEIN,TMTOP,VFCH[2][16],VCKM[3][3],VGCUT,VQCUT,
	    VPCUT,ZBINM,EFFMIN,OMHMIX,ET2MIX,PH3MIX,GCUTME;
	int IOPREM,IPRINT,ISPAC,LRSUD,LWSUD,MODPDF[2],NBTRY,NCOLO,NCTRY,
	    NDTRY,NETRY,NFLAV,NGSPL,NSTRU,NSTRY,NZBIN,IOP4JT[2],NPRFMT;
	int AZSOFT,AZSPIN,CLDIR[2],HARDME,NOSPAC,PRNDEC,PRVTX,SOFTME,
	    ZPRIME,PRNDEF,PRNTEX,PRNWEB; //Beware! in F77 these are logical
};


extern "C" HWPROC_DEF HWPROC;
extern "C" HWBMCH_DEF HWBMCH;
extern "C" HWEVNT_DEF HWEVNT;
extern "C" HWPRAM_DEF HWPRAM;

#define hwproc HWPROC
#define hwbmch HWBMCH
#define hwevnt HWEVNT
#define hwpram HWPRAM

//--------------------------------------------------------------------------
// HERWIG routines declaration

#define hwigin HWIGIN  // initialise other common blocks
#define hwigup HWIGUP  // initialise HepUP run common block
#define hwuinc HWUINC  // compute parameter-dependent constants
#define hwusta HWUSTA  // call hwusta to make any particle stable
#define hweini HWEINI  // initialise elementary process
#define hwuine HWUINE  // initialise event
#define hwepro HWEPRO  // generate HERWIG hard subprocess
#define hwupro HWUPRO  // read USER hard subprocess from HepUP event common
#define hwbgen HWBGEN  // generate parton cascades
#define hwdhob HWDHOB  // do heavy object decays
#define hwcfor HWCFOR  // do cluster hadronization
#define hwcdec HWCDEC  // do cluster decay
#define hwdhad HWDHAD  // do unstable particle decays
#define hwdhvy HWDHVY  // do heavy flavour decays
#define hwmevt HWMEVT  // add soft underlying event if needed 
#define hwufne HWUFNE  // event generation completed, wrap up event .... 
#define hwefin HWEFIN  // terminate elementary process

#define hwudpr HWUDPR  // prints out particle/decay properties
#define hwuepr HWUEPR  // prints out event data
#define hwupup HWUPUP  // prints out HepEUP user common block event data
#define hwegup HWEGUP  // terminal calculations to replace HWEFIN for HepUP 

extern "C" {
  void __stdcall HWIGIN(void);
  void __stdcall HWIGUP(void);
  void __stdcall HWUINC(void);
  void __stdcall HWUSTA(const char*,int);
  void __stdcall HWEINI(void);
  void __stdcall HWUINE(void);
  void __stdcall HWEPRO(void);
  void __stdcall HWUPRO(void);
  void __stdcall HWBGEN(void);
  void __stdcall HWDHOB(void);
  void __stdcall HWCFOR(void);
  void __stdcall HWCDEC(void);
  void __stdcall HWDHAD(void);
  void __stdcall HWDHVY(void);
  void __stdcall HWMEVT(void);
  void __stdcall HWUFNE(void);
  void __stdcall HWEFIN(void);
  void __stdcall HWUDPR(void);
  void __stdcall HWUEPR(void);
  void __stdcall HWUPUP(void);
  void __stdcall HWEGUP(void);
}

//--------------------------------------------------------------------------
// HERWIG block data
// ( with gcc it works to initialize the block data by calling 
//   "hwudat();" at beginning. )

#define hwudat HWUDAT
extern "C" {
  void __stdcall HWUDAT(void);
}

#endif  // HERWIG_WRAPPER_H
#endif  // _WIN32
//--------------------------------------------------------------------------
