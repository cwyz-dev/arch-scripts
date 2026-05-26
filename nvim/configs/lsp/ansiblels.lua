return {
	cmd = { "distrobox", "enter", "lsp-ansible", "--", "ansible-language-server", "--stdio" },
	filetiypes = { "yaml.ansible" },
	settings = {
		ansible = {
			ansible = { path = "ansible" },
			ansibleLint = {
				enabled = true,
				path = "ansible-lint"
			}
		}
	}
}
