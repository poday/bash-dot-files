#!/usr/bin/env bash

#set -x

function set_script_dir {
    local script_path="$(readlink -f ${BASH_SOURCE[0]})"
    SCRIPTDIR="$( cd "$( dirname "${script_path}" )" >/dev/null 2>&1 && pwd )"
}
function move_file_to_local {
    [[ -f "${1}" ]] && [[ ! -L "${1}" ]] && mv "${1}" $HOME/.bash_local_rc
}

set_script_dir
move_file_to_local $HOME/.bashrc
ln -s $SCRIPTDIR/rc.bash $HOME/.bashrc
