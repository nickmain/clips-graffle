#-------------------------------------------------------------------------
# Read an Omnigraffle diagram file and emit CLIPS facts representing it
#-------------------------------------------------------------------------
import plistlib, sys, subprocess, re

gid = 0     # index to generate unique ids for dicts and arrays
arrays = {} # arrays found - to be emitted at the end

def make_dict_id():
    """Make a new dict id"""
    global gid
    gid = gid + 1
    return "d"+str(gid)

def make_array_id():
    """Make a new array id"""
    global gid
    gid = gid + 1
    return "a"+str(gid)

def unpack_rect( dict_key, dict_id, s ):
    """Detect a rectangle spec in a string and convert to an array - return true if so"""
    matches = re.findall(r"\{\{\s*(.+),\s*(.+)\},\s*\{\s*(.+),\s*(.+)\}\}",s)
    if len(matches) == 0: return False
    else:
        (x,y,w,h) = matches[0]
        array_id = make_array_id()
        print_dict( dict_key, dict_id, array_id )
        handle_array( [float(x),float(y),float(w),float(h)], array_id )
        return True        

def unrtf( s ):
    """Convert an RTF string to plain text, otherwise pass-thru"""
    if len(s) > 4 and s[:5] == '{\\rtf':
        cmd = ['textutil', '-cat', 'txt', '-stdin', '-stdout']
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                                  stderr=subprocess.PIPE,
                                  stdin=subprocess.PIPE)
        out, err = p.communicate(s)
        return out
    else:
        return s        

def handle_dict( d, id ):
    """Process the elements in a dict and write them out"""
    global arrays
    for key, value in d.iteritems():
        if isinstance( value, dict ):
            dict_id = make_dict_id()
            print_dict( key, id, dict_id )
            handle_dict( value, dict_id )
        elif isinstance( value, list ):
            array_id = make_array_id()
            print_dict( key, id, array_id )
            handle_array( value, array_id )
        elif isinstance( value, str ):
            if not unpack_rect( key, id, value ):
                print_dict( key, id, '"' + unrtf(value) + '"')
        else:
            print_dict( key, id, str(value) )
            
def handle_array( a, id ):            
    """Process the elements in an array and gather them for later writing"""
    global arrays
    array = []
    arrays[id] = array
    for value in a:
        if isinstance( value, dict ):
            dict_id = make_dict_id()
            array.append( dict_id )
            handle_dict( value, dict_id )
        elif isinstance( value, list ):
            array_id = make_array_id()
            array.append( array_id )
            handle_array( value, array_id )
        elif isinstance( value, str ):
            array.append( '"' + unrtf(value) + '"')
        else:
            array.append( str(value) )
                
def print_dict( key, id, value ):
    """Print a dict entry fact"""
    print "(dict-entry (id " + id + ")(key " + key + ")(value " + value + "))"

def print_array( a, id ):
    """Print an array fact"""
    print "(array (id " + id + ")(values "    
    for val in a: print val
    print "))"

# Omnigraffle filename to process is arg 1
filename = sys.argv[1]
graffle = plistlib.readPlist( filename )

# defining fact for the plist 
root_id = make_dict_id()
print "(omnigraffle (root " + root_id + ")(path \"" + filename + "\"))"
    
# recursive processing from the root dict
handle_dict(graffle, root_id)

# write out the gathered arrays
for key, value in arrays.iteritems():
    print_array( value, key )

