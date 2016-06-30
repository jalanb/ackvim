#! /bin/cat

# This script is intended to be sourced, not run
if [[ $0 == $BASH_SOURCE ]]
then
    echo "This file should be run as"
    echo "  source $0"
    echo "and should not be run as"
    echo "  sh $0"
fi


# x

a () {
    ack "$@"
}

# xx

aa () {
    vack "$@"
}

ac () {
    ack --code "$@"
}

ae () {
    ack --erl "$@"
}

af () {
    ack --python \\s*def."$@"
}

ai () {
    local sought=$1
    shift
    $(which ack) --pyt '(import.*'"$sought|$sought"'.*import)' "$@"
}

al () {
    ack --html "$@"
}

ap () {
    ack --python "$@"
}

at () {
    ack --pyt "$@"
}

av () {
    vack "$@"
}

# xxx

aaa () {
    vack --nojunk "$@"
}

aap () {
    local _root=${1:-.}
    local _pattern=${2:-def.main}
    local _ignores=( /test /lib /__pycache__ )
    ap \
        ${_ignores[@]/#\// --ignore-dir } "$_pattern" $_root -l | \
        grep -v -e '###' -e '^\s*$' | \
        tr '\n' ' ' | \
        sed -e 's:^:vim -p :' -e "s:$: +/ $_pattern:"
}

aav () {
    vack --all "$@"
}

acv () {
    vack --code "$@"
}

aev () {
    vack --erl "$@"
}

alv () {
    vack --html "$@"
}

apv () {
    vack --python "$@"
}

atv () {
    vack --pyt "$@"
}

awv () {
    vack -w "$@"
}

aiw () {
    local sought=$1
    ack --pyt "(import.*\b$sought\b|\b$sought\b.import)"
}

ash () {
    ack --shell "$@"
}

ack () {
    if [[ $# -gt 0 && ${!#} =~ -v ]]; then
        vack "${@/-v/}"
    else
        ackack "$@"
    fi
}

vap () {
    vack --python "$@"
}

# xxxx

aack () {
    vack "$@"
}

aaav () {
    vack --nojunk "$@"
}

apnt () {
    ap --ignore-dir=test "$@"
}

aash () {
    vack --shell "$@"
}

lack () {
    ackack -l "$@"
}

convert_regexp () {
    VACK_DIR=$(dirname $(readlink -f $BASH_SOURCE))
    python $VACK_DIR/convert_regexps.py "$@"
}

vack () {
    local _regexp=$(convert_regexp "$@")
    local _files=$(ackack -l "$@" | tr '\n' ' ')
    vim -p $_files +/$_regexp
}

vall () {
    vack --all "$@"
}

# xxxxx

clack () {
    clear
    ack "$@"
}

quack () {
    local _result=1
    for $item in "$@"; do
        if has_py $item; then
            python  $1
            _result=0
        fi
    done
    return $_result
}

vvack () {
    vack --nojunk "$@"
}

# xxxxxx

ackack () {
    [[ $* =~ -l ]] || python -c "print '\n\033[0;36m%s\033[0m\n' % ('#' * $(tput cols))"
    local _script="$(dirname $(readlink -f $BASH_SOURCE))/ack_vack.py"
    local _paste=
    [[ $* == v || $1 == PASTE ]] && _paste=$(pbpaste)
    [[ $1 == PASTE ]] && shift
    if [[  $PYTHON_DEBUGGING == -U || $DEBUGGING == www ]]; then
        python $_script $PYTHON_DEBUGGING "$@"
    else
        $(python $_script "$@")
    fi
}
