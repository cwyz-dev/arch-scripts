vim.filetype.add({
	extension = {
		yml = function(path, bufnr)
			if vim.fs.find(
				{ "roles", "playbooks" },
				{ path = path, upward = true }
			)[1] then
				return "yaml.ansible"
			end
			return "yaml"
		end,
		yaml = function(path, bufnr)
			if vim.fs.find(
				{ "roles", "playbooks" },
				{ path = path, upward = true }
			)[1] then
				return "yaml.ansible"
			end
			return "yaml"
		end,
		[ "Containerfile" ] = "dockerfile"
	},
	filename = {
		[ "Containerfile" ] = "dockerfile"
	}
})
