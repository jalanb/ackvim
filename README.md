# viack

viack eases the interface beween [ack](http://beyondgrep.com/) and [vim](http://www.vim.org/), so that `ack`'s findings can be found with `vim` as well.

It helps by running `ack` commands, gathering the results and using `vim` to edit any found files, and telling `vim` to search for similar strings to those `ack` sought. The strings `vim` searches for are "similar", not "the same", because the two commands use different regexp languages, so viack converts the strings.

viack is useful at the [bash](https://www.gnu.org/software/bash/) command line, it is not used within `vim`.

## Usage

viack allows lines in `bash` like

```shell
ap -w main -v
```

which tells `ack` to search all python files for the word main, and tells `vim` to open all those files searching for the word main

And it allows lines like

```shell
vai sys
```

which searches all python files for any "import sys" or "from sys import", and vims those files with that search
## Install

Clone the repository and source a file to add viack's command into `bash`
```shell
git clone https://github.com/jalanb/viack.git
source viack/viack
```

Merge viack's ackrc file into `ack`'s config file in $HOME

```shell
vim -d viack/ackrc ~/.ackrc
```

## Options
Because it needs to handle options for both `ack` and `vim`, viack does not provide any options itself. Rather it provides individual commands, such as the following which add filetype options to the `ack` command line

command | filetype
--------|---------
   aa   |  --all
   ac   |  --code
   ae   |  --erl
   al   |  --html
   ap   |  --python
   at   |  --pyt

(These filetypes are defined in the ackrc file [included in this repository](https://github.com/jalanb/viack/blob/master/ackrc))

Some commands add other options, e.g. `ai` searches in python files for imports only. [RTFS](https://github.com/jalanb/viack/blob/master/viack) for more commands

Each `a...` command has a matching `va...` command which runs the `ack` command, and sends the results on to `vim`. And, for the convenience of those using `readline`'s [vi mode](http://tiswww.case.edu/php/chet/readline/rluserman.html#SEC22) at the command line, each also has an equivalent `aa...` alias.

So, to search for "fred" using `ack` the command is the usual

```shell
ack fred
```

Or, to search only in web files:

```shell
al fred
```

To do the same searches, and then open the results in `vim` the commands would be

```shell
vack fred
val fred
```

or, equivalently

```shell
aack fred
aal fred
```

## How does it work?

viack provides [bash functions with abbreviated names](https://github.com/jalanb/viack/blob/master/viack), all of which [eventually](https://github.com/jalanb/viack/blob/master/viack#L113) hand over to [a python program](https://github.com/jalanb/viack/blob/master/viack.py) which interprets arguments, and does some conversion of `ack` to `vim` regexps, before sending the correct `vim` command to stdout. Bash captures that and runs it.

## Limitations

* viack only provides the commands I have needed - searching in shell, python, and web files. But they are very easy to extend
* viack needs to handle options from the shell command line for both `ack` and `vim`. The code which handles this is a "good enough" hack

## Readers who got this far went on to view:

* [Thomas Sibley](http://tsibley.net/)'s [viack](https://github.com/tsibley/viack)
* [Miles Whittaker](https://plus.google.com/+MilesWhittaker_mjwhitta/about)'s [zoom](https://gitlab.com/mjwhitta/zoom)
* [Sampson Chen](http://sampsonchen.com/)'s [sack](https://github.com/sampson-chen/sack)

###
Although this code was originally forked from [viack](https://github.com/tsibley/viack) we have diverged completely, hence the copyright claim in the LICENSE file

This code [WFM](http://www.urbandictionary.com/define.php?term=wfm) and I use it daily, but [caveat lector](http://www.urbandictionary.com/define.php?term=ymmv)
