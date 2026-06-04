#!/usr/bin/env sh
CONTAINER_NAME="neovim-daemon"
ARGS=()
for arg in "$@" ; do
	if [ -e "$arg" ] ; then
		ABS_PATH=$(realpath "$arg")
		if [[ "$ABS_PATH" == "$HOME"* ]] ; then
			CONTAINER_PATH="${ABS_PATH/$HOME/\/workspace}"
			ARGS+=("$CONTAINER_PATH")
		else
			ARGS+=("$ABS_PATH")
		fi
	else
		ARGS+=("$arg")
	fi
done
exec podman exec -it "$CONTAINER_NAME" nvim "${ARGS[@]}"
