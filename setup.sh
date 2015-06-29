#!/bin/sh

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
fi

#initialize vim plugin submodules
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
