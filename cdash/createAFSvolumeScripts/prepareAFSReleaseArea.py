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
    parser.add_option('-e', '--handleExternalsOnly', action='store', dest='handleExternalsOnly', help='Set true if you install only externals and not Generators', default=False )

    (opts,args) = parser.parse_args()

    # some checks on the parameters:
    if not opts.version or not opts.prefix:
        print "You have to specify all --prefix, --version"
        raise ValueError("You have to specify both --prefix and --version")
    if not os.path.exists(opts.prefix):
        print ("You specified a non existing path in --prefix")
        raise ValueError("You have to specify an existing path")
#    if not re.match(full_releasename_pattern, opts.version):
#        print "ERROR : the name of the release is not standard"
#        raise ValueError("You have to use a standard release name (number[+letter] ")   
    if opts.handleExternalsOnly == 'False' or opts.handleExternalsOnly =='false': 
        print "Externals and Generators areas will be prepared"

    releasename = 'lcg'+opts.version
    area = ProjectAreaManager( releasename, opts.prefix, dry=opts.dry )

    print opts.handleExternalsOnly
    print "Prepare the AFS volumes in  %s" % (opts.prefix)

    if opts.handleExternalsOnly == 'True' or opts.handleExternalsOnly == 'true' : # Build only externals
        if not os.path.exists(os.path.join(opts.prefix, releasename)):
            print "create %s area"  % os.path.join(opts.prefix,releasename) 
            area.create_area(full_releasename_pattern, "")
        else:
            print "area already exits - check replicas"
    else: # Build both Generators and Externals
        if os.path.exists(os.path.join(opts.prefix, releasename)):
            # lcg area for externals already exists
            if os.path.exists(os.path.join(opts.prefix,releasename,"MCGenerators")):
                # both areas already exist
                print "Both areas already exists, nothing need to be created"
            else:
                print "create %s area" % (os.path.join(opts.prefix,releasename,"MCGenerators"))
                area.create_area(full_releasename_pattern, "MCGenerators")
        else: # lcg area does not exists 
            print "create %s area and %s area" % (os.path.join(opts.prefix,releasename), (os.path.join(opts.prefix,releasename,"MCGenerators")))
            area.create_area(full_releasename_pattern, "")
            cmd = '/usr/bin/fs checks; /usr/bin/fs checkv; /usr/bin/fs flushm '+os.path.join(opts.prefix,releasename)
            os.system(cmd)
            area.create_area(full_releasename_pattern, "MCGenerators")

