"""Script to convert ack regexps to vim regexps"""


from __future__ import print_function
import os
import re
import sys
import commands
import itertools


__version__ = '0.4.4'


def bs_to_brackets(string):
    r"""Convert \b to \< or \>

    ack uses the former, vim the latter, to mean start (or end) of word

    >>> bs_to_brackets(r'\bword\b') == r'\<word\>'
    True
    """
    if '\\b' not in string:
        return string
    start_of_word = re.compile(r'(^|\W)\\b')
    string = start_of_word.sub(r'\<', string)
    end_of_word = re.compile(r'\\b(\w|$)')
    return end_of_word.sub(r'\>', string)


def escape_alternates(string):
    r"""Convert '(aaa|bbb|ccc)' to '\(aaa\|bbb\|ccc\)'

    Not a generic solution for alternates
        just covers the simple case

    >>> escape_alternates('(aaa|bbb|ccc)') == r'\(aaa\|bbb\|ccc\)'
    True
    """
    try:
        string = re.match(r'\((.*)\)', string).group(1)
        string = string.replace('|', r'\|')
        return r'\(%s\)' % string
    except AttributeError:
        return string


def convert(strings):
    bracketed_strings = [bs_to_brackets(_) for _ in strings]
    escaped_strings = [escape_alternates(_) for _ in bracketed_strings]
    return escaped_strings


def ack_help(help_):
    status, output = commands.getstatusoutput(
        'PATH=/usr/local/bin:/usr/bin:/bin ack --%s' % help_)
    if status:
        raise ValueError(output)
    return [_[2:] for _ in output.splitlines() if _.startswith('  -')]


def ackrc_types():
    types_set = [_ for _ in ack_help('dump') if _.startswith('--type')]
    types = (re.split('[:=]', _)[1] for _ in types_set)
    return ['--(no)?%s' % _ for _ in types]


def ack_options():
    options = ack_help('help') + ack_help('help-types')
    bare_options = [re.sub(r'\s\s+.*', '', _).split(', ') for _ in options]
    bare_option_list = [_ for _ in itertools.chain(*bare_options) if _ != '-?']
    bare_regexps = [_.replace('[no]', '(no)?') for _ in bare_option_list]
    bare_regexps.extend(ackrc_types())
    return ([_.split(' ')[0] for _ in bare_regexps if ' ' in _],
            [re.split('[=[]', _)[0] for _ in bare_regexps if '=' in _],
            [_ for _ in bare_regexps if '=' not in _ and ' ' not in _])


def match_option(regexps, string):
    for regexp in regexps:
        if re.match(regexp, string):
            return True
    return False


def detach_ack_option(args):
    spaced, equalled, plain = ack_options()
    if not args:
        return args
    arg = args[0]
    i = 0
    if match_option(plain, arg):
        i = 1
    if match_option(spaced, arg):
        i = 2
    if match_option(equalled, arg):
        if '=' in arg:
            i = 1
        else:
            i = 2
    return args[:i], args[i:]


def remove_ack_options(args):
    if not args:
        return args
    option, args = detach_ack_option(args)
    if option:
        return remove_ack_options(args)
    return args[:1] + remove_ack_options(args[1:])


def remove_ack_arguments(args):
    positionals = remove_ack_options(args)
    if os.path.isdir(positionals[-1]):
        return positionals[:-1]
    return positionals


def main(args):
    non_ack_args = remove_ack_arguments(args)
    try:
        non_ack_args.remove('-j')
    except ValueError:
        joiner = ' '
    else:
        joiner = '.'
    converted = convert(non_ack_args)
    print(joiner.join(converted))
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
