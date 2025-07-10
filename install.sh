#!/bin/bash

echo "Installing dotfiles config..."

apt update
apt install build-essential
xargs apt install -y < ~/dotfiles/.config/homebrew/leaves.txt

echo "Establishing symlinks..."
stow .
