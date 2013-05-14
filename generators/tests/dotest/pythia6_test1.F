C#@# 1: Z + jets total cross section [mb] at LHC
C#@# 2: Fraction of events with >1 charged leptons plus >1 jets

C-----------------------------------------------------------------

#include "gen_pyt_s.inc"
*
      INTEGER ITIME(10)

cc      COMMON/EVPROFILE/NEVTYPE(10)
cc      INTEGER NEVTYPE

C-----------------------------------------------------------------

C...First section: initialization.
 
cc      call pyckbd
cc                     pyckbd is called in pyinit; absent before 6_323

      CALL COLLIDERINI
      CALL ANZJETSINI

C...You may want to turn off multiple interactions
C...(default in Pythia6.3 is 1 (on)). This will make Pythia 100 times faster
C...for pp interactions

cc      MSTP(81)=0

C...Main parameters of run: c.m. energy and number of events.
      ECM=14000.0D0
      NEV=1000

C...Select Z0 + g production (two subprocesses in PYTHIA).
      MSEL=13

C...Minimal Pt of g
      CKIN(3) = 20.  ! PT LOW CUT

C...Allow Z0 to decay only to charged leptons
      DO 100 IDC=MDCY(23,2),MDCY(23,2)+MDCY(23,3)-1
        IF(IABS(KFDP(IDC,1)).NE.11.AND.IABS(KFDP(IDC,1)).NE.13.
     &     .AND.IABS(KFDP(IDC,1)).NE.15) MDME(IDC,1)=MIN(0,MDME(IDC,1))
  100 CONTINUE

C...Initialize.
      CALL PYINIT('CMS','P','P',ECM)

C...Check that Z0 decay channels set correctly.
C      CALL PYSTAT(2)

      if(MSTP(81).eq.1)then
        write(6,661) NEV, 700.*float(NEV)/10000.
      elseif(MSTP(81).eq.11)then
        write(6,661) NEV, 7000.*float(NEV)/10000.
      else
        write(6,661) NEV, 100.*float(NEV)/10000.
      endif

C-----------------------------------------------------------------

C...Second section: event loop.

C...Starting time.
      CALL PYTIME(ITIME)
      TOLD=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)

C...Begin event loop.
      DO 200 IEV=1,NEV
        CALL PYEVNT

C...List first few events.
c        IF(IEV.LE.2) CALL PYLIST(1)

C...Typical collider reconstruction.

        CALL ANZJETS

C...End event loop.
  200 CONTINUE

C...Finishing time.
      CALL PYTIME(ITIME)
      TNEW=3600D0*ITIME(4)+60D0*ITIME(5)+ITIME(6)

C-----------------------------------------------------------------

C...Third section: produce output and end.

C...Cross section table.
      CALL PYSTAT(1)

      write(6,666) NEV, TNEW-TOLD, PARI(1)

661   format(/I6, ' Events, will take about ', f8.1,
     &       ' seconds on P4-1600'/)

666   format(/ I6, ' Events generated in ', f10.4,
     &       ' seconds, cross section = ', e12.4, ' mb')

      CALL ANZJETSOUT
      CALL ANZJETSFILE('pythia_test1')
      END
