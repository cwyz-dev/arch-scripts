local DBox = require("dbox.dbox")

local TSBox = {}
TSBox.__index = DBox

function TSBox:new(name)
	return DBox.new(self, "ts-" .. name, "tree-sitter")
end

return TSBox

