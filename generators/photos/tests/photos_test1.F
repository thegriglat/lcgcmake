C#@# Z' + gammas production at LHC
C#@# 1: Fraction of events with detectable gammas w/o PHOTOS
C#@# 2: Same but with PHOTOS
C
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays TeST program
C.
C.    Purpose:  Example of application of PHOTOS and comparison
C.              with Pythia brem.
C.
C.    Input Parameters:   None
C.
C.    Output Parameters:  None
C.
C.    Author(s):  M. Kirsanov                     Created at:  17/05/2005
C.                                                
C.----------------------------------------------------------------------
      PROGRAM MAIN
*
      IMPLICIT NONE
      integer h
      COMMON/PAWC/H(100000)
C      include 'pythia_cms.inc'
      include 'pythia_strongtyp.inc'
#include "hepevt.inc"
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      integer iprint
      common/PRINT/iprint
*                       
*       Common block from Photos, to change parameter IEXP
*
      LOGICAL INTERF,ISEC,ITRE,IEXP,IFTOP,IFW
      REAL*8 FINT,FSEC,EXPEPS
      COMMON /PHOKEY/ FSEC,FINT,EXPEPS,INTERF,ISEC,ITRE,IEXP,IFTOP,IFW
*
      INTEGER IEVENT,NEVENT
*
      INTEGER IW,IDC,I,indzprim,nele,npho,nphodet1,nphodet2,ifdet
      real pele(3,10),ppho(3,10),cost1,cost2,sint1,sint2,sint,theta
      real PHTHRESH
      real pmode1,pmode2,pmodph
*
      integer lun
      real val,errval
*
* -------------------
*
*                       You can change the main parameters here:
      iprint = 1
      NEVENT=1
      PHTHRESH = 10.  ! Threshold to accept photon
*
cc      CALL HLIMIT(100000)
*
cc      CALL HBOOK1(1,'PY: number of photons',10,-0.5,9.5,0.)
cc      CALL HBOOK1(2,'PY: photon min theta',200,0.,2.,0.)
cc      CALL HBOOK1(3,'PY: photon energy',200,0.,2000.,0.)
cc      CALL HBOOK1(4,'PY: photon energy theta.gt.0.3',200,0.,2000.,0.)
cc      CALL HBOOK1(5,'PY: photon energy theta.gt.0.5',200,0.,2000.,0.)
*
cc      CALL HBOOK1(11,'PH: number of photons',10,-0.5,9.5,0.)
cc      CALL HBOOK1(12,'PH: photon min theta',200,0.,2.,0.)
cc      CALL HBOOK1(13,'PH: photon energy',200,0.,2000.,0.)
cc      CALL HBOOK1(14,'PH: photon energy theta.gt.0.3',200,0.,2000.,0.)
cc      CALL HBOOK1(15,'PH: photon energy theta.gt.0.5',200,0.,2000.,0.)
C--
C--   Initialise PYTHIA
      MSEL=0
      MSUB(141)=1 ! Z' production
      MSTP(44) = 3 ! only Zprim, no interference with gamma, Z
      IW = PYCOMP(32) ! Zprim
      pmas(IW,1) = 4000.
      DO IDC = MDCY(IW,2), MDCY(IW,2) + MDCY(IW,3) - 1
         if(iabs(KFDP(IDC,1)).ne.11.and.              ! only electron modes
     ;      iabs(KFDP(IDC,2)).ne.11) MDME(IDC,1)=0
      ENDDO
      CALL PYINIT('CMS','P','P',14000D0)
cc      CALL PYSTAT(2)
C
C--    Event loop without Photos
C
      write(6,663) NEVENT
      nphodet1=0
      DO IEVENT=1,NEVENT
        CALL PYEVNT
C--   Write event record before emission...
        NEVHEP=IEVENT
cc        if(IEVENT.eq.1)CALL PHODMP
C--   Generate photon(s)...
cc        if(IEVENT.eq.1)CALL PHODMP
        indzprim=0
        do i=1,N
          if(k(i,2).eq.32)indzprim=i
        enddo
        if(iprint.gt.1.and.indzprim.ne.0)
     &     write(6,661) k(indzprim,5)-k(indzprim,4)+1
        nele=0
        npho=0
        do i=k(indzprim,4),k(indzprim,5)
          if(iabs(k(i,2)).eq.11) then
            nele=nele+1
            pele(1,nele)=p(i,1)
            pele(2,nele)=p(i,2)
            pele(3,nele)=p(i,3)
          endif
          if(iabs(k(i,2)).eq.22.and.p(i,4).gt.PHTHRESH) then
            npho=npho+1
            ppho(1,npho)=p(i,1)
            ppho(2,npho)=p(i,2)
            ppho(3,npho)=p(i,3)
          endif
        enddo
        if(nele.ne.2) write(6,662)
cc        call hfill(1,float(npho),0.,1.)
        ifdet=0
        if(npho.gt.0.and.nele.eq.2) then
          pmode1=sqrt(pele(1,1)**2+pele(2,1)**2+pele(3,1)**2)
          pmode2=sqrt(pele(1,2)**2+pele(2,2)**2+pele(3,2)**2)
          do i=1,npho
            pmodph=sqrt(ppho(1,i)**2+ppho(2,i)**2+ppho(3,i)**2)
cc            call hfill(3,pmodph,0.,1.)
            cost1=(ppho(1,i)*pele(1,1)+ppho(2,i)*pele(2,1)+
     &             ppho(3,i)*pele(3,1))/(pmodph*pmode1)
            if(cost1.gt.0.9999) then ! if you want to go to smaller angles
              sint1=0.               ! then double precision should be used!
            elseif(cost1.lt.0.) then
              sint1=0.99
            else
             sint1=sqrt(1.-cost1**2)
            endif
            cost2=(ppho(1,i)*pele(1,2)+ppho(2,i)*pele(2,2)+
     &             ppho(3,i)*pele(3,2))/(pmodph*pmode2)
            if(cost2.gt.0.9999) then
              sint2=0.
            elseif(cost2.lt.0.) then
              sint2=0.99
            else
             sint2=sqrt(1.-cost2**2)
            endif
            sint=sint1
            if(sint2.lt.sint1) sint = sint2
            theta=asin(sint)
cc            call hfill(2,theta,0.,1.)
cc            if(theta.gt.0.3)call hfill(4,pmodph,0.,1.)
cc            if(theta.gt.0.5)call hfill(5,pmodph,0.,1.)
            if(theta.gt.0.5.and.pmodph.gt.30.)ifdet=1
          enddo
        endif
        if(ifdet.gt.0)nphodet1=nphodet1+1
      ENDDO
C
C--    Event loop with Photos
C
      write(6,664)
      MSTJ(41)=1 ! Switch off Pythia QED bremsshtrahlung
      CALL PHOINI ! Initialise PHOTOS
      IEXP = .TRUE.
      nphodet2=0
      DO IEVENT=1,NEVENT
        CALL PYEVNT
C--   Write event record before emission...
        NEVHEP=IEVENT
cc        if(IEVENT.eq.1)CALL PHODMP
C--   Generate photon(s)...
        CALL PHINTERFZ1
cc        if(IEVENT.eq.1)CALL PHODMP
        indzprim=0
        do i=1,N
          if(k(i,2).eq.32)indzprim=i
        enddo
cc        if(indzprim.ne.0) write(6,661) k(indzprim,5)-k(indzprim,4)+1
        nele=0
        npho=0
        do i=k(indzprim,4),k(indzprim,5)
          if(iabs(k(i,2)).eq.11) then
            nele=nele+1
            pele(1,nele)=p(i,1)
            pele(2,nele)=p(i,2)
            pele(3,nele)=p(i,3)
          endif
          if(iabs(k(i,2)).eq.22.and.p(i,4).gt.PHTHRESH) then
            npho=npho+1
            ppho(1,npho)=p(i,1)
            ppho(2,npho)=p(i,2)
            ppho(3,npho)=p(i,3)
          endif
        enddo
        if(nele.ne.2) write(6,662)
cc        call hfill(11,float(npho),0.,1.)
        ifdet=0
        if(npho.gt.0.and.nele.eq.2) then
          pmode1=sqrt(pele(1,1)**2+pele(2,1)**2+pele(3,1)**2)
          pmode2=sqrt(pele(1,2)**2+pele(2,2)**2+pele(3,2)**2)
          do i=1,npho
            pmodph=sqrt(ppho(1,i)**2+ppho(2,i)**2+ppho(3,i)**2)
cc            call hfill(13,pmodph,0.,1.)
            cost1=(ppho(1,i)*pele(1,1)+ppho(2,i)*pele(2,1)+
     &             ppho(3,i)*pele(3,1))/(pmodph*pmode1)
            if(cost1.gt.0.9999) then ! if you want to go to smaller angles
              sint1=0.               ! then double precision should be used!
            elseif(cost1.lt.0.) then
              sint1=0.99
            else
             sint1=sqrt(1.-cost1**2)
            endif
            cost2=(ppho(1,i)*pele(1,2)+ppho(2,i)*pele(2,2)+
     &             ppho(3,i)*pele(3,2))/(pmodph*pmode2)
            if(cost2.gt.0.9999) then
              sint2=0.
            elseif(cost2.lt.0.) then
              sint2=0.99
            else
             sint2=sqrt(1.-cost2**2)
            endif
            sint=sint1
            if(sint2.lt.sint1) sint = sint2
            theta=asin(sint)
cc            call hfill(12,theta,0.,1.)
cc            if(theta.gt.0.3)call hfill(14,pmodph,0.,1.)
cc            if(theta.gt.0.5)call hfill(15,pmodph,0.,1.)
            if(theta.gt.0.5.and.pmodph.gt.30.)ifdet=1
          enddo
        endif
        if(ifdet.gt.0)nphodet2=nphodet2+1
      ENDDO
C-
      write(6,665) float(nphodet1)/float(NEVENT)
      write(6,666) float(nphodet2)/float(NEVENT)
*
cc      lun = 36
cc      OPEN(lun, file='testi.dat', status='UNKNOWN', form='formatted')
      call testfileopen
*
      val = float(nphodet1)/float(NEVENT) ! fraction with detectable gamma
      errval = 0.
      if(nphodet1.gt.0) then
        errval = val*sqrt(1./float(nphodet1))
      endif
      call testfile('photos_test1', 1, val, errval)
*
      val = float(nphodet2)/float(NEVENT) ! fraction with detectable gamma
      errval = 0.
      if(nphodet2.gt.0) then
        errval = val*sqrt(1./float(nphodet2))
      endif
      call testfile('photos_test1', 2, val, errval)
*
cc      close(lun)
      call testfileclose
*
cc      CALL HMSTO4(2)
      STOP
661   format('number of Zprim decay products: ',i3)
662   format('less than 2 electrons!')
663   format('starting event loop without Photos, Nevents = ',i6)
664   format('starting event loop with Photos')
665   format('PYTHIA BREM: fract. of events with detectable gamma:',
     &       f5.4)
666   format('PHOTOS BREM: fract. of events with detectable gamma:',
     &       f5.4)
      END
*
      SUBROUTINE PHINTERFZ1
C.----------------------------------------------------------------------
C.
C.    PHOTOS: Interface to Pythia Z' production and lepton decay
C.
C.    Purpose: Take Z' and its decay products, make QED corrections
C.             (emit photon(s)), put everything back to PYJETS.
C.             The point is that Photos does not understand PYTHIA
C.             event record with INFO lines.
C.
C.    Input Parameters:   Common /PYJETS/
C.
C.    Output Parameters:  Common /HEPEVT/
C.
C.    Author(s):  M. Kirsanov                     Created at:  17/05/2005
C.
C.----------------------------------------------------------------------
      IMPLICIT NONE

C      include 'pythia_cms.inc'
      include 'pythia_strongtyp.inc'
#include "hepevt.inc"
      integer iprint
      common/PRINT/iprint

      integer nprinted
      INTEGER I,NZ,J,N_OLD,N_NEW,LZ(2),IZ,IPD1,IPD2,JP1,JP2
      INTEGER    NHEP_BEF_PHOTOS,NHEP_AFT_PHOTOS
      INTEGER NHEPORI,I_PARENT,KF_PARENT,KF_CODE,IFIRSTNEW,N21
      INTEGER NCOM,NNOCOM,KTEMP(4000,5)
      REAL PTEMP(4000,5),VTEMP(4000,5)
      data nprinted/0/
*
*       Perform Z' decays allowing for radiation using PHOTOS, as follows:
*       ------------------------------------------------------------------------
*
*       1.  clear HEPEVT common (which contains full event)
*       2.  copy two Z's and decay products (4 leptons) into HEPEVT common
*       3.  allow PHOTOS to deal with the radiation in Z decays
*       4.  move "new leptons" and photons to (empty) end of PYJETS
*       5.  flag original leptons in PYJETS as "documentation" and
*           update pointers to and from modified leptons and new photons
*
*       Steps 6 to 10 carried out only if one or both Zs have decayed to taus:
*       6.  clear HEPEVT common
*       7.  copy taus and their decay products (1 charged lepton plus 2
*           neutrinos for each tau) into HEPEVT common
*       8.  allow PHOTOS to deal with the radiation in tau decays
*       9.  move new tau decay products and photons to (empty) end of PYJETS
*       10. flag original tau decay products in PYJETS as "documentation" and
*           update pointers to and from modified tau decay products and new
*           photons
*
*       11. fill HEPEVT common with (modified) full event
*
*
      NHEPORI = N
*
*         Zero HEPEVT and Pythia arrays
*
      NHEP = 0
      do i=1,nmxhep
        ISTHEP(i)=0
        IDHEP(i)=0
        JMOHEP(1,i)=0
        JMOHEP(2,i)=0
        JDAHEP(1,i)=0
        JDAHEP(2,i)=0
        do j=1,5
          PHEP(j,i)=0.
          if(j.le.4)VHEP(j,i)=0.
        enddo
      enddo

cc      CALL VZERO (ISTHEP,   NMXHEP)
cc      CALL VZERO (IDHEP,    NMXHEP)
cc      CALL VZERO (JMOHEP, 2*NMXHEP)
cc      CALL VZERO (JDAHEP, 2*NMXHEP)
cc      CALL VZERO (PHEP,5*NMXHEP*2)    ! Note: double precision
cc      CALL VZERO (VHEP,4*NMXHEP*2)
*
*       Fill Z' decay products into HEPEVT common
*       ----------------------------------------
*
      NZ = 0
*
      DO I=1,N
*
        IF(K(I,1) .EQ. 11 .AND. K(I,2) .EQ. 32) THEN    ! This is a Z'
*
          NZ           = NZ + 1
*
          IF (NZ .GT. 1) THEN
            WRITE (*,*) '**KIS_HEAVYNU** Error: >1 Z''s in event!'
            STOP '=> FORTRAN STOP'
          ENDIF
*
          NEVHEP       = 0              ! Event number (unused)
          NHEP         = 3              ! No. of particles to go in HEPEVT
*
          IPD1         = K (I,4)        ! Index of 1st  daughter of Z'
          IPD2         = K (I,5)        ! Index of last daughter of Z'

*
          JP1          = 2              ! Offset in HEPEVT of 1st  daughter
          JP2          = 3              ! Offset in HEPEVT of last daughter
*
          ISTHEP (NZ)  = 2              ! \ Do not end line with a backslash!
          ISTHEP (JP1) = 1              !  }-   Status codes
          ISTHEP (JP2) = 1              ! /
*
          IDHEP  (NZ)  = K (I,   2)     ! \ Do not end line with a backslash!
          IDHEP  (JP1) = K (IPD1,2)     !  }-   KF codes
          IDHEP  (JP2) = K (IPD2,2)     ! /
*
          JMOHEP (1,NZ)  = 0            ! 1st mother of Z (none)
          JMOHEP (2,NZ)  = 0            ! 2nd mother of Z (none)
          JMOHEP (1,JP1) = NZ           ! 1st mother of lepton
          JMOHEP (2,JP1) = 0            ! 2nd mother of lepton
          JMOHEP (1,JP2) = NZ           ! 1st mother of lepton
          JMOHEP (2,JP2) = 0            ! 2nd mother of lepton
*
          JDAHEP (1,NZ)  = JP1          ! 1st daughter of Z
          JDAHEP (2,NZ)  = JP2          ! 2nd daughter of Z
          JDAHEP (1,JP1) = 0            ! 1st daughter of lepton
          JDAHEP (2,JP1) = 0            ! 2nd daughter of lepton
          JDAHEP (1,JP2) = 0            ! 1st daughter of lepton
          JDAHEP (2,JP2) = 0            ! 2nd daughter of lepton
*
          DO J=1,5
            PHEP (J,NZ)  = P (I,J)
            PHEP (J,JP1) = P (IPD1,J)
            PHEP (J,JP2) = P (IPD2,J)
          ENDDO
*
*
          DO J=1,4
            VHEP (J,NZ)  = V (I,J)
            VHEP (J,JP1) = V (IPD1,J)
            VHEP (J,JP2) = V (IPD2,J)
          ENDDO
*
        ENDIF
*
      ENDDO
*
*       Call PHOTOS to generate radiation in Z' decay
*       --------------------------------------------
*
      NHEP_BEF_PHOTOS=NHEP
      CALL PHOTOS (1)

      NHEP_AFT_PHOTOS=NHEP
      IF(iprint.gt.1.and.NHEP_BEF_PHOTOS.NE.NHEP_AFT_PHOTOS)
     &     WRITE(*,*) NHEP_AFT_PHOTOS-NHEP_BEF_PHOTOS,
     &     ' NEW PARTICLES FROM PHOTOS IN Zprim DECAY!!!',
     &     NHEP_BEF_PHOTOS,NHEP_AFT_PHOTOS,IDHEP(1)

      IF(NHEP_AFT_PHOTOS.GT.NHEP_BEF_PHOTOS)THEN  ! --- actions if generated -

        if(iprint.gt.1) call pylist(5)
        if(iprint.eq.1) then
          if(nprinted.eq.0) then
            call pylist(5)
            nprinted = nprinted + 1
          endif
        endif
*
*         Original leptons still in PYJETS => flag lines as documentation only
*         --------------------------------------------------------------------
*
        DO I = 1,N
          IF(K(I,1).EQ.1) THEN
*
            I_PARENT  = K(I,3)
            KF_PARENT = IABS (K(I_PARENT,2)) ! KF code of the parent
            KF_CODE   = IABS (K(I,2)) ! KF code of the particle
*
*           Need to flag ORIGINAL leptons as documentation lines
*           (the parents of these are ALSO leptons (due to Pythia convention),
*           the parents of THESE are then the Z!)
*
            IF( (KF_CODE .EQ. 11  .AND. KF_PARENT .EQ. 11) ) THEN
              K(I,1) = 21                       ! flag as documentation line
            ENDIF
*
          ENDIF
        ENDDO
*
*
*         Count Z's in the event and save the corresponding indices
*         ---------------------------------------------------------
*
        NZ=0
*
        DO I = 1,N
          IF(K(I,1).EQ.11 .AND. K(I,2) .EQ. 32) THEN  ! Save index to Z'
*
            NZ      = NZ + 1
            LZ (NZ) = I
*
          ENDIF
        ENDDO
*
*
*         Copy leptons and any extra photons back into PYJETS
*         ---------------------------------------------------
*
        N_OLD = N
        N_NEW = N
*
        DO I=1,NHEP
*
          KF_CODE = IABS (IDHEP(I))
*
          IF( KF_CODE .EQ. 11 .OR.
     &        KF_CODE .EQ. 22) THEN
*
            N_NEW  = N_NEW + 1
*
            K (N_NEW,1) = 1
            K (N_NEW,2) = IDHEP(I)
            K (N_NEW,3) = LZ(1)
            K (N_NEW,4) = 0
            K (N_NEW,5) = 0
*
*
            DO J=1,5
              P (N_NEW,J) = PHEP(J,I)
            ENDDO
*
            DO J=1,4
              V (N_NEW,J) = VHEP(J,I)
            ENDDO
*
          ENDIF
        ENDDO
*
*         Point last daughters of Z's to the "new" leptons/photons
*         --------------------------------------------------------
*
        DO IZ = 1,NZ                        ! Loop over Z's
          DO I = N_OLD+1, N_NEW             ! Loop over "extra" particles
*
            IF(K(I,3) .EQ. LZ(IZ)) THEN     ! Parent is Z
              K(LZ(IZ),5) = I               ! Set "last daughter" of Z
            ENDIF
*
          ENDDO
        ENDDO
*
*
*         Point first daughters of Z's to the "new" leptons/photons
*         ---------------------------------------------------------
*
        K(LZ(1),4) = N_OLD      + 1 ! 1st "extra particle"
*
*
        N = N_NEW                   ! New no. of particles in PYJETS
        IFIRSTNEW = N_OLD+1

***** Put all the '21' particles first

        N21 = 0
        DO I=1,NHEPORI
          IF(K(I,1).EQ.21) N21 = N21 + 1
        ENDDO
        NCOM = 0
        NNOCOM = N21
        DO I=1,NHEPORI
*
          IF(K(I,1).EQ.21) THEN
            NCOM = NCOM + 1
            N_NEW = NCOM
          ELSE
            NNOCOM = NNOCOM + 1
            N_NEW = NNOCOM
          ENDIF
          DO J=1,5
            KTEMP(N_NEW,J) = K(I,J)
            PTEMP(N_NEW,J) = P(I,J)
            VTEMP(N_NEW,J) = V(I,J)
          ENDDO
*
        ENDDO

        DO I=1,NHEPORI
*
          DO J=1,5
            K(I,J) = KTEMP(I,J)
            P(I,J) = PTEMP(I,J)
            V(I,J) = VTEMP(I,J)
          ENDDO
*
        ENDDO
*
****** Restore correct mother after reordering above
*
        IF(NHEP_AFT_PHOTOS.GT.NHEP_BEF_PHOTOS)THEN
          DO I = 1,N
            IF(K(I,1).EQ.11 .AND. K(I,2) .EQ. 32) THEN  ! Save index to Z'
              LZ (1) = I
            ENDIF
          ENDDO
          DO I = IFIRSTNEW, N
            K (I,3) = LZ(1)
          ENDDO
        ENDIF

      ENDIF  !  ---------  end of actions in case of photons generarion

*       Re-fill HEPEVT common with FULL event from PYJETS
*       -------------------------------------------------

      CALL PYHEPC(1)
*
      RETURN
      END
*
      SUBROUTINE PHODMP
C.----------------------------------------------------------------------
C.
C.    PHOTOS:   PHOton radiation in decays event DuMP routine
C.
C.    Purpose:  Print event record.
C.
C.    Input Parameters:   Common /HEPEVT/
C.
C.    Output Parameters:  None
C.
C.    Author(s):  B. van Eijk                     Created at:  05/06/90
C.                                                Last Update: 05/06/90
C.
C.----------------------------------------------------------------------
C      IMPLICIT NONE
      DOUBLE PRECISION  SUMVEC(5)
      INTEGER I,J
#include "hepevt.inc"
      INTEGER PHLUN
      COMMON/PHOLUN/PHLUN
      DO 10 I=1,5
   10 SUMVEC(I)=0.
C--
C--   Print event number...
      WRITE(PHLUN,9000)
      WRITE(PHLUN,9010) NEVHEP
      WRITE(PHLUN,9080)
      WRITE(PHLUN,9020)
      DO 30 I=1,NHEP
C--
C--   For 'stable particle' calculate vector momentum sum
        IF (JDAHEP(1,I).EQ.0) THEN
          DO 20 J=1,4
   20     SUMVEC(J)=SUMVEC(J)+PHEP(J,I)
          IF (JMOHEP(2,I).EQ.0) THEN
            WRITE(PHLUN,9030) I,IDHEP(I),JMOHEP(1,I),(PHEP(J,I),J=1,5)
          ELSE
            WRITE(PHLUN,9040) I,IDHEP(I),JMOHEP(1,I),JMOHEP(2,I),(PHEP
     &      (J,I),J=1,5)
          ENDIF
        ELSE
          IF (JMOHEP(2,I).EQ.0) THEN
            WRITE(PHLUN,9050) I,IDHEP(I),JMOHEP(1,I),JDAHEP(1,I),
     &      JDAHEP(2,I),(PHEP(J,I),J=1,5)
          ELSE
            WRITE(PHLUN,9060) I,IDHEP(I),JMOHEP(1,I),JMOHEP(2,I),
     &      JDAHEP(1,I),JDAHEP(2,I),(PHEP(J,I),J=1,5)
          ENDIF
        ENDIF
   30 CONTINUE
      SUMVEC(5)=SQRT(SUMVEC(4)**2-SUMVEC(1)**2-SUMVEC(2)**2-
     &SUMVEC(3)**2)
      WRITE(PHLUN,9070) (SUMVEC(J),J=1,5)
      RETURN
 9000 FORMAT(1H0,80('='))
 9010 FORMAT(1H ,29X,'Event No.:',I10)
 9020 FORMAT(1H0,1X,'Nr',3X,'Type',3X,'Parent(s)',2X,'Daughter(s)',6X,
     &'Px ',7X,'Py ',7X,'Pz ',7X,'E ',4X,'Inv. M.')
 9030 FORMAT(1H ,I4,I7,3X,I4,9X,'Stable',2X,5F10.4)
 9040 FORMAT(1H ,I4,I7,I4,' - ',I4,5X,'Stable',2X,5F10.4)
 9050 FORMAT(1H ,I4,I7,3X,I4,6X,I4,' - ',I4,5F10.4)
 9060 FORMAT(1H ,I4,I7,I4,' - ',I4,2X,I4,' - ',I4,5F10.4)
 9070 FORMAT(1H0,23X,'Vector Sum: ', 5F10.4)
 9080 FORMAT(1H0,6X,'Particle Parameters')
      END
C
      subroutine testfileopen
      INTEGER lun
      lun = 36
      OPEN(lun, file='testi.dat', status='UNKNOWN', form='formatted')
      END
*
      subroutine testfileclose
      INTEGER lun
      lun = 36
      close(lun)
      END
*
      subroutine testfile(genname, itest, value, error)
      implicit none
      character*(*) genname
      integer itest
      real value, error
*
      write(36,1) genname, itest, value, error
      return
1     format(A, 1X, I2, 1X, E14.6, 1X, E14.6)
      end
C
      SUBROUTINE HMSTO4(LUNH)  
C.    * 
C.    *  STORES HISTOGRAMS ON DISK, CANAL LUNH
C.    * 
      DATA IWRIT/0/
cc      IF(IWRIT.LE.0)CALL HROPEN(LUNH,'M','hist.dat',' N',1024,IOK)
cc      IF(IWRIT.GT.0)CALL HROPEN(LUNH,'M','hist.dat','  ',1024,IOK)
cc      CALL HROUT(0,ICICLE,' ')
cc      CALL HREND('M')
      CLOSE (LUNH)   
      IWRIT=IWRIT+1
      RETURN
      END
