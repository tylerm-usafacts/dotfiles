export PATH=~/.local/bin:$PATH

# starship set location of config + init on shell
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# Set up fzf key bindings and fuzzy completion + init on shell
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide init on shell
eval "$(zoxide init zsh)"

# pyenv config
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# ensures nvm is loaded
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# aliases
alias chex="chmod -R 755 ~/.local/bin/"
alias lg="lazygit"
alias zrc="source ~/.zshrc"

# opencode
export PATH=/Users/tylerm-admin/.opencode/bin:$PATH
