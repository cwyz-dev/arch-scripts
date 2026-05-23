local DBox = require("dbox")
local LSPBox = setmetatable({}, { __index = DBox })
LSPBox.__index = LSPBox

function LSPBox:new(name)
	return DBox:new(self, "lsp-" .. name, name)
end

return LSPBox
