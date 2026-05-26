#!/usr/bin/env sh

# VARIABLES
CONFIG_DIR="${HOME}/.config/nvim"
SCRIPT_DIR="$(cd "$(dirname "$BASH_SOURCE[0]}")" && pwd)"
FILE_DIR="${SCRIPT_DIR}/configs"

IMAGE="archlinux:latest"

MAIN_CONTAINER="neovim"
LSPS=("ansible" "bash" "container" "lua")

# CLI OPTIONS
CHECK_HOST_PACKAGES=false
VERBOSITY=-1
RECREATE_CONTAINERS=false
CONFIG_ONLY=false

while [[ $# -gt 0 ]]; do
	case $1 in
		--host|-h)
			CHECK_HOST_PACKAGES=true
			shift
			;;
		--verbosity|-v)
			VERBOSITY=$2
			shift
			shift
			;;
		--recreate|-r)
			RECREATE_CONTAINERS=true
			shift
			;;
		--config|-c)
			CONFIG_ONLY=true
			shift
			;;
	esac
done

# HELPER FUNCTIONS
container_exists() {
	distrobox list --no-color 2>/dev/null \
		| tail -n +2 \
		| awk '{print $3}' \
		| grep -Fxq "$1"
}

dbox_command() {
	container="$1"
	shift
	distrobox enter "$container" -- "$@" >/dev/null 2>&1
}		

create_container() {
	echo "Creating $1"
	if ! container_exists $1 || [[ "$RECREATE_CONTAINERS" == "true" ]] ; then
		distrobox rm -f $1 >/dev/null 2>&1

		distrobox create --name $1 --image "$IMAGE" >/dev/null 2>&1

		echo "First entry to $1"
		dbox_command $1 echo 'Entry'

		dbox_command $1 sudo pacman -Syu --noconfirm
	fi
}

create_lsp() {
	create_container "lsp-$1"
}

install_container() {
	container=$1
	shift
	dbox_command $container sudo pacman -S --noconfirm --needed "$@"
}

nvim_command() {
	dbox_command "${MAIN_CONTAINER}" nvim --headless "$@" -c "qa"
}

# FUNCTIONALITY
echo "Cleanup"
rm -rf "${CONFIG_DIR}"

echo "Directories"
mkdir -p "${CONFIG_DIR}"
mkdir -p "${CONFIG_DIR}/lua"

if ! $CONFIG_ONLY ; then
	echo "Host"
	if $CHECK_HOST_PACKAGES ; then
		sudo pacman -S distrobox --no-confirm --needed >/dev/null 2>&1
	fi

	echo "Create containers"
	create_container "${MAIN_CONTAINER}"
	create_container treesitter-build
	for c in "${LSPS[@]}"; do
		create_lsp "$c"
	done

	echo "Install to containers"
	install_container "${MAIN_CONTAINER}" neovim git unzip tar curl
	install_container treesitter-build gcc make
	
	install_container "lsp-ansible" nodejs npm python python-pip ansible ansible-lint yamllint
	dbox_command "lsp-ansible" sudo npm install -g @ansible/ansible-language-server

	install_container "lsp-bash" nodejs npm
	dbox_command "lsp-bash" sudo npm install -g bash-language-server

	install_container "lsp-container" nodejs hadolint
	dbox_command "lsp-container" sudo npm install -g dockerfile-language-server-nodejs

	install_container "lsp-lua" lua-language-server

	echo "Export nvim"
	dbox_command "${MAIN_CONTAINER}" distrobox-export --bin /usr/bin/nvim --export-path $HOME/.local/bin
fi

echo "Copy configs"
cp "${FILE_DIR}/init.lua" "${CONFIG_DIR}/init.lua"
cp -a "${FILE_DIR}"/*/ "${CONFIG_DIR}/lua"

echo "Run nvim commands"
nvim_command -c "helptags ALL"
nvim_command "+Lazy! sync"
#nvim_command "+Lazy! update" -c "qa"
#nvim_command -c "TSInstallSync all" -c "qa"
#nvim_command -c "TSUpdateSync" -c "qa"
