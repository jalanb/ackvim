"""Script to change -v for an ack command to vack"""

import os
import re
import sys
import commands

def which_ack():
    ack = os.environ.get('ACK') or 'ack'
    if not ack or not os.path.isfile(ack):
        status, output = commands.getstatusoutput('which ack')
        if status != os.EX_OK:
            raise NotImplementedError('"which ack" failed: "%s"' % output)
        ack = output
    if not os.path.isfile(ack):
        raise NotImplementedError('"%s" is not a file' % ack)
    return ack

def main(args):
    if '-U' in sys.argv:
        import pudb
        pudb.set_trace()
    words = [which_ack()]
    for word in args:
        if re.match('-[a-uw-z]*[vV][a-uw-z]*', word):
            words[0] = 'vack'
            words.append(word)
        else:
            if ' ' in word:
                if ' $' in word:
                    words.append("'%s'" % word)
                else:
                    words.append('"%s"' % word)
            else:
                words.append(word)
    print ' '.join(words)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
