return {
	cmd = { "distrobox", "enter", "-n", "lsp-container", "--", "docker-langserver", "--stdio" },
	filetypes = { "dockerfile" },
	root_dir = function(fname)
		returp lspconfig.util.root_pattern("Containerfile", "Dockerfile", ".git")(fname)
	end
}
