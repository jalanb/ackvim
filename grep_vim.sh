#! /bin/cat

# "Big Electric Cat", Adrian Belew, "Lone Rhino", 1982.

# Kvetching vim into grep


_gvep () {
    s="$1"; shift;
    vim -p $(grep "$s" -r * 2>/dev/null | sed -e s/:.*// | sort | uniq | tr '\n' ' ') "$@" +/"$s";
    git status $(grep "$s" -r * 2>/dev/null | sed -e s/:.*// | sort | uniq | tr '\n' ' ') "$@";
}

gvep () {
    local __doc__="'gvep fred' will search recursively from here in all files for 'fred'\
                   and open all matching files in vim searching for 'fred'"
    _gvep "$1"
}

gvep_with () {
    local __doc__="'gvep_with fred some.log' will search here for 'fred', and vim any findings with some.log"
    _gvep "$@"
}

gvep_from () {
    local __doc__="'gvep_from ~ fred *.log' will search from $HOME for 'fred', and vim any findings with $HOME/*.log"
    (cd $1; shift;
        _gvep "$@")
}
