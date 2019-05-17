#! /bin/cat

# "Big Electric Cat", Adrian Belew, "Lone Rhino", 1982.

# Kvetching vim into grep


_gvep () {
    local _sought="$1"; shift;
    local _paths=$(grep "$_sought" -r * 2>/dev/null | sed -e s/:.*// | sort | uniq | tr '\n' ' ')
    if [[ -z "$_paths" ]]; then
        echo "\"""$_sought""\" not found"
        return 1
    fi
    vim -p $_paths "$@" +/"$_sought";
}

gvep () {
    local __doc__="'gvep fred' will search recursively from here in all files for 'fred'\
                   and open all matching files in vim searching for 'fred'"
    _gvep "$1"
}

gvep_from () {
    local __doc__="'gvep_from ~ fred *.log' will search from ~/ for 'fred', and vim any findings"
    (cd $1; shift;
        _gvep "$@")
}
