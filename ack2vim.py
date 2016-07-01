"""Script to integrate ack with vim"""


import os
import re
import sys
import commands


from convert_regexps import convert


__version__ = '0.4.1'


class ShellError(Exception):
    def __init__(self, status, output):
        Exception.__init__(self, output)
        self.status = status


def join_args(args):
    return ' '.join(args)


def quote_arg(arg):
    if '"' in arg:
        if "'" in arg:
            raise ValueError('Cannot quote [%s]' % arg)
        else:
            return "'%s'" % arg
    return '"%s"' % arg


def parse_args(args):
    options, result = [], []
    for arg in args:
        if arg[0] == '-':
            options.append(arg)
        else:
            result.append(arg)
    return options, result


def join_quoted_args(args):
    return join_args([quote_arg(arg) for arg in args])


def args_to_strings(args):
    options, args = parse_args(args)
    return join_args(options), join_quoted_args(args)


def run_command_in_path(command):
    return commands.getstatusoutput('%s %s' % ('PATH=/usr/local/bin:/usr/bin:/bin', command))


def run_ack(args):
    status, output = run_command_in_path('which ack')
    ack = status and 'ack' or output
    ack_command = '%s --files-with-matches --nocolor %%s %%s' % ack
    command = ack_command % (args_to_strings(args))
    status, output = run_command_in_path(command)
    if status:
        raise ShellError(status, output)
    return output.splitlines()


def worded(string):
    r"""Add vim-style \< \> around each string


    >>> worded('word') == r'\<word\>'
    True
    >>> worded(r'\<some words') == r'\<some words\>'
    True
    """
    if string[:2] != r'\<':
        string = r'\<%s' % string
    if string[-2:] != r'\>':
        string = r'%s\>' % string
    return string


def remove_option(string, char):
    """Remove the given option char from the string

    >>> remove_option('arg -x', 'x')
    ('arg ', 'x')
    >>> remove_option('arg -x ', 'x')
    ('arg ', 'x')
    >>> remove_option('-x arg', 'x')
    ('arg', 'x')
    >>> remove_option('-xyz arg', 'x')
    ('-yz arg', 'x')
    >>> remove_option('-y arg', 'x')
    ('-y arg', '')
    >>> remove_option('-y xrg', 'x')
    ('-y xrg', '')
    >>> remove_option('-x xrg', 'x')
    ('xrg', 'x')
    """
    assert char
    regexp = r'-%s(\W|$)' % char
    result_string = re.sub(regexp, '', string)
    regexp = r'-([a-z]*)%s([a-z]*)' % char
    if re.search(regexp, result_string):
        if not re.search('-%s' % regexp, result_string):
            result_string = re.sub(regexp, r'-\1\2', result_string)
    if result_string == string:
        char = ''
    return result_string, char


def as_vim_args(args):
    """Convert ack args to vim args"""
    args = convert(args)
    options, args = parse_args(args)
    option_string = join_args(options)
    if 'w' in option_string:
        args = [worded(arg) for arg in args]
        option_string, _ = remove_option(option_string, 'w')
    return option_string, join_quoted_args(args)


def as_vim_command(vim_args, path_to_file):
    return 'vim %s +/%s' % (path_to_file, vim_args)


def as_vim_commands(args, paths_to_files):
    return [as_vim_command(args, quote_arg(path_to_file))
            for path_to_file in paths_to_files]


def as_a_vim_command(args, paths_to_files):
    paths_to_files = ' '.join(['-p'] + [quote_arg(path_to_file)
                                        for path_to_file in paths_to_files])
    return as_vim_command(args, paths_to_files)


def run_vim_option():
    return 'v'


def verbose_option():
    return 'V'


def use_files(run_vim, args, paths_to_files):
    if run_vim:
        vim_command = as_a_vim_command(args, paths_to_files)
        print vim_command
        return os.EX_OK
    vim_commands = as_vim_commands(args, paths_to_files)
    print '\n'.join(vim_commands)
    return os.EX_TEMPFAIL


def parse_command_line(args):
    result = []
    any_run_vim = False
    for arg in args:
        if arg[-1] == '/':
            continue
        arg, _consumed = remove_option(arg, verbose_option())
        if not arg:
            continue
        arg, run_vim = remove_option(arg, run_vim_option())
        any_run_vim |= run_vim == run_vim_option()
        if arg:
            result.append(arg)
    return result, any_run_vim


def main(args):
    args, run_vim = parse_command_line(args)
    try:
        paths_to_files = run_ack(args)
        _, args = as_vim_args(args)
        return use_files(run_vim, args, paths_to_files)
    except ShellError, e:
        print >> sys.stderr, e
        return e.status
    return os.EX_OK


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
