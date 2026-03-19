# dotfiles
My personal dotfiles

# install

1. Clone this repo to your `$HOME` directory
```
git clone <repo-url> ~/dotfiles
```
2. Run the install script
```
cd ~/dotfiles
chmod +x install.sh
./install.sh
```
3. Restart your terminal emulator

The script detects your OS and handles package installation automatically:
- **macOS** — installs packages via Homebrew (installing Homebrew first if needed), then runs `stow`
- **Linux (Ubuntu/Debian)** — installs packages via `apt` plus standalone installers, then runs `stow`
