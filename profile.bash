#!/usr/bin/env bash

#set -x

function is_bin_in_path {
    if [[ -n $ZSH_VERSION ]]; then
        builtin whence -p "$1" &> /dev/null
    else  # bash:
        builtin type -P "$1" &> /dev/null
    fi
}

function add_dir_to_path {
    [[ -d "$1" ]] && export PATH="$1:$PATH";
}

function source_existing_file {
    [[ -f $1 ]] && source $1
}

function set_script_dir {
    local script_path="$(readlink -f ${BASH_SOURCE[0]})"
    SCRIPTDIR="$( cd "$( dirname "${script_path}" )" >/dev/null 2>&1 && pwd )"
}

function prompt_command {
    # capture the previous command's exit code before it is over writen
    RET=$?
    #set the tab/window title. Current length is based around MS's "Windows Terminal"
    if [[ ${#PWD} < 15 ]]; then
        echo -en "\033]0;$(whoami)@$(hostname)@${PWD}\a"
    else
        echo -en "\033]0;$(whoami)@$(hostname)@...${PWD: -14}\a"
    fi;

    export PS1=$($SCRIPTDIR/bash_prompt_command.bash $RET $SHLVL)
}

add_dir_to_path "$HOME/bin"
add_dir_to_path "$HOME/.cargo/bin"
add_dir_to_path "$HOME/.local/bin"

source_existing_file "$HOME/.bashrc"

set_script_dir

source_existing_file "/usr/local/etc/bash_completion"

export GLICOLOR=1

#bash env var to shorten displayed path prompt
PROMPT_DIRTRIM=3
export PROMPT_COMMAND=prompt_command

# Get color support for 'less'
export LESS="--RAW-CONTROL-CHARS"

source_existing_file "$SCRIPTDIR/aliases.bash"

# Use colors for less, man, etc.
source_existing_file "$SCRIPTDIR/less-termcap.bash"

# bash completion for git
if is_bin_in_path brew; then
    [[ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]] && source $(brew --prefix)/etc/bash_completion.d/git-completion.bash
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" $HOME/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;


if is_bin_in_path kubectl; then
    source <(kubectl completion bash)
fi;

if is_bin_in_path helm; then
    source <(helm completion bash)
fi;

#source_existing_file "$HOME/.bash_local_profile"
