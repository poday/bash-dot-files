# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	alias ls="ls -Fh --color"
else # macOS `ls`
	alias ls="ls -Fh -G"
fi

# Move export GREP_OPTIONS="--color=auto" (which is deprecated) from .exports to .alias
# Always enable colored `grep` output`
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"

alias tmux-create="tmux new-session -A -s"
