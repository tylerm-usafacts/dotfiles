export PATH=~/.local/bin:$PATH

# starship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# pyenv config
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# aliases
alias chex="chmod -R 755 ~/.local/bin/"
alias lg="lazygit"
alias zrc="source ~/.zshrc"
