"""Handle options and regexps between ack and vim"""

import os
import re
import sys


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


def ack_command(options, regexps, joiner):
    strings_ = joiner.join([f"'{_}'" for _ in regexps])
    option_string = " ".join(options)
    ack = which_ack()
    return f"{ack} {option_string} {strings_}"


def had_option(options, option):
    try:
        options.remove(option)
        return True
    except ValueError:
        return False


def read_options(args):
    args_ = []
    options = []
    nexters = (
        "--ignore-directory", "--ignore-dir", "--match", "--type",
        "-A", "-B", "-T"
    )
    take_next = False
    for arg in args:
        if take_next:
            options.append(arg)
            take_next = False
            continue
        initial, *_ = arg
        if initial != '-':
            destination = options if take_next else args_
            destination.append(arg)
            continue
        if arg in nexters:
            take_next = True
        options.append(arg)
    return options, args_


def read_regexps(args):
    path = "."
    regexps = []
    for arg in args:
        if os.path.isdir(arg):
            path = arg
            continue
        regexp = arg
        if " " in arg or re.search("[.(]", arg):
            if " $" in arg:
                regexp = "'%s'" % arg
            else:
                regexp = arg.replace(" ", ".")
        regexps.append(regexp)
    return path, regexps


def main(args):
    """Run this script as a program"""
    options, args_ = read_options(args)
    no_follow_option = not had_option(options, "-f")
    if not no_follow_option:
        options.append("--follow")
    join_regexps = had_option(options, "-j")
    path, regexps = read_regexps(args_)
    command = ack_command(
        options,
        regexps,
        "." if join_regexps else " ",
    )
    print(command, path)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
