"""Handle options and regexps between ack and vim"""

from __future__ import print_function
import os
import re
import sys

__version__ = '0.7.0'


def assert_perl_script(path):
    """Raise errors if that path is not a perl script

    It is a perl script if it
        1. is a file, and
        2.a. has a '.pl' extension, or
        2.b. mentions 'perl' in first line
    """
    if not os.path.isfile(path):
        raise NotImplementedError('"%s" is not a file' % path)

    _stem, ext = os.path.splitext(path)
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
    ack = os.environ.get('ACK') or '/usr/local/bin/ack'
    assert_perl_script(ack)
    return ack


def main(args):
    """Run this script as a program"""
    if '-U' in sys.argv:
        import pudb
        pudb.set_trace()
    try:
        args.remove('-j')
    except ValueError:
        dot_join = False
    else:
        dot_join = True
    words = [which_ack()]
    sought_words = [] if dot_join else words
    ignoring = False
    for word in args:
        if word == '--ignore-dir':
            words.append(word)
            ignoring = True
            continue
        if ignoring:
            words.append(word)
            ignoring = False
            continue
        if re.match('-[a-uw-z]*[vV][a-uw-z]*', word):
            words[0] = 'vack'
            words.append(word)
        elif word.startswith('-'):
            words.append(word)
        else:
            if ' ' in word or re.search('[.(]', word):
                if ' $' in word:
                    sought_words.append("'%s'" % word)
                else:
                    sought_words.append(word.replace(' ', '.'))
            else:
                sought_words.append(word)
    command = ' '.join(words)
    if dot_join:
        new_args = '.'.join(sought_words)
        command = '%s %s' % (command, new_args)
    print(command)

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
