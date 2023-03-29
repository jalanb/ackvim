#! /bin/cat

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
    ack_find "$@"
}

# xx

unalias aa 2>/dev/null || true
aa () {
    run_ack_vim "$@"
}

ac () {
    find_class_or_function ack_find class "$@"
}

ae () {
    ack_find --erl "$@"
}

af () {
    find_class_or_function ack_find def "$@"
}

ah () {
    ack --html "$@"
}

ahv () {
    ack --help | vim -
}

ai () {
    local _options=--python
    [[ $1 == "-t" ]] && _options=--test && shift
    [[ $1 == "-T" ]] && _options=--pyt && shift
    [[ $1 == "-l" ]] && _options="$_options --files-with-matches" && shift
    local sought=$1; shift
    ack $_options '(import.*'"$sought|$sought"'.*import)' "$@"
}

al () {
    ack_find --html "$@"
}

ap () {
    local _ignores=( /test /tests /lib )
    ack_find ${_ignores[@]/#\// --ignore-dir } --python "$@"
}

at () {
    ack_find --test "$@"
}

ay () {
    ack_find --yaml "$@"
}

av () {
    run_ack_vim "$@"
}

# xxx

unalias aaa 2>/dev/null || true
aaa () {
    run_ack_vim --nojunk "$@"
}

aac () {
    find_class_or_function run_ack_vim class "$@"
}

aae () {
    run_ack_vim --erl "$@"
}

aaf () {
    find_class_or_function run_ack_vim def "$@"
}

aal () {
    run_ack_vim --html "$@"
}

aai () {
    local _regexp=$(convert_regexp "$@")
    local _files=$(ai "$@" -l| tr '\n' ' ')
    vim -p $_files +/"$_regexp"
}

aap () {
    local _ignores=( /test /tests /lib )
    run_ack_vim ${_ignores[@]/#\// --ignore-dir } --python "$@"
}

aat () {
    run_ack_vim --test "$@"
}

aay () {
    run_ack_vim --yaml "$@"
}

aaw () {
    run_ack_vim -w "$@"
}

aco () {
    run_ack_vim --code "$@"
}

aiw () {
    local sought=$1
    ack --python "(import.*\b$sought\b|\b$sought\b.import)"
}

app () {
    local _ignores=( /lib )
    ack_find ${_ignores[@]/#\// --ignore-dir } --pyt "$@"
}

ash () {
    ack_find --shell "$@"
}

# xxxx

unalias aaaa 2>/dev/null || true
aaaa () {
    run_ack_vim --all "$@"
}

aash () {
    run_ack_vim --shell "$@"
}

aapp () {
    local _ignores=( /lib )
    run_ack_vim ${_ignores[@]/#\// --ignore-dir } --pyt "$@"
}

lack () {
    ack_find -l "$@"
}

convert_regexp () {
    local python_dir_=$(dirname $(readlink -f $BASH_SOURCE))/ackvim
    python $python_dir_/convert_regexps.py "$@"
}

# xxxxx

clack () {
    clear
    ack_find "$@"
}

# xxxxxx+

run_ack_with () {
    local __doc__="Interpret args, search with ack"
    [[ $* =~ -l ]] || python -c "print('\n\033[0;36m%s\033[0m\n' % ('#' * "$(tput cols 2>/dev/null || echo 0)"))"
    local _script="$(readlink -f $BASH_SOURCE)"
    local sh_dir_="$(dirname $_script)"
    local py_dir_="$sh_dir_/ackvim"
    local py_script_="$py_dir_/run_ack_with.py"
    if [[ ! -f $py_script_ ]]; then
        [[ -f $_script ]] || echo "$_script is not a file" >&2
        [[ -d $py_dir_ ]] || echo "$py_dir_ is not a directory" >&2
        [[ -f $py_script_ ]] || echo "$py_script_ is not a file" >&2
        command ack "$@"
        return 1
    fi
    local _option=-j
    [[ $* =~ -j ]] && _option=
    eval $(python $py_script_ $_option "$@")
}

ack_find () {
    local __doc__="Choose which ack-function to run"
    if [[ $# -gt 0 && ${!#} =~ -v ]]; then
        run_ack_vim "${@/-v/}"
    else
        run_ack_with "$@"
    fi
}

run_ack_vim () {
    local __doc__="Search for args with ack, edit results with vim"
    local _regexp=$(convert_regexp "$@")
    local _files=$(run_ack_with -l "$@" | tr '\n' ' ')
    [[ $_files ]] && vim -p $_files +/"$_regexp"
}

find_class_or_function () {
    local __doc__="""Search for a class/function definition in python files"""
    local _find_command=$1; shift
    local _class_or_function=$1; shift
    local _option=
    local _sought="$@"
    if has_option i $_sought; then
        _option=-i
        _sought=$(remove_option i $_sought)
    fi
    local _regexp=\\s*${_class_or_function}.'[^(]*'"$_sought"
    $_find_command $_option --python $_regexp --ignore-dir=tests && return 0
    _regexp=$_sought
    [[ $_class_or_function == "class" ]] && return 1
    [[ $_class_or_function == "def" ]] && _regexp="^$_sought ()"
    $_find_command $_option --shell $_regexp
}
