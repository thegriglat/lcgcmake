C #@# 1 cross-section [mb]  subprocess 298:  f + fbar -> H+/- + H0 
C
*------------------------------------------------------------------------------
*
* Filename             : TEST_ISAJET.F
*
*==============================================================================
*
* Description :
*
C...Example program to generate higgs production events at LHC, using a 
C...SuSy spectrum calculated with ISAJET mSUGRA 
C...Made from pythia example main76.f by Mikhail Kirsanov
C...see also http://home.fnal.gov/~skands/slha.
*==============================================================================
c
C--------------- PREAMBLE: COMMON BLOCK DECLARATIONS ETC -------------
C...All real arithmetic done in double precision.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
C...The PYTHIA event record:
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
C...PYTHIA MSSM and subprocess common blocks
      COMMON/PYMSSM/IMSS(0:99),RMSS(0:99)
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(500),KFIN(2,-40:40),CKIN(200)
      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
C
C        ISAJET check declarations:
C          ISAPW1 is used to check whether ALDATA is loaded
      COMMON/ISAPW/ISAPW1
      CHARACTER*30 ISAPW1
      CHARACTER*30 ISAPW2
      DATA ISAPW2/'ALDATA REQUIRED BY FORTRAN G,H'/
C
      COMMON /SUGNU/ XNUSUG(20),INUHM
      REAL XNUSUG
      INTEGER INUHM
      SAVE /SUGNU/
C
C...EXTERNAL statement links PYDATA on most machines.
      EXTERNAL PYDATA
      EXTERNAL ALDATA
c
        real sec0, secrm0, sec, secrms
        real val, errval 

C-------------------------- PYTHIA SETUP -----------------------------


C - Number of events to generate.
      NEV=1000

C - Subprocesses: q qbar -> H+- h0
      MSEL=0
cc      MSUB(297)=1
      MSUB(298)=1
cc      MSUB(299)=1
cc      MSUB(300)=1
cc      MSUB(301)=1

C - CM energy
      ECM=14000D0

C...Switch on ISAJET SUSY: mSUGRA.
      IMSS(1)=12

C...ISAJET check:
      IF(ISAPW1.NE.ISAPW2.or.xnusug(13).lt.1000.) THEN
        PRINT*, ' MAIN77 : '
        PRINT*, ' ERROR: BLOCK DATA ALDATA HAS NOT BEEN LOADED.'
        PRINT*, ' ISAJET CANNOT RUN WITHOUT IT.'
        PRINT*, ' PLEASE READ THE FINE MANUAL FOR ISAJET. '
        STOP99
      ENDIF

C...ISASUSY parameters:
      RMSS(8)=60.  !  LM1
      RMSS(1)=250.
      RMSS(5)=10.
      RMSS(4)=1.
      RMSS(16)=0.
*
cc      RMSS(8)=85.  !  LM6
cc      RMSS(1)=400.
cc      RMSS(5)=10.
cc      RMSS(4)=1.
cc      RMSS(16)=0.

C...Switch on FeynHiggs.
ccc      IMSS(4)=3
      
C - Initialize PYTHIA
      CALL PYINIT('CMS','p','p',ECM)

C - Close the SLHA file (only used during initialization).
cc      CLOSE(LUNSPC)

c Start event loop
c
* set original (rounded) test values and its rms for current model parameters 
      sec0   = 0.28590E-11
      secrm0 = 0.28590E-13

C------------------------- GENERATE EVENTS ---------------------------
      DO 100 IEV=1,NEV
c
        CALL PYEVNT
C...Make a print of the event record for the first event.
c
        IF (IEV.eq.1) THEN 
          CALL PYLIST(2)
        ENDIF

 100  CONTINUE

C----------------------------- FINALIZE ------------------------------
C - Print info on cross sections and errors/warnings
      CALL PYSTAT(1)
c
10000 FORMAT(' cross section  = ',e15.5,' mb   +/- ',e15.5)
      sec = XSEC(0,3)
      secrms = sec/sqrt(float(NEV))
      WRITE(6,10000) sec, secrms
c
c            test output
c
      call testfileopen
      val=sec
      errval=secrms
      call testfile('isajet_test1', 1, val, errval)
      call testfileclose

      END
c
      include 'aldata.f'
