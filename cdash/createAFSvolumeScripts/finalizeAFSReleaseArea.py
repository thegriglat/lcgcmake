#! /usr/bin/env python

from projectareamanager import ProjectAreaManager

##########################
if __name__ == '__main__':

    import optparse, sys

    usage = 'Finalize the AFS volumes for the LCG release'

    parser = optparse.OptionParser(usage)
    parser.add_option('-d', '--dry', action='store_true', dest='dry', help='dry run, no commands will be executed' )
    parser.add_option('-v','--version', dest='version', help='name of the release')
    parser.add_option('-p', '--prefix', action='store', dest='basepath', help='AFS prefix where to install the new volume')

    (opts,args) = parser.parse_args()

    if not opts.version or not opts.basepath:
        print "You have to specify both --prefix and --version"
        sys.exit(1)
        #        raise ValueError("You have to specify both --version and --name or neither of both")
    if opts.dry == None:
        opts.dry = False
    area = ProjectAreaManager( opts.version, opts.basepath, dry=opts.dry )
    area.finalize_area()


