#! /bin/cat

[[ -n $WELCOME_BYE ]] && echo Welcome to $(basename "$BASH_SOURCE") in $(dirname $(readlink -f "$BASH_SOURCE")) on $(hostname -f) || true

# This script is intended to be sourced, not run
if [[ $0 == $BASH_SOURCE ]]
then
    echo "This file should be run as"
    echo "  source $0"
    echo "and should not be run as"
    echo "  sh $0"
fi

# File organisation: Functions are sorted by length of name first, then alphabetically

# x

unalias a 2>/dev/null || true
a () {
    choose_ack "$@"
}

# xx

unalias aa 2>/dev/null || true
aa () {
    ack_then_vim "$@"
}

ac () {
    _ack_class_def choose_ack class "$@"
}

ae () {
    choose_ack --erl "$@"
}

af () {
    _ack_class_def choose_ack -l def "$@"
}

ah () {
    ack --html "$@"
}

ai () {
    local _options=--python
    [[ $1 == "-t" ]] && _options=--test && shift
    [[ $1 == "-T" ]] && _options=--pyt && shift
    local sought=$1; shift
    ack $_options '(import.*'"$sought|$sought"'.*import)' "$@"
}

al () {
    choose_ack --html "$@"
}

ap () {
    local _ignores=( /test /tests /lib /__pycache__ )
    choose_ack ${_ignores[@]/#\// --ignore-dir } --python "$@"
}

at () {
    choose_ack --pyt "$@"
}

ay () {
    choose_ack --yaml "$@"
}

av () {
    ack_then_vim "$@"
}

# xxx

unalias aaa 2>/dev/null || true
aaa () {
    ack_then_vim --nojunk "$@"
}

aac () {
    _ack_class_def ack_then_vim class "$@"
}

aae () {
    ack_then_vim --erl "$@"
}

aaf () {
    _ack_class_def ack_then_vim def "$@"
}

aal () {
    ack_then_vim --html "$@"
}

aai () {
    local _regexp=$(convert_regexp "$@")
    local _files=$(ai "$@" -l| tr '\n' ' ')
    vim -p $_files +/$_regexp
}

aap () {
    local _ignores=( /test /lib /__pycache__ )
    ack_then_vim ${_ignores[@]/#\// --ignore-dir } --python "$@"
}

aat () {
    ack_then_vim --pyt "$@"
}

aay () {
    ack_then_vim --yaml "$@"
}

aaw () {
    ack_then_vim -w "$@"
}

aco () {
    ack_then_vim --code "$@"
}

aiw () {
    local sought=$1
    ack --python "(import.*\b$sought\b|\b$sought\b.import)"
}

ash () {
    choose_ack --shell "$@"
}

# xxxx

unalias aaaa 2>/dev/null || true
aaaa () {
    ack_then_vim --all "$@"
}

aash () {
    ack_then_vim --shell "$@"
}

lack () {
    choose_ack -l "$@"
}

convert_regexp () {
    VACK_DIR=$(dirname $(readlink -f $BASH_SOURCE))
    python $VACK_DIR/convert_regexps.py "$@"
}

# xxxxx

clack () {
    clear
    choose_ack "$@"
}

# xxxxxx+

ack_args () {
    local __doc__="Interpret args, search with ack"
    [[ $* =~ -l ]] || python -c "print('\n\033[0;36m%s\033[0m\n' % ('#' * "$(tput cols 2>/dev/null || echo 0)"))"
    local _script="$(readlink -f $BASH_SOURCE)"
    local _dir="$(dirname $_script)"
    local _script_py="$_dir/ack_args.py"
    if [[ ! -f $_script_py ]]; then
        [[ -f $_script ]] || echo "$_script is not a file" >&2
        [[ -d $_dir ]] || echo "$_dir is not a file" >&2
        [[ -f $_script_py ]] || echo "$_script_py is not a file" >&2
        ack "$@"
        return 1
    fi
    local _option=-j
    [[ $* =~ -j ]] && _option=
    $(python $_script_py $_option "$@")
}

choose_ack () {
    local __doc__="Choose which ack-function to run"
    if [[ $# -gt 0 && ${!#} =~ -v ]]; then
        ack_then_vim "${@/-v/}"
    else
        ack_args "$@"
    fi
}

ack_then_vim () {
    local __doc__="Search for args with ack, edit results with vim"
    local _regexp=$(convert_regexp "$@")
    local _files=$(ack_args -l "$@" | tr '\n' ' ')
    [[ $_files ]] && vim -p $_files +/$_regexp
}

_ack_class_def () {
    local __doc__="""Search for a class/def definition in python files"""
    local _function=$1; shift
    local _type=$1; shift
    local _option=
    local _sought="$@"
    if has_option i $_sought; then
        _option=-i
        _sought=$(remove_option i $_sought)
    fi
    local _regexp=\\s*${_type}.'[^(]*'"$_sought"
    $_function $_option --python $_regexp --ignore-dir=tests && return 0
    _regexp=$_sought
    [[ $_type == "class" ]] && return 1
    [[ $_type == "def" ]] && _regexp="^$_sought ()"
    $_function $_option --shell $_regexp
}

[[ -n $WELCOME_BYE ]] && echo Bye from $(basename "$BASH_SOURCE") in $(dirname $(readlink -f "$BASH_SOURCE")) on $(hostname -f) || true
