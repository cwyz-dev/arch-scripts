return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	init = function()
		local wrapper_dir = vim.fn.stdpath("cache") .. "/dbox_bin"
		vim.fn.mkdir(wrapper_dir, "p")
		local gcc_path = wrapper_dir .. "/gcc"
		local gcc_wrapper = io.open(gcc_path, "w")

		if gcc_wrapper then
			gcc_wrapper:write("#!/bin/sh\n")
			gcc_wrapper:write("distrobox enter -n treesitter-build -- gcc \"$@\"\n")
			gcc_wrapper:close()
			vim.fn.setfperm(gcc_path, "rwxr-xr-x")
		end

		vim.env.PATH = wrapper_dir .. ":" .. vim.env.PATH
	end,
	config = function()
		local status_configs, configs = pcall(require, "nvim-treesitter.configs")
		local status_install, install_config = pcall(require, "nvim-treesitter.install")
		if not (status_configs and status_install) then
			return
		end

		install_config.compilers = { "gcc" }
		configs.setup({
			ensure_installed = { "bash", "lua", "markdown", "query" },
			sync_install = false,
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = false
			},
			indent = { enable = true }
		})
	end
}
