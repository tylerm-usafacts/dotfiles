#!/bin/bash

echo "Installing dotfiles config..."
sudo apt update -y && sudo apt install -y build-essential fzf gcc gh lazygit lua-language-server make neovim node pyenv-virtualenv ripgrep starship tree unzip xclip zoxide

echo "Creating config directories..."
mkdir -p ~/.config/nvim
mkdir -p ~/.config/starship
mkdir -p ~/.config/wezterm

echo "Copying in nvim..."
cp -r ~/dotfiles/.config/nvim/* ~/.config/nvim/

echo "Copying in starship..."
cp -r ~/dotfiles/.config/starship/* ~/.config/starship/

echo "Copying in wezterm..."
cp -r ~/dotfiles/.config/wezterm/* ~/.config/wezterm/

echo "Copying in .zshrc..."
cp ~/dotfiles/.zshrc ~/.zshrc
