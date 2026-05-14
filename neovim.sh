
#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="neovim"
IMAGE="archlinux:latest"

echo "[ 1 / 4 ] Checking dependencies..."
FAILED_DEPS=()
command -v podman >/dev/null 2>&1 || FAILED_DEPS+=("podman")
command -v distrobox >/dev/null 2>&1 || FAILED_DEPS+=("distrobox")
if [ ${#FAILED_DEPS[@]} -ne 0 ]; then
  echo "ERROR: Missing required dependencies:"
  printf '  - %s\n' "${FAILED_DEPS[@]}"
  echo ""
  exit 1
fi

echo "[ 2 / 4 ] Creating 'Distrobox' container..."
if distrobox list | grep -q "$CONTAINER_NAME"; then
  echo "Removing old instance"
  distrobox rm -f "$CONTAINER_NAME" >/dev/null 2>&1
fi
distrobox create -n "$CONTAINER_NAME" -i "$IMAGE" >/dev/null 2>&1

echo "[ 3 / 4 ] Entering container for first-time setup..."
distrobox enter "$CONTAINER_NAME" -- bash -c '
set -euo pipefail
echo "[ 3 . [ 1 / 6 ] / 4 ] Updating container..."
sudo pacman -Syu --noconfirm >/dev/null 2>&1

echo "[ 3 . [ 2 / 6 ] / 4 ] Installing core dev toolchain..."
echo "[ 3 . [ 2 . [ 1 / 8 ] / 6 ] / 4 ] {neovim, git, base-devel}"
sudo pacman -S --noconfirm --needed \
  neovim git base-devel \
  >/dev/null 2>&1

echo "[ 3 . [ 2 . [ 2 / 8 ] / 6 ] / 4 ] {ripgrep fd fzf unzip curl wget openssh jq shellcheck lazygit}"
sudo pacman -S --noconfirm --needed \
  ripgrep fd fzf unzip curl wget \
  openssh jq shellcheck \
  lazygit \
  >/dev/null 2>&1

echo "[ 3 . [ 2 . [ 3 / 8 ] / 6 ] / 4 ] {rustup rust-analyzer}"
sudo pacman -S --noconfirm --needed \
  rustup rust-analyzer \
  >/dev/null 2>&1

echo "[ 3 . [ 2 . [ 4 / 8 ] / 6 ] / 4 ] {dotnet-sdk}"
sudo pacman -S --noconfirm --needed \
  dotnet-sdk \
  >/dev/null 2>&1

echo "[ 3 . [ 2 . [ 5 / 8 ] / 6 ] / 4 ] {python python-pip ansible}"
sudo pacman -S --noconfirm --needed \
  python python-pip ansible \
  >/dev/null 2>&1

echo "[ 3 . [ 2 . [ 6 / 8 ] / 6 ] / 4 ] {ansible-lint yamllint lua-language-server yaml-language-server bash-language-server}"
sudo pacman -S --noconfirm --needed \
  ansible-lint yamllint \
  lua-language-server yaml-language-server \
  bash-language-server \
  >/dev/null 2>&1

echo "[ 3 . [ 2 . [ 7 / 8 ] / 6 ] / 4 ] {nodejs npm}"
sudo pacman -S --noconfirm --needed \
  nodejs npm \
  >/dev/null 2>&1

echo "[ 3 . [ 2 . [ 8 / 8 ] / 6 ] / 4 ] {lldb}"
sudo pacman -S --noconfirm --needed \
  lldb \
  >/dev/null 2>&1

echo "[ 3 . [ 3 / 6 ] / 4 ] Installing python tooling..."
mkdir -p "$HOME/.venvs/devtools"
python -m venv "$HOME/.venvs/devtools"
source "$HOME/.venvs/devtools/bin/activate"
pip install --upgrade pip >/dev/null 2>&1

echo "[ 3 . [ 4 / 6 ] / 4 ] Installing global node tools..."
mkdir -p ~/.npm-global
npm config set prefix "$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"
npm install -g prettier >/dev/null 2>&1

echo "[ 3 . [ 5 / 6 ] / 4 ] Setting environment variables..."
cat >> ~/.bashrc <<EOF
export EDITOR=nvim
export PATH="\$PATH:\$HOME/.cargo/bin"
export PATH="\$PATH:\$HOME/.dotnet/tools"
# Python venv
#if [ -d "\$HOME/.venvs/devtools/bin" ]; then
#  export PATH="\$HOME/.venvs/devtools/bin:\PATH"
#fi
EOF

echo "[ 3 . [ 6 / 6 ] / 4 ] Creating full NeoVim IDE configs..."
echo "[ 3 . [ 6 . [ 1 / 5 ] / 6 ] / 4 ] Creating directories..."
mkdir -p ~/.config/nvim/lua/{core,plugins}

echo "[ 3 . [ 6 . [ 2 / 5 ] / 6 ] / 4 ] init.lua"
cat > ~/.config/nvim/init.lua <<EOF
vim.g.mapleader = " "
require("core.options")
require("core.keymaps")
require("lazy").setup("plugins")
EOF

echo "[ 3 . [ 6 . [ 3 / 5 ] / 6 ] / 4 ] lua/core/options.lua"
cat > ~/.config/nvim/lua/core/options.lua <<EOF
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
EOF

echo "[ 3 . [ 6 . [ 4 / 5 ] / 6 ] / 4 ] lua/core/keymaps.lua"
cat > ~/.config/nvim/lua/core/keymaps.lua <<EOF
local map = vim.keymap.set
-- Basics
map("n", "<leader>w", ":w<CR>")
map("n", "<leader>q", ":q<CR>")
-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
-- Oil
map("n", "<leader>e", "<cmd>Oil<cr>")
-- Diagnostics
map("n", "<leader>dd", "vim.diagnostic.open_float")
EOF

echo "[ 3 . [ 6 . [ 5 / 5 ] / 6 ] / 4 ] lua/plugins/init.lua"
cat > ~/.config/nvim/lua/plugins/init.lua <<EOF
return {
  { "folke/lazy.nvim" },
  -- LSP
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim" },
  -- Completion
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "L3M0N4D3/LuaSnip"
  }},
  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  -- Telescope
  { "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
  }},
  -- File Explorer
  { "stevearc/oil.nvim" },
  -- Git
  { "lewis6991/gitsigns.nvim" },
  -- Formatting
  { "stevearc/conform.nvim" },
  -- Debugging
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui" }
}
EOF
'

echo "[ 4 / 4 ] Creating 'fnvim' launcher..."
sudo tee /usr/local/bin/fnvim >/dev/null <<EOF
#!/usr/bin/env bash
if [ $# -eq 0 ]; then
  distrobox enter neovim -- nvim
else
  distrobox enter neovim -- nvim "$@"
fi
EOF
sudo chmod +x /usr/local/bin/fnvim

echo "DONE"
