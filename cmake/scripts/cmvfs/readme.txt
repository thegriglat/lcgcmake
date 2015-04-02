  CVMFS replica update instructions
  =================================

Introduction:

  - CernVM FS web site:
      http://cernvm.cern.ch/portal/startcvmfs
  
  - CVMFS maintainer instructions:
      https://twiki.cern.ch/twiki/bin/view/CvmFS/Installers
  
  - GENSER area at CVMFS:
      /cvmfs/sft.cern.ch/lcg/external/MCGenerators*
  
  - status of SFT CVMFS repository:
      http://lemon.cern.ch/lemon-web/?fb=host+%2F+clusters+%2F+lxcvmfs%25sft&target=process_search

Checkout update scripts to your public area:

  $ cd ~/public
  $ svn co svn+ssh://svn.cern.ch/reps/GENSER/doc/cvmfs
  $ cd cvmfs
  $ pwd

Sync CVMFS:

  $ ssh cvmfs-sft.cern.ch
  
  Check no one updating CVMFS repository now:
  
  $ pgrep -fl -u shared
  
  If output is non-empty, someone is updating the repository,
  you can see who with `who` command:
  
  $ who
  
  If you are alone login as 'shared' user
  
  $ sudo -i -u shared
  
  And run replication (xxx is the full path to your ~/public/cvmfs):
  
    - whole /afs/cern.ch/sw/lcg/external/MCGenerators:
  
       $ xxx/update-cvmfs.sh MCGenerators
       $ cvmfs_server publish
    
    - or one generator /afs/cern.ch/sw/lcg/external/MCGenerators_lcgcmt66/pythia8:
    
       $ xxx/update-cvmfs.sh MCGenerators_lcgcmt66/pythia8
       $ cvmfs_server publish
    
    - or one version /afs/cern.ch/sw/lcg/external/MCGenerators_lcgcmt61c/sherpa/2.0.0
    
       $ xxx/update-cvmfs.sh MCGenerators_lcgcmt61c/sherpa/2.0.0
       $ cvmfs_server publish


Note: contact Benedikt Hegner for installation of all
      dependencies (like gcc, HepMC, etc.) and access
      permissions.
