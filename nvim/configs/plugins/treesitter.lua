local TSBox = require("dbox.treesitter")

local luats = TSBox:new("lua")
local bashts = TSBox:new("bash")

local wrappers = {
	bash = bashts:run(),
	lua = luats:run()
}

return {{
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		local_langs = { "bash", "lua" }
	end
}}
