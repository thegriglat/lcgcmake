#!/usr/bin/env python
import sys
from xml.dom import minidom
import yoda

def GetNodesByAttributes(nodelist,options):
    """ Select XML nodes by 'options' """
    result = []
    for node in nodelist:
        ret = True
        for key in options.keys():
            value = options[key]
            if not node.hasAttribute(key) or not node.getAttribute(key) == value:
                ret = False
        if ret:
            result.append(node)
    return result

def GetNodeValue(node):
    """ Return XML node value """
    return node.firstChild.nodeValue

def YodaRead(filename):
    """ Return YODA object """
    try:
        tmp = yoda.read(filename)
    except:
        print "Cannot read YODA file"
        sys.exit(1)
    return tmp

def Yoda2XML(input,options):
    """ Produce simple XML output from YODA file """
    hep = YodaRead(input)
    tags = ["<tests>\n"]
    for ex in hep:
        tag = "<reference "
        for optkey in options.keys():
           tag = tag + " " + optkey + "=\"" + options[optkey] + "\""
        for key in ex.annotations.keys():
            tag = tag + " " + key + "=\"" + ex.annotations[key] + "\""
        if ex.annotations['Path'] == '/MC_XS/XS':
            tag = tag + ">" + str(ex.points()[0].y) + "</reference>\n"
        else:
            tag = tag + ">" + ex.string() + "</reference>\n"
        tags.append(tag)
    tags.append("</tests>")
    return "\n".join(tags)

def Check_XS(XS_ref,XS_test_yoda,percent = 5):
    """ Compare two XS and return True if difference less than 'percent' %"""
    # Get 'y' of XS point
    XS_test = float(XS_test_yoda[1].points()[0].y)
    XS_ref = float(XS_ref)
    if abs(XS_test - XS_ref)/float(XS_ref)*100 <= percent:
        print "Test value: " + str(XS_test) + " | Reference value: " + str(XS_ref)
        return True
    else:
        print "Test value: " + str(XS_test) + " | Reference value: " + str(XS_ref)
        return False

def Check_Histos():
    pass

##
# Options are      
# TestName RefFile YodaFile check "key1=value1" "key2=value2" ...
# TestName Infile Outfile make
# key=output,input

TestName = sys.argv[1]
RefFile = sys.argv[2]
YodaFile = sys.argv[3]
JobType = sys.argv[4]

options = {'Test':TestName}

if len(sys.argv) >= 5:
    for opt in sys.argv[5:]:
        try:
            key,value = opt.split("=")
            options[key] = value
        except:
            print "Can't split key=value pair by symbol '='"
            sys.exit(1)

if JobType == "make":
    input = RefFile
    output = YodaFile
    try:
        outfile = open(output,"w")
        outfile.write(Yoda2XML(input,options))
        outfile.close()
    except:
        print "Can't write to file " + output
        sys.exit(1)
    sys.exit(0)

RefFile = minidom.parse(RefFile)
reflist = RefFile.getElementsByTagName('reference')
if len(GetNodesByAttributes(reflist,options)) == 1:
    node =  GetNodesByAttributes(reflist,options)[0]
    if options['Path'] == '/MC_XS/XS':
        if Check_XS(GetNodeValue(node),YodaRead(YodaFile)):
            sys.exit(0)
        else:
            sys.exit(1)
    elif options['Path'] == '/MC_XS/N':
        if Check_Histos():
            sys.exit(0)
        else:
            sys.exit(1)
    else:
        sys.exit(1)
    print "value =",GetNodeValue(node)
else:
    print "More than 1 node are agreed with select options"
    sys.exit(1)
