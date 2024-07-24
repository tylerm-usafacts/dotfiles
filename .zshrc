export PATH=~/.local/bin:$PATH

# starship set location of config + init on shell
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion + init on shell
source <(fzf --zsh)

# zoxide init on shell
eval "$(zoxide init zsh)"

# pyenv config
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# aliases
alias chex="chmod -R 755 ~/.local/bin/"
alias lg="lazygit"
alias zrc="source ~/.zshrc"
