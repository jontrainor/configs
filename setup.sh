#!/bin/sh -e

# save current working directory
cwd=$(pwd)

#if osx 
if [[ "$OSTYPE" == "darwin"* ]]; then
	# install brew
	# from install instructions on brew.sh
	if ! hash brew 2>/dev/null; then
		ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
	fi

	brew update

	# install macvim
	if ! hash mvim 2>/dev/null; then
		brew install macvim --override-system-vim
		brew linkapps
	fi

	# install ack for ack.vim plugin
	if ! hash ack 2>/dev/null; then
		brew install ack
	fi

	# install matcher for ctrlp vim plugin
	if ! hash matcher 2>/dev/null; then
		cd ./.vim/bundle/matcher-ctrlp/
		make
		make install
	fi

	# install vimpdb for debugging python
	pip install vimpdb

	# fix tmux copy/paste
	if ! hash reattach-to-user-namespace 2>/dev/null; then
		brew install reattach-to-user-namespace
	fi

	# install linters
	if ! hash jshint 2>/dev/null; then
		npm install -g jshint
	fi

	if ! hash pylint 2>/dev/null; then
		pip install pylint
	fi

	if ! hash scss-lint 2>/dev/null; then
		gem install scss-lint

	fi

	if ! hash cflint 2>/dev/null; then
		brew install maven
		cd ~
		git clone https://github.com/cflint/CFLint.git
		cd CFLint
		mvn clean install -D assembleDirectory=/usr/local
		cd $cwd
	fi
fi

#initialize vim & tmux plugin submodules
git submodule init
git submodule update

#copy configs to home directory
cp -rf .vim ~/
cp -f vimrc ~/.vimrc
cp -f tmux.conf ~/.tmux.conf
cp -f bashrc ~/.bashrc
cp -f inputrc ~/.inputrc
cp -f profile ~/.profile
cp -f onpeak-hgrc ~/.hgrc
cp -f gitconfig ~/.gitconfig

if [ ! -d ~/.tmux ]; then
	mkdir ~/.tmux
fi
cp -rf ./tmux/* ~/.tmux

if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
fi
cp -f ssh-config ~/.ssh/config

if [ ! -d ~/hgrc.d ]; then
	mkdir ~/hgrc.d
	echo "install mercurial extensions"
fi
cp -f ./hgignore ~/hgrc.d/.hgignore

if [ ! -d ~/git.d ]; then
	mkdir ~/git.d
fi
cp -rf ./git/* ~/git.d

#copy scripts to ~/bin
if [ ! -d ~/bin ]; then
	mkdir ~/bin
fi
cp -rf ./bin/* ~/bin

#create directories for vim sessions and undo
cd ~/.vim
if [ ! -d ~/.vim/sessions ]; then
	mkdir sessions
fi

if [ ! -d ~/.vim/undodir ]; then
	mkdir undodir
fi
