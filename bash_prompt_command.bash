BLACK="\[\033[0;30m\]"
BLUE="\[\033[0;34m\]"
BROWN="\[\033[0;33m\]"
CYAN="\[\033[0;36m\]"
GREEN="\[\033[0;32m\]"
LIGHT_BLUE="\[\033[1;34m\]"
LIGHT_CYAN="\[\033[1;36m\]"
LIGHT_GRAY="\[\033[0;37m\]"
LIGHT_GREEN="\[\033[1;32m\]"
LIGHT_PURPLE="\[\033[1;35m\]"
LIGHT_RED="\[\033[1;31m\]"
ORANGE="\[\033[0;33m\]"
PURPLE="\[\033[0;35m\]"
RED="\[\033[0;31m\]"
WHITE="\[\033[1;37m\]"
YELLOW="\[\033[33m\]"

RESTORE="\[\033[0m\]" #0m restores to the terminal's default colour

parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}
parse_git_remote() {
    git config --get remote.origin.url | sed 's|^.*//||; s/.*@//; s/[^:/]\+[:/]//; s/.git$//'
}
parse_git_file_status() {
    gitstatus=$( LC_ALL=C git status --untracked-files=normal --porcelain --branch )
    num_staged=0
    num_changed=0
    num_conflicts=0
    num_untracked=0
    while IFS='' read -r line || [[ -n "${line}" ]]; do
        status="${line:0:2}"
        while [[ -n ${status} ]]; do
            case "${status}" in
            #two fixed character matches, loop finished
            \#\#) branch_line="${line/\.\.\./^}"; break ;;
            \?\?) ((num_untracked++)); break ;;
            U?) ((num_conflicts++)); break;;
            ?U) ((num_conflicts++)); break;;
            DD) ((num_conflicts++)); break;;
            AA) ((num_conflicts++)); break;;
            #two character matches, first loop
            ?M) ((num_changed++)) ;;
            ?D) ((num_changed++)) ;;
            ?\ ) ;;
            #single character matches, second loop
            U) ((num_conflicts++)) ;;
            \ ) ;;
            *) ((num_staged++)) ;;
            esac
            status="${status:0:(${#status}-1)}"
        done
    done <<< "${gitstatus}"
    IFS="^" read -ra branch_fields <<< "${branch_line/\#\# }"
    branch="${branch_fields[0]}"
    IFS="[,]" read -ra remote_fields <<< "${branch_fields[1]}"
    upstream="${remote_fields[0]}"
    up_arrow=$'\xe2\x86\x91'
    down_arrow=$'\xe2\x86\x93'
    for remote_field in "${remote_fields[@]}"; do
      if [[ "${remote_field}" == "ahead "* ]]; then
        num_ahead="${remote_field:6}"
        #\xe2\x86\x91
        ahead="${up_arrow}${num_ahead# }"
      fi
      if [[ "${remote_field}" == "behind "* ]] || [[ "${remote_field}" == " behind "* ]]; then
        num_behind="${remote_field:7}"
        behind="${down_arrow}${num_behind# }"
      fi
    done
    remote="${behind-}${ahead-} "

    if (( num_staged != 0)) ; then
        git_stage_prompt="stage: ${num_staged} "
    fi
    if (( num_changed != 0)) ; then
        git_num_changed="changed: ${num_changed} "
    fi
    if (( num_conflicts != 0)) ; then
        git_num_conflicts="stage: ${num_conflicts} "
    fi
    if (( num_untracked != 0)) ; then
        git_num_untracked="stage: ${num_untracked} "
    fi


    echo "${git_stage_prompt-}${git_num_changed-}${git_num_conflicts-}${git_num_untracked-}commits: ${remote}"
}

parse_tmux_session() {
    CUSTOMTTY=$(tty)
    tmux list-panes -a -F '#{pane_tty} #{session_name}' -t "$s" 2>/dev/null | grep "$CUSTOMTTY" 2>/dev/null | awk '{print $2}'
}

count_dir_pop_depth() {
    echo $(( $(dirs -p | wc -l) -1))
}
next_dir_pop_directory() {
    dirs +1
}

if [ -z $SCHROOT_CHROOT_NAME ]; then
    SCHROOT_CHROOT_NAME=" "
fi;

# set the color of $? to red when $? != 0
ERRMSG=""
RET=$1
if [[ $RET != 0 ]]; then
    ERRMSG="${RED}(${RET})"
else
    ERRMSG="${YELLOW}(${RET})"
fi;

#set the user color to red when root
if [[ "${USER}" == "root" ]]; then
    USERSTYLE="${RED}"
else
    USERSTYLE="${CYAN}"
fi;

# Highlight the hostname when connected via SSH.
if [[ "${SSH_TTY}" ]]; then
	HOSTSTYLE="${YELLOW}";
else
	HOSTSTYLE="${GREEN}";
fi;

#export PS1="\`if [ \$? = 0 ]; then echo \[\e[33m\]\(0\)\[\e[0m\]; else echo \[\e[31m\]\(\$?\)\[\e[0m\]; fi\`\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h\[\033[m\]@\[\033[36m\]\t\[\033[m\]@\[\033[33;1m\]\w\[\033[m\]\$ "
#echo "${GREEN}\u@\h${SCHROOT_CHROOT_NAME}${BLUE}\w \
#${CYAN}${BRANCH}${RED}${ERRMSG} \$ $RESTORE"

ENVSTR=""

#small hack, SHLVL is off by 1 in OSX so we handle it differently
#ubuntu bash 4.4.20 seems to have shlvl off by 2
if [[ $(uname -s) == Darwin ]]; then
    SHELL_LEVEL=$((${SHLVL} - 2))
else
    SHELL_LEVEL=$((${SHLVL} - 2))
fi;
if [[ ${SHELL_LEVEL} != 0 ]]; then
    ENVSTR="${ENVSTR}${WHITE}NEST(${ORANGE}${SHELL_LEVEL}${WHITE})"
fi;

if [[ "${TMUX}" != "" ]]; then
    TMUX_SESSION=$(parse_tmux_session)
    if [[ "${TMUX_SESSION}" != "" ]]; then
        ENVSTR="${ENVSTR}${WHITE}TMUX(${LIGHT_GREEN}${TMUX_SESSION}${WHITE})"
    fi;
fi;

GITBRANCH=$(parse_git_branch)
if [[ "${GITBRANCH}" != "" ]]; then
    GITSTATUS=$(parse_git_file_status)
    ENVSTR="${ENVSTR}${WHITE}GIT(${LIGHT_GREEN}${GITBRANCH}${WHITE})${GITSTATUS}"
fi;

if [[ "${PIPENV_ACTIVE}" == "1" ]]; then
    ENVSTR="${ENVSTR}${WHITE}(${ORANGE}PIPENV${WHITE})"
fi;

DIRPOPDEPTH=$(count_dir_pop_depth)
if [[ "${DIRPOPDEPTH}" != "0" ]]; then
    NEXTDIRPOP=$(next_dir_pop_directory)
    ENVSTR="${ENVSTR}${WHITE}POPD(${ORANGE}${DIRPOPDEPTH}${WHITE}:${LIGHT_GREEN}${NEXTDIRPOP}${WHITE})"
fi;


if [[ "${ENVSTR}" != "" ]]; then
    ENVSTR="${ENVSTR}\n"
fi;

echo "\n${ENVSTR}${ERRMSG}${USERSTYLE}\u${WHITE}@${HOSTSTYLE}\h${WHITE}@${CYAN}\t${WHITE}@${YELLOW}\w\n${WHITE}\$ $RESTORE"
