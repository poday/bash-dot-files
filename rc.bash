#!/usr/bin/env bash

#set -x
#set -euo pipefail

function is_bin_in_path {
    builtin type -P "$1" &> /dev/null
}

function add_dir_to_path {
    if [[ -d "$1" ]]; then
        export PATH="$1:$PATH";
    fi
}

function source_existing_file {
    if [[ -f "$1" ]]; then
        #set +euo pipefail
        source "$1"
        #set -euo pipefail
    fi
}

function base_completion_handle {
    if is_bin_in_path $1; then
        #set +euo pipefail
        source <($1 completion bash)
        #set -euo pipefail
    fi;
}

function set_script_dir {
    local script_path="$(readlink -f ${BASH_SOURCE[0]})"
    SCRIPTDIR="$( cd "$( dirname "${script_path}" )" >/dev/null 2>&1 && pwd )"
}

function prompt_command {
    # capture the previous command's exit code before it is over writen
    CUSTOM_RET=$?
    #set the tab/window title. Current length is based around MS's "Windows Terminal"
    if [[ ${#PWD} < 15 ]]; then
        echo -en "\033]0;$(whoami)@$(hostname)@${PWD}\a"
    else
        echo -en "\033]0;$(whoami)@$(hostname)@...${PWD: -14}\a"
    fi;

    export PS1=$($SCRIPTDIR/bash_prompt_command.bash $CUSTOM_RET $SHLVL)
}

source_existing_file "$HOME/.bash_local_rc"

add_dir_to_path "$HOME/bin"
add_dir_to_path "$HOME/.cargo/bin"
add_dir_to_path "$HOME/.local/bin"

set_script_dir

export GLICOLOR=1

# only use custom prompt when opted in
if [[ "${USE_CUSTOM_PROMPT}" != "" ]]; then
    #bash env var to shorten displayed path prompt
    PROMPT_DIRTRIM=3
    export PROMPT_COMMAND=prompt_command
fi



# Get color support for 'less'
export LESS="--RAW-CONTROL-CHARS"

source_existing_file "$SCRIPTDIR/aliases.bash"

# Use colors for less, man, etc.
source_existing_file "$SCRIPTDIR/less-termcap.bash"

# bash completion
source_existing_file "/usr/local/etc/bash_completion"

# bash completion for MacOS git
if is_bin_in_path brew; then
    if [[ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]]; then
        #set +euo pipefail
        source $(brew --prefix)/etc/bash_completion.d/git-completion.bash
        #set -euo pipefail
    fi;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" $HOME/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# if there is a global bash completion, use that. Otherwise select a few
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    #set +euo pipefail
    source /usr/share/bash-completion/bash_completion
    #set -euo pipefail
else
    source_existing_file "/usr/share/bash-completion/completions/apt"
    source_existing_file "/usr/share/bash-completion/completions/git"
fi

# aws auto complete
if is_bin_in_path aws_completer; then
    complete -C "$(command -v aws_completer)" aws
fi;

base_completion_handle eksctl
base_completion_handle kubectl
base_completion_handle helm

if is_bin_in_path pipenv; then
    #set +euo pipefail
    eval "$(_PIPENV_COMPLETE=bash_source pipenv)"
    #set -euo pipefail
fi;

# init the ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
   # Check for a currently running instance of the agent
   RUNNING_AGENT="`ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]'`"
   if [ "$RUNNING_AGENT" = "0" ]; then
        # Launch a new instance of the agent
        ssh-agent -s &> $HOME/.ssh/ssh-agent
   fi;
   eval `cat $HOME/.ssh/ssh-agent` > /dev/null 2>&1;
fi;

# disbale the settings as other bash scripts may not have the same bar
#set +euo pipefail
