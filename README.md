# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). One repo, one install script, works on both macOS and Linux (Ubuntu/Debian).

## Install

```bash
git clone <repo-url> ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

Restart your terminal after installation.

The script detects your OS and handles everything automatically:
- **macOS** — installs Homebrew if needed, then installs all packages via `brew`
- **Linux (Ubuntu/Debian)** — installs packages via `apt` where available, with standalone installers for tools that need them (neovim, lazygit, starship, etc.)
- Skips GUI tools (wezterm) in headless environments like devcontainers
- Runs `stow .` to symlink configs into place

## Structure

```
~/dotfiles/
├── install.sh                 # Cross-platform installer
├── packages.txt               # Single source of truth for all tools
├── .zshrc                     # Shell configuration
│
├── .config/
│   ├── ai/                    # Shared AI agent instructions
│   │   ├── AGENTS.md          # Instructions used by both Claude Code and OpenCode
│   │   └── skills/            # Shared skills (both systems pick these up)
│   ├── opencode/              # OpenCode configuration
│   │   ├── opencode.json      # Settings and permissions
│   │   ├── AGENTS.md          # -> ../ai/AGENTS.md (symlink)
│   │   └── skills             # -> ../ai/skills (symlink)
│   ├── git/                   # Global git config (includes global gitignore)
│   ├── gh/                    # GitHub CLI config
│   ├── nvim/                  # Neovim configuration
│   ├── starship/              # Starship prompt config
│   ├── wezterm/               # Wezterm terminal config
│   └── ...                    # Other tool configs
│
├── .claude/                   # Claude Code configuration
│   ├── settings.json          # Permissions, model, and plugin settings
│   ├── CLAUDE.md              # Imports shared instructions from .config/ai/AGENTS.md
│   └── plugins/local/         # Local plugin providing shared skills
│
└── .local/bin/                # Custom scripts and tool wrappers
```

## How it works

**Stow** mirrors the repo structure into `$HOME` via symlinks. For example, `.config/nvim/` becomes `~/.config/nvim/` and `.zshrc` becomes `~/.zshrc`.

Directories that mix stow-managed config with runtime data (`~/.config`, `~/.claude`) are pre-created before stow runs. This prevents stow from folding the entire directory into a single symlink, keeping runtime files (history, sessions, cache) out of the repo.

## Packages

All desired tools are listed in `packages.txt`. This file is read by `install.sh` on both macOS and Linux:

- **macOS**: each package is installed via `brew install` (with name mapping where brew formula names differ)
- **Linux**: packages with a custom installer use it; everything else falls through to `apt install`

To add a new tool, add a line to `packages.txt`. If it needs a custom Linux install, add an `install_linux_<name>()` function to `install.sh`.

## AI agent config

Agent instructions and skills are shared between Claude Code and OpenCode from a single source of truth at `.config/ai/`:

- **Claude Code** — `.claude/CLAUDE.md` imports `.config/ai/AGENTS.md` via the `@` directive. Shared skills are available through a local plugin that symlinks to `.config/ai/skills/`.
- **OpenCode** — `.config/opencode/AGENTS.md` and `.config/opencode/skills` are symlinks to the shared location. `opencode.json` also references the shared instructions via the `instructions` field.
