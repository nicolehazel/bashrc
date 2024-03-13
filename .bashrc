# I  not running interactively, don't do anything
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

###########################################################################

# alias for pushd and popd
alias dirs='dirs -v'

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="$HOME/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# RUST (I didn't add this)
. "$HOME/.cargo/env"

export PATH="~/Library/Python/3.10/bin:/usr/local/opt/python/libexec/bin:/opt/homebrew/bin:/opt/homebrew/opt/rabbitmq/sbin:/opt/homebrew/opt/redis/bin:$HOME/gcp/google-cloud-sdk/bin:$PATH:$HOME/Library/Python/3.9/bin"
export PYTHONPATH="$HOME/git/gc/pyscf:$HOME/git/gc/qemist-cloud/qemist_sdk:$HOME/git/gc/qemist-cloud/protocloud:$HOME/git/gc/qemist-cloud/client_lib/release_lib"

function source_ext() {
  EXT_FILE="$HOME/git/bashrc/extensions/$1"
  if [ -f "$EXT_FILE" ]; then
    echo "- ${EXT_FILE}"
    source "$EXT_FILE"
    echo
  else
    echo "!! Extension not found: ${EXT_FILE}"
  fi
}

echo "Adding extensions:"
source_ext aws
source_ext bash_aliases
# source_ext dev
source_ext docker
# source_ext gcp
# source_ext git
# source_ext jenkins
source_ext kubectl
# source_ext ps
source_ext python
source_ext qemist
# source_ext ssh
source_ext terraform
