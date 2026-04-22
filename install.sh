#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_FILE="$DOTFILES_DIR/packages.json"
MODE="install"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --mode)
            if [[ $# -lt 2 ]]; then
                echo "Missing value for --mode"
                exit 1
            fi
            MODE="$2"
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
            exit 1
            ;;
    esac
done

if [[ "$MODE" != "install" && "$MODE" != "upgrade" ]]; then
    echo "Unsupported mode: $MODE"
    exit 1
fi

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
echo "Mode: $MODE"

BREW_UPDATED=0
APT_UPDATED=0

ensure_packages_file() {
    if [[ ! -f "$PACKAGES_FILE" ]]; then
        echo "Missing packages file: $PACKAGES_FILE"
        exit 1
    fi
}

package_names() {
    jq -r '.packages[].name' "$PACKAGES_FILE"
}

package_installer_field() {
    local pkg="$1"
    local field="$2"
    jq -r --arg name "$pkg" --arg os "$OS" --arg field "$field" '
        .packages[]
        | select(.name == $name)
        | .installer[$os][$field] // .installer.linux[$field] // empty
    ' "$PACKAGES_FILE" | head -n 1
}

install_package() {
    local pkg="$1"
    local type detect_cmd install_cmd fn formula apt_pkg

    type=$(package_installer_field "$pkg" type)
    if [[ -z "$type" ]]; then
        echo "Missing installer.${OS}.type for package: $pkg"
        return 1
    fi

    case "$type" in
        native)
            install_cmd=$(package_installer_field "$pkg" install)
            detect_cmd=$(package_installer_field "$pkg" detect)

            if [[ -z "$install_cmd" || -z "$detect_cmd" ]]; then
                echo "native installer for $pkg requires install and detect"
                return 1
            fi

            if bash -lc "$detect_cmd"; then
                return 0
            fi

            echo "Installing ${pkg} via native installer..."
            bash -lc "$install_cmd"

            if ! bash -lc "$detect_cmd"; then
                echo "Native install detect failed for ${pkg}"
                return 1
            fi
            ;;
        custom)
            fn=$(package_installer_field "$pkg" function)
            if [[ -z "$fn" ]]; then
                echo "custom installer for $pkg requires function"
                return 1
            fi

            if ! type "$fn" &>/dev/null; then
                echo "custom installer function not found for $pkg: $fn"
                return 1
            fi

            "$fn"
            ;;
        brew)
            formula=$(package_installer_field "$pkg" formula)
            [[ -z "$formula" ]] && formula="$pkg"
            brew install "$formula"
            ;;
        apt)
            apt_pkg=$(package_installer_field "$pkg" package)
            [[ -z "$apt_pkg" ]] && apt_pkg="$pkg"
            install_linux_via_apt "$apt_pkg"
            ;;
        skip)
            return 0
            ;;
        *)
            echo "Unsupported installer type for $pkg on $OS: $type"
            return 1
            ;;
    esac
}

ensure_brew_updated() {
    if [[ "$BREW_UPDATED" -eq 0 ]]; then
        brew update
        BREW_UPDATED=1
    fi
}

ensure_apt_updated() {
    if [[ "$APT_UPDATED" -eq 0 ]]; then
        sudo apt update -y
        APT_UPDATED=1
    fi
}

brew_formula_installed() {
    local formula="$1"
    brew list --formula "$formula" >/dev/null 2>&1
}

apt_package_installed() {
    local pkg="$1"
    dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "ok installed"
}

upgrade_package() {
    local pkg="$1"
    local type detect_cmd install_cmd upgrade_cmd fn upgrade_fn formula apt_pkg

    type=$(package_installer_field "$pkg" type)
    if [[ -z "$type" ]]; then
        echo "Missing installer.${OS}.type for package: $pkg"
        return 1
    fi

    case "$type" in
        native)
            upgrade_cmd=$(package_installer_field "$pkg" upgrade)
            install_cmd=$(package_installer_field "$pkg" install)
            detect_cmd=$(package_installer_field "$pkg" detect)

            if [[ -n "$upgrade_cmd" ]]; then
                echo "Upgrading ${pkg} via native upgrade command..."
                bash -lc "$upgrade_cmd"
                return
            fi

            if [[ -z "$install_cmd" || -z "$detect_cmd" ]]; then
                echo "native installer for $pkg requires install and detect"
                return 1
            fi

            echo "No native upgrade command for ${pkg}; falling back to install command..."
            bash -lc "$install_cmd"

            if ! bash -lc "$detect_cmd"; then
                echo "Native install fallback failed for ${pkg}"
                return 1
            fi
            ;;
        custom)
            upgrade_fn=$(package_installer_field "$pkg" upgrade_function)
            fn=$(package_installer_field "$pkg" function)

            if [[ -n "$upgrade_fn" ]]; then
                if ! type "$upgrade_fn" &>/dev/null; then
                    echo "custom upgrade function not found for $pkg: $upgrade_fn"
                    return 1
                fi

                echo "Upgrading ${pkg} via custom upgrade function..."
                "$upgrade_fn"
                return
            fi

            if [[ -z "$fn" ]]; then
                echo "custom installer for $pkg requires function"
                return 1
            fi

            if ! type "$fn" &>/dev/null; then
                echo "custom installer function not found for $pkg: $fn"
                return 1
            fi

            echo "No custom upgrade function for ${pkg}; falling back to install function..."
            "$fn"
            ;;
        brew)
            formula=$(package_installer_field "$pkg" formula)
            [[ -z "$formula" ]] && formula="$pkg"

            if ! brew_formula_installed "$formula"; then
                echo "Skipping ${pkg}: brew formula not installed (${formula})"
                return 0
            fi

            ensure_brew_updated
            brew upgrade "$formula"
            ;;
        apt)
            apt_pkg=$(package_installer_field "$pkg" package)
            [[ -z "$apt_pkg" ]] && apt_pkg="$pkg"

            if ! apt_package_installed "$apt_pkg"; then
                echo "Skipping ${pkg}: apt package not installed (${apt_pkg})"
                return 0
            fi

            ensure_apt_updated
            echo "Upgrading ${pkg} via apt..."
            sudo apt install --only-upgrade -y "$apt_pkg"
            ;;
        skip)
            return 0
            ;;
        *)
            echo "Unsupported installer type for $pkg on $OS: $type"
            return 1
            ;;
    esac
}

is_core_dependency() {
    local pkg="$1"
    case "$pkg" in
        jq|yq) return 0 ;;
        *) return 1 ;;
    esac
}

install_gh_dash() {
    if ! command -v gh &>/dev/null; then
        echo "gh-dash install requires gh"
        return 1
    fi

    if gh extension list | grep -qE '(^|[[:space:]])dlvhdr/gh-dash([[:space:]]|$)'; then
        return 0
    fi

    echo "Installing gh-dash..."
    gh extension install dlvhdr/gh-dash
}

# ─── macOS ───────────────────────────────────────────────────────────────────

install_macos() {
    ensure_packages_file

    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "Installing core dependencies (jq, yq)..."
    brew install jq yq

    if [[ "$MODE" == "install" ]]; then
        echo "Installing packages via Homebrew..."
    else
        echo "Upgrading managed packages via Homebrew..."
    fi

    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        if [[ "$MODE" == "install" ]]; then
            is_core_dependency "$pkg" && continue
            install_package "$pkg"
        else
            upgrade_package "$pkg"
        fi
    done < <(package_names)
}

install_macos_gh_dash() {
    install_gh_dash
}

# ─── Linux ───────────────────────────────────────────────────────────────────

# Per-tool install functions for packages that need custom install on Linux.
# packages.json declares which packages use these custom installers.

install_linux_fzf() {
    command -v fzf &>/dev/null && return
    echo "Installing fzf..."

    if [[ ! -d "$HOME/.fzf" ]]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    fi

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

install_linux_tree_sitter() {
    command -v tree-sitter &>/dev/null && return

    echo "Installing tree-sitter..."
    if sudo apt install -y tree-sitter-cli; then
        return
    fi

    if ! command -v npm &>/dev/null; then
        install_linux_node
    fi

    npm install -g tree-sitter-cli
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

install_linux_gh_dash() {
    install_gh_dash
}

is_container_runtime() {
    [[ -f /.dockerenv ]] && return 0
    grep -qaE "(docker|containerd|kubepods)" /proc/1/cgroup 2>/dev/null && return 0
    return 1
}

resolve_stow_conflicts() {
    local rel source target backup ts source_link target_link
    ts=$(date +%Y%m%d-%H%M%S)

    while IFS= read -r -d '' rel; do
        case "$rel" in
            .stowrc|install.sh|packages.json) continue ;;
        esac

        source="$DOTFILES_DIR/$rel"
        target="$HOME/$rel"
        if [[ ! -e "$target" && ! -L "$target" ]]; then
            continue
        fi

        if [[ -L "$target" ]]; then
            if [[ -L "$source" ]]; then
                source_link=$(readlink "$source" 2>/dev/null || true)
                target_link=$(readlink "$target" 2>/dev/null || true)
                if [[ "$target_link" == "$source_link" ]]; then
                    continue
                fi
            elif [[ -e "$source" && "$target" -ef "$source" ]]; then
                continue
            fi

            rm -f "$target"
            echo "Removed existing symlink: $target"
            continue
        fi

        if [[ ( -e "$source" || -L "$source" ) && "$target" -ef "$source" ]]; then
            continue
        fi

        if [[ -d "$target" && ! -L "$target" ]]; then
            continue
        fi

        if [[ "${DOTFILES_FORCE_DELETE_CONFLICTS:-}" == "1" ]]; then
            rm -f "$target"
            echo "Removed conflicting file: $target"
            continue
        fi

        if [[ "${DOTFILES_BACKUP_CONFLICTS:-}" == "1" ]] || ! is_container_runtime; then
            backup="${target}.bak.${ts}"
            mv "$target" "$backup"
            echo "Backed up conflicting file: $target -> $backup"
            continue
        fi

        rm -f "$target"
        echo "Removed conflicting file in container: $target"
    done < <(git -C "$DOTFILES_DIR" ls-files -z && git -C "$DOTFILES_DIR" ls-files --others --exclude-standard -z)
}

install_linux_neovim_from_source() {
    echo "Installing neovim from source..."
    git clone https://github.com/neovim/neovim.git /tmp/neovim
    cd /tmp/neovim
    if [[ -n "${NEOVIM_VERSION:-}" ]]; then
        git checkout "$NEOVIM_VERSION"
    fi
    make CMAKE_BUILD_TYPE=Release
    sudo make install
    cd "$DOTFILES_DIR"
    rm -rf /tmp/neovim
}

install_linux_neovim() {
    command -v nvim &>/dev/null && return

    if ! command -v jq &>/dev/null; then
        echo "neovim install requires jq"
        return 1
    fi

    local version arch asset url tmp_archive tmp_dir extracted_dir

    case "$(uname -m)" in
        x86_64) arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)
            echo "Unsupported architecture for neovim: $(uname -m)"
            return 1
            ;;
    esac

    if [[ -n "${NEOVIM_VERSION:-}" ]]; then
        version="$NEOVIM_VERSION"
    else
        version=$(curl -fsSL "https://api.github.com/repos/neovim/neovim/releases/latest" | jq -r '.tag_name')
    fi

    if [[ -z "$version" || "$version" == "null" ]]; then
        echo "Could not determine latest neovim version"
        return 1
    fi

    echo "Installing neovim ${version}..."

    asset="nvim-linux-${arch}.tar.gz"
    url="https://github.com/neovim/neovim/releases/download/${version}/${asset}"
    tmp_archive="/tmp/${asset}"
    tmp_dir="/tmp/nvim-install"

    if ! curl -fsSL "$url" -o "$tmp_archive"; then
        if [[ "${NEOVIM_ALLOW_SOURCE_BUILD:-}" == "1" ]] || ! is_container_runtime; then
            echo "Prebuilt neovim archive unavailable, falling back to source build"
            install_linux_neovim_from_source
            return
        fi

        echo "Failed to fetch prebuilt neovim archive and source build is disabled in container runtimes"
        return 1
    fi

    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    tar -xzf "$tmp_archive" -C "$tmp_dir"
    extracted_dir=$(tar -tzf "$tmp_archive" | head -n 1 | cut -d/ -f1)

    if [[ -z "$extracted_dir" || ! -d "$tmp_dir/$extracted_dir" ]]; then
        rm -rf "$tmp_dir" "$tmp_archive"
        echo "Unexpected neovim archive layout"
        return 1
    fi

    sudo rm -rf /opt/nvim
    sudo mv "$tmp_dir/$extracted_dir" /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
    rm -rf "$tmp_dir" "$tmp_archive"
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

ensure_linux_usr_local_bin_path() {
    case ":$PATH:" in
        *":/usr/local/bin:"*) ;;
        *) export PATH="/usr/local/bin:$PATH" ;;
    esac
}

install_linux() {
    ensure_packages_file
    ensure_linux_usr_local_bin_path

    if [[ "$MODE" == "upgrade" ]]; then
        echo "Upgrading managed packages on Linux..."
        while IFS= read -r pkg; do
            [[ -z "$pkg" ]] && continue
            upgrade_package "$pkg"
        done < <(package_names)
        return
    fi

    echo "Updating system packages..."
    sudo apt update -y
    if is_container_runtime && [[ "${DOTFILES_APT_UPGRADE:-}" != "1" ]]; then
        echo "Skipping apt upgrade in container runtime"
    else
        sudo apt upgrade -y
    fi

    # Install build dependencies
    sudo apt install -y \
        build-essential cmake curl gettext git ninja-build xdg-utils

    echo "Installing core dependencies (jq, yq)..."
    sudo apt install -y jq
    install_linux_yq

    # Install each package from declarative installer config
    while IFS= read -r pkg; do
        [[ -z "$pkg" ]] && continue
        is_core_dependency "$pkg" && continue
        install_package "$pkg"
    done < <(package_names)

    # Set zsh as default shell
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        echo "Setting zsh as default shell..."
        sudo usermod -s "$(which zsh)" "$(whoami)"
    fi

    sudo apt clean
    sudo rm -rf /var/lib/apt/lists/*
    rm -rf /tmp/neovim /tmp/nvim-install /tmp/nvim-linux-*.tar.gz
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

if [[ "$MODE" == "upgrade" ]]; then
    echo "Done!"
    exit 0
fi

# ─── Stow dotfiles ────────────────────────────────────────────────────────────
# Pre-create directories that contain a mix of stow-managed and runtime files.
# This prevents stow from "folding" them into a single directory symlink.

echo "Preparing directories for stow..."
mkdir -p ~/.config ~/.claude/plugins ~/.local/bin

echo "Resolving stow conflicts..."
resolve_stow_conflicts

echo "Stowing dotfiles..."
cd "$DOTFILES_DIR"
stow --no-folding --restow .

if [[ -x "$HOME/.local/bin/sync-ai-config" ]]; then
    echo "Syncing AI config..."
    "$HOME/.local/bin/sync-ai-config"
fi

echo "Done!"
