-- load the components

local component = {}

component._init = function(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	for k,file in ipairs(files) do
		local f = file:gsub('%.[^%.]+$', '')
		print(f)
		component[f] = require('src.com.' .. f)
		print(f,component[f])
	end
end

return (function() component._init('/src/com/') return component end)()