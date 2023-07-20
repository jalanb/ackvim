"""Handle options and regexps between ack and vim"""

import os
import re
import sys

from ackvim.commands import which_ack


def ack_command(options, regexps, joiner, path):
    strings = joiner.join([f"'{_}'" for _ in regexps])
    option_string = " ".join(options)
    return f"{which_ack()} {option_string} {strings} {path}"


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
    for arg in reversed(args):
        if path == "." and os.path.isdir(arg):
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
        path,
    )
    print(command)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
