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
    parser.add_option('-p', '--prefix', action='store', dest='prefix', help='AFS prefix where to install the new volume')
    parser.add_option('-t', '--target', action='store', dest='target', help='all|externals|generators')

    (opts,args) = parser.parse_args()
    if not opts.version or not opts.prefix:
        print "You have to specify all --prefix, --version"
        raise ValueError("You have to specify both --prefix and --version")
    if not opts.target: 
        print "No option target - all - will be used by default"
        opts.target = 'all'
    if not os.path.exists(opts.prefix):
        print ("You specified a non existing path in --prefix")
        raise ValueError("You have to specify an existing path")

    # here it is decided the pattern of the release i.e. lcg65 or lcg_65 ...
    releasename_pattern = r"lcg\d+[a-z]?"

    if not re.match(releasename_pattern, opts.version):
        print "the name of the release is not standard"
        raise ValueError("You have to use a standard release name (lcg+number[+letter] ")
    if opts.target not in ('all', 'externals', 'generators'): 
        print "target must be one of all|externals|generators"
        print "target : ",opts.target
        raise ValueError("target must be either all or externals or generators")

    area = ProjectAreaManager( opts.version, opts.prefix, dry=opts.dry )

    print "Prepare the AFS volumes in  %s" % (opts.prefix)

    if opts.target == "externals": 
        print "create %s area"  % os.path.join(opts.prefix,opts.version) 
        area.create_area(releasename_pattern, "")
    else: 
        if os.path.exists(os.path.join(opts.prefix,opts.version)):
            if opts.target == 'generators':
                print "create %s area - if %s exists" % (os.path.join(opts.prefix,opts.version,"MCGenerators_"+opts.version), os.path.join(opts.prefix,opts.version))
                area.create_area(releasename_pattern, "MCGenerators_"+opts.version)
        else: # opts.target == all or opts.target == generatos but lcg volume does not exist
            print "create %s area and %s area" % (os.path.join(opts.prefix,opts.version), (os.path.join(opts.prefix,opts.version,"MCGenerators_"+opts.version)))
            area.create_area(releasename_pattern, "")
            cmd = '/usr/bin/fs checks; /usr/bin/fs checkv; /usr/bin/fs flushm '+os.path.join(opts.prefix,opts.version)
            os.system(cmd)
            area.create_area(releasename_pattern, "MCGenerators_"+opts.version)

