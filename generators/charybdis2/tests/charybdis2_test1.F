C--------------------------------------------------------------------
C--------------------------------------------------------------------
C     Main program for the pythia implementation:
C
C     -A Les houches event file is produced with the events
C     -An external parton distribution library must be used. The two 
C      possibilities are PDFLIB and LHAPDF. These options are 
C      chosen by editing the Makefile
C--------------------------------------------------------------------
C--------------------------------------------------------------------
      PROGRAM PYTHIA
C-----Declaration of variables--------------------------------------- 
C...Double precision and integer declarations.
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      IMPLICIT INTEGER(I-N)
      INTEGER PYK,PYCHGE,PYCOMP
      EXTERNAL CHDATA

C...To reset Charybdis parameters via common
      INCLUDE 'charybdis2.inc'
C #@# Charybdis2 1.0.3 test for BH production in p-p collision at E = 7TeV + 7TeV
C #@# reference value - 1.0.3, 1000 events
C #@# 1 Cross section for hadronisation with Pythia

C...Commonblocks.
      COMMON/PYJETS/N,NPAD,K(4000,5),P(4000,5),V(4000,5)
      COMMON/PYDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)
      COMMON/PYDAT2/KCHG(500,4),PMAS(500,4),PARF(2000),VCKM(4,4)
      COMMON/PYDAT3/MDCY(500,3),MDME(8000,2),BRAT(8000),KFDP(8000,5)
      COMMON/PYSUBS/MSEL,MSELPD,MSUB(500),KFIN(2,-40:40),CKIN(200)
      COMMON/PYPARS/MSTP(200),PARP(200),MSTI(200),PARI(200)
C-----Common for pythia seeds
      COMMON/PYDATR/MRPY(6),RRPY(100)
      SAVE /PYJETS/,/PYDAT1/,/PYDAT2/,/PYDAT3/,/PYSUBS/,/PYPARS/
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
C-----Local Variables
      INTEGER I,MAXPR,NSUCCESS


ccc******************************************************************
ccc   GENSER variables
C...Generation and cross section statistics.
      COMMON /PYINT5/ NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      integer ITEST
      real val, errval
      data ITEST/1/
ccc******************************************************************


      NSUCCESS=0



C--------------------------------------------------------------------
C                           INITIALISATION
C
C     Please set parameters in the subroutine CHDEFAULTS below, where 
C     the default values can be changed. Use also 
C--------------------------------------------------------------------

C---CHANGE DEFAULTS---------------------(EDIT THIS ROUTINE if needed)
      CALL CHDEFAULTS(MAXPR)
C--------------------------------------(COMMENT LINE below if needed)
C-----If you have an input file the following subroutine call will 
C     override the initialisation above. If you do not wish to use an
C     input file please comment this line.
      CALL CHREADINITFILE
c--------------------------------------------------------------------

C---Pythia initialisation
      CALL PYINIT('USER','p','p',14000.0D0)
C---User defined initial routine--------(EDIT THIS ROUTINE if needed)
      CALL CHARYBEG
C--------------------------------------------------------------------

C--------------------------------------------------------------------
C                       GENERATE EVENTS
C-------------------------------------------------------------------- 
      DO 180 I=1,CHNMAXEV
         CALL PYEVNT
         IF (I.LE.10) CALL PYLIST(1)
         IF(XWGTUP.EQ.0) THEN
            WRITE(*,*)'EVENT FAILED. SKIP TO NEXT EVENT'
            GOTO 180
         END IF
         NSUCCESS=NSUCCESS+1

C--------User analysis routine----------(EDIT THIS ROUTINE if needed)
         CALL CHANAL
C--------------------------------------------------------------------

C--------Print out BH history
         CALL CHPRINT(NSUCCESS,MAXPR)

 180  CONTINUE
      CALL PYSTAT(1)
C---User's terminal calculations--------(EDIT THIS ROUTINE if needed)
      CALL CHAEND
C--------------------------------------------------------------------
      WRITE(*,*)'Total number of events generated =',NSUCCESS


***************************************************************************
ccc   GENSER output
c...Printing the total cross section in pb and its uncerainty to testi.dat:

      val=XSEC(0,3)*1E09
      errval=XSEC(0,3)*1E09/sqrt(dble(NGEN(0,3)))

c     Opening the file for output:
      OPEN(unit = 10, file = 'testi.dat', status = 'unknown')
      WRITE(10,100) ITEST, val, errval
      CLOSE(10)
100   FORMAT('charybdis2_test1',I3,2(1PE15.6))

***************************************************************************


 
      RETURN
      END

C----------------------------------------------------------------------
      SUBROUTINE CHDEFAULTS(MAXPR)
C     Routine for changing charybdis defaults. Make your changes here
C----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION(A-H, O-Z)
      IMPLICIT INTEGER(I-N)
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
C--Max number of events and printed events
      INTEGER MAXPR
C-----Common where you can change the seed (reset NRN(1))
      INTEGER NRN
      COMMON/CHRANDOM/NRN(2)
C-----Common for pythia seeds
      COMMON/PYDATR/MRPY(6),RRPY(100)

C-----Reset Charybdis Parameters here (optional)
      TOTDIM=8
      MINMSS=5000D0
      MAXMSS=14000D0
      MSSDEF=3
      MPLNCK=1000D0
      CHNMAXEV=1000
C-----Reset Les houches common blocks parameters here (optional)
      IDBMUP(1)=2212
      IDBMUP(2)=2212
      EBMUP(1)=7000.0D0
      EBMUP(2)=7000.0D0
C-----Reset XML Les Houches Event file name here (optional. Note: this is 8 characters long)
      LHEFILENAME='lhouches'
C-----Reset seed
      NRN(1)=5281415
C-----Number of events to print on screen
      MAXPR=10

C-----Don't touch this
      MRPY(1)=NRN(1)
      END

C----------------------------------------------------------------------
      SUBROUTINE CHARYBEG
C     USER'S ROUTINE FOR INITIALIZATION
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

C---Open LES HOUCHES EVENT FILE to write event
      CALL SYSTEM('rm '//LHEFILENAME//'.xml;')
      OPEN(UNIT=10,FILE=LHEFILENAME//'.xml',STATUS='NEW')
C------Write header information        
      WRITE(10,1)'<LesHouchesEvents version="1.0">'
      WRITE(10,1)'<!--'
      WRITE(10,1)'File generated with charybdis2-1.0.2 '
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
      SUBROUTINE CHANAL
C     USER'S ROUTINE TO ANALYSE DATA FROM EVENT
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
      SUBROUTINE CHPRINT(N,MAXPR)
C     PRINT OUT BH HISTORY
C----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'charybdis2.inc'
      INTEGER N,MAXPR
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

      IF((N/(CHNMAXEV/10.)-10*N/CHNMAXEV).EQ.0)WRITE(*,*)N,'EVENTS DONE'
      END

C----------------------------------------------------------------------
      SUBROUTINE CHAEND
C     USER'S ROUTINE FOR TERMINAL CALCULATIONS, HISTOGRAM OUTPUT, ETC
C----------------------------------------------------------------------
      IMPLICIT NONE
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



