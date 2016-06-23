"""Script to change -v for an ack command to vack"""

import os
import re
import sys
import commands

def assert_perl_script(path):
    """Raise errors if that path is not a perl script

    It is a perl script if it
        1. is a file, and
        2.a. has a '.pl' extension, or
        2.b. mentions 'perl' in first line
    """
    if not os.path.isfile(path):
        #  I prefer string interpolation operator over format()
        raise NotImplementedError('"%s" is not a file' % path)

    stem, ext = os.path.splitext(path)
    if ext == '.pl':
        return
    with open(path) as stream:
        if 'perl' in stream.readline():
            return
    raise NotImplementedError('%s is not a perl script' % path)


def which_ack():
    """Find the system 'ack' with which

    Should be a perl script
    """
    ack = os.environ.get('ACK') or 'ack'
    if not ack or not os.path.isfile(ack):
        status, output = commands.getstatusoutput('which ack')
        if status != os.EX_OK:
            raise NotImplementedError('"which ack" failed: "%s"' % output)
        ack = output
    assert_perl_script(ack)
    return ack

def main(args):
    """Run this script as a program"""
    if '-U' in sys.argv:
        import pudb
        pudb.set_trace()
    words = [which_ack()]
    for word in args:
        if re.match('-[a-uw-z]*[vV][a-uw-z]*', word):
            words[0] = 'vack'
            words.append(word)
        else:
            if re.search('[.(]', word):
                if ' $' in word:
                    words.append("'%s'" % word)
                else:
                    words.append('"%s"' % word)
            else:
                words.append(word)
    script = os.path.join(os.path.dirname(__file__), 'ack2vim.sh')
    words[0:0] = ('.', script, ';')
    print ' '.join(words)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
