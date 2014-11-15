-- creates entities

local component = require 'src.component'

local entity = {}

entity.new = function(c)
	-- create a new entity; only state is stored there via references to other tables
	local e = {}
	-- go through the given components, and add them; true initialization happens outside the constructor.
	for k,v in pairs(c) do
		e[c] = component[c] and component[c](e) -- e param may not be needed, but still, just in case.
	end
	return e
end

return entity