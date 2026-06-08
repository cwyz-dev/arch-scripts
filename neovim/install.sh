#!/usr/bin/env sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set up daemon
IMAGE_NAME="custom-neovim-daemon:latest"
CONTAINER_NAME="neovim-daemon"

CONFIG_DIR="$HOME/projects/neovim-configuration"
SHARE_DIR="$HOME/.local/share/neovim"
STATE_DIR="$HOME/.local/state/neovim"

mkdir -p "$SHARE_DIR" "$STATE_DIR"

podman rm -fi "$CONTAINER_NAME"
podman run -d \
	--name "$CONTAINER_NAME" \
	--ipc=host \
	--pid=host \
	\
	-e TERM="$TERM" \
	\
	-v "$CONFIG_DIR":"/root/.config/nvim":Z \
	-v "$SHARE_DIR":"/root/.local/share/nvim":Z \
	-v "$STATE_DIR":"/root/.local/state/nvim":Z \
	-v "$HOME":"/workspace":z \
	\
	"$IMAGE_NAME"

# Set up service
USER_SYSTEMD_DIR="$HOME/.config/systemd/user"
mkdir -p "$USER_SYSTEMD_DIR"
cp -a "$SCRIPT_DIR/daemon.service" "$USER_SYSTEMD_DIR/neovim-daemon.service"
systemctl --user daemon-reload
systemctl --user enable --now neovim-daemon.service

podman exec -it "$CONTAINER_NAME" nvim "+Lazy! sync" -c "qa"
podman exec -it "$CONTAINER_NAME" nvim "+Lazy! update" -c "qa"

# Wrapper
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
cp -a "$SCRIPT_DIR/launcher.sh" "$BIN_DIR/nvim"
