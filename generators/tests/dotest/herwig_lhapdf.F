C#@# 5-26: Single W production total cross section [mb] at LHC
C#@# with various PDF sets.

      PROGRAM herwig_lhapdf

c... Common blocks are included from file herwig65.inc

#include "HERWIG65.INC"

      external HWUDAT
      integer MINTEST,MAXTEST
      parameter (MINTEST=5,MAXTEST=26)
      integer IPDFSET(MINTEST:MAXTEST)
      integer Ievt, Nevt, ITEST
      double precision val,XNWGTS,RNWGT,SPWGT,errval
      logical iopened

c... using only central value PDF sets (*.LHgrid only, as
c... calculating PDFs "in flight" is too CPU consuming):
c... see http://hepforge.cedar.ac.uk/lhapdf/manual5#tth_sEcA
     
C######################################################################
C NOTE: "It should be noted that we have only added leading-order fits
C because the evolution algorithms in HERWIG, in particular the
C backward-evolution algorithm for initial-state parton showering, are
C only leading-order and therefore inconsistencies could occur with
C next-to-leading-order distributions."
C
C See http://webber.home.cern.ch/webber/hw65_manual.html for details.
C
C######################################################################
      
      data IPDFSET/
     &19050,19051,19060,19070,19150,19160,19170,
     &20050,20052,20053,20054,20060,20070,20250,20270,20350,20370,
     &20450,20470,
     &70050,70250,70150
     &/

      data iopened/.FALSE./
c... --------------------------------------------------------

*          Opening the file for output:
      open(unit=11,file='testi.dat',status='unknown')

      DO 01 ITEST = MINTEST,MAXTEST

c         write(11,101) ITEST

c... Number of events 
         Nevt = 1000
c... Beams
         PART1 = 'P'
         PART2 = 'P'
c... Beam momenta
         PBEAM1 = 7000.
         PBEAM2 = 7000.
c... Process q qbar --> W+-
         IPROC = 1499
c... Initialising other common blocks
         call HWIGIN
         
c Increase threshould on number of errors before termination
c of the run, to prevent probram abort with PDF sets 19060 and 70150
         MAXER = 50

c. User can reset parameters at this point, otherwise default
c  values set HWIGIN will be used

c... Setting PDF sets, see http://hepforge.cedar.ac.uk/lhapdf/manual5#tth_sEcA
         AUTPDF(1) = 'HWLHAPDF'
         AUTPDF(2) = 'HWLHAPDF'
         MODPDF(1) = IPDFSET(ITEST)
         MODPDF(2) = IPDFSET(ITEST)
c... pT > 10 GeV:
         PTMIN = 10.
         call HWUINC             ! Compute parameter-dependent constants
C         call HWUSTA('PI0     ') ! Call HWUSTA to make any particle stable
         call HWABEG             ! User's initial calculations
         call HWEINI             ! Initialise elementary process
c... Event loop:
         DO 02 Ievt = 1,Nevt
            call HWUINE ! Initialise event
            call HWEPRO ! Generate hard subprocess
            call HWBGEN ! Generate parton cascades
            call HWDHOB ! Do heavy object decays
            call HWCFOR ! Do cluster formation
            call HWCDEC ! Do cluster decays
            call HWDHAD ! Do unstable particle decays
            call HWDHVY ! Do heavy flavour hadron decays
            call HWMEVT ! Add soft underlying event if needed
            call HWUFNE ! Finalize event
            call HWANAL ! User's event analysis: dummy in our case
02       CONTINUE

         call HWEFIN ! Terminate elementary process

         call HWAEND ! User's terminal calculations

C-- printing the total cross section in mb and its uncertainty to testi.dat:

         val = AVWGT*1.e-6
         XNWGTS=NWGTS
         RNWGT = 1./XNWGTS
         SPWGT = sqrt(max(WSQSUM*RNWGT - AVWGT**2 , 0.))
         errval = SPWGT*sqrt(RNWGT)*1.e-6
         if(.NOT.iopened) then
           open(unit=11,file='testi.dat',status='unknown')
           iopened = .TRUE.
         endif
         write(11,100) ITEST, val, errval
c         write(11,102) val, errval       

01    CONTINUE ! End loop over PDF sets

      close(11)

100   format('herwig_lhapdf',I3,2E15.6)
c.....FIXME: linefeed suppresion can be system dependent
101   format('herwig_lhapdf',I3,$)
102   format(2E15.6)
    

      END

c-------------------------------------------------------------------

c... User's routine for initialization:

      subroutine HWABEG
      end

c... User's routine for terminal calculations, histogram output, etc:
c... Adopted from herwig's HWEFIN()

      subroutine HWAEND

#include "HERWIG65.INC"

      integer ITEST, I
      DOUBLE PRECISION RNWGT,SPWGT,ERWGT
C--Les Houches Common Block
      INTEGER MAXPUP
      PARAMETER(MAXPUP=100)
      INTEGER IDBMUP,PDFGUP,PDFSUP,IDWTUP,NPRUP,LPRUP
      DOUBLE PRECISION EBMUP,XSECUP,XERRUP,XMAXUP
      COMMON /HEPRUP/ IDBMUP(2),EBMUP(2),PDFGUP(2),PDFSUP(2),
     &                IDWTUP,NPRUP,XSECUP(MAXPUP),XERRUP(MAXPUP),
     &                XMAXUP(MAXPUP),LPRUP(MAXPUP)
C--output Les Houches common block information
      IF(IPROC.LE.0) THEN
C--FOR THE FIRST WEIGHT OPTION CALCULATE THE CROSS SECTION
        IF(ABS(IDWTUP).EQ.1) THEN
          DO I=1,NPRUP
            RNWGT     = 1.0D0/DBLE(LHIWGT(I))
            LHXSCT(I) = LHWGT(I)*RNWGT
            LHXERR(I) = SQRT(MAX(LHWGTS(I)*RNWGT-LHXSCT(I)**2,ZERO))
            LHXERR(I) = LHXERR(I)*SQRT(RNWGT)
            LHXSCT(I) = LHXSCT(I)*1.0D3
            LHXERR(I) = LHXERR(I)*1.0D3
            LHXMAX(I) = LHXMAX(I)*1.0D3
          ENDDO
C--FOR THE SECOND WEIGHT OPTION THIS WAS AN INPUT
        ELSEIF(ABS(IDWTUP).EQ.2) THEN
          DO I=1,NPRUP
            LHXMAX(I) = LHXMAX(I)*1.0D3
          ENDDO
        ENDIF
        IF(ABS(IDWTUP).LE.2) THEN
          AVWGT = ZERO
          ERWGT = ZERO
          DO I=1,NPRUP
            AVWGT = AVWGT+LHXSCT(I)
            ERWGT = ERWGT+LHXERR(I)**2
          ENDDO
          AVWGT = AVWGT*1.0D-3
          ERWGT = SQRT(ERWGT)*1.0D-3
        ELSE
          RNWGT=1./FLOAT(NWGTS)
          IF (NEGWTS) AVABW=ABWSUM*RNWGT
          AVWGT=WGTSUM*RNWGT
          SPWGT=SQRT(MAX(WSQSUM*RNWGT-AVWGT**2,ZERO))
          ERWGT=SPWGT*SQRT(RNWGT)
          IF (.NOT.NOWGT) WGTMAX=AVWGT
          IF (WGTMAX.EQ.ZERO) WGTMAX=ONE
        ENDIF
C--STANDARD HERWIG OPTION
      ELSE
        RNWGT=1./FLOAT(NWGTS)
        IF (NEGWTS) AVABW=ABWSUM*RNWGT
        AVWGT=WGTSUM*RNWGT
        SPWGT=SQRT(MAX(WSQSUM*RNWGT-AVWGT**2,ZERO))
        ERWGT=SPWGT*SQRT(RNWGT)
        IF (.NOT.NOWGT) WGTMAX=AVWGT
        IF (WGTMAX.EQ.ZERO) WGTMAX=ONE
      ENDIF
      end

c... User's routine to analyse data from event:

      subroutine HWANAL
      end

