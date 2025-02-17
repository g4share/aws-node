#!/bin/bash

# vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Check if Neovim or Vim is installed
if command -v nvim &> /dev/null; then
    CONFIG_DIR="$HOME/.config/nvim"
    CONFIG_FILE="$CONFIG_DIR/init.vim"
else
    CONFIG_DIR="$HOME"
    CONFIG_FILE="$HOME/.vimrc"
fi

mkdir -p "$CONFIG_DIR"

# Create the config file if it does not exist
if [ ! -f "$CONFIG_FILE" ]; then
    cat <<EOF > "$CONFIG_FILE"
set tabstop=2 softtabstop=2 shiftwidth=2
set expandtab
set number ruler
set autoindent smartindent

syntax enable
filetype plugin indent on

call plug#begin()
Plug 'andrewstuart/vim-kubernetes'
call plug#end()
EOF
fi

# Install plugins
if command -v vim &> /dev/null || command -v nvim &> /dev/null; then
    vim +'PlugInstall --sync' +qall &>/dev/null
fi