-- load the components

local component = {}

component._init = function(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	for k,file in ipairs(files) do
		component[file] = require(file)
	end
end

return (function() component._init('/src/com/') return component end)()