#!/bin/sh -e

# save current working directory
cwd=$(pwd)

# trunk club specific
# add trunk club private npm repo token if one exists
if cat ~/.tc-npm-token > temp_profile && cat profile >> temp_profile ; then
	cp -f temp_profile ~/.bash_profile
	rm temp_profile
else
	cp -f profile ~/.bash_profile
fi

#copy configs to home directory
cp -f vimrc ~/.vimrc
if [[ ! -d ~/.vim ]]; then
	mkdir ~/.vim
fi
if [[ ! -d ~/.ssh ]]; then
	mkdir ~/.ssh
fi
cp -f sshconfig ~/.ssh/config
cp -f .vim/vimrc ~/.vim/vimrc
cp -f tmux.conf ~/.tmux.conf
cp -f bashrc ~/.bashrc
cp -f inputrc ~/.inputrc
cp -f gitconfig ~/.gitconfig
# ls ~/localgitconfig.sh && ~/localgitconfig.sh
cp -f vimpdbrc ~/.vimpdbrc
cp -f agignore ~/.agignore

#if osx 
if [[ "$OSTYPE" == "darwin"* ]]; then
	# install brew
	# from install instructions on brew.sh
	if ! hash brew 2>/dev/null; then
		ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
	fi

	brew update

	# install python
	if ! hash python3 2>/dev/null; then
		brew install python
	fi

	# install brew autocomplete
	if ! brew ls --versions bash-completion >/dev/null; then
		brew install bash-completion
	fi

	# install macvim
	if ! hash mvim 2>/dev/null; then
		brew install macvim
	fi

	# install tmux
	if ! hash tmux 2>/dev/null; then
		brew install tmux
	fi

	# install node
	if ! hash node 2>/dev/null; then
		brew install node
		curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
		source ~/.bashrc
	fi

	# install ack for ack.vim plugin
	if ! hash ack 2>/dev/null; then
		brew install ack
	fi

	# install ag for searching
	if ! hash ag 2>/dev/null; then
		brew install the_silver_searcher
	fi

	# install ripgrep for improved searching with ctrlp
	if ! hash rg 2>/dev/null; then
		brew install ripgrep
	fi

	# install fzf for fuzzy file searching
	if ! hash fzf 2>/dev/null; then
		brew install fzf
	fi

	# install kdiff3 for 3 way merging
	if ! hash kdiff3 2>/dev/null; then
		brew tap caskroom/cask
		brew cask install kdiff3
	fi

	# fix tmux copy/paste
	if ! hash reattach-to-user-namespace 2>/dev/null; then
		brew install reattach-to-user-namespace
	fi

	# install language servers
	# javascript flow
	if ! hash flow-language-server 2>/dev/null; then
		npm install -g flow-language-server
	fi
	
	# ruby
	if ! hash rbenv 2>/dev/null; then
		brew install rbenv
		rbenv global 2.4.3
		source ~/.bashrc
	fi
	if ! hash solargraph 2>/dev/null; then
		gem install solargraph
	fi

fi

# initialize tmux plugin submodules
git submodule init
git submodule update

if cp -R ./tmux/* ~/.tmux; then
	echo 'tmux directory copied'
else
	rm -rf ~/.tmux
	mkdir ~/.tmux
	cp -R ./tmux/* ~/.tmux
	echo 'tmux directory rebuilt'
fi

if cp -R ./git/* ~/git.d; then
	echo 'git directory copied'
else
	rm -rf ~/git.d
	mkdir ~/git.d
	cp -R ./git/* ~/git.d
	echo 'git directory rebuilt'
fi

#copy project files over where possible
#tc 
cp -f tc-customer-app-projections.json ~/projects/customer_app/.projections.json

#copy scripts to ~/bin
if cp -R ./bin/* ~/bin; then
	echo 'bin scripts directory copied'
else
	rm -rf ~/bin
	mkdir ~/bin
	cp -R ./bin/* ~/bin
	echo 'bin scripts directory rebuilt'
fi

if [[ ! -f ~/.vim/autoload/plug.vim ]]; then
	#install vim-plug
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	echo 'vim-plug plugin manager installed'
fi

#create directories for vim sessions and undo
cd ~/.vim
if [ ! -d ~/.vim/plugged ]; then
	mkdir plugged
fi

if [ ! -d ~/.vim/sessions ]; then
	mkdir sessions
fi

if [ ! -d ~/.vim/undodir ]; then
	mkdir undodir
fi

echo 'setup complete'
