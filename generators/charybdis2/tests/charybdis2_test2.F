C #@# Charybdis2 1.0.3 test for BH production in p-p collision at E = 7TeV + 7TeV
C #@# reference value - 1.0.3, 1000 events
C #@# 1 Cross section for hadronisation with Herwig

C--------------------------------------------------------------------
C--------------------------------------------------------------------
C     Main program for the herwig implementation
C
C     -A Les houches event file is produced with the events
C     -An external parton distribution library can be used. The two 
C      possibilities are PDFLIB and LHAPDF. These options are 
C      chosen by editing the Makefile
C--------------------------------------------------------------------
C--------------------------------------------------------------------  
      PROGRAM HWIGPR
C-----Declaration of variables---------------------------------------
C---COMMON BLOCKS ARE INCLUDED AS FILE HERWIG65.INC
      INCLUDE 'HERWIG65.INC'
      INCLUDE 'charybdis2.inc'
C--Les Houches run common block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)
C--event common block
      INTEGER MAXNUP
      PARAMETER (MAXNUP=500)
      INTEGER NUP,IDPRUP,IDUP,ISTUP,MOTHUP,ICOLUP
      DOUBLE PRECISION XWGTUP,SCALUP,AQEDUP,AQCDUP,PUP,VTIMUP,SPINUP
      COMMON/HEPEUP/NUP,IDPRUP,XWGTUP,SCALUP,AQEDUP,AQCDUP,
     &              IDUP(MAXNUP),ISTUP(MAXNUP),MOTHUP(2,MAXNUP),
     &              ICOLUP(2,MAXNUP),PUP(5,MAXNUP),VTIMUP(MAXNUP),
     &              SPINUP(MAXNUP)
C--Local
      INTEGER N,I,J,IUP,IHEP,ID,POLN
      DOUBLE PRECISION HWRUNI
      EXTERNAL HWUDAT,HWRUNI

ccc*******************************************************************
ccc   GENSER variables

      integer ITEST
      real val, XNWGTS, RNWGT, SPWGT, errval
      data ITEST/1/
ccc*******************************************************************

C--------------------------------------------------------------------
C                           INITIALISATION 
C
C     Some parameters need to be initialised here others may or may 
C     not be set (defaults will be used if not)
C--------------------------------------------------------------------

C--------------Compulsory initialisation-----------------------------
C---MAX NUMBER OF EVENTS THIS RUN------------(MAKE CHANGES IF NEEDED)
      CHNMAXEV=1000
C---BEAM PARTICLES
      IDBMUP(1)=2212
      IDBMUP(2)=2212
C---BEAM MOMENTA
      EBMUP(1)=7000D0
      EBMUP(2)=7000D0
C-----------------------(END OF CHANGES)-----------------------------

C---Change CHARYBDIS defaults------------(EDIT THIS ROUTINE IF NEEDED)
      CALL CHDEFAULTS
C--------------------------------------------------------------------

C--------------------------------------(COMMENT LINE below if needed)
C-----If you have an input file the following subroutine call will 
C     override the initialisation above. If you do not wish to use an
C     input file please comment this line. Note that this file is read
C     once again some lines below so you will have to comment there as
C     well
      CALL CHREADINITFILE
C--------------------------------------------------------------------
C---PROCESS (Do not change this value (must be  <0)!!!!!)
      IPROC=-100
      CALL HWUIDT(1,IDBMUP(1),I,PART1)
      CALL HWUIDT(1,IDBMUP(2),I,PART2)
      PBEAM1=EBMUP(1)
      PBEAM2=EBMUP(2)
C---INITIALISE OTHER COMMON BLOCKS



      CALL HWIGIN



C---Herwig optional change of defaults--------(MAKE CHANGES IF NEEDED)
C---Random number generator seeds (will be reset below if 
C   CHREADINITFILE is being used)
      NRN(1)=9685569
      NRN(2)=1393138
C---Print vertex information
      PRVTX = .FALSE.
C---Maximum number of events to print
      MAXPR = 10

C--------------------------------------(COMMENT LINE below if needed)
C-----If you have an input file the following subroutine call will 
C     override the initialisation above. If you do not wish to use an
C     input file please comment this line. 
      CALL CHREADINITFILE
C-----------------------(END OF CHANGES)-----------------------------
C--------------------------------------------------------------------
 
C--------------------------------------------------------------------
C                    Other HERWIG initialisation  
C--------------------------------------------------------------------



      MAXEV=CHNMAXEV
      IF (RMSTAB) THEN
C---DEFINE STABLE BLACK HOLE REMNANTS
         NRES=NRES+1
         RNAME(NRES)='Remnant0'
         IDPDG(NRES)=50
         ICHRG(NRES)=0
         NRES=NRES+1
         RNAME(NRES)='Remnant+'
         IDPDG(NRES)=51
         ICHRG(NRES)=1
         NRES=NRES+1
         RNAME(NRES)='Remnant-'
         IDPDG(NRES)=-51
         ICHRG(NRES)=-1
      ENDIF
C---DEFINE BLACK HOLE
      NRES=NRES+1
      RNAME(NRES)='BlacHole'
      WRITE(*,*)'NRES=',NRES
      IDPDG(NRES)=40

C---COMPUTE PARAMETER-DEPENDENT CONSTANTS



      CALL HWUINC




      AVWGT =XSECUP(1)
      WGTMAX=XMAXUP(1)
      EVWGT=AVWGT 
C---CALL HWUSTA TO MAKE ANY PARTICLE STABLE
      CALL HWUSTA('PI0     ')
C---USER'S INITIAL CALCULATION------------(Edit this subroutine if needed)
      CALL HWABEG
C-------------------------------------------------------------------------
C---INITIALISE ELEMENTARY PROCESS
      CALL HWEINI
      MAXER=MAX(10,MAXEV/10)
C-------------------------------------------------------------------------
C                               GENERATE EVENTS
C-------------------------------------------------------------------------
C---LOOP OVER EVENTS
      DO 100 N=1,MAXEV
C---INITIALISE EVENT
      CALL HWUINE
C---GENERATE HARD SUBPROCESS
      CALL HWEPRO
C---GET POLARIZATIONS
      IUP=3
      DO IHEP=JDAHEP(1,6),JDAHEP(2,6)
         ID=IDHEP(IHEP)
         IF (IDUP(IUP).EQ.ID) THEN
            CALL HWVZRO(3,RHOHEP(1,IHEP))
            POLN=SPINUP(IUP)
            IF (POLN.LT.1.1D0) THEN
               IF (POLN.LT.ZERO) THEN
                  RHOHEP(1,IHEP)=ONE
               ELSEIF (POLN.GT.ZERO) THEN
                  RHOHEP(3,IHEP)=ONE
               ELSE
                  RHOHEP(2,IHEP)=ONE
               ENDIF
            ENDIF
         ELSE
            PRINT *,' WARNING: PARTICLE NOT FOUND IN HEPEUP'
         ENDIF
         IUP=IUP+1
      ENDDO
      
      IF (MJLOST) THEN
C--Put BH in event record
         NHEP=NHEP+1
         CALL CHVDIF(5,PHEP(1,6),PHEP(1,7),PHEP(1,NHEP))
         CALL CHUMAS(PHEP(1,NHEP))
         IDHW(NHEP)=NRES
         IDHEP(NHEP)=40
         ISTHEP(NHEP)=2      
         JMOHEP(1,NHEP) = 6
         JMOHEP(2,NHEP) = NHEP
      ELSEIF (IDHEP(6).EQ.0) THEN
C--RELABEL HARD AS BLACK HOLE (UNLESS REMANT IS IMEDIATELY OBTAINED AFTER FORMATION)
         IDHW(6)=NRES
         IDHEP(6)=40
      ENDIF  
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
C---USER'S EVENT ANALYSS-------------------(EDIT THIS ROUTINE if needed)
      CALL HWANAL
C-----------------------------------------------------------------------

C--------Print out BH history
      CALL CHPRINT(N,MAXPR,MAXEV)
  100 CONTINUE



C-----------------------------------------------------------------------
C                           TERMINATE RUN
C-----------------------------------------------------------------------

C---TERMINATE ELEMENTARY PROCESS
      CALL HWEFIN
C---USER'S TERMINAL CALCULATIONS----------(EDIT THIS ROUTINE if needed)
      CALL HWAEND
C----------------------------------------------------------------------


ccc***********************************************************************
ccc   GENSER output
C-- printing the total cross section in pb and its uncertainty to testi.dat:

         val = AVWGT*1E03
         XNWGTS=NWGTS
         RNWGT = 1./XNWGTS
         SPWGT = sqrt(max(WSQSUM*RNWGT - AVWGT**2 , 0.))
         errval = SPWGT*sqrt(RNWGT)*1E03
c
           open(unit=11,file='testi.dat',status='unknown')
         write(11,1001) ITEST, val, errval
 1001    FORMAT('charybdis2_test2',I3,2(1PE15.6))

ccc************************************************************************


      STOP
      END

C----------------------------------------------------------------------
C----------------------------------------------------------------------
C                       USER DEFINED ROUTINES
C----------------------------------------------------------------------
C----------------------------------------------------------------------

C----------------------------------------------------------------------
      SUBROUTINE CHDEFAULTS
C     Routine for changing charybdis defaults. Make your changes here
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'charybdis2.inc'
C--Les Houches run common block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)
C--event common block
      INTEGER MAXNUP
      PARAMETER (MAXNUP=500)
      INTEGER NUP,IDPRUP,IDUP,ISTUP,MOTHUP,ICOLUP
      DOUBLE PRECISION XWGTUP,SCALUP,AQEDUP,AQCDUP,PUP,VTIMUP,SPINUP
      COMMON/HEPEUP/NUP,IDPRUP,XWGTUP,SCALUP,AQEDUP,AQCDUP,
     &              IDUP(MAXNUP),ISTUP(MAXNUP),MOTHUP(2,MAXNUP),
     &              ICOLUP(2,MAXNUP),PUP(5,MAXNUP),VTIMUP(MAXNUP),
     &              SPINUP(MAXNUP)

C-----Reset Charybdis Parameters here (optional)
c      TOTDIM=10
c      MINMSS=5000D0
c      MAXMSS=14000D0
c      MSSDEF=2
c      MPLNCK=1000D0
c      MAXEV=1000
c      BHSPIN=.FALSE.
c      YRCSEC=.FALSE.
c      MJLOST=.FALSE.
c      IBHPRN=1
C-----Reset XML Les Houches Event file name here (optional. Note: this is 8 characters long)
c      LHEFILENAME='lhouches'

      END

C----------------------------------------------------------------------
      SUBROUTINE HWABEG
C     USER'S ROUTINE FOR INITIALIZATION
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      INCLUDE 'charybdis2.inc'
C--Les Houches run common block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)

C---Open LES HOUCHES EVENT FILE to write event
      CALL SYSTEM('rm '//LHEFILENAME//'.xml;')
      OPEN(UNIT=10,FILE=LHEFILENAME//'.xml',STATUS='NEW')
C------Write header information        
      WRITE(10,1)'<LesHouchesEvents version="1.0">'
      WRITE(10,1)'<!--'
      WRITE(10,1)'File generated with charybdis2-1.0.3 '
      WRITE(10,1)'http://projects.hepforge.org/charybdis2/'
      WRITE(10,1)
      CALL CHWRITEINIT(10)
      WRITE(10,1)'-->'
      WRITE(10,1)'<init>'
      WRITE(10,2)IDBMUP,EBMUP,PDFGUP,PDFSUP,IDWTUP,1
      WRITE(10,3)XSECUP(1),XERRUP(1),1D0,LPRUP(1)
      WRITE(10,1)'</init>'
 1    FORMAT(A)
 2    FORMAT(2(TR1,I5),2(TR1,E11.5),6(TR1,I5))
 3    FORMAT(3(TR1,E11.5),1(TR1,I5))

      CALL SYSTEM('rm '//HISFILENAME//'.xml;')
      OPEN(UNIT=11,FILE=HISFILENAME//'.xml',STATUS='NEW')
C------Write header information     
      WRITE(11,1)'<BHhistories>'
      WRITE(11,1)'<!--'
      WRITE(11,1)'File generated with charybdis2-1.0.2 '
      WRITE(11,1)'http://projects.hepforge.org/charybdis2/'
      WRITE(11,1)
      CALL CHWRITEINIT(11)
      WRITE(11,1)'-->'
      WRITE(11,1)'<init>'
      WRITE(11,4)IDBMUP,EBMUP,PDFGUP,PDFSUP,IDWTUP,1
      WRITE(11,5)XSECUP(1),XERRUP(1),XMAXUP(1),LPRUP(1)
      WRITE(11,1)'</init>'
 4    FORMAT(2(TR1,I5),2(TR1,E11.5),6(TR1,I5))
 5    FORMAT(3(TR1,E11.5),1(TR1,I5))

      END

C----------------------------------------------------------------------
      SUBROUTINE HWANAL
C     USER'S ROUTINE TO ANALYSE DATA FROM EVENT
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      INCLUDE 'charybdis2.inc'
C--Les Houches run common block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)
C--event common block
      INTEGER MAXNUP
      PARAMETER (MAXNUP=500)
      INTEGER NUP,IDPRUP,IDUP,ISTUP,MOTHUP,ICOLUP
      DOUBLE PRECISION XWGTUP,SCALUP,AQEDUP,AQCDUP,PUP,VTIMUP,SPINUP
      COMMON/HEPEUP/NUP,IDPRUP,XWGTUP,SCALUP,AQEDUP,AQCDUP,
     &              IDUP(MAXNUP),ISTUP(MAXNUP),MOTHUP(2,MAXNUP),
     &              ICOLUP(2,MAXNUP),PUP(5,MAXNUP),VTIMUP(MAXNUP),
     &              SPINUP(MAXNUP)
C--Local variables
      INTEGER I,J
      DOUBLE PRECISION MODJ

C--Write out event in the LES HOUCHES EVENT FILE
      IF(XWGTUP.NE.0)THEN

      WRITE(10,1)'<event>'
      IF(MJLOST.AND.BHLHOUCHES)THEN
         WRITE(10,2)NUP+2,LPRUP(1),1D0,SCALUP,1./137.,0.118
      ELSE IF((MJLOST.AND.(.NOT.BHLHOUCHES)).OR.
     &        ((.NOT.MJLOST).AND.BHLHOUCHES))THEN
         WRITE(10,2)NUP+1,LPRUP(1),1D0,SCALUP,1./137.,0.118            
      ELSE
         WRITE(10,2)NUP,LPRUP(1),1D0,SCALUP,1./137.,0.118           
      END IF


C-----Put incoming partons in the event record
      DO J=1,2
         WRITE(10,3)IDUP(J),ISTUP(J),MOTHUP(1,J),MOTHUP(2,J),
     &ICOLUP(1,J),ICOLUP(2,J),(PUP(I,J),I=1,5),VTIMUP(J),SPINUP(J)
      END DO

C-----Put Black hole in the event record
      IF(BHLHOUCHES)THEN
         MODJ=SQRT(SBHD(1,1)**2+SBHD(2,1)**2+SBHD(3,1)**2)
         IF(MODJ.GT.0.1D0)THEN
            WRITE(10,3)40,2,1,2,0,0,(PBHD(I,1),I=1,5),0.0,
     &(SBHD(1,1)*PBHD(1,1)+SBHD(2,1)*PBHD(2,1)+SBHD(3,1)*PBHD(3,1))/
     &SQRT(PBHD(1,1)**2+PBHD(2,1)**2+PBHD(3,1)**2)/MODJ
         ELSE
            WRITE(10,3)40,2,1,2,0,0,(PBHD(I,1),I=1,5),0.0,9D0
         END IF
      END IF

      DO J=3,NUP
         IF(IDUP(J).NE.39)THEN
            WRITE(10,3)IDUP(J),ISTUP(J),MOTHUP(1,J),MOTHUP(2,J),
     &ICOLUP(1,J),ICOLUP(2,J),(PUP(I,J),I=1,5),VTIMUP(J),SPINUP(J)
         ELSE
C-----Split total gravitational radiation into two fictitious massless gravitons (note that this is missing energy anyway)
            WRITE(10,3)IDUP(J),ISTUP(J),MOTHUP(1,J),MOTHUP(2,J),
     &ICOLUP(1,J),ICOLUP(2,J),
     &PUP(1,J)/2+PUP(5,J)*PUP(2,J)/SQRT(PUP(1,J)**2+PUP(2,J)**2),
     &PUP(2,J)/2-PUP(5,J)*PUP(1,J)/SQRT(PUP(1,J)**2+PUP(2,J)**2),
     &PUP(3,J)/2,PUP(4,J)/2,0D0,VTIMUP(J),SPINUP(J)   
            WRITE(10,3)IDUP(J),ISTUP(J),MOTHUP(1,J),MOTHUP(2,J),
     &ICOLUP(1,J),ICOLUP(2,J),
     &PUP(1,J)/2-PUP(5,J)*PUP(2,J)/SQRT(PUP(1,J)**2+PUP(2,J)**2),
     &PUP(2,J)/2+PUP(5,J)*PUP(1,J)/SQRT(PUP(1,J)**2+PUP(2,J)**2),
     &PUP(3,J)/2,PUP(4,J)/2,0D0,VTIMUP(J),SPINUP(J) 
         END IF
      END DO
      WRITE(10,1)'</event>'

C------Write BH histories in a similar file
      WRITE(11,1)'<event>'
      WRITE(11,*)NBHD
      DO J=1,NBHD
         WRITE(11,4)(PBHD(I,J),I=1,5),(SBHD(I,J),I=1,3),RHBHD(J),
     &OBBHD(J),THBHD(J),NFLUXBHD(J)
      END DO
      WRITE(11,1)'</event>'

 1    FORMAT(A)
 2    FORMAT(2(TR1,I5),4(TR1,E17.10))
 3    FORMAT(6(TR1,I5),5(TR1,E17.10),2(TR1,F3.0))
 4    FORMAT(12(TR1,E17.10))
      END IF

      END

C----------------------------------------------------------------------
      SUBROUTINE CHPRINT(N,MAXPR,MAXEVN)
C     PRINT OUT BH HISTORY
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'charybdis2.inc'
      INTEGER N,MAXPR,MAXEVN
C---LOCAL VARIABLES
      INTEGER I,J

      IF (N.LE.MAXPR) THEN
         WRITE(*,*)
         WRITE(*,*)'                          ---BLACK HOLE HISTORY---'
         WRITE(*,*)
         WRITE(*,1)'NBHD','PBHX','PBHY','PBHZ','EBH','MBH','EEM',
     &'OMEGA*','S','SBHX','SBHY','SBHZ','A*','THBH','TSTAR'
         DO J=1,NBHD-1
            WRITE(*,2)J,(PBHD(I,J),I=1,5),PBHD(5,J)-PBHD(5,J+1),
     &(PBHD(5,J)-PBHD(5,J+1))*RHBHD(J),
     &SQRT(SBHD(1,J)**2+SBHD(2,J)**2+SBHD(3,J)**2)
     &,(SBHD(I,J),I=1,3),OBBHD(J)/RHBHD(J),THBHD(J),
     &1D0/NFLUXBHD(J)/RHBHD(J)
         ENDDO
         WRITE(*,3)J,(PBHD(I,NBHD),I=1,5),'------','------',
     &SQRT(SBHD(1,NBHD)**2+SBHD(2,NBHD)**2+SBHD(3,NBHD)**2),
     &(SBHD(I,NBHD),I=1,3),OBBHD(NBHD)/RHBHD(NBHD),THBHD(NBHD),'------'

      ENDIF


 1    FORMAT(A4,6(TR1,A8),5(TR1,A6),(TR1,A8),2(TR1,A8))
 2    FORMAT(I4,6(TR1,F8.1),5(TR1,F6.2),1(TR1,F8.2),1(TR1,F8.1),
     &1(TR1,E8.2))
 3    FORMAT(I4,5(TR1,F8.1),(TR1,A8),(TR1,A6),4(TR1,F6.2),(TR1,F8.2)
     &,1(TR1,F8.1),(TR1,A8))

      IF((N/(MAXEVN/10.)-10*N/MAXEVN).EQ.0)WRITE(*,*)N,'EVENTS DONE'
      END

C----------------------------------------------------------------------
      SUBROUTINE HWAEND
C     USER'S ROUTINE FOR TERMINAL CALCULATIONS, HISTOGRAM OUTPUT, ETC
C----------------------------------------------------------------------
      INCLUDE 'HERWIG65.INC'
      INCLUDE 'charybdis2.inc'

C---Finish LES HOUCHES EVENT FILE and close it
      WRITE(10,1)'</LesHouchesEvents>'
      CLOSE(UNIT=10)

C---Finish Histories FILE and close it
      WRITE(11,1)'</BHhistories>'
      CLOSE(UNIT=11)
 1    FORMAT(A)

      END

C----------------------------------------------------------------------
      SUBROUTINE CHREADINITFILE
C     READ INITIALISATION FILE
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'charybdis2.inc'
C--Les Houches run common block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)
C--Seeds for the random number generator
      INTEGER NRN
      COMMON/CHRANDOM/NRN(2)
C-----Local variables
      LOGICAL READSTATUS

      WRITE(*,*)
      WRITE(*,*)'-----> Reading charybdis2.init '//
     &'initialisation file ...'

      OPEN(UNIT=12,FILE='charybdis2.init',STATUS='OLD')
C-----IDBMUP(1)
      CALL CHGOTOVARIABLE('IDBMUP(1)',9,READSTATUS)
      IF(READSTATUS) READ(12,*)IDBMUP(1)
C-----IDBMUP(2)
      CALL CHGOTOVARIABLE('IDBMUP(2)',9,READSTATUS)
      IF(READSTATUS) READ(12,*)IDBMUP(2)
C-----EBMUP(1)
      CALL CHGOTOVARIABLE('EBMUP(1)',8,READSTATUS)
      IF(READSTATUS) READ(12,*)EBMUP(1)
C-----EBMUP(2)
      CALL CHGOTOVARIABLE('EBMUP(2)',8,READSTATUS)
      IF(READSTATUS) READ(12,*)EBMUP(2)
C-----MINMSS
      CALL CHGOTOVARIABLE('MINMSS',6,READSTATUS)
      IF(READSTATUS) READ(12,*)MINMSS
C-----MAXMSS
      CALL CHGOTOVARIABLE('MAXMSS',6,READSTATUS)
      IF(READSTATUS) READ(12,*)MAXMSS
C-----PDFGUP(1)
      CALL CHGOTOVARIABLE('PDFGUP(1)',9,READSTATUS)
      IF(READSTATUS) READ(12,*)PDFGUP(1)
C-----PDFGUP(2)
      CALL CHGOTOVARIABLE('PDFGUP(2)',9,READSTATUS)
      IF(READSTATUS) READ(12,*)PDFGUP(2)
C-----LHAPDFSET
      CALL CHGOTOVARIABLE('LHAPDFSET',9,READSTATUS)
      IF(READSTATUS) READ(12,*)LHAPDFSET
C-----CHNMAXEV
      CALL CHGOTOVARIABLE('CHNMAXEV',8,READSTATUS)
      IF(READSTATUS) READ(12,*)CHNMAXEV
C-----NRN(1)
      CALL CHGOTOVARIABLE('NRN(1)',6,READSTATUS)
      IF(READSTATUS) READ(12,*)NRN(1)
C-----NRN(2)
      CALL CHGOTOVARIABLE('NRN(2)',6,READSTATUS)
      IF(READSTATUS) READ(12,*)NRN(2)
C-----LHEFILENAME
      CALL CHGOTOVARIABLE('LHEFILENAME',11,READSTATUS)
      IF(READSTATUS) READ(12,*)LHEFILENAME
C-----HISFILENAME
      CALL CHGOTOVARIABLE('HISFILENAME',11,READSTATUS)
      IF(READSTATUS) READ(12,*)HISFILENAME
C-----BHLHOUCHES
      CALL CHGOTOVARIABLE('BHLHOUCHES',10,READSTATUS)
      IF(READSTATUS) READ(12,*)BHLHOUCHES
C-----TOTDIM
      CALL CHGOTOVARIABLE('TOTDIM',6,READSTATUS)
      IF(READSTATUS) READ(12,*)TOTDIM
C-----MPLNCK
      CALL CHGOTOVARIABLE('MPLNCK',6,READSTATUS)
      IF(READSTATUS) READ(12,*)MPLNCK
C-----MSSDEF
      CALL CHGOTOVARIABLE('MSSDEF',6,READSTATUS)
      IF(READSTATUS) READ(12,*)MSSDEF
C-----YRCSEC
      CALL CHGOTOVARIABLE('YRCSEC',6,READSTATUS)
      IF(READSTATUS) READ(12,*)YRCSEC
C-----MJLOST
      CALL CHGOTOVARIABLE('MJLOST',6,READSTATUS)
      IF(READSTATUS) READ(12,*)MJLOST
C-----USEMINMSSBH
      CALL CHGOTOVARIABLE('USEMINMSSBH',11,READSTATUS)
      IF(READSTATUS) READ(12,*)USEMINMSSBH
C-----CVBIAS
      CALL CHGOTOVARIABLE('CVBIAS',6,READSTATUS)
      IF(READSTATUS) READ(12,*)CVBIAS
C-----FMLOST
      CALL CHGOTOVARIABLE('FMLOST',6,READSTATUS)
      IF(READSTATUS) READ(12,*)FMLOST
C-----GTSCA
      CALL CHGOTOVARIABLE('GTSCA',5,READSTATUS)
      IF(READSTATUS) READ(12,*)GTSCA
C-----DGSB
      CALL CHGOTOVARIABLE('DGSB',4,READSTATUS)
      IF(READSTATUS) READ(12,*)DGSB
C-----DGGS
      CALL CHGOTOVARIABLE('DGGS',4,READSTATUS)
      IF(READSTATUS) READ(12,*)DGGS
C-----DGMS
      CALL CHGOTOVARIABLE('DGMS',4,READSTATUS)
      IF(READSTATUS) READ(12,*)DGMS
C-----BHSPIN
      CALL CHGOTOVARIABLE('BHSPIN',6,READSTATUS)
      IF(READSTATUS) READ(12,*)BHSPIN
C-----BHJVAR
      CALL CHGOTOVARIABLE('BHJVAR',6,READSTATUS)
      IF(READSTATUS) READ(12,*)BHJVAR
C-----BHANIS
      CALL CHGOTOVARIABLE('BHANIS',6,READSTATUS)
      IF(READSTATUS) READ(12,*)BHANIS
C-----GRYBDY
      CALL CHGOTOVARIABLE('GRYBDY',6,READSTATUS)
      IF(READSTATUS) READ(12,*)GRYBDY
C-----TIMVAR
      CALL CHGOTOVARIABLE('TIMVAR',6,READSTATUS)
      IF(READSTATUS) READ(12,*)TIMVAR
C-----MSSDEC
      CALL CHGOTOVARIABLE('MSSDEC',6,READSTATUS)
      IF(READSTATUS) READ(12,*)MSSDEC
C-----RECOIL
      CALL CHGOTOVARIABLE('RECOIL',6,READSTATUS)
      IF(READSTATUS) READ(12,*)RECOIL
C-----THWMAX
      CALL CHGOTOVARIABLE('THWMAX',6,READSTATUS)
      IF(READSTATUS) READ(12,*)THWMAX
C-----DGTENSION
      CALL CHGOTOVARIABLE('DGTENSION',9,READSTATUS)
      IF(READSTATUS) READ(12,*)DGTENSION
C-----NBODYAVERAGE
      CALL CHGOTOVARIABLE('NBODYAVERAGE',12,READSTATUS)
      IF(READSTATUS) READ(12,*)NBODYAVERAGE
C-----KINCUT
      CALL CHGOTOVARIABLE('KINCUT',6,READSTATUS)
      IF(READSTATUS) READ(12,*)KINCUT
C-----SKIP2REMNANT
      CALL CHGOTOVARIABLE('SKIP2REMNANT',12,READSTATUS)
      IF(READSTATUS) READ(12,*)SKIP2REMNANT
C-----NBODY
      CALL CHGOTOVARIABLE('NBODY',5,READSTATUS)
      IF(READSTATUS) READ(12,*)NBODY
C-----NBODYPHASE
      CALL CHGOTOVARIABLE('NBODYPHASE',10,READSTATUS)
      IF(READSTATUS) READ(12,*)NBODYPHASE
C-----NBODYVAR
      CALL CHGOTOVARIABLE('NBODYVAR',8,READSTATUS)
      IF(READSTATUS) READ(12,*)NBODYVAR
C-----RMBOIL
      CALL CHGOTOVARIABLE('RMBOIL',6,READSTATUS)
      IF(READSTATUS) READ(12,*)RMBOIL
C-----RMSTAB
      CALL CHGOTOVARIABLE('RMSTAB',6,READSTATUS)
      IF(READSTATUS) READ(12,*)RMSTAB
C-----RMMINM
      CALL CHGOTOVARIABLE('RMMINM',6,READSTATUS)
      IF(READSTATUS) READ(12,*)RMMINM
C-----IBHPRN
      CALL CHGOTOVARIABLE('IBHPRN',6,READSTATUS)
      IF(READSTATUS) READ(12,*)IBHPRN
C-----NLEPTONCSV(0)
      CALL CHGOTOVARIABLE('NLEPTONCSV(0)',13,READSTATUS)
      IF(READSTATUS) READ(12,*)NLEPTONCSV(0)
C-----NLEPTONCSV(1)
      CALL CHGOTOVARIABLE('NLEPTONCSV(1)',13,READSTATUS)
      IF(READSTATUS) READ(12,*)NLEPTONCSV(1)
C-----NLEPTONCSV(2)
      CALL CHGOTOVARIABLE('NLEPTONCSV(2)',13,READSTATUS)
      IF(READSTATUS) READ(12,*)NLEPTONCSV(2)
C-----NLEPTONCSV(3)
      CALL CHGOTOVARIABLE('NLEPTONCSV(3)',13,READSTATUS)
      IF(READSTATUS) READ(12,*)NLEPTONCSV(3)
     
      CLOSE(UNIT=12)

      WRITE(*,*)'-----> Done'
      WRITE(*,*)

      END
  

C----------------------------------------------------------------------
      SUBROUTINE CHGOTOVARIABLE(VARNAME,VARNAMELENGTH,READSTATUS)
C     READ ONE VARIABLE IN INITIALISATION FILE
C----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER VARNAMELENGTH
      CHARACTER VARNAME*30
C-----Local variables
      INTEGER STAT1
      CHARACTER READLINE*70,EMPTYLINE*70,ENDOFINPUT*70,TESTCHAR*7
      LOGICAL READSTATUS
      
      READSTATUS=.FALSE.

      EMPTYLINE='-----------------------------------'//
     &'-----------------------------------'
      ENDOFINPUT='*****************************END*OF*INPUT***********'
     &//'******************'

C-----
      REWIND(12)
      READLINE=EMPTYLINE
      DO WHILE ((READLINE(1:VARNAMELENGTH+1).NE.VARNAME(1:VARNAMELENGTH)
     &//':')
     &.AND.
     &(READLINE(1:60).NE.ENDOFINPUT(1:60)))
         READ(12,*,ERR=333,IOSTAT=STAT1)READLINE(1:60)
      END DO
      IF(READLINE(1:VARNAMELENGTH+1).EQ.VARNAME(1:VARNAMELENGTH)//':') 
     &THEN
         READ(12,*)TESTCHAR
         IF(TESTCHAR.NE.'default')THEN
            BACKSPACE(12)
            READSTATUS=.TRUE.
         END IF
         GOTO 444
      END IF
 333  CONTINUE
      WRITE(*,*)VARNAME(1:VARNAMELENGTH)//' not found in '//
     &'charybdis2-1.0.1.init file -- default will be used'

 444  CONTINUE

      END

C----------------------------------------------------------------------
      SUBROUTINE CHWRITEINIT(UNITNUM)
C     WRITE INPUT INFORMATION IN HEADERS OF FILES
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'charybdis2.inc'
C--Les Houches run common block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)
C--Seeds for the random number generator
      INTEGER NRN
      COMMON/CHRANDOM/NRN(2)
C-----Local variables
      INTEGER UNITNUM
      
      WRITE(UNITNUM,*)'Below are the values of the switches that were'//
     &' used in the run. You can copy/paste this block into a '//
     &'charybdis2.init file and rerun using the version above. Please '
     &//'do not forget to check the instructions in the header of the '
     &//'charybdis2.init file provided with the distribution. For your'
     &//' future reference you may want to copy that header and place '
     &//'it  as header of your new charybdis2.init file, together with'
     &//' any other information you may find relevant.'
      WRITE(UNITNUM,1)      
      WRITE(UNITNUM,1)'*********************************************'//
     &'*************************'
      WRITE(UNITNUM,1)'**********************  START OF INPUT OPTIONS'//
     &'  **********************'
      WRITE(UNITNUM,1)'**********************************************'//
     &'************************'
      WRITE(UNITNUM,1)
      WRITE(UNITNUM,1)'----------------------------'
      WRITE(UNITNUM,1)'----- Beams & Energies -----'
      WRITE(UNITNUM,1)'----------------------------'
      WRITE(UNITNUM,1)'IDBMUP(1): (default is 2212)'
      WRITE(UNITNUM,*)IDBMUP(1)
      WRITE(UNITNUM,1)'IDBMUP(2): (default is 2212)'
      WRITE(UNITNUM,*)IDBMUP(2)
      WRITE(UNITNUM,1)'EBMUP(1): (default is 7000.0)'
      WRITE(UNITNUM,*)EBMUP(1)
      WRITE(UNITNUM,1)'EBMUP(2): (default is 7000.0)'
      WRITE(UNITNUM,*)EBMUP(2)
      WRITE(UNITNUM,1)'MINMSS: (default is 5000.0)'
      WRITE(UNITNUM,*)MINMSS
      WRITE(UNITNUM,1)'MAXMSS: (default is 14000.0)'
      WRITE(UNITNUM,*)MAXMSS
      WRITE(UNITNUM,1)'PDFGUP(1): (Default depends on specific'//
     &' implementation)'
      WRITE(UNITNUM,*)PDFGUP(1)
      WRITE(UNITNUM,1)'PDFGUP(2): (Default depends on specific'//
     &' implementation)'
      WRITE(UNITNUM,*)PDFGUP(2)
      WRITE(UNITNUM,1)'LHAPDFSET: (default is 10000 -- needs to'//
     &' be set if you are using LHAPDF)'
      WRITE(UNITNUM,*)LHAPDFSET
      WRITE(UNITNUM,1)'-----------------------'
      WRITE(UNITNUM,1)'----- MC & OUTPUT -----'
      WRITE(UNITNUM,1)'-----------------------'
      WRITE(UNITNUM,1)'CHNMAXEV: (default is 100)'
      WRITE(UNITNUM,*)CHNMAXEV
      WRITE(UNITNUM,1)'NRN(1): (default is 245234)'
      WRITE(UNITNUM,*)NRN(1)
      WRITE(UNITNUM,1)'NRN(2): (default is 42542)'
      WRITE(UNITNUM,*)NRN(2)
      WRITE(UNITNUM,1)'LHEFILENAME: (default is lhouches -- must'//
     &' be exactly 8 characters long !!!)'
      WRITE(UNITNUM,*)LHEFILENAME
      WRITE(UNITNUM,1)'HISFILENAME: (default is histfile -- must'//
     &' be exactly 8 characters long !!!)'
      WRITE(UNITNUM,*)HISFILENAME
      WRITE(UNITNUM,1)'BHLHOUCHES: (default is F -- means .FALSE.)'
      WRITE(UNITNUM,*)BHLHOUCHES
      WRITE(UNITNUM,1)'IBHPRN: (default is 1)'
      WRITE(UNITNUM,*)IBHPRN
      WRITE(UNITNUM,1)'--------------------------------------------'
      WRITE(UNITNUM,1)'----- Model parameters and conventions -----'
      WRITE(UNITNUM,1)'--------------------------------------------'
      WRITE(UNITNUM,1)'TOTDIM: (default is 6)'
      WRITE(UNITNUM,*)TOTDIM
      WRITE(UNITNUM,1)'MPLNCK: (default is 1000.0)'
      WRITE(UNITNUM,*)MPLNCK
      WRITE(UNITNUM,1)'MSSDEF: (default is 3 -- PDG definition)'
      WRITE(UNITNUM,*)MSSDEF
      WRITE(UNITNUM,1)'YRCSEC: (default is T -- means .TRUE.)'
      WRITE(UNITNUM,*)YRCSEC
      WRITE(UNITNUM,1)'MJLOST: (default is T -- means .TRUE.)'
      WRITE(UNITNUM,*)MJLOST
      WRITE(UNITNUM,1)'USEMINMSSBH: (default is T -- means .TRUE.)'
      WRITE(UNITNUM,*)USEMINMSSBH
      WRITE(UNITNUM,1)'CVBIAS: (default is F -- means .FALSE.)'
      WRITE(UNITNUM,*)CVBIAS
      WRITE(UNITNUM,1)'FMLOST: (default is 0.99)'
      WRITE(UNITNUM,*)FMLOST
      WRITE(UNITNUM,1)'GTSCA: (default is F)'
      WRITE(UNITNUM,*)GTSCA
      WRITE(UNITNUM,1)'NLEPTONCSV(0): (default is F -- means .FALSE.)'
      WRITE(UNITNUM,*)NLEPTONCSV(0)
      WRITE(UNITNUM,1)'NLEPTONCSV(1): (default is F -- means .FALSE.)'
      WRITE(UNITNUM,*)NLEPTONCSV(1)
      WRITE(UNITNUM,1)'NLEPTONCSV(2): (default is F -- means .FALSE.)'
      WRITE(UNITNUM,*)NLEPTONCSV(2)
      WRITE(UNITNUM,1)'NLEPTONCSV(3): (default is F -- means .FALSE.)'
      WRITE(UNITNUM,*)NLEPTONCSV(3)
      WRITE(UNITNUM,1)'DGSB: (default is F)'
      WRITE(UNITNUM,*)DGSB
      WRITE(UNITNUM,1)'DGGS: (default is 0.3)'
      WRITE(UNITNUM,*)DGGS
      WRITE(UNITNUM,1)'DGMS: (default is 1000.0)'
      WRITE(UNITNUM,*)DGMS
      WRITE(UNITNUM,1)'--------------------------------'
      WRITE(UNITNUM,1)'----- Evaporation switches -----'
      WRITE(UNITNUM,1)'--------------------------------'
      WRITE(UNITNUM,1)'BHSPIN: (default is T)'
      WRITE(UNITNUM,*)BHSPIN
      WRITE(UNITNUM,1)'BHJVAR: (default is T)'
      WRITE(UNITNUM,*)BHJVAR
      WRITE(UNITNUM,1)'BHANIS: (default is T)'
      WRITE(UNITNUM,*)BHANIS
      WRITE(UNITNUM,1)'GRYBDY: (default is T)'
      WRITE(UNITNUM,*)GRYBDY
      WRITE(UNITNUM,1)'TIMVAR: (default is T)'
      WRITE(UNITNUM,*)TIMVAR
      WRITE(UNITNUM,1)'MSSDEC: (default is 3)'
      WRITE(UNITNUM,*)MSSDEC
      WRITE(UNITNUM,1)'RECOIL: (default is 2)'
      WRITE(UNITNUM,*)RECOIL
      WRITE(UNITNUM,1)'THWMAX: (default is 1000.0)'
      WRITE(UNITNUM,*)THWMAX
      WRITE(UNITNUM,1)'DGTENSION: (default is 1000.0)'
      WRITE(UNITNUM,*)DGTENSION
      WRITE(UNITNUM,1)'---------------------------------'//
     &'------------------'
      WRITE(UNITNUM,1)'----- Switches for termination of '//
     &'evaporation -----'
      WRITE(UNITNUM,1)'-----------------------------------'//
     &'----------------'
      WRITE(UNITNUM,1)'NBODYAVERAGE: (default is T)'
      WRITE(UNITNUM,*)NBODYAVERAGE
      WRITE(UNITNUM,1)'KINCUT: (default is F)'
      WRITE(UNITNUM,*)KINCUT
      WRITE(UNITNUM,1)'SKIP2REMNANT: (default is F)'
      WRITE(UNITNUM,*)SKIP2REMNANT
      WRITE(UNITNUM,1)'----------------------------------'
      WRITE(UNITNUM,1)'----- Remnant model switches -----'
      WRITE(UNITNUM,1)'----------------------------------'
      WRITE(UNITNUM,1)'NBODY: (default is 2)'
      WRITE(UNITNUM,*)NBODY
      WRITE(UNITNUM,1)'NBODYPHASE: (default is F)'
      WRITE(UNITNUM,*)NBODYPHASE
      WRITE(UNITNUM,1)'NBODYVAR: (default is F)'
      WRITE(UNITNUM,*)NBODYVAR
      WRITE(UNITNUM,1)'RMBOIL: (default is F)'
      WRITE(UNITNUM,*)RMBOIL
      WRITE(UNITNUM,1)'RMSTAB: (default is F)'
      WRITE(UNITNUM,*)RMSTAB
      WRITE(UNITNUM,1)'RMMINM: (default is 100.0)'
      WRITE(UNITNUM,*)RMMINM
      WRITE(UNITNUM,1)'************************************'//
     &'**********************************'
      WRITE(UNITNUM,1)'*****************************END*OF*'//
     &'INPUT*****************************'
      WRITE(UNITNUM,1)'*************************************'//
     &'*********************************'
 1    FORMAT(A)
      END




















