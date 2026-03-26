#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.txt"

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

# Map logical package names to brew formula names where they differ.
brew_name() {
    case "$1" in
        pyenv)   echo "pyenv-virtualenv" ;;
        zsh)     return 1 ;; # macOS ships with zsh
        *)       echo "$1" ;;
    esac
}

install_macos() {
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Installing packages via Homebrew..."
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        formula=$(brew_name "$pkg") || continue
        brew install "$formula"
    done < "$PACKAGES_FILE"
}

# ─── Linux ───────────────────────────────────────────────────────────────────

# Per-tool install functions for packages that need custom install on Linux.
# Packages without a custom function fall through to apt install.

install_linux_fzf() {
    command -v fzf &>/dev/null && return
    echo "Installing fzf..."
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install --all
}

install_linux_zoxide() {
    command -v zoxide &>/dev/null && return
    echo "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

install_linux_node() {
    command -v node &>/dev/null && return
    echo "Installing nvm + node..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install node
}

install_linux_pyenv() {
    command -v pyenv &>/dev/null && return
    echo "Installing pyenv..."
    curl -fsSL https://pyenv.run | sh
}

install_linux_yq() {
    if command -v yq &>/dev/null && yq --version 2>/dev/null | grep -qi "mikefarah"; then
        return
    fi

    command -v jq &>/dev/null || {
        echo "install_linux_yq requires jq to be installed first"
        exit 1
    }

    echo "Installing mikefarah/yq..."
    local version arch url tmp_bin
    version=$(curl -fsSL "https://api.github.com/repos/mikefarah/yq/releases/latest" | jq -r '.tag_name')

    case "$(uname -m)" in
        x86_64) arch="amd64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            echo "Unsupported architecture for yq: $(uname -m)"
            exit 1
            ;;
    esac

    url="https://github.com/mikefarah/yq/releases/download/${version}/yq_linux_${arch}"
    tmp_bin="/tmp/yq_linux_${arch}"

    curl -fsSL "$url" -o "$tmp_bin"
    chmod +x "$tmp_bin"
    sudo install "$tmp_bin" /usr/local/bin/yq
    rm -f "$tmp_bin"
}

install_linux_lazygit() {
    command -v lazygit &>/dev/null && return
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
}

install_linux_wezterm() {
    command -v wezterm &>/dev/null && return
    [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" ]] && return
    echo "Installing wezterm..."
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' \
        | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo chmod 644 /usr/share/keyrings/wezterm-fury.gpg
    sudo apt update
    sudo apt install -y wezterm
}

install_linux_starship() {
    command -v starship &>/dev/null && return
    echo "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
}

install_linux_neovim() {
    command -v nvim &>/dev/null && return
    echo "Installing neovim..."
    git clone https://github.com/neovim/neovim.git /tmp/neovim
    cd /tmp/neovim
    git checkout v0.11.4
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    cd "$DOTFILES_DIR"
    rm -rf /tmp/neovim
}

install_linux_lua_language_server() {
    command -v lua-language-server &>/dev/null && return

    if ! command -v jq &>/dev/null; then
        echo "lua-language-server install requires jq"
        return 1
    fi

    echo "Installing lua-language-server..."

    local arch release_api download_url tmp_archive install_dir
    case "$(uname -m)" in
        x86_64) arch="linux-x64" ;;
        aarch64|arm64) arch="linux-arm64" ;;
        *)
            echo "Unsupported architecture for lua-language-server: $(uname -m)"
            return 1
            ;;
    esac

    release_api="https://api.github.com/repos/LuaLS/lua-language-server/releases/latest"
    download_url=$(curl -fsSL "$release_api" | jq -r \
        ".assets[] | select(.name | test(\"${arch}.*\\\\.tar\\\\.gz$\")) | .browser_download_url" | head -n 1)

    if [[ -z "$download_url" || "$download_url" == "null" ]]; then
        echo "Could not find lua-language-server release for ${arch}"
        return 1
    fi

    tmp_archive="/tmp/lua-language-server.tar.gz"
    install_dir="/opt/lua-language-server"

    curl -fsSL "$download_url" -o "$tmp_archive"
    sudo rm -rf "$install_dir"
    sudo mkdir -p "$install_dir"
    sudo tar -xzf "$tmp_archive" -C "$install_dir"
    sudo ln -sf "$install_dir/bin/lua-language-server" /usr/local/bin/lua-language-server
    rm -f "$tmp_archive"
}

install_linux_via_apt() {
    local pkg="$1"
    command -v "$pkg" &>/dev/null && return

    echo "Installing ${pkg} via apt..."
    if ! sudo apt install -y "$pkg"; then
        echo "Skipping ${pkg}: package unavailable in current apt sources"
    fi
}

install_linux() {
    echo "Updating system packages..."
    sudo apt update -y && sudo apt upgrade -y

    # Install build dependencies
    sudo apt install -y \
        build-essential cmake curl gettext git ninja-build xdg-utils

    # Install each package: use custom function if defined, otherwise apt
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        func="install_linux_${pkg//-/_}"
        if type "$func" &>/dev/null; then
            "$func"
        else
            install_linux_via_apt "$pkg"
        fi
    done < "$PACKAGES_FILE"

    # Set zsh as default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "Setting zsh as default shell..."
        sudo usermod -s "$(which zsh)" "$(whoami)"
    fi
}

# ─── Install packages ─────────────────────────────────────────────────────────

case "$OS" in
    macos)         install_macos ;;
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
mkdir -p ~/.config ~/.claude/plugins ~/.local/bin

echo "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow .

if [[ -x "$HOME/.local/bin/sync-ai-config" ]]; then
    echo "Syncing AI config..."
    "$HOME/.local/bin/sync-ai-config"
fi

echo "Done!"
