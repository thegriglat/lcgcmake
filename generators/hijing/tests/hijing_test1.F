C #@# HIJING 1.383bs.2 test for Au-Au at E=5.5TeV per NN collision
C #@# reference value - 1.383bs.2, 1000 events
C #@# 1 Mean multiplicity for |eta| < 1 and Pt > 0.1GeV/c
 


C****************************************************************************
C     The program for calculation of the general properties of
C                   interactions in the HIJING model.
C	          Written by V.Uzhinsky, CERN, Oct. 2003
C***************************************************************************

      CHARACTER FRAME*8,PROJ*8,TARG*8

      COMMON/HIMAIN1/ NATT,EATT,JATT,NT,NP,N0,N01,N10,N11
      COMMON/HIMAIN2/KATT(130000,4),PATT(130000,4)

C         ********information of produced particles
C

      COMMON/HIPARNT/HIPR1(100),IHPR2(50),HINT1(100),IHNT2(50)
      SAVE  /HIPARNT/

  
     

 

      COMMON/RANSEED/NSEED
      SAVE  /RANSEED/

      real mean1,sqr1,mean2,sqr2,mean3,sqr3,N_ch1,N_ch2,N_ch3


      NSEED=0

      write(6,*)'====================================================='
      write(6,*)'The program for calculation of general properties of '
      write(6,*)'         interactions in the HIJING model.           '
      write(6,*)'====================================================='
      write(6,*)
      write(6,*)'CM system is used --------------------------------'
      FRAME='CMS'

      write(6,*)'The energy per NN collision  = 5500 GeV'

      EFRM=5500.

      write(6,*)
      write(6,*)'projectile particle - Au (Z=79, A=197)'
      write(6,*)
  
      PROJ='A'
      IAP=197
      IZP=79
 

      write(6,*)
      write(6,*)'target particle - Au (Z=79, A=197)'
      write(6,*)
   
      TARG='A'
      IAT=197
      IZT=79
   

      write(6,*)
      write(6,*)'number of events = 100'
      write(6,*)

      N_events=100



c------------------------------------------------------------------
      CALL HIJSET(EFRM,FRAME,PROJ,TARG,IAP,IZP,IAT,IZT)
C			********Initialize HIJING

      WRITE(6,*)' Simulation of interactions with'
      WRITE(6,*)
      WRITE(6,*)' Proj = ',PROJ,' and  Targ = ',TARG
      WRITE(6,*)' IAP  =',IAP  ,'            IAT  =',IAT
      WRITE(6,*)' IZP  =',IZP  ,'            IZT  =',IZT
      WRITE(6,*)
      WRITE(6,*)' Reference frame -   ',FRAME
      WRITE(6,*)' ENERGY            ',EFRM,' GeV'
      WRITE(6,*)' Number of generated events -',N_events
      WRITE(6,*)

      BMIN=0.
      BMAX=HIPR1(34)+HIPR1(35)

c------------------------------------------------------------------
c----------------- Charged particles ------------------------------
c------------------------------------------------------------------


      Nu_max=MIN(IAP*IAT+1,2000)


      if(PROJ.eq.'A'.or.TARG.eq.'A') then
        CH_max=5*Nu_max
        M_neg=CH_max/2.
      else
        CH_max=99.5
        M_neg=CH_max
      endif


      if(FRAME.eq.'CMS') then
        Eta_l=-15.
        Eta_h=+15.
      else
        Eta_l=-2.0
        Eta_h=Alog(2.*EFRM)+2.
      endif
      NbinEta=(Eta_h-Eta_l)/0.2



      if(FRAME.eq.'CMS') then
        Y_l=-Alog(EFRM)-2.
        Y_h=+Alog(EFRM)+2.
      else
        Y_l=-2.0
        Y_h=Alog(2.*EFRM)+2.
      endif
      NbinY=(Y_h-Y_l)/0.2



      if(FRAME.eq.'CMS') then
        E_l= 0.
        E_h=EFRM/2.
      else
        E_l= 0.
        E_h=EFRM
      endif
      NbinE=(E_h-E_l)/0.5




      open(UNIT=31,FILE='mult_ch1.txt')
      open(UNIT=32,FILE='mult_ch2.txt')
      open(UNIT=33,FILE='mult_ch3.txt')
      open(UNIT=40,FILE='pt_ch.txt')

      Pi=4.*ATAN(1.)                   ! 3.14159

ccc   putting <N>  and  <N**2> equal to zero
      mean1=0.
      sqr1=0.
      mean2=0.
      sqr2=0.
      mean3=0.
      sqr3=0.

      DO 2000 I_event=1,N_events

        WRITE(6,*)' Event # ',I_event,' ------------------'
C
        CALL HIJING(FRAME,BMIN,BMAX)
C
        B=HINT1(19)


        Nu=N0+N01+N10+N11


        N_ch=0
        N_neg=0
        N_pos=0
        N_protons=0
        N_gammas=0

ccc   putting multiplicities equal to zero
        N_ch1=0.
        N_ch2=0.
        N_ch3=0.
  

       

        DO 3000 I=1,NATT

          if(KATT(I,2).eq. 0) go to 3000 ! reject non-interacting projectile
          if(KATT(I,2).eq. 1) go to 3000 ! reject elastic scattering
          if(KATT(I,2).eq.10) go to 3000 ! reject non-interacting target
          if(KATT(I,2).eq.11) go to 3000 ! reject elastic scattering

          ID=KATT(i,1)

          ICH=LUCHGE(KATT(I,1))/3

          Amass=ULMASS(KATT(I,1))

          E=PATT(i,4)
          Pz=PATT(i,3)
          Pt=sqrt(PATT(i,1)**2+PATT(i,2)**2)
          P=sqrt(Pz**2+Pt**2)

          if(P-Pz.ge.1.0e-4) then
            Eta= 0.5*Alog((P+Pz)/(P-Pz))
          elseif(P+Pz.ge.1.0e-4) then
            Eta=-0.5*Alog((P-Pz)/(P+pz))
          else
            Eta=15.
          endif

          if(E-Pz.ge.1.0e-4) then
            Y= 0.5*Alog((E+Pz)/(E-Pz))
          elseif(E+Pz.ge.1.0e-4) then
            Y=-0.5*Alog((E-Pz)/(E+pz))
          else
            Y=15.
          endif


          if(P.ge.1.0e-4) then
            Cos_Theta=Pz/P
          else
            Cos_Theta=1.
          endif

          Phi=ULANGL(PATT(i,1),PATT(i,2))*180./Pi
c==========================================================

          if(ICH.ne.0) then

ccc   main cut: |eta| < 1 , Pt > 0.1 GeV/c
            if(Pt.gt.0.1.and.abs(Eta).lt.1) then
               N_ch1=N_ch1+1.
               write(40,*) Pt,Eta
            endif

ccc   additional cut: |eta| < 1 , Pt > 0.2 GeV/c
            if(Pt.gt.0.2.and.abs(Eta).lt.1) then
               N_ch2=N_ch2+1
            endif
ccc   additional cut: |eta| < 1 , Pt > 0.3 GeV/c
            if(Pt.gt.0.3.and.abs(Eta).lt.1) then
               N_ch3=N_ch3+1
            endif


          endif

          if(ICH.lt.0) then
            N_neg=N_neg+1


          endif

          if(ICH.gt.0) then
            N_pos=N_pos+1


          endif

          if(Id.eq.2212) then
            N_protons=N_protons+1


          endif

          if(Id.eq.  22) then
            N_gammas=N_gammas+1


          endif

          

3000    CONTINUE

         write(31,*) N_ch1,N_ch1**2
         write(32,*) N_ch2,N_ch2**2
         write(33,*) N_ch3,N_ch3**2

         mean1=mean1+N_ch1/float(N_events)   
         sqr1=sqr1+N_ch1**2/float(N_events)
  
         mean2=mean2+N_ch2/float(N_events)   
         sqr2=sqr2+N_ch2**2/float(N_events) 
 
         mean3=mean3+N_ch3/float(N_events)   
         sqr3=sqr3+N_ch3**2/float(N_events)  
        





2000  CONTINUE

c================ Normalization ===========================

      C1=1./float(N_events)                        ! Multiplicity distr.
      C2=0.



      C1=1./float(N_events)/((Eta_h-Eta_l)/NbinEta)! Eta distr.
      C2=0.



      C1=1./float(N_events)/((Y_h-Y_l)/NbinY)      ! Y distr.
      C2=0.


      C1=1./float(N_events)/0.1                    ! Pt distr.
      C2=0.



      C1=1./float(N_events)/((E_h-E_l)/NbinE)      ! E distr.
      C2=0.



      C1=1./float(N_events)/0.05                   ! Cos Theta distr.
      C2=0.



      C1=1./float(N_events)                        ! Phi distr.
      C2=0.


      close(33)
      close(34)


c        GENSER test output

c      call testfileopen  

ccc   Y = charged particles multiplicity
      val=mean1
c     Y error is calculated as for gauss distribution
      errval=sqrt(sqr1 - mean1**2)/sqrt(float(N_events))                
c      call testfile('hijing_test1', 1, val, errval)
c      call testfileclose


      print*,'mean,error, D, N_events  ',mean1,errval,sqr1,N_events
 


      END

      FUNCTION RAN(NSEED)                                            
      RAN=RLU(NSEED)                                           
      RETURN                                                   
      END
