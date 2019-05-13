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

echo "${ERRMSG}${USERSTYLE}\u${WHITE}@${HOSTSTYLE}\h${WHITE}@${CYAN}\t${WHITE}@${YELLOW}\w${WHITE}\$ $RESTORE"
