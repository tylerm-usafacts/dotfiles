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
├── packages.json              # Single source of truth for all tools
├── .zshrc                     # Shell configuration
│
├── .config/
│   ├── ai/                    # Shared AI agent instructions
│   │   ├── AGENTS.md          # Instructions used by both Claude Code and OpenCode
│   │   ├── skills/            # Shared skills (both systems pick these up)
│   │   ├── agents/            # Shared custom agent definitions (single source)
│   │   └── mcp/               # Shared MCP server definitions (single source)
│   ├── opencode/              # OpenCode configuration
│   │   ├── opencode.json      # Settings and permissions
│   │   ├── AGENTS.md          # -> ../ai/AGENTS.md (symlink)
│   │   ├── skills             # -> ../ai/skills (symlink)
│   │   └── agents/            # Generated from ../ai/agents via sync-ai-config
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

All desired tools are listed in `packages.json`. Each package declares an explicit installer strategy per OS:

- `type: "native"` uses a native install script with a required `detect` command
- `type: "custom"` calls a function in `install.sh` (for packages with special logic)
- `type: "brew"` / `type: "apt"` use package-manager defaults (with optional formula/package override)
- `type: "skip"` skips install on that OS
- `jq` and `yq` are installed at the start of `install.sh` before package parsing/install

To add a new tool, use the CLI:

```bash
dotfiles add <package>
dotfiles add <package> --native "<install script>" --detect "<detect command>"
dotfiles sync
dotfiles upgrade
```

Native package metadata lives with the package entry in `packages.json`.

Command behavior:

- `dotfiles sync`: install missing packages, then stow dotfiles and run `sync-ai-config`
- `dotfiles upgrade`: upgrade only packages declared in `packages.json` (managed-only), without stow or AI config sync

Managed-only upgrade strategy by installer type:

- `brew`: `brew update` once, then `brew upgrade <formula>` for managed formulae that are already installed
- `apt`: `apt update` once, then `apt install --only-upgrade` for managed packages that are already installed
- `native`: run `installer.<os>.upgrade` when defined; otherwise fallback to `install`
- `custom`: run `installer.<os>.upgrade_function` when defined; otherwise fallback to `function`
- `skip`: no-op

## AI agent config

AI instructions, skills, and custom agents use `.config/ai/` as the source of truth.

- Shared instructions: `.config/ai/AGENTS.md`
- Shared skills: `.config/ai/skills/`
- Shared custom agents: `.config/ai/agents/*.md` (canonical YAML frontmatter + markdown prompt)
- Shared references: `.config/ai/references/`
- Shared MCP server definitions: `.config/ai/mcp/servers.json`

Sync lifecycle:

- `sync-ai-config` publishes custom agents to tool-native locations:
  - `~/.claude/agents/*.md`
  - `~/.config/opencode/agents/*.md`
- `sync-ai-config` publishes MCP server config from `.config/ai/mcp/servers.json` to:
  - `~/.config/opencode/opencode.json` (`mcp` block)
  - `~/dotfiles/.mcp.json` (`mcpServers` for Claude project scope)
- MCP DSL mapping reference: `.config/ai/references/mcp-dsl-mapping.md`
- `claude` and `opencode` wrappers run `sync-ai-config` before launch and fail fast if sync fails.
- `sync-ai-config` depends on `yq` and `jq`.

Cost-control defaults:

- Planning agent uses `openai/gpt-5.3-codex` for deep planning.
- Execution/review agents default to `openai/gpt-5.1-codex-mini`.
- Turn budgets are kept lower for executor agents to reduce token burn.

For agent authoring rules, supported frontmatter, and troubleshooting, see `.config/ai/README.md`.
