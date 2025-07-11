#!/bin/bash

# Install necessary dependencies
echo "Upgrading ubuntu..."
sudo apt update -y && sudo apt install -y
sudo apt install update-manager-core -y
sudo do-release-upgrade -f DistUpgradeViewNonInteractive

echo "Install and switch default shell to zsh..."
sudo apt update -y && sudo apt install -y zsh
sudo usermod -s $(which zsh) $(whoami)

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

echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
nvm install 22.17.0

echo "Installing dependencies..."
sudo apt update -y && sudo apt install -y build-essential fzf gcc gh make ripgrep tree unzip xclip zoxide

# Install pyenv
echo "Installing pyenv..."
curl -fsSL https://pyenv.run | sh

echo "Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

echo "Installing neovim..."
# Install pre-built neovim
sudo apt-get install -y ninja-build gettext cmake
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout v0.11.2
make CMAKE_BUILD_TYPE=Release
sudo make install

echo "Installing starship..."
# Install starship from installer
curl -sS https://starship.rs/install.sh | sh -s -- --yes
