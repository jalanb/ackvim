"""Script to integrate ack with vim"""


import os
import re
import sys
import shlex
import commands


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


def run_ack(args):
	command = 'ack --files-with-matches --nocolor %s %s' % args_to_strings(args)
	status, output = commands.getstatusoutput(command)
	if status:
		raise ShellError(status, output)
	return output.splitlines()


def bs_to_brackets(string):
	"""Convert \b to \< or \>

	ack uses the former, vim the latter, to mean start (or end) of word

	>>> bs_to_brackets('\\bword\\b'') == '\\<word\\>'
	True
	"""
	if '\\b' not in string:
		return string
	start_of_word = re.compile('(^|\W)\\\\b')
	string = start_of_word.sub('\\<', string)
	end_of_word = re.compile('\\\\b(\w|$)')
	return end_of_word.sub('\\>', string)


def worded(string):
	"""Add vim-style \< \> around each string


	>>> worded('word') == r'\<word\>' and worded(r'\<some words') == r'\<some words\>'
	True
	"""
	if string[0] != r'\<':
		string = r'\<%s' % string
	if string[-1] != r'\>':
		string = r'%s\>' % string
	return string


def remove_option(option_string, option):
	regexp = '-%s(\W|$)' % option
	result_string = re.sub(regexp, '', option_string).replace(option, '')
	if result_string == option_string:
		option = ''
	return result_string, option


def as_vim_args(args):
	"""Convert ack args to vim args"""
	args = [bs_to_brackets(arg) for arg in args]
	options, args = parse_args(args)
	option_string = join_args(options)
	if 'w' in option_string:
		args = [worded(arg) for arg in args]
		option_string, _ = remove_option(option_string, 'w')
	return option_string, join_quoted_args(args)


def as_vim_command(vim_args, path_to_file):
	return 'vim %s +/%s' % (path_to_file, vim_args)


def as_vim_commands(args, paths_to_files):
	return [as_vim_command(args, quote_arg(path_to_file)) for path_to_file in paths_to_files]


def as_a_vim_command(args, paths_to_files):
	paths_to_files = ' '.join(['-p'] + [quote_arg(path_to_file) for path_to_file in paths_to_files])
	return as_vim_command(args, paths_to_files)


def run_vim_option():
	return 'V'


def use_files(run_vim, args, paths_to_files):
	if run_vim:
		vim_command = as_a_vim_command(args, paths_to_files)
		print vim_command
		return os.EX_OK
	vim_commands = as_vim_commands(args, paths_to_files)
	print '\n'.join(vim_commands)
	return os.EX_TEMPFAIL


def parse_command_line(command_line):
	command_line, _consumed = remove_option(command_line, 'v')
	command_line, run_vim = remove_option(command_line, run_vim_option())
	return shlex.split(command_line), run_vim


def main(command_line):
	args, run_vim = parse_command_line(command_line)
	try:
		paths_to_files = run_ack(args)
		_, args = as_vim_args(args)
		return use_files(run_vim, args, paths_to_files)
	except ShellError, e:
		print >> sys.stderr, e
		return e.status
	return os.EX_OK


if __name__ == '__main__':
	sys.exit(main(' '.join(sys.argv[1:])))
