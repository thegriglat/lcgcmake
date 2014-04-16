#! /usr/bin/env python

import os,re
from projectareamanager import ProjectAreaManager

##########################
if __name__ == '__main__':

    import optparse, sys 

    # some general variables : 

    # here it is decided the pattern of the release i.e. 65, 65a 
    # and the full path (for ?) lcg65 or lcg_65 ...
    full_releasename_pattern = r"lcg\d+[a-z]?"
    releasename_pattern = r"\d+[a-z]?"

    usage = 'Prepare the AFS volumes for the LCG release'
    
    parser = optparse.OptionParser(usage)
    parser.add_option('-d', '--dry', action='store_true', dest='dry', help='dry run, no commands will be executed',default=False )
    parser.add_option('-v', '--version', action='store', dest='version', help='name of the release')
    parser.add_option('-p', '--prefix', action='store', dest='prefix', help='AFS prefix where to install the new volume')
    parser.add_option('-t', '--target', action='store', dest='target', help='all|externals|generators')

    (opts,args) = parser.parse_args()

    # some checks on the parameters:
    if not opts.version or not opts.prefix:
        print "You have to specify all --prefix, --version"
        raise ValueError("You have to specify both --prefix and --version")
    if not os.path.exists(opts.prefix):
        print ("You specified a non existing path in --prefix")
        raise ValueError("You have to specify an existing path")
    if not re.match(full_releasename_pattern, opts.version):
        print "ERROR : the name of the release is not standard"
        raise ValueError("You have to use a standard release name (number[+letter] ")   
    if not opts.target: 
        print "No option target - all - will be used by default"
        opts.target = 'all'
    if opts.target not in ('all', 'externals', 'generators'): 
        print "target must be one of all|externals|generators"
        raise ValueError("target must be either all or externals or generators")

    releasename = opts.version
    area = ProjectAreaManager( releasename, opts.prefix, dry=opts.dry )

    print "Prepare the AFS volumes in  %s" % (opts.prefix)

    if opts.target == "externals":
        if not os.path.exists(os.path.join(opts.prefix, releasename)):
            print "create %s area"  % os.path.join(opts.prefix,releasename) 
            area.create_area(full_releasename_pattern, "")
        else:
            print "area already exits - check replicas"
    else: 
        if os.path.exists(os.path.join(opts.prefix, releasename)):
            # case target generators/all when lcg area already exists
            print "create %s area" % (os.path.join(opts.prefix,releasename,"MCGenerators_"+releasename))
            area.create_area(full_releasename_pattern, "MCGenerators_"+releasename)
        else: # target is all/ generators and area lcg does not exists 
            print "create %s area and %s area" % (os.path.join(opts.prefix,releasename), (os.path.join(opts.prefix,releasename,"MCGenerators_"+releasename)))
            area.create_area(full_releasename_pattern, "")
            cmd = '/usr/bin/fs checks; /usr/bin/fs checkv; /usr/bin/fs flushm '+os.path.join(opts.prefix,releasename)
            os.system(cmd)
            area.create_area(full_releasename_pattern, "MCGenerators_"+releasename)

