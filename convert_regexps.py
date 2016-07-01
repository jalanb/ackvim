"""Script to convert ack regexps to vim regexps"""


import re
import sys


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


def main(args):
    converted = convert([_ for _ in args if _ and _[0] != '-'])
    print ' '.join(converted)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
