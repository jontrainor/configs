#!/bin/sh

#initialize vim plugin submodules
git submodule init
git submodule update

#copy configs to home directory
cp -rf ./.vimrc ~/
cp -rf ./.vim ~/
cp -rf ./.tmux.conf ~/

#create directories for vim sessions and undo
cd ~/.vim
if [ ! -d ~/.vim/sessions ]; then
	mkdir sessions
fi

if [ ! -d ~/.vim/undodir ]; then
	mkdir undodir
fi

