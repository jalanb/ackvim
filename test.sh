#! /bin/bash 

set -e # fail for any reason

_here=$(dirname $BASH_SOURCE)
source $_here/vimack.sh

run_tests () {
    a source
    ash source
    ap import
    at import
}

cd $_here
run_tests >/dev/null
echo PASS
