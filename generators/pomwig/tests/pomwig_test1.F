C#@# 1: Cross section [pb] for the process: double pomeron -> Higgs at LHC.
C#@#    Higgs mass is 115 GeV, using H1 2006 Pomeron Fit A. MAXEV=1000.
C#@# 

      PROGRAM HWIGPR
C---COMMON BLOCKS ARE INCLUDED AS FILE HERWIG61.INC
      INCLUDE 'HERWIG65.INC'
      INTEGER N
      INTEGER SEED
C---MAX NUMBER OF EVENTS THIS RUN
      MAXEV=1000
C---BEAM PARTICLES
      PART1='E-      '
      PART2='E-    '
C---BEAM MOMENTA
      PBEAM1=7000.
      PBEAM2=7000.
C---INITIALISE OTHER COMMON BLOCKS
      CALL HWIGIN
C---USER CAN RESET PARAMETERS AT
C   THIS POINT, OTHERWISE DEFAULT
C   VALUES IN HWIGIN WILL BE USED.
C --- select H1 pomeron structure function
       MODPDF(1)=-1
C also select for second beam particle in case of double pomeron
       MODPDF(2)=-1
C --- Structure functions
C      AUTPDF(1)='GRVLO'
C      MODPDF(1)=4
c      AUTPDF(2)='GRVLO'
c      MODPDF(2)=4
C---PROCESS
C      IPROC=11705 ! bbar 
      iproc=11605 ! Higgs
C      iproc=11500 ! dijets
      MAXPR =1
      RMASS(201)=115            ! Higgs Mass
      NSTRU=12
      PTMIN=30.                 
      NFLAV=6
      IOPREM=0
      MAXER=999999
c for pomwig, Q2WW = tmin,tmax
c yww = xpommin,xpommax
      Q2WWMN=1.E-6
      Q2WWMX=1.
      YWWMIN=1.E-6
      YWWMAX=.1
c set the seeds!
      NRN(1)=9987659
      NRN(2)=7659465
C---COMPUTE PARAMETER-DEPENDENT CONSTANTS
      CALL HWUINC
C---CALL HWUSTA TO MAKE ANY PARTICLE STABLE
      CALL HWUSTA('PI0     ')
C---USER'S INITIAL CALCULATIONS
      CALL HWABEG
C---INITIALISE ELEMENTARY PROCESS
      CALL HWEINI
C---LOOP OVER EVENTS
      DO 100 N=1,MAXEV
C---INITIALISE EVENT
         CALL HWUINE
C---GENERATE HARD SUBPROCESS
         CALL HWEPRO
C---GENERATE PARTON CASCADES
         CALL HWBGEN
C---DO HEAVY OBJECT DECAYS
         CALL HWDHOB
C---DO CLUSTER FORMATION
         CALL HWCFOR
C---DO CLUSTER DECAYS
         CALL HWCDEC
C---DO UNSTABLE PARTICLE DECAYS
         CALL HWDHAD
C---DO HEAVY FLAVOUR HADRON DECAYS
         CALL HWDHVY
C---ADD SOFT UNDERLYING EVENT IF NEEDED
         CALL HWMEVT
C---FINISH EVENT
         CALL HWUFNE
C---USER'S EVENT ANALYSIS
         CALL HWANAL
  100 CONTINUE

C---TERMINATE ELEMENTARY PROCESS
      CALL HWEFIN

C---USER'S TERMINAL CALCULATIONS
      CALL HWAEND
      STOP
      END
C----------------------------------------------------------------------

C----------------------------------------------------------------------
      SUBROUTINE HWABEG
C     USER'S ROUTINE FOR INITIALIZATION
      INCLUDE 'HERWIG65.INC'
      double precision XPQ(-6:6),X,Q2
      double precision F2(2),FL(2),C2(2),CL(2)
      integer ifit
C INITIALISE H1 POMERON
         Q2=75
         X=0.1
         WRITE(*,*) 'INITIALISING H1 POMERON STRUCTURE'
         IF (NSTRU.EQ.9) THEN
            ifit=5
            call QCD_1994(X,Q2,XPQ,ifit)
         ELSEIF (NSTRU.EQ.12) THEN
            ifit=1
            call QCD_2006(X,Q2,ifit,XPQ,f2,fl,c2,cl)
         ELSEIF (NSTRU.EQ.14) THEN
            ifit=2
            call QCD_2006(X,Q2,ifit,XPQ,f2,fl,c2,cl)
         ENDIF
      RETURN
      END
C----------------------------------------------------------------------
      
C----------------------------------------------------------------------
      SUBROUTINE HWAEND
C     USER'S ROUTINE FOR TERMINAL CALCULATIONS, HISTOGRAM OUTPUT, ETC
#include "HERWIG65.INC"
      real val, errval
      DOUBLE PRECISION RNWGT,SPWGT,ERWGT

      val = AVWGT ! total cross section (nb)
      RNWGT=1./FLOAT(NWGTS)
      SPWGT=SQRT(MAX(WSQSUM*RNWGT-AVWGT**2,ZERO))
      ERWGT=SPWGT*SQRT(RNWGT)
      errval = ERWGT

      OPEN(unit = 10, file = 'testi.dat', status = 'unknown')
C...  Printing the total accepted cross section and its uncerainty to testi.dat:
      WRITE(10,100) 1,val*1000,errval*1000
      CLOSE(10)
C
100   FORMAT('pomwig_test1',I3,2(1PE15.6))
      RETURN
      END
C----------------------------------------------------------------------
      
C----------------------------------------------------------------------
      SUBROUTINE HWANAL
      RETURN
      END














