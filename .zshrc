export PATH=/opt/homebrew/bin:$PATH

export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
