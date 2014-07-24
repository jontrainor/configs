#!/bin/sh

#if osx install macvim; requires brew
if [[ "$OSTYPE" == "darwin"* ]]; then
	brew install macvim --override-system-vim
	brew linkapps
fi

#initialize vim plugin submodules
git submodule init
git submodule update

#copy configs to home directory
cp -rf ./.vimrc ~/
cp -rf ./.vim ~/
cp -rf ./.tmux.conf ~/

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
