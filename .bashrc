# If not running interactively, don't do anything
[ -z "$PS1" ] && return

HISTCONTROL=ignoredups:ignorespace

# append to the history file, don't overwrite it
shopt -s histappend

PROMPT_COMMAND='history -a'

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=100000
HISTFILESIZE=100000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
shopt -s cmdhist
shopt -s cdspell

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

function parse_git_branch {
git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'
}

function git_unadded_new {
if git rev-parse --is-inside-work-tree &> /dev/null
then
if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]]
then
echo ""
else
echo "[] "
fi
fi
}

function git_needs_commit {
if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
then
# Default: off - these are potentially expensive on big repositories
git diff-index --cached --quiet --ignore-submodules HEAD 2> /dev/null
(( $? && $? != 128 )) && echo "๏ "
fi
}

function git_modified_files {
        if [[ "git rev-parse --is-inside-work-tree &> /dev/null)" != 'true' ]] && git rev-parse --quiet --verify HEAD &> /dev/null
        then
                # Default: off - these are potentially expensive on big repositories
                git diff --no-ext-diff --ignore-submodules --quiet --exit-code || echo "༅ "
        fi
}

function pgvim() {
    COMPREPLY=()
    local cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    cd ~/phpprojects/"$@" && gvim ;
}

complete -F "pgvim" -o "default" "pgvim"

if [ `id -u` = 0 ]; then
COLOUR="04;01;31m"
PATH_COLOUR="04;01;31m"
TIME_COLOUR="0;31m"
else
COLOUR="01;32m"
PATH_COLOUR="01;34m"
TIME_COLOUR="0;33m"
fi

BOLD_RED="01;31m"
BOLD_GREEN="01;32m"
BOLD_BLUE="01;34m"

PS1='\[\033[$TIME_COLOUR\]$(date +%H:%M)\[\033[00m\] ${debian_chroot:+($debian_chroot)}\[\033[$COLOUR\]\u@\h\[\033[00m\]: \[\033[01;$PATH_COLOUR\]\w\[\033[00m\]\[\033[01;35m\] $(parse_git_branch)\[\033[00m\]\[\033[$BOLD_RED\]$(git_unadded_new)\[\033[00m\]\[\033[$BOLD_GREEN\]$(git_needs_commit)\[\033[00m\]\[\033[$BOLD_BLUE\]$(git_modified_files)\[\033[00m\]\n$ '

#if [ "$color_prompt" = yes ]; then
#    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
#else
#    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
#fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=always'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'    

    alias grep='grep --color=always'
    alias fgrep='fgrep --color=always'
    alias egrep='egrep --color=always'
fi

# some more ls aliases
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'
alias less='less -R'
alias g='git'
alias phpunit='phpunit --colors'
alias py='python'
alias uctag="ctags -R --exclude='.git' ."
alias mvim='gvim'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# pip bash completion start
_pip_completion()
{
    COMPREPLY=( $( COMP_WORDS="${COMP_WORDS[*]}" \
                   COMP_CWORD=$COMP_CWORD \
                   PIP_AUTO_COMPLETE=1 $1 ) )
}
complete -o default -F _pip_completion pip
# pip bash completion end

# used to autocomplete ssh connections using aliases defined in ssh config...
_ssh() 
{
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config | grep -v '[?*]' | cut -d ' ' -f 2-)

    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh

PATH=/usr/local/bin:/usr/local/share/python:$PATH
PATH=/usr/local/php5/bin:$PATH
PATH=$PATH:/usr/local/sbin
PATH=$PATH:$HOME/bin


# Work specific. only run following on local machine. dont want to overwrite test server settings.
export PROD_HOSTNAME='ess-lon-ora-001.internal.essence.co.uk'
export TEST_HOSTNAME='ess-lon-oratest-002.internal.essence.co.uk'

if [[ $(hostname) = ${PROD_HOSTNAME} ]]; then
    echo "Setting MIS1_CONFIG='ProdConfig'"
    export MIS1_CONFIG='ProdConfig'
elif [[ $(hostname) = ${TEST_HOSTNAME} ]]; then
    echo "Setting MIS1_CONFIG='TestConfig'"
    export MIS1_CONFIG='TestConfig'
    # mod - autocompletes when using bash aliases which is sweet!
    if [ -f ~/walkerd/bashrc/.git-completion.bash ]; then
        source ~/walkerd/bashrc/.git-completion.bash
    else
        echo "~/walkerd/bashrc/.git-completion.bash does not exist!"
    fi
else
    echo "Setting MIS1_CONFIG='LocalConfig'"
    export MIS1_CONFIG='LocalConfig'

    # mod - autocompletes when using bash aliases which is sweet!
    if [ -f ~/bashrc/.git-completion.bash ]; then
        source ~/bashrc/.git-completion.bash
    else
        echo "~/bashrc/.git-completion.bash does not exist!"
    fi

    if [[ -z ${MIS_BASE} ]]; then
        #only set this if it's not currently set. test environment will have this already set.
        echo "Setting MIS_BASE=$HOME/git/essence-mis-1"
        export MIS_BASE="$HOME/git/essence-mis-1"
    fi

    if [ -f ${MIS_BASE}/env.sh ]; then
        . "$MIS_BASE/env.sh"
    else
        echo "$MIS_BASE/env.sh does not exist!"
    fi
    
    ###########################################################################
    ### ORACLE  
    ###########################################################################

    # ORACLE_HOME is also set in env.sh above so need to redefined it here
    export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib/:${LD_LIBRARY_PATH}
    export OCI_LIB=/usr/lib/oracle/12.1/client64/lib
    export ORACLE_HOME=/usr/lib/oracle/12.1/client64
    export PATH=/usr/lib/oracle/12.1/client64/bin:${PATH}

    # General Oracle details
    export DB_HOST="localhost"
    export DB_PORT="1521"
    export DB_SERVICE="xe"

    # Credentials for use in Oracle XE docker containers
    export SYSTEM_USER_STRING="system/oracle"
    export SYS_USER_STRING="sys/sys"
    export OLIVE_USER_STRING="olive/olive"
    export SANFRAN_USER_STRING="sanfran/sanfran"
    export EBAY_USER_STRING="ebay/ebay"

    if [[ -f ~/export_connections.sh ]]; then
        . ~/export_connections.sh
    else
        echo "~/export_connections.sh does not exist!"
    fi

    if [[ -z ${CONN_STRING} ]]; then
        echo "Setting CONN_STRING=${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
        export CONN_STRING="@${DB_HOST}:${DB_PORT}/${DB_SERVICE}"
    fi
    export PROD_CONN_STRING="ess-lon-ora-001:1521/ffmis.essence.co.uk"
    export TEST_CONN_STRING="ess-lon-oratest-002:1521/ffmis.essence.co.uk"

    alias kill_sqldev="ps -ef | grep sqldeveloper | awk '/[j]ava/{print $2}' | xargs -n1 kill; exit"
    ###########################################################################


    ###########################################################################
    ### PYTHON
    ###########################################################################
    export PYTHONPATH=~/git/ds-olive-3/:${PYTHONPATH}
    alias py27='source ~/pve/py27/bin/activate'
    alias py34='source ~/pve/py34/bin/activate'
    alias pylocal='source ~/pve/py34/bin/activate && export MIS3_CONFIG=LocalTestConfig && echo "MIS3_CONFIG set to LocalTestConfig"'
    alias pyprod='source ~/pve/py34/bin/activate && export MIS3_CONFIG=ProdConfig && echo "MIS3_CONFIG set to ProdConfig"'
    alias pyunit='export MIS3_CONFIG=LocalUnitTestConfig'
    ###########################################################################


    ###########################################################################
    ### DOCKER
    ###########################################################################

    # docker service aliases
    alias dstart='service docker_oracle_xe start'
    alias dstop='service docker_oracle_xe stop'

    # docker aliases
    alias dps='docker ps'
    alias dpsa='docker ps -a'
    alias drun='function _docker_run(){ echo " creating oracle_xe container $1 using port $2"; docker run -d -v $MIS_BASE:/opt/essence-mis-1 --restart unless-stopped -p $2:1521 --name $1 essence_oracle_xe; }; _docker_run'
    alias drmi='function _docker_rmi(){ echo "stop and remove image $1"; docker rmi $1; }; _docker_rmi'
    alias drmc='function _docker_rmc(){ echo "stop and remove container $1"; docker stop $1; docker rm $1; }; _docker_rmc'
    alias dbsh='function _docker_execute(){ echo "starting bash in container $1"; docker exec -ti $1 bash; }; _docker_execute'
    alias dsql='function _docker_sql(){ local SYS="SYS"; local SCRIPT="$2"; local USER="$1"; if [[ -z ${DB_PORT} ]]; then local DB_PORT=1521; fi; echo "running sql script ${SCRIPT} as user ${USER} on port ${DB_PORT}"; if [[ "${USER,,}" = "${SYS,,}" ]]; then local append=" as sysdba"; fi; sqlplus -L "${USER}/${USER}@localhost:${DB_PORT}/xe${append}" @${SCRIPT}; }; _docker_sql'

    ###########################################################################

    # django
    source ~/.django_bash_completion.sh

fi

# Local sqlplus alias'
alias sqllol='function _run_sql_olive(){ if [[ -z ${OLIVE_USER_STRING} ]]; then echo "OLIVE_USER_STRING not set. Cannot execute"; fi; sqlplus -L ${OLIVE_USER_STRING}${CONN_STRING} $1 $2 $3 $4 $5 $6; }; _run_sql_olive'
alias sqllsan='function _run_sql_sanfran(){ if [[ -z ${SANFRAN_USER_STRING} ]]; then echo "SANFRAN_USER_STRING not set. Cannot execute"; fi; sqlplus -L ${SANFRAN_USER_STRING}${CONN_STRING} $1 $2 $3 $4 $5 $6; }; _run_sql_sanfran'
alias sqllsys='function _run_sql_sys(){ if [[ -z ${SYS_USER_STRING} ]]; then echo "SYS_USER_STRING not set. Cannot execute"; fi; sqlplus -L ${SYS_USER_STRING}${CONN_STRING} AS SYSDBA $1 $2 $3 $4 $5 $6; }; _run_sql_sys'
alias sqllur='sqllol @ $MIS_BASE/release/scripts/update_release.sql'

# PROD sqlplus alias'
alias sqlpol='function _run_sql_prod_olive(){ sqlplus -L ${OLIVE_PROD}@${PROD_CONN_STRING} $1 $2 $3 $4 $5 $6; }; _run_sql_prod_olive'
alias sqlpsan='function _run_sql_prod_sanfran(){ sqlplus -L ${SANFRAN_PROD}@${PROD_CONN_STRING} $1 $2 $3 $4 $5 $6; }; _run_sql_prod_sanfran'
alias sqlpsys='function _run_sql_prod_sys(){ sqlplus -L ${SYS_PROD}@${PROD_CONN_STRING} AS SYSDBA $1 $2 $3 $4 $5 $6; }; _run_sql_prod_sys'

# TEST sqlplus alias'
alias sqltol='function _run_sql_test_olive(){ sqlplus -L ${OLIVE_TEST}@${TEST_CONN_STRING} $1 $2 $3 $4 $5 $6; }; _run_sql_test_olive'
alias sqltsan='function _run_sql_test_sanfran(){ sqlplus -L ${SANFRAN_TEST}@${TEST_CONN_STRING} $1 $2 $3 $4 $5 $6; }; _run_sql_test_sanfran'
alias sqltsys='function _run_sql_test_sys(){ sqlplus -L ${SYS_TEST}@${TEST_CONN_STRING} AS SYSDBA $1 $2 $3 $4 $5 $6; }; _run_sql_test_sys'

# github
alias gd='cd ~/git'    

#. /etc/bash_completion.d/django_bash_completion
export PYTHONSTARTUP=~/.pythonrc
export DJANGO_COLORS="light"

# format json
alias pjson='python -m json.tool'

# git aliases.
# this is the only one that's required. All others are defined in .gitconfig
alias g="git"

alias sanitize='~/git/database-scripts/unix/sanitize'
alias matrixize='/home/dave/bashrc/matrix'

alias rmswp='find ./ -type f -name "\.*sw[klmnop]" -delete'

alias wo_mis1='if [[ ! -z ${VIRTUAL_ENV} ]]; then deactivate; fi; cd ~/git/essence-mis-1'
alias wo_mis3='cd ~/git/ds-olive-3 && source ~/pve/py34/bin/activate'

