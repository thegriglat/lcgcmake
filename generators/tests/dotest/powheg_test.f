C#@#  1  NLO Cross-section [pb] of the  t \bar t  production
      program mainqqpythia
      include 'LesHouches.h'
      real * 8 parp,pari
      integer mstp,msti
      common/pypars/mstp(200),parp(200),msti(200),pari(200)
      integer MSTU,MSTJ
      double precision PARU,PARJ
      COMMON/PYDAT1/MSTU(200),PARU(200),MSTJ(200),PARJ(200)

      COMMON/PYINT5/NGENPD,NGEN(0:500,3),XSEC(0:500,3)
      INTEGER NGENPD,NGEN
      DOUBLE PRECISION XSEC

      real val, errval

      integer maxev
      real * 8 powheginput
      external powheginput
c Set up PYTHIA to accept user processes
      call PYINIT('USER','','',0d0)
c Do not stop for errors
      mstu(22)=200
      call abegin
      maxev=powheginput('maxev')
      do iev=1,maxev
         call pyevnt
c convert to hepevt common block
         call pyhepc(1)
c list the Les Houches event 
c         if(iev.eq.754) then
c         endif
c list the HEPEVT event
c          CALL PYLIST(5)
         call analize
      enddo
      call aend
      call printstat

      call testfileopen
      val = XSEC(0,3) ! total cross section
cc      errval = 0.
cc      if(NGEN(0,3).gt.0) errval = val/sqrt(float(NGEN(0,3)))
      errval = 0.001*val ! there is no easy access to the real value
      call testfile("powheg_test", 1, val, errval)
      call testfileclose

      END

      subroutine UPINIT
      implicit none
      include 'LesHouches.h'
      integer MDCY,MDME,KFDP,pycomp
      double precision brat
      COMMON/PYDAT3/MDCY(500,3),MDME(8000,2),BRAT(8000),KFDP(8000,5)
      external pycomp
      call pwhginit
      if(lprup(1).eq.1004) then
c make D+ and D- stable (using PDG codes)
         mdcy(pycomp(411),1)=0
         mdcy(pycomp(-411),1)=0
c make D0 and D0bar stable
         mdcy(pycomp(421),1)=0
         mdcy(pycomp(-421),1)=0
      elseif(lprup(1).eq.1005) then
c make B+ and B- stable
         mdcy(pycomp(521),1)=0
         mdcy(pycomp(-521),1)=0
c make B0 and B0bar stable
         mdcy(pycomp(511),1)=0
         mdcy(pycomp(-511),1)=0
      endif
      end

      subroutine UPEVNT
      call pwhgevnt
      end


      subroutine upveto
c pythia routine to abort event
      end
