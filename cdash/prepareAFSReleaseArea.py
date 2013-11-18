#! /usr/bin/env python

import os,re
from projectareamanager import ProjectAreaManager

##########################
if __name__ == '__main__':

    import optparse, sys 

    usage = 'Prepare the AFS volumes for the LCG release'
    
    parser = optparse.OptionParser(usage)
    parser.add_option('-d', '--dry', action='store_true', dest='dry', help='dry run, no commands will be executed',default=False )
    parser.add_option('-v', '--version', action='store', dest='version', help='name of the release')
    parser.add_option('-p', '--prefix', action='store', dest='basepath', help='AFS prefix where to install the new volume')

    (opts,args) = parser.parse_args()
    if not opts.version or not opts.basepath:
        print "You have to specify both --prefix and --version"
        sys.exit(1)
        #        raise ValueError("You have to specify both --prefix and --version")
    if not os.path.exists(opts.basepath):
        print ("You specified a non existing path in --prefix")
        sys.exit(1)
    releasename_pattern = r"lcg\d+[a-z]?"
    if not re.match(releasename_pattern, opts.version):
        print "the name of the release is not standard"
        sys.exit(1)
    area = ProjectAreaManager( opts.version, opts.basepath, dry=opts.dry )
    print "Prepare the AFS volumes in  %s" % (opts.basepath)
    area.create_area(releasename_pattern)

