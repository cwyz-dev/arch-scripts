return {
	cmd = { "distrobox", "enter", "lsp-lua", "--", "lua-language-server" }
	filetypes = { "lua" },
	root_markers = { ".luarc.json", ".luarc.jsonc" },
	settings = {
		Lua = {
			runtime = { version = 'LuaJIT' },
			diagnostics = { globals = { 'vim' } },
			signatureHelp = { enabled = true },
			telemetry = { enable = false },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false
			}
		}
	},
	on_attach = function(client, bufnr)
		local opts = { buffer = bufnr, silent = true },
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	end
}
