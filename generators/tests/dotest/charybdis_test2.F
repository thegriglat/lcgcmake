C#@# 1: Cross section [mb] of Black Hole production.
C#@#  
C#@#    Parameters of the black hole production model (see CERN-TH/2003-170) are specified in 
C#@#    http://svnweb.cern.ch/world/wsvn/GENSER/GENSER2/tests/trunk/examples/charybdis_test2.F

      PROGRAM HWIGPR
C---COMMON BLOCKS ARE INCLUDED AS FILE HERWIG65.INC
      INCLUDE 'HERWIG65.INC'
      INCLUDE 'charybdis1003.inc'
      INTEGER N
      DOUBLE PRECISION HWRUNI
      EXTERNAL HWUDAT,HWRUNI,CHDATA
c
      integer ITEST
      real val, XNWGTS, RNWGT, SPWGT, errval
      data ITEST/1/
c
C---MAX NUMBER OF EVENTS THIS RUN
      MAXEV=1000
C---BEAM PARTICLES
      PART1='P'
      PART2='P'
C---BEAM MOMENTA
      PBEAM1=7000.0D0
      PBEAM2=7000.0D0
C---PROCESS
      IPROC=-100
C---INITIALISE OTHER COMMON BLOCKS
      CALL HWIGIN
C---USER CAN RESET PARAMETERS AT
C   THIS POINT, OTHERWISE DEFAULT
C   VALUES IN HWIGIN WILL BE USED.
      PRVTX = .FALSE.
      MAXPR = 1
C---CHARYBDIS PARAMETERS CAN ALSO BE RESET HERE
      TOTDIM=8
      YRCSEC=.TRUE.
      RMBOIL=.TRUE.
      RMMINM=200.D0
C---DEFINE BLACK HOLE
      NRES=NRES+1
      RNAME(NRES)='BlacHole'
      IDPDG(NRES)=40
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
C--RELABEL HARD AS BLACK HOLE
      IDHW(6)=NRES
      IDHEP(6)=40
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
c
C-- printing the total cross section in mb and its uncertainty to testi.dat:

         val = AVWGT*1.e-6
         XNWGTS=NWGTS
         RNWGT = 1./XNWGTS
         SPWGT = sqrt(max(WSQSUM*RNWGT - AVWGT**2 , 0.))
         errval = SPWGT*sqrt(RNWGT)*1.e-6
c
           open(unit=11,file='testi.dat',status='unknown')
         write(11,1001) ITEST, val, errval
 1001    FORMAT('charybdis_test2',I3,2(1PE15.6))
c
c      
      END
C----------------------------------------------------------------------
      SUBROUTINE HWABEG
C     USER'S ROUTINE FOR INITIALIZATION
C----------------------------------------------------------------------
      END
C----------------------------------------------------------------------
      SUBROUTINE HWAEND
C     USER'S ROUTINE FOR TERMINAL CALCULATIONS, HISTOGRAM OUTPUT, ETC
C----------------------------------------------------------------------
      END
C----------------------------------------------------------------------
      SUBROUTINE HWANAL
C     USER'S ROUTINE TO ANALYSE DATA FROM EVENT
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      DOUBLE PRECISION PTOTAL(4),EPS
      INTEGER ITOTAL,I,J
      PARAMETER(EPS=1.0D-4)
C--TEST CHARGE AND MOMENTUM CONSERVATION
      IF(IERROR.NE.0) RETURN
      DO I=1,4
         PTOTAL(I) = ZERO
      ENDDO
      ITOTAL = 0
      DO I=1,NHEP
         IF(ISTHEP(I).EQ.1) THEN
            ITOTAL = ITOTAL+ICHRG(IDHW(I))
            DO J=1,4
               PTOTAL(J) = PTOTAL(J)+PHEP(J,I)
            ENDDO
         ENDIF
      ENDDO
      DO I=1,2
         ITOTAL = ITOTAL-ICHRG(IDHW(I))
         DO J=1,4
            PTOTAL(J) = PTOTAL(J)-PHEP(J,I)
         ENDDO
      ENDDO
      IF(ITOTAL.NE.0) PRINT *,
     &     'NON-CONSERVATION OF CHARGE: CHARGE VIOLATION=',ITOTAL
      DO J=1,4
         IF(ABS(PTOTAL(J)).GT.EPS) PRINT *,
     &     'NON-CONSERVATION OF MOMENTUM: MOMENTUM VIOLATION=',PTOTAL(J)
      ENDDO
      END
C----------------------------------------------------------------------
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
