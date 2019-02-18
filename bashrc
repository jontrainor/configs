# prepend ~/bin scripts to PATH
PATH=$HOME/bin:$PATH

# append global npm packages to PATH
PATH=$PATH:/usr/local/lib/node_modules

# brew settings
export PATH="/usr/local/sbin:$PATH"

# custom prompt
# username@computername:path (git branch)
# $ 
PS1="\u@\h:\w\[\e[35m\]\$(__git_ps1)\[\e[m\]\n$ "

# personal aliases
alias tmux="tmux -2"
alias nosetests="nosetests -sv --exe"
alias ls="ls -G"
alias ll="ls -FGlAhp"
alias la="ls -a"
alias lla="ls -la"
alias serve="python -m SimpleHTTPServer 8000"
alias rtail-server="rtail-server --web-port 8889"
alias reload="source ~/.bash_profile"

# osx
# flush dns cache
alias dnsflush="sudo killall -HUP mDNSResponder"

cd () {
    builtin cd "$@"
    if [ -f .nvmrc ]; then
	nvm use || nvm install
    fi
}

# ll outputs in kb/mb/gb
export BLOCKSIZE=1k

function vimgit() {
	mvim -v $(git ls-files --modified --others --exclude-standard)
}

export -f vimgit

# set up npm autocomplete if npm is installed
if hash npm 2>/dev/null; then
	npm completion >/dev/null
fi

# osx specific aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
	if hash mvim 2>/dev/null; then
		alias vim="mvim -v"
	fi
fi

if hash git 2>/dev/null; then
	source ~/git.d/git-completion.bash
	source ~/git.d/git-prompt.sh
fi

#copy/paste from tmux buffers to linux clipboard
#relies on xclip being installed

# A shortcut function that simplifies usage of xclip.
# - Accepts input from either stdin (pipe), or params.
# ------------------------------------------------
cb() {
	local _scs_col="\e[0;32m"; local _wrn_col='\e[1;31m'; local _trn_col='\e[0;33m'
	# Check that xclip is installed.
	if ! type xclip > /dev/null 2>&1; then
		echo -e "$_wrn_col""You must have the 'xclip' program installed.\e[0m"
	# Check user is not root (root doesn't have access to user xorg server)
	elif [[ "$USER" == "root" ]]; then
		echo -e "$_wrn_col""Must be regular user (not root) to copy a file to the clipboard.\e[0m"
	else
		# If no tty, data should be available on stdin
		if ! [[ "$( tty )" == /dev/* ]]; then
		input="$(< /dev/stdin)"
		# Else, fetch input from params
	else
		input="$*"
	fi
	if [ -z "$input" ]; then  # If no input, print usage message.
		echo "Copies a string to the clipboard."
		echo "Usage: cb <string>"
		echo "       echo <string> | cb"
	else
		# Copy input to clipboard
		echo -n "$input" | xclip -selection c
		# Truncate text for status
		if [ ${#input} -gt 80 ]; then input="$(echo $input | cut -c1-80)$_trn_col...\e[0m"; fi
			# Print status.
			echo -e "$_scs_col""Copied to clipboard:\e[0m $input"
		fi
	fi
}
# ------------------------------------------------

# Aliases / functions leveraging the cb() function
# ------------------------------------------------
# Copy contents of a file
function cbf() { cat "$1" | cb; }  
# Copy SSH public key
alias cbssh="cbf ~/.ssh/id_rsa.pub"  
# Copy current working directory
alias cbwd="pwd | cb"  
# Copy most recent command in bash history
alias cbhs="cat $HISTFILE | tail -n 1 | cb" 

# Copy tmux buffer
# alias tmuxcopy="tmux show-buffer | cb"

#copy/paste from tmux buffers to osx
alias tmuxcopy="tmux saveb -|pbcopy"

# virtualenvwrapper settings
# export WORKON_HOME=$HOME/.virtualenvs
# export PROJECT_HOME=$HOME/Devel
# source /usr/local/bin/virtualenvwrapper.sh

# nvm settings
export NVM_DIR="$HOME/.nvm"
# load nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# nvm autocomplete
[[ -r $NVM_DIR/bash_completion ]] && . $NVM_DIR/bash_completion

export LANG=en_US.UTF-8
# ------------------------------------------------

# required for bash-comption
# ------------------------------------------------
if [ -f /usr/local/etc/bash_completion ]; then
	.	/usr/local/etc/bash_completion
fi
# ------------------------------------------------

# required for nosecomplete
# ------------------------------------------------
# copied from newer versions of bash
__ltrim_colon_completions() {
    # If word-to-complete contains a colon,
    # and bash-version < 4,
    # or bash-version >= 4 and COMP_WORDBREAKS contains a colon
    if [[
        "$1" == *:* && (
            ${BASH_VERSINFO[0]} -lt 4 ||
            (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*)
        )
    ]]; then
        # Remove colon-word prefix from COMPREPLY items
        local colon_word=${1%${1##*:}}
        local i=${#COMPREPLY[*]}
        while [ $((--i)) -ge 0 ]; do
            COMPREPLY[$i]=${COMPREPLY[$i]#"$colon_word"}
        done fi
} # __ltrim_colon_completions()

_nosetests()
{
    cur=${COMP_WORDS[COMP_CWORD]}
    if [[
            ${BASH_VERSINFO[0]} -lt 4 ||
            (${BASH_VERSINFO[0]} -ge 4 && "$COMP_WORDBREAKS" == *:*)
    ]]; then
        local i=$COMP_CWORD
        while [ $i -ge 0 ]; do
            [ "${COMP_WORDS[$((i--))]}" == ":" ] && break
        done
        if [ $i -gt 0 ]; then
            cur=$(printf "%s" ${COMP_WORDS[@]:$i})
        fi
    fi
    COMPREPLY=(`nosecomplete ${cur} 2>/dev/null`)
    __ltrim_colon_completions "$cur"
}
complete -o nospace -F _nosetests nosetests
# ------------------------------------------------


# docker-machine settings
if hash docker-machine 2>/dev/null; then
    eval "$(docker-machine env)"
fi

# rbenv settings
if hash rbenv 2>/dev/null; then
    eval "$(rbenv init -)"
fi

if hash nvm 2>/dev/null && [ -f .nvmrc ]; then
    nvm use || nvm install
fi
