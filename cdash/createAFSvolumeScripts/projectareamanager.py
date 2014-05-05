
import os,sys,re, time
import AFS

def skip_in_dry_mode(method):
    def decorated_method(self, *args, **argv):
        if self._dryMode == True:
            print "...SKIPPED (dry mode)"
        else:
            method(self, *args, **argv)
            #print "DONE"
    return decorated_method


class ProjectAreaManager(object):
    #(eg)
    def __init__(self, project_release, prefix, dry=False ):
        self._releasename = project_release
        if dry:
           print "=== Running in dry mode === \n"            
        self._dryMode = dry
        self._prefix =  prefix

    # create AFS area for LCG release
    # (eg)
    def create_area(self, releasename_pattern, target):
        
        print "Start CREATE_AREA script"
        prefix = self._prefix
        release = self._releasename

        path = os.path.join(prefix,release,target)
        print "Check existence of LCG release path" 
        print 'PATH: %s' % path
#        if target:
#            if not os.path.exists(os.path.join(prefix,release)):
#                raise SystemExit(os.path.join(prefix,release), "does not exist I cannot create the MCGenerators volume")
            
        if os.path.exists(path):
            print path, "already exists. Nothing to be done"
        else:
            print "Going to create mount point", path
            # define necessary size by the size of the previous (shrinked) installation +30%
            print "Looking for previous version"
            previous_release = self.get_previous_project_version(prefix,release,releasename_pattern)
            print "Previous version %s:" % previous_release
            quota = "5000000"
            if previous_release:
                if previous_release < release:
                    previous_path = os.path.join(prefix,previous_release,target)
                    print "Previous path ", previous_path
                    # previous path exists 
                    if os.path.exists(previous_path):
                        quota = max (int( int(AFS.getVolumeSize(previous_path)) * 1.3 ), int(quota))
                        print "Previous quota %s" % AFS.getVolumeSize(previous_path)
                        print "New Quota %s" % quota
                elif previous_release > release:
                    raise SystemExit ("You are creating a release older then the last one. Nothing to be done")

            if target: 
                volume_name = self.create_AFS_volume_name("x"+release+"mc")
            else: 
                volume_name = self.create_AFS_volume_name("x"+release)
            print 'Going to create volume %s of size %s and mounting at %s\n' %(volume_name, quota, path)
            self.create_AFS(path, volume_name, quota)
            if previous_release:
                print 'Going to copy ACLs from %s to %s' % (previous_path, path)
                self.copy_ACL(previous_path, path)
            else:
                print "No previous release. Going to set default premissions"
                self.set_default_ACL(path)
            self.list_ACL(path)
            self.vos_examine(volume_name)
        
    # Find the last release installed
    # (eg)
    def get_previous_project_version(self, prefix, version,releasename_pattern):
        """Return the last project version installed."""
        start_dir = os.getcwd()
        proj_dir = prefix
        try: 
            versions = [entry for entry in os.listdir(proj_dir) if re.match(releasename_pattern,entry)] 
        except OSError:
            raise StandardError("This release is not known. Maybe you mispelled it.") 
        if version in versions: 
            versions.remove(version)
        versions.sort()
        if not versions:
            return versions
        else:
            return versions[-1]


    # (eg)
    @staticmethod
    def create_AFS_volume_name(release):
        #remove name for the projects:
        #### THIS MUST BE CHANGED FOR SW PROJECT !!
        name = "p.sw.lcg."+release.lower().replace("_","").replace(".","")
        if len(name) > 22:
            print "ERROR: volume name "+name+" too large (>22 char) !"
            sys.exit(1)
        else:
            print "AFS volume name %s" % name
            return name

    # (eg)
    @skip_in_dry_mode
    def create_AFS(self, path, volume_name, quota):
        AFS.create(path, volume_name, quota)


    # (eg)
    @skip_in_dry_mode
    def set_quota(self, path, size):
        AFS.setQuota(path, size)

    #(eg)
    @skip_in_dry_mode
    def copy_ACL(self, fromdir, todir):
        AFS.copy_ACL(fromdir, todir)        

    #(eg)
    @skip_in_dry_mode
    def set_default_ACL(self, path):
        AFS.set_default_ACL(path) 

    #(eg)
    @skip_in_dry_mode
    def list_ACL(self, path):
        AFS.list_ACL(path) 

    @skip_in_dry_mode
    #(eg)
    def do_vos_release(self, path):
        AFS.doVosRelease(path)
        
    @skip_in_dry_mode
    #(eg)
    def vos_examine(self, vol):
        AFS.doVosExamine(vol)

    def finalize_area(self):
    #(eg)
        print "Start FINALIZE_ARE script"
        """Finalize the area by volume shrinking, replica creation and vos_release """
        prefix = self._prefix
        version = self._version
        print "BasePATH: %s" % self._prefix
        print "=== Area for LCG release %s:" %(version)
        path = os.path.join(prefix, version)
        for path in [ path, os.path.join(path,'MCGenerators')]:
            print path
            if not os.path.exists(path):
                print "Area does not exist!"
            else:
                volume_name = AFS.getVolume(path)
                volume_size, volume_used, percentage = AFS.getQuota(path)
                new_volume_size = int( 1.1 * volume_used )
                print "Shrink volume %s from %s to %s (110 percent of the %s used):" %(volume_name, volume_size, new_volume_size, volume_used),
                self.set_quota(path,new_volume_size)
                volume_replicas = AFS.getNumberOfReplicas(path)
                print "Number of replicas: %s," %(volume_replicas),                 
                if volume_replicas < 2 and self._dryMode == False:
                    print "adding missing replicas",
                    for i in xrange(2-volume_replicas):
                        AFS.replicateVolume(path)
                    print "...DONE" 
                else:
                    if self._dryMode:
                        print"...SKIPPED (dry mode)"
                    else: print "enough replicas exist."
                print "Do vos_release for volume %s:" %(volume_name),
                self.do_vos_release(path)  


    def delete_area(self):
    #(eg)
        print "Start DELETE_AREA script"
        # delete an afs are"
        prefix = self._prefix
        version = self._version
        path = os.path.join(prefix, version)
        for path in [ os.path.join(path,'MCGenerators'), path]:
            if not os.path.exists(path):
                print "Area does not exist!"
                print path
            else:
                print "Going to delete AFS volume %s" % path
                volume_replicas = AFS.getNumberOfReplicas(path)
                print "Number of replicas: %s," %(volume_replicas)
                if volume_replicas > 2 and self._dryMode == False:
                    print "removing replicas",
                    for i in xrange(2-volume_replicas):
                        AFS.deleteVolumeReplicas(path)
                        print"...DONE"
                else:
                    if volume_replicas == 0:
                        print "no replicas need to be deleted"
                    else:
                        print "...SKIPPED (dry mode)"
                print "Going to delete the volume %s" % path
                if self._dryMode:
                    print "...SKIPPED (dry mode)"
                else:
                    AFS.removeVolume(path)
                    print "...DONE"
                    
        
