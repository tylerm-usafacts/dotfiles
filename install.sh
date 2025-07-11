#!/bin/bash

# Install necessary dependencies
echo "Installing dotfiles config..."

echo "Installing dependencies..."
sudo apt update -y && sudo apt install -y zsh build-essential fzf gcc gh lazygit lua-language-server make node pyenv-virtualenv ripgrep tree unzip xclip zoxide

# Set default shell to zsh
echo "Switch default shell to zsh..."
usermod -s $(which zsh) $(whoami)

echo "Installing neovim..."
# Install pre-built neovim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin' >> ~/.zshrc

echo "Installing starship..."
# Install starship from installer
curl -sS https://starship.rs/install.sh | sh -y

# Create config directories
echo "Creating config directories..."
mkdir -p ~/.config/nvim
mkdir -p ~/.config/starship
mkdir -p ~/.config/wezterm

echo "Copying in configs..."
cp -r ~/dotfiles/.config/nvim/* ~/.config/nvim/
cp -r ~/dotfiles/.config/starship/* ~/.config/starship/
cp -r ~/dotfiles/.config/wezterm/* ~/.config/wezterm/
cp ~/dotfiles/.zshrc ~/.zshrc

