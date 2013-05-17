C #@# p p --> (Z -> tau+ tau-)  (W -> tau nutaubar) X,
C #@#
C #@# tau --> nu hadron(s), 
C #@# where "hadrons" are a1+- or rho+- or pi+- or K+-
C #@#
C #@# 1: average E(hadron(s))/E(tau) as given by PYTHIA
C #@# 2: average E(hadron(s))/E(tau) as given by TAUOLA
C
      program tautest
      implicit none      
#include "pyt_str_s.inc"
*
      double precision ECM, RAT, RAT2, RATS, RATS2
      real  RRPYT, RRTAU, DRPYT, DRTAU
      Integer I, IDC, IEV, NEV, mode
*   for TAUOLA package
      integer            PJAK1, PJAK2, MDTAU
      common /ki_taumod/ PJAK1, PJAK2, MDTAU
      save /ki_taumod/
C-----------------------------------------------------------------
      
C...First section: initialization.
      MSEL = 0
      MSTP(43) = 2 ! only Z0      
      MSUB(23) = 1 ! f + f -> Z W+-
      CKIN(3) = 30.d0     ! PThat_min
C.....Allow Z0 to decay only to tau tau
      DO IDC=MDCY(23,2),MDCY(23,2)+MDCY(23,3)-1
        IF(IABS(KFDP(IDC,1)).NE.15) MDME(IDC,1)=MIN(0,MDME(IDC,1))
      ENDDO
C.....Allow W to decay only to tau nu
      DO IDC=MDCY(24,2),MDCY(24,2)+MDCY(24,3)-1
        IF(IABS(KFDP(IDC,1)).NE.15.AND.
     &     IABS(KFDP(IDC,2)).NE.15) MDME(IDC,1)=MIN(0,MDME(IDC,1))
      ENDDO

C...Main parameters of run: c.m. energy and number of events.
      ECM=14000.0D0
      NEV = 500

C...Initialize.
      CALL PYINIT('CMS','P','P',ECM)

C...Begin event loop.
      mode = 0
      RATS = 0.d0
      RATS2 = 0.d0
      mdtau = -1
      DO IEV=1,NEV
         call PYEVNT
         call tauver2(rat, rat2)
         RATS = RATS + RAT
         RATS2 = RATS2 + RAT2
      ENDDO  ! End event loop
      RATS = RATS / float(NEV)
      RATS2 = RATS2 / float(NEV)
      RRPYT = RATS
      DRPYT = sqrt( (rats2 - rats**2)/ float(NEV) )
*
* for pretauola CMS 
      pjak1 = 0     ! all decay channels
      pjak2 = 0     ! all decay channels
      mdtau = 0
      mode = -1
      call PRETAUOLA(mode)     ! TAUOLA initialization

      mode = 0
      RATS = 0.d0
      RATS2 = 0.d0
      DO IEV=1,NEV
         call PYEVNT
         call PRETAUOLA(mode) 
         call tauver2(rat, rat2)
         RATS = RATS + RAT
         RATS2 = RATS2 + RAT2
      ENDDO  ! End event loop
      mode = 1
      call PRETAUOLA(mode) 
      RATS = RATS / float(NEV)
      RATS2 = RATS2 / float(NEV)
      RRTAU = RATS
      DRTAU = sqrt( (rats2 - rats**2)/ float(NEV) )

      print*,'******************************************************'
      print*,'* f + fbar  -> Z0 + W+/-                             *'
      print*,'* with Z0 -> tau+ tau- and W+/- -> tau+/- nutau      *'
      print*,'* E(PI+- + K+- + A1+-) / E(TAU) ratio                *'
      print*,'*   PYTHIA =',RRPYT,'   TAUOLA =',RRTAU,'    *'
      print*,'* ERPYTHIA =',DRPYT,' ERTAUOLA =',DRTAU,'  *'
      print*,'******************************************************'
    
*      call testfileopen
*      call testfile('tauola_test1', 1, RRPYT, DRPYT)
*      call testfile('tauola_test1', 2, RRTAU, DRTAU)
*      call testfileclose

      stop
      end

*----------------------------------------------------------------------------*
*-- Author   :  Serge Slabospitsky                                           *
      subroutine tauver2(rat, rat2)
      implicit none      
      integer         MSTP,               MSTI
      double precision          PARP,               PARI     
      COMMON /PYPARS/ MSTP(200),PARP(200),MSTI(200),PARI(200)
      INTEGER         N, NPAD, KK
      DOUBLE PRECISION                      PP,         VV
      COMMON /PYJETS/ N, NPAD, KK(4000,5), PP(4000,5), VV(4000,5)
      integer I, J, NT, JJ
      double precision EE, RAT, RAT2
* PI+ = 211, K+ = 321
      NT = 0
      RAT = 0.
      RAT2 = 0.
      do I = (msti(4)+1),N
        if(abs(kk(i,2)).eq.15) then
          EE = 0.d0
          JJ = 0
          do J = kk(i,4), kk(i,5)
            if(abs(kk(j,2)).eq.20213.or.abs(kk(j,2)).eq.213.
     &         or.abs(kk(j,2)).eq.211.or.abs(kk(j,2)).eq.321) then
              EE = EE + PP(J,4)
              JJ = 1
            endif
          enddo
          RAT = RAT + EE / PP(I,4)             
          RAT2 = RAT2 + (EE / PP(I,4))**2
          NT = NT + JJ
        endif
      enddo
*
      if(NT.eq.0) return
      rat = rat / float(NT)
      rat2 = rat2 / float(NT)
      return
      end
