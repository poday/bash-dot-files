#!/usr/bin/env bash

#set -x
set -euo pipefail

function set_script_dir {
    local script_path="$(readlink -f ${BASH_SOURCE[0]})"
    SCRIPTDIR="$( cd "$( dirname "${script_path}" )" >/dev/null 2>&1 && pwd )"
}

function move_file_to_local {
    local bashrc="$HOME/.bashrc"
    if [[ -f "${bashrc}" ]] && [[ ! -L "${bashrc}" ]]; then
        mv "${bashrc}" $HOME/.bash_local_rc
        ln -s $SCRIPTDIR/rc.bash $bashrc
    fi
}

set_script_dir
move_file_to_local

set +euo pipefail
