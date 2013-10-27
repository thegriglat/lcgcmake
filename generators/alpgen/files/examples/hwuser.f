      program hwigpr
      include "HERWIG65.INC"
      INCLUDE "pyt_cms_short.inc"  ! not #include: preprocessor crashes on
      common/mkpars/nev            ! long names. Hence, no dependencies
      integer nev
      COMMON/EVPROFILE/NEVTYPE(10)
      INTEGER NEVTYPE
      INTEGER IEV, ITIME(10)
      REAL TOLD, TNEW
      EXTERNAL HWUDAT

      CALL COLLIDERINI
      CALL ANZJETSINI

C---MAX NUMBER OF EVENTS THIS RUN
      MAXEV=1000
      nev = MAXEV
C---BEAM PARTICLES
      PART1='P'
      PART2='P'
C---BEAM MOMENTA
      PBEAM1=7000.
      PBEAM2=7000.
C---PROCESS
c      IPROC=2150
c---process - don't change
      iproc=-100
C---INITIALISE OTHER COMMON BLOCKS
      CALL HWIGIN

C---USER CAN RESET PARAMETERS AT
C   THIS POINT, OTHERWISE DEFAULT
C   VALUES IN HWIGIN WILL BE USED.

C---COMPUTE PARAMETER-DEPENDENT CONSTANTS
      CALL HWUINC
C---CALL HWUSTA TO MAKE ANY PARTICLE STABLE
C      CALL HWUSTA('PI0     ')
C---USER'S INITIAL CALCULATIONS
      CALL HWABEG
C---INITIALISE ELEMENTARY PROCESS
      CALL HWEINI

C...Starting time
      CALL PYTIME(ITIME)
      TOLD=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)

C---LOOP OVER EVENTS -----------------------------
      DO 100 IEV=1,MAXEV
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
      CALL HWANAL(IEV)

      if(IEV.eq.1) write(6,661) MAXEV, 250.*float(MAXEV)/10000.

  100 CONTINUE ! -------------------------------

C---TERMINATE ELEMENTARY PROCESS
      CALL HWEFIN

C...Finishing time
      CALL PYTIME(ITIME)
      TNEW=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)

      write(6,666) MAXEV, TNEW-TOLD, AVWGT

661   format(/I6, ' Events, will take about ', f8.1,
     &       ' seconds on P4-1600'/)

666   format(/ I6, ' Events generated in ', f10.4,
     &       ' seconds, cross section (nb) = ', f8.4)

C---USER'S TERMINAL CALCULATIONS
      CALL HWAEND
      STOP
      END

C----------------------------------------------------------------------
      SUBROUTINE HWABEG
C     USER'S ROUTINE FOR INITIALIZATION
C----------------------------------------------------------------------
  999 END                                         
C----------------------------------------------------------------------
      SUBROUTINE HWANAL(IEV)
C user analysis routine
C----------------------------------------------------------------------
      integer IEV
      INCLUDE "pyt_cms_short.inc"
cc      if(IEV.le.1) call pylist(5)
      call pyhepc(2)
      if(IEV.le.1) call pylist(1)

        CALL ANZJETS

  999 END  
C----------------------------------------------------------------------
      SUBROUTINE HWAEND
C  user routine to output analysis results
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      COMMON/EVPROFILE/NEVTYPE(10)
      INTEGER NEVTYPE
      common/mkpars/nev
      integer nev
      INTEGER lun
      real val, errval
      DOUBLE PRECISION RNWGT,SPWGT,ERWGT

      call anzjetsout            !for zjets analysis

      lun = 36
      OPEN(lun, file='testi.dat', status='UNKNOWN', form='formatted')

      val = AVWGT ! total cross section (nb)
      RNWGT=1./FLOAT(NWGTS)
      SPWGT=SQRT(MAX(WSQSUM*RNWGT-AVWGT**2,ZERO))
      ERWGT=SPWGT*SQRT(RNWGT)
      errval = ERWGT
      call testfile('alpgen_test1', 1, val, errval)

      val = float(nevtype(4))/float(nev) ! fraction with > 1 lept. and > 1 jets
      errval = 0.
      if(nevtype(4).gt.0) then
        errval = val*sqrt(float(nevtype(4)))/float(nevtype(4))
      endif

      call testfile('alpgen_test1', 2, val, errval)
      close(lun)
 999  END

* MK: this routine is modified in order to understand some additional
* HERWIG status codes when converting HEPEVT to PYTHIA record.

      INCLUDE "pyhepc_herwig.f"

