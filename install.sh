#!/usr/bin/env bash

#set -x
set -euo pipefail

function set_script_dir {
    local script_path="$(readlink -f ${BASH_SOURCE[0]})"
    SCRIPTDIR="$( cd "$( dirname "${script_path}" )" >/dev/null 2>&1 && pwd )"
}

function move_file_to_local {
    local bashrc="$HOME/.bashrc"
    local localbashrc="$HOME/.bash_local_rc"
    if [[ -f "${bashrc}" && ! -L "${bashrc}" && ! -f "${localbashrc}" ]]; then
        mv "${bashrc}" "${localbashrc}"
        ln -s "${SCRIPTDIR}/rc.bash" "${bashrc}"
    fi
}

function copy_config_files {
    local config_dir=${XDG_CONFIG_HOME:-"$HOME/.config"}
    mkdir -p "${config_dir}/git"
    cp -R "${SCRIPTDIR}/git" "${config_dir}"
}

set_script_dir
move_file_to_local
copy_config_files

set +euo pipefail
