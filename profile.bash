
# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

export GLICOLOR=1

function prompt_command {
    RET=$?
    export PS1=$($SCRIPTDIR/bash_prompt_command.bash $RET)
}
PROMPT_DIRTRIM=3
export PROMPT_COMMAND=prompt_command

# Get color support for 'less'
export LESS="--RAW-CONTROL-CHARS"

[[ -f $SCRIPTDIR/aliases.bash ]] && . $SCRIPTDIR/aliases.bash

# Use colors for less, man, etc.
[[ -f $SCRIPTDIR/less-termcap.bash ]] && . $SCRIPTDIR/less-termcap.bash

# bash completion for git
[[ -f "$(brew --prefix)/etc/bash_completion.d/git-completion.bash" ]] && . $(brew --prefix)/etc/bash_completion.d/git-completion.bash

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" $HOME/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

export PATH="$HOME/.cargo/bin:$PATH"
