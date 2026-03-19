#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ─── OS Detection ────────────────────────────────────────────────────────────

detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

OS=$(detect_os)
echo "Detected OS: $OS"

# ─── macOS ───────────────────────────────────────────────────────────────────

install_macos() {
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Installing packages via Homebrew..."
    xargs brew install < "$DOTFILES_DIR/.config/homebrew/leaves.txt"
}

# ─── Linux ───────────────────────────────────────────────────────────────────

install_linux() {
    echo "Updating system packages..."
    sudo apt update -y && sudo apt upgrade -y
    sudo apt install -y \
        build-essential cmake curl gcc gettext gh git make \
        ninja-build ripgrep stow tree unzip xclip xdg-utils zsh

    # Set zsh as default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "Setting zsh as default shell..."
        sudo usermod -s "$(which zsh)" "$(whoami)"
    fi

    # fzf
    if ! command -v fzf &>/dev/null; then
        echo "Installing fzf..."
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
    fi

    # zoxide
    if ! command -v zoxide &>/dev/null; then
        echo "Installing zoxide..."
        curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    # nvm + node
    if ! command -v node &>/dev/null; then
        echo "Installing nvm + node..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        # shellcheck source=/dev/null
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install node
    fi

    # pyenv
    if ! command -v pyenv &>/dev/null; then
        echo "Installing pyenv..."
        curl -fsSL https://pyenv.run | sh
    fi

    # lazygit
    if ! command -v lazygit &>/dev/null; then
        echo "Installing lazygit..."
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
            | grep -Po '"tag_name": *"v\K[^"]*')
        ARCH=$(uname -m)
        [[ "$ARCH" == "aarch64" ]] && ARCH="arm64"
        curl -Lo /tmp/lazygit.tar.gz \
            "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${ARCH}.tar.gz"
        tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
        sudo install /tmp/lazygit -D -t /usr/local/bin/
        rm /tmp/lazygit.tar.gz /tmp/lazygit
    fi

    # wezterm (skip in headless environments like devcontainers)
    if ! command -v wezterm &>/dev/null && [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
        echo "Installing wezterm..."
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
            | sudo tee /etc/apt/sources.list.d/wezterm.list
        sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
        sudo apt update
        sudo apt install -y wezterm
    fi

    # starship
    if ! command -v starship &>/dev/null; then
        echo "Installing starship..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi

    # neovim (build from source)
    if ! command -v nvim &>/dev/null; then
        echo "Installing neovim..."
        git clone https://github.com/neovim/neovim.git /tmp/neovim
        cd /tmp/neovim
        git checkout v0.11.4
        make CMAKE_BUILD_TYPE=Release
        sudo make install
        cd "$DOTFILES_DIR"
        rm -rf /tmp/neovim
    fi
}

# ─── Install packages ─────────────────────────────────────────────────────────

case "$OS" in
    macos)   install_macos ;;
    ubuntu|debian) install_linux ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# ─── Stow dotfiles ────────────────────────────────────────────────────────────
# Pre-create directories that contain a mix of stow-managed and runtime files.
# This prevents stow from "folding" them into a single directory symlink.

echo "Preparing directories for stow..."
mkdir -p ~/.config ~/.claude/plugins

echo "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow .

echo "Done!"
