
import os,sys,re
import AFS

def skip_in_dry_mode(method):
    def decorated_method(self, *args, **argv):
        if self._dryMode == True:
            print "...SKIPPED (dry mode)"
        else:
            method(self, *args, **argv)
            print "...DONE"
    return decorated_method


class ProjectAreaManager(object):
    #(eg)
    def __init__(self, project_version, basepath, dry=False ):
        self._version = project_version
        if dry:
           print "=== Running in dry mode === \n"            
        self._dryMode = dry
        self._basepath =  basepath

    # create AFS area for LCG release
    # (eg)
    def create_area(self, releasename_pattern):
        
        print "Start CREATE_AREA script"
        basepath = self._basepath
        version = self._version
        #print "BasePATH: %s" % self._basepath
        path = os.path.join(basepath,version)
        exts = {('',''),('MCGenerators','MC')}
        for ext in exts:
            if ext[0]:
                print "=== Area for LCG release MCGenerators %s:" %(version)
                path = os.path.join(basepath,version,ext[0])
            else:
                print "=== Area for LCG release %s:" %(version)
                path = os.path.join(basepath,version)
            if os.path.exists(path):
                print path, "already exists. Nothing to be done"
            else:
                #print "Going to create path", path
                # define necessary size by the size of the previous (shrinked) installation + 30 %
                previous_version = self.get_previous_project_version(basepath,version,releasename_pattern)
                print "Previous version %s:" % previous_version
                if not previous_version:
                    quota = int("5000")
                elif previous_version > version:
                    print "You are creating a release older then the last one"
                    sys.exit(1)
                else:
                    previous_path = os.path.join(basepath,previous_version,ext[0])
                    quota = int( int(AFS.getVolumeSize(previous_path)) * 1.3 )
                volume_name = self.create_AFS_volume_name(version+ext[1])
                print 'Going to create volume %s of size %s and mounting at %s\n' %(volume_name, quota, path)
                self.create_AFS(path, volume_name, quota)
                if previous_version:
                    print 'Going to copy ACLs'   
                    self.copy_ACL(previous_path, path)
                else:
                    print "No previous release. You will need to define ACL permissions on %s" % path

        
    # Find the last release installed
    # (eg)
    def get_previous_project_version(self, basepath, version,releasename_pattern):
        """Return the last project version installed."""
        start_dir = os.getcwd()
        proj_dir = basepath
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
    def create_AFS_volume_name(version):
        #remove name for the projects:
        #### THIS MUST BE CHANGED FOR SW PROJECT !!
        name = "p.sw.lcg."+version.lower().replace("_","").replace(".","")
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

    @skip_in_dry_mode
    #(eg)
    def do_vos_release(self, path):
        AFS.doVosRelease(path)
        
    def finalize_area(self):
    #(eg)
        print "Start FINALIZE_ARE script"
        """Finalize the area by volume shrinking, replica creation and vos_release """
        basepath = self._basepath
        version = self._version
        print "BasePATH: %s" % self._basepath
        print "=== Area for LCG release %s:" %(version)
        path = os.path.join(basepath, version)
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
        basepath = self._basepath
        version = self._version
        path = os.path.join(basepath, version)
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
                    
        