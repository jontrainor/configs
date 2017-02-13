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

	# install virtualenvwrapper
	pip install virtualenvwrapper
	if [[ ! -d ~/.virtualenvs ]]; then
		mkdir ~/.virtualenvs
	fi

	# fix tmux copy/paste
	if ! hash reattach-to-user-namespace 2>/dev/null; then
		brew install reattach-to-user-namespace
	fi

	# install linters
	if ! hash jshint 2>/dev/null; then
		npm install -g jshint
	fi

	if ! hash eslint 2>/dev/null; then
		npm install -g eslint
		npm install -g babel-eslint
		npm install -g eslint-plugin-react
	fi

	if ! hash pylint 2>/dev/null; then
		pip install pylint
	fi

	if ! hash scss-lint 2>/dev/null; then
		sudo gem install scss-lint

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
cp -f vimrc ~/.vimrc
if [[ ! -d ~/.vim ]]; then
	mkdir ~/.vim
fi
cp -f .vim/vimrc ~/.vim/vimrc
cp -f tmux.conf ~/.tmux.conf
cp -f bashrc ~/.bashrc
cp -f inputrc ~/.inputrc
cp -f profile ~/.bash_profile
cp -f gitconfig ~/.gitconfig
cp -f vimpdbrc ~/.vimpdbrc

if cp -R ./tmux/* ~/.tmux; then
	echo 'tmux directory copied'
else
	rm -rf ~/.tmux
	mkdir ~/.tmux
	cp -R ./tmux/* ~/.tmux
	echo 'tmux directory rebuilt'
fi

if [ ! -d ~/.ssh ]; then
	mkdir ~/.ssh
fi
cp -f ssh-config ~/.ssh/config

if cp -R ./git/* ~/git.d; then
	echo 'git directory copied'
else
	rm -rf ~/git.d
	mkdir ~/git.d
	cp -R ./git/* ~/git.d
	echo 'git directory rebuilt'
fi

#copy scripts to ~/bin
if cp -R ./bin/* ~/bin; then
	echo 'bin scripts directory copied'
else
	rm -rf ~/bin
	mkdir ~/bin
	cp -R ./bin/* ~/bin
	echo 'bin scripts directory rebuilt'
fi

if [[ ! -d ~/.vim/bundle ]]; then
	#install pathogen
	mkdir -p ~/.vim/autoload ~/.vim/bundle && \
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
	echo 'pathogen.vim plugin manager installed'
fi

#copy vim plugins to ~/.vim/bundle
if cp -R ./.vim/bundle/* ~/.vim/bundle; then
	echo 'vim plugins directory copied'
else
	rm -rf ~/.vim/bundle
	mkdir ~/.vim/bundle
	cp -R ./.vim/bundle/* ~/.vim/bundle
	echo 'vim plugins directory rebuilt'
fi

#create directories for vim sessions and undo
cd ~/.vim
if [ ! -d ~/.vim/sessions ]; then
	mkdir sessions
fi

if [ ! -d ~/.vim/undodir ]; then
	mkdir undodir
fi

echo 'setup complete'
