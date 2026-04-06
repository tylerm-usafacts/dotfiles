export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export PATH="$HOME/.claude-code/bin:$PATH"

brew_bin="$(command -v brew 2>/dev/null || true)"

if [ -z "$brew_bin" ]; then
  for candidate in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew "$HOME/.linuxbrew/bin/brew"; do
    if [ -x "$candidate" ]; then
      brew_bin="$candidate"
      break
    fi
  done
fi

if [ -n "$brew_bin" ]; then
  eval "$("$brew_bin" shellenv)"
fi
