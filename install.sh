#!/bin/bash

# Install necessary dependencies for lts distro upgrade
echo "Upgrading ubuntu..."
sudo apt update -y && sudo apt install -y
sudo apt install update-manager-core -y
sudo do-release-upgrade -f DistUpgradeViewNonInteractive

# Install zsh and set as default
echo "Install and switch default shell to zsh..."
sudo apt update -y && sudo apt install -y zsh
sudo usermod -s $(which zsh) $(whoami)

# Create config directories
echo "Creating config directories..."
mkdir -p ~/.config/nvim
mkdir -p ~/.config/starship
mkdir -p ~/.config/wezterm

# Copy in core configs
echo "Copying in configs..."
cp -r ~/dotfiles/.config/nvim/* ~/.config/nvim/
cp -r ~/dotfiles/.config/starship/* ~/.config/starship/
cp -r ~/dotfiles/.config/wezterm/* ~/.config/wezterm/
cp ~/dotfiles/.zshrc ~/.zshrc

# Install system dependencies
echo "Installing dependencies..."
sudo apt update -y && sudo apt install -y build-essential gcc gh make ripgrep tree unzip xclip ninja-build gettext cmake xdg-utils

# Install fzf
echo "Installing fzf..."
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Install zoxide
echo "Installing zoxide..."
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Install nvm + node
echo "Installing nvm..."
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install node

# Install pyenv
echo "Installing pyenv..."
curl -fsSL https://pyenv.run | sh

# Install pre-built lazygit
echo "Installing lazygit..."
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/

# Install wezterm
echo "Installing wezterm..."
curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
sudo apt update
sudo apt install wezterm

# Install starship from installer
echo "Installing starship..."
curl -sS https://starship.rs/install.sh | sh -s -- --yes

# Install neovim by building from source
echo "Installing neovim..."
git clone https://github.com/neovim/neovim.git
cd neovim
git checkout v0.11.4
make CMAKE_BUILD_TYPE=Release
sudo make install
