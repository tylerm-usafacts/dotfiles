#!/bin/bash

echo "Install dotfiles config"

sudo apt update
sudo apt install build-essential
git clone https://github.com/tylerm-usafacts/dotfiles
xargs sudo apt install -y < ~/dotfiles/.config/homebrew/leaves.txt
stow .
