"""This module handles shell commands to run ack"""

import os
from subprocess import getstatusoutput

from pysyte.types import paths

class ShellError(Exception):
    def __init__(self, status, output):
        Exception.__init__(self, output)
        self.status = status


def _assert_perl_script(path):
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


def shell_path() -> str:
    """The PATH in the current shell

    If PATH is not raise a ShellError
        This would be exceptional and user's environment is not set correctly
    """
    try:
        return os.environ["PATH"]
    except KeyError:
        raise ShellError(1, "Environment symbol `PATH` is not set")


def run_command(command: str) -> str:
    """Run the given command in the shell's PATH"""
    path_command = f"PATH={shell_path()} {command}"
    status, output = getstatusoutput(path_command)
    if status == 0:
        return output
    raise ShellError(status, output)


def which_ack() -> str:
    """Get path to the ack command, given shell's path"""
    ack = paths.environ_path("ACK")
    if ack.is_executable():
        return str(ack)
    if ack:
        raise ShellError(2, "$ACK is not executable: {ack}")
    ack = run_command("which ack")
    _assert_perl_script(ack)
    return ack


def run_ack(args: str) -> str:
    """Run an ack command with those args"""
    command = f"{which_ack()} {args}"
    return run_command(command)


def ack_help(help_wanted: str):
    """Get the wanted help from ack

    ack provides more/less verbose help depending on what's asked
        so help_wanted can be one of "help", "help-types", "dump"
    """
    if help_wanted not in ("help", "help-types", "dump"):
        raise ValueError(f"Bad option for ack help: {help_wanted!r}")
    option = f"--{help_wanted}"
    output = run_ack(option)
    return [_[2:] for _ in output.splitlines() if _.startswith("  -")]
