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

# mod - autocompletes when using bash aliases which is sweet!
if [ -f ~/bashrc/.git-completion.bash ]; then
    source ~/bashrc/.git-completion.bash
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

#. /etc/bash_completion.d/django_bash_completion
export PYTHONSTARTUP=~/.pythonrc
export DJANGO_COLORS="light"

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

#json
alias pjson='python -m json.tool'

# docker aliases
alias dostart="service docker_oracle_xe start"
alias dostop="service docker_oracle_xe stop"

#git aliases - other aliases are now in .gitconfig
alias g="git"
alias gd='cd ~/git'

# work specific
export PYTHONPATH=~/git/ds-olive-3/:${PYTHONPATH}
alias py27='source ~/pve/py27/bin/activate'
alias py34='source ~/pve/py34/bin/activate'
alias pylocal='source ~/pve/py34/bin/activate && export MIS3_CONFIG=LocalTestConfig && echo "MIS3_CONFIG set to LocalTestConfig"'
alias pyprod='source ~/pve/py34/bin/activate && export MIS3_CONFIG=ProdConfig && echo "MIS3_CONFIG set to ProdConfig"'
alias pyunit='export MIS3_CONFIG=LocalUnitTestConfig'

export MIS_BASE="$HOME/git/essence-mis-1"
if [ -f $MIS_BASE/env.sh ]; then
    . "$MIS_BASE/env.sh"
fi

# oracle - ORACLE_HOME is also set in env.sh above so need to redefined it
export LD_LIBRARY_PATH=/usr/lib/oracle/12.1/client64/lib/:${LD_LIBRARY_PATH}
export OCI_LIB=/usr/lib/oracle/12.1/client64/lib
export ORACLE_HOME=/usr/lib/oracle/12.1/client64
export PATH=/usr/lib/oracle/12.1/client64/bin:${PATH}

source ~/.django_bash_completion.sh