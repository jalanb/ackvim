#! /bin/cat

# set -x

# This script is intended to be sourced, not run
if [[ $0 == $BASH_SOURCE ]]
then
    echo "This file should be run as"
    echo "  source $0"
    echo "and should not be run as"
    echo "  sh $0"
fi


# x

# a is a function

# xx

# so is aa

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
    ack --pyt '(import.*'"$sought|$sought"'.*import)' "$@"
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
    ack --nojunk "$@"
}

aap () {
    ack --python -v "$@"
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

av_ () {
    (cd $1; a "$@" -v)
}

avb () {
    __doc__="vack all args in $JAB/src/bash";
    av_ $JAB/src/bash "$@"
}

avd () {
    __doc__="vack all args in $DASHBOARD";
    av_ $DASHBOARD "$@"
}

avg () {
    __doc__="vack all args in $GIT";
    av_ $GIT "$@"
}

avh () {
    __doc__="vack all args in $HUB";
    av_ $HUB "$@"
}

avj () {
    __doc__="vack all args in $JAB";
    av_ $JAB "$@"
}

avp () {
    __doc__="vack all args in $JAB/src/python";
    av_ $JAB/src/python "$@"
}

avs () {
    __doc__="vack all args in $SRC";
    av_ $SRC "$@"
}

avu () {
    __doc__="vack all args in ~";
    av_ ~ "$@"
}

avv () {
    __doc__="vack all args in $JAB/vim";
    av_ $JAB/vim "$@"
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

VACK_DIR=$(dirname $(readlink -f $BASH_SOURCE))

ack () {
    python -c "print '\n\033[0;36m%s\033[0m\n' % ('#' * $(tput cols))"
    local _sought="$@"; [[ $* == v ]] && _sought=$(pbpaste)
    cmd="$(python $VACK_DIR/ack_vack.py $_sought)"
    $cmd
}

a () {
    ack "$@"
}

aa () {
    vack "$@"
}

vap () {
    vack --python -v "$@"
}

# xxxx

aack () {
    vack "$@" -v
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
    ack -l "$@"
}

vack () {
    local python_script=$VACK_DIR/ack2vim.py
    local bash_script=$VACK_DIR/ack2vim.bash
    rm -f $bash_script
    trap "{ rm -f $bash_script ; exit 0; }" EXIT
    local python_options=-v
    [[ "$@" =~ -v ]] && python_options=
    if PYTHONPATH=$VACK_DIR python $python_script $python_options "$@" > $bash_script 2>&1
    then bash $bash_script
    else cat $bash_script
    fi
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

# echo "from ack2vim"
# set +x
