C #@# STARLIGHT test for Pb-Pb at E = 3.5 + 3.5 TeV
C #@# process: two-photon interaction
C #@# reference value - starlight r38, 1000 events
C #@# 1: cross-section


      real evnum, val, err

c        GENSER test output

      call testfileopen  

      open(UNIT=33,FILE='starlight_val.out')
      read(33,*) evnum, val

      err=val/sqrt(evnum)

      close(33)
             
      call testfile('starlight_test0', 1, val, err)
      call testfileclose
   
      end

