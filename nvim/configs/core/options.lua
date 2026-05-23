vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.hidden = true
vim.opt.lazyredraw = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 5
vim.opt.showmode = true
vim.opt.signcolumn = "yes:3"
vim.opt.swapfile = false
vim.opt.synmaxcol = 150
vim.opt.termguicolors = true

vim.opt.updatetime = 300
vim.opt.timeoutlen = 500

-- Python/Ruby/Node/Perl provider disable (not in this container)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

-- No automatic comment insersion
-- (from Enrique Dominguez "NeoVim from scratch in 2025", taken on 2026-05-21)
vim.cmd([[autocmd FileType * set formatoptions-=ro]])
