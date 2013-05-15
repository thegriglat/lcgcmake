C#@# 1: Cross section [mb] of Black Hole production.
C#@#  
C#@#    Parameters of the black hole production model (see CERN-TH/2003-170) are specified in 
C#@#    http://svnweb.cern.ch/world/wsvn/GENSER/GENSER2/tests/trunk/examples/charybdis_test1.F


 
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      IMPLICIT INTEGER(I-N)
      INTEGER PYK,PYCHGE,PYCOMP
      external pydata
      EXTERNAL CHDATA

C...To reset Charybdis parameters via common
      INCLUDE 'charybdis1003.inc'

C...Commonblocks.
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      COMMON/PYDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/PYDAT2/KCHG(500,4),PMAS(500,4),PARF(2000),VCKM(4,4)
      COMMON/PYDAT3/MDCY(500,3),MDME(8000,2),BRAT(8000),KFDP(8000,5)
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(500),KFIN(2,-40:40),CKIN(200)
      COMMON/PYPARS/MSTP(200),PARP(200),MSTI(200),PARI(200)
      SAVE /PYJETS/,/PYDAT1/,/PYDAT2/,/PYDAT3/,/PYSUBS/,/PYPARS/
C...Generation and cross section statistics.
      COMMON /PYINT5/ NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      INTEGER         ITEST/1/
C...Local arrays.
      DIMENSION PSUM(5),PINI(6),PFIN(6)

C---CHARYBDIS PARAMETERS CAN ALSO BE RESET HERE
      TOTDIM=8
      YRCSEC=.TRUE.
      RMBOIL=.TRUE.
      RMMINM=200.D0
      CALL PYINIT('USER','p','p',14000.0D0)
      DO 180 IEV=1,1000
         CALL PYEVNT
         IF (IEV.LE.1) CALL PYLIST(1)
 180  CONTINUE
       CALL PYSTAT(1)
c...Printing the total cross section and its uncerainty to testi.dat:
c     Opening the file for output:
      OPEN(unit = 10, file = 'testi.dat', status = 'unknown')
      WRITE(10,100) ITEST, XSEC(0,3),XSEC(0,3)/sqrt(dble(NGEN(0,3)))
      CLOSE(10)
100   FORMAT('charybdis_test1',I3,2(1PE15.6))
 
      RETURN
      END

CDECK  ID>, CHDATA.
*CMZ :-        -21/08/06  10.33.53  by  Peter Richardson
*-- Author :    
C-----------------------------------------------------------------------
      BLOCK DATA CHDATA
C-----------------------------------------------------------------------
C    BLOCK DATA TO SET INITIAL VALUES OF PARAMETERS
C-----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'charybdis1003.inc'
C--Les Houches run common block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)
C--event common block
C--Set MPLNCK and define what is meant by it:
C--MSSDEF=1 means M_GT, MSSDEF=2 means M_DL and MSSDEF=3 means M_D
      DATA MPLNCK /1000.0D0/
      DATA MSSDEF /2/
C--Set number of dimensions (number of EXTRA dimensions is n=TOTDIM-4)
C--TOTDIM can be in the range 6-11
      DATA TOTDIM/6/
C--Use Giddings+Thomas momentum scale for calling pdfs?
C--(See page 12 of hep-ph/0106219)
      DATA GTSCA /.FALSE./
C--Set mass window for black holes produced
      DATA  MINMSS /5000.0D0/
      DATA  MAXMSS /14000.0D0/
C--Set NBODY decay of BH remnant - NBODY can be in range 2-5.
      DATA NBODY /2/
C--Turn time variation of BH Hawking temperature in decay on or off
      DATA TIMVAR /.TRUE./
C--Set which decay products are to be used:
C--MSSDEC=1 gives no heavy particles
C--MSSDEC=2 gives t, W and Z as well
C--MSSDEC=3 gives t, W, Z and Higgs as well  
      DATA MSSDEC /3/
C--Turn grey-body factors on/off
      DATA GRYBDY /.TRUE./
C--Turn kinematic cut-off of decay on (rather than M=MPLANCK cut-off)
      DATA KINCUT /.FALSE./
C--BW mod 16/08/06: new parameters for version 1.003
C--Use Yoshino-Rychkov factors in cross-section
      DATA YRCSEC /.FALSE./
C--Max Hawking temperature
      DATA THWMAX /1000.0D0/
C--Remnant decay model: boiling at THWMAX
      DATA RMBOIL /.FALSE./
C--Min BH mass, ends boiling
      DATA RMMINM /1000.D0/
C--print out option (0=no printout, 1 =errors only, 2=errors+info)
      DATA IBHPRN /1/
C--pdf's for the beams (use the generator default)
C--MUST BE THE SAME FOR BOTH BEAMS
      DATA PDFGUP /-1,-1/
      DATA PDFSUP /-1,-1/
C--Beam particles and energies (only proton and/or antiproton)
      DATA IDBMUP /2212,2212/
      DATA EBMUP /7000.0D0,7000.0D0/
      END

