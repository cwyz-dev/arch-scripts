#!/usr/bin/env sh
distrobox assemble create --file distrobox.ini
distrobox enter -n neovim -- distrobox-export --bin /usr/bin/nvim --export-path "$HOME/.local/bin"
