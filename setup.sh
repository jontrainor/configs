#!/bin/sh

#initialize vim plugin submodules
git submodule init
git submodule update

#copy configs to home directory
cp -rf ./.vim ~/
cp -f ./vimrc ~/.vimrc
cp -f ./tmux.conf ~/.tmux.conf
cp -f ./bashrc ~/.bashrc
cp -f ./inputrc ~/.inputrc
cp -f ./ssh-config ~/.ssh/config
cp -f ./onpeak-hgrc ~/.hgrc

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
