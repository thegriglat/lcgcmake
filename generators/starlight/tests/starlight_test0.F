C #@# STARLIGHT test for Pb-Pb at E = 3.5 + 3.5 TeV
C #@# process: two-photon interaction
C #@# reference value - starlight r38, 1000 events
C #@# 1: cross-section


      real evnum, val, err

c        GENSER test output

c      call testfileopen  

c      open(UNIT=33,FILE='starlight_val.out')
c      read(33,*) evnum, val

      err=val/sqrt(evnum)

c      close(33)
             
c      call testfile('starlight_test0', 1, val, err)
c      call testfileclose
   
      end

