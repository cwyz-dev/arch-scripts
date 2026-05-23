local DBox = {}
DBox.__index = DBox

function DBox:new(name, func)
	local obj = {}
	
	setmetatable(obj, self)
	
	obj.container = name
	obj.app = func
	
	return obj
end

function DBox:run(args)
	local a_str
	if type(command) == "table" then
		a_str = table.concat(args, " ")
	else
		a_str = args or ""
	end

	local output = vim.fn.system(string.format(
		"distrobox enter %s -- %s %s",
		self.container, self.app, a_str
	))
	return output:gsub("\n$", "")
end

return DBox
