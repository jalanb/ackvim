#! /bin/cat

[[ -n $WELCOME_BYE ]] && echo Welcome to $(basename "$BASH_SOURCE") in $(dirname $(readlink -f "$BASH_SOURCE")) on $(hostname -f)

# This script is intended to be sourced, not run
if [[ $0 == $BASH_SOURCE ]]
then
    echo "This file should be run as"
    echo "  source $0"
    echo "and should not be run as"
    echo "  sh $0"
fi


# x

unalias a 2>/dev/null
a () {
    ack "$@"
}

# xx

unalias aa 2>/dev/null
aa () {
    aack "$@"
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
    local _ignores=( /test /lib /__pycache__ )
    ack ${_ignores[@]/#\// --ignore-dir } --python "$@"
}

at () {
    ack --pyt "$@"
}

av () {
    aack "$@"
}

# xxx

unalias aaa 2>/dev/null
aaa () {
    aack --nojunk "$@"
}

aac () {
    aack --code "$@"
}

aae () {
    aack --erl "$@"
}

aaf () {
    vack --python \\s*def."$@"
}

aal () {
    aack --html "$@"
}


aap () {
    local _ignores=( /test /lib /__pycache__ )
    vack ${_ignores[@]/#\// --ignore-dir } --python "$@"
}

aat () {
    aack --pyt "$@"
}

aaw () {
    aack -w "$@"
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
        aack "${@/-v/}"
    else
        ackack "$@"
    fi
}

# xxxx

unalias aaaa 2>/dev/null
aaaa () {
    aack --all "$@"
}

aash () {
    aack --shell "$@"
}

lack () {
    ackack -l "$@"
}

convert_regexp () {
    VACK_DIR=$(dirname $(readlink -f $BASH_SOURCE))
    python $VACK_DIR/convert_regexps.py "$@"
}

aack () {
    local _regexp=$(convert_regexp "$@")
    local _files=$(ackack -l "$@" | tr '\n' ' ')
    [[ -n $_files ]] && vim -p $_files +/$_regexp
}

# xxxxx

clack () {
    clear
    ack "$@"
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
        local _option=-j
        [[ $* =~ -j ]] && _option=
        $(python $_script $_option "$@")
    fi
}

[[ -n $WELCOME_BYE ]] && echo Bye from $(basename "$BASH_SOURCE") in $(dirname $(readlink -f "$BASH_SOURCE")) on $(hostname -f)
