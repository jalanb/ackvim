"""Handle options and regexps between ack and vim"""

import os
import re
import sys

__version__ = "0.7.3"


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
    if ext == ".pl":
        return
    with open(path) as stream:
        if "perl" in stream.readline():
            return
    raise NotImplementedError("%s is not a perl script" % path)


def which_ack():
    """Find the system 'ack' in shell's environemnt, or with which

    Should be a perl script
    """
    ack = os.environ.get("ACK") or "/usr/local/bin/ack"
    assert_perl_script(ack)
    return ack


def ack_command(joiner, arguments, no_follow_option):
    args = joiner.join([f"'{_}'" for _ in arguments])
    ack = which_ack()
    follow = "" if no_follow_option else "--follow"
    return f"{ack} {args}"


def had_option(args, option):
    try:
        args.remove(option)
        return True
    except ValueError:
        return False


def main(args):
    """Run this script as a program"""
    strings = []
    regexps = []
    join_option = had_option(args, "-j")
    no_follow_option = not had_option(args, "-f")
    ignoring = False
    final_dir = ""
    for word in args:
        if word == "--ignore-dir":
            strings.append(word)
            ignoring = True
            continue
        if ignoring:
            strings.append(word)
            ignoring = False
            continue
        if re.match("-[a-uw-z]*[vV][a-uw-z]*", word):
            strings[0] = "vack"
            strings.append(word)
        elif word.startswith("-"):
            strings.append(word)
        elif os.path.isdir(word):
            final_dir = word
        else:
            if " " in word or re.search("[.(]", word):
                if " $" in word:
                    regexps.append("'%s'" % word)
                else:
                    regexps.append(word.replace(" ", "."))
            else:
                regexps.append(word)
    command = ack_command(
        "." if join_option else " ",
        regexps if join_option else strings,
        no_follow_option,
    )
    print(command, final_dir)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
