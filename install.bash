#!/usr/bin/env bash

#set -x

function set_script_dir {
    local script_path="$(readlink -f ${BASH_SOURCE[0]})"
    SCRIPTDIR="$( cd "$( dirname "${script_path}" )" >/dev/null 2>&1 && pwd )"
}

set_script_dir
ln -s $SCRIPTDIR/profile.bash $HOME/.bash_profile
