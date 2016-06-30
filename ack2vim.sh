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
    ack --nojunk "$@"
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

VACK_DIR=$(dirname $(readlink -f $BASH_SOURCE))

ack_python () {
    (cd $(dirname $(readlink -f $BASH_SOURCE))
    local _script=$1; shift
    if [[  $PYTHON_DEBUGGING == -U|| $DEBUGGING == www ]]; then
        python $_script $PYTHON_DEBUGGING "$@"
    else
        $(python $_script "$@")
    fi
    )
}

ack () {
    python -c "print '\n\033[0;36m%s\033[0m\n' % ('#' * $(tput cols))"
    # /usr/local/bin/ack "$@"
    # return
    local _sought="$@"; [[ $* == v ]] && _sought=$(pbpaste)
    cmd="$(python $VACK_DIR/ack_vack.py $_sought)"
    (cd $VACK_DIR
    if [[ $* == v ]]; then
        ack_python ack_vack.py $(pbpaste)
    elif [[ $1 == PASTE ]]; then
        shift
        ack_python ack_vack.py $(pbpaste) "$@"
    else
        ack_python ack_vack.py "$@"
    fi)
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

convert_regexp () {
    VACK_DIR=$(dirname $(readlink -f $BASH_SOURCE))
    python $VACK_DIR/convert_regexps.py "$@"
}

vack () {
    local _regexp=$(convert_regexp "$@")
    local python_options=-v
    [[ "$@" =~ -v ]] && python_options=
    (cd $VACK_DIR
    if ack_python ack2vim.py $python_options "$@" > ack2vim.bash 2>&1; then
        trap "{ rm -f $bash_script ; exit 0; }" EXIT
        bash $bash_script
    else
        cat $bash_script
    fi)
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
