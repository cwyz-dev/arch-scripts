return {
	cmd = { "distrobox", "enter", "-n", "lsp-bash", "--", "bash-language-server", "start" },
	on_attach = function(client, bufnr)
		local opts = { buffer = bufnr, silent = true }
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
	end,
	filetypes = { "sh" }
}
