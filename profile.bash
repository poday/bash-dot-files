function set_script_dir {
    local script_path="$(readlink -f ${BASH_SOURCE[0]})"
    SCRIPTDIR="$( cd "$( dirname "${script_path}" )" >/dev/null 2>&1 && pwd )"
}

function source_existing_file {
    [[ -f "${1}" ]] && source "${1}"
}
function source_real_file {
    [[ -f "${1}" ]] && [[ ! -L "${1}" ]] && source "${1}"
}

set_script_dir

source_real_file "$HOME/.bashrc"
source_existing_file "$SCRIPTDIR/rc.bash"
source_existing_file "$HOME/.bash_local_profile"
