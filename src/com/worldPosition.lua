-- pixel position of an entity relative to the world/map.
-- This needn't be duplicated, since the other cell's world coords can be calculated from that tile's indices and these coords...
-- but we'll get back to that.

local static = {}

-- creates initial world positions for an entity
static.init = function(self,n)
	for i = 1, (n or 1) do
		self[i] = {
			x = 0,
			y = 0,
			z = 0, -- currently not used, but here for future compatibility
		}
	end
end

-- gets a world position for an entity
static.get = function(self,i)
	local i = i or 1
	assert(self[i],"Error: " .. i .. ". world position entry is nonexistent.")
	return self[i].tx, self[i].ty, self[i].tz
end

-- sets a world position for an entity
static.set = function(self,i,x,y,z)
	local i = i or 1
	assert(self[i],"Error: " .. i .. ". world position entry is nonexistent.")
	local t = self[i]
	local x,y,z = x,y,z
	if type(x) == 'table' then
		z, y, x = x[3], x[2], x[1]
	end
	t.x = x
	t.y = y
	t.z = z
end

-- converts world position to tile position
static.toTilePosition = function(self,w,i)
	local i = i or 1
	assert(w,"Error: argument #1 (world) not given.")
	assert(self[i],"Error: " .. i .. ". world position entry is nonexistent.")
	local tw,th,td = w.getTileDimensions()
	local x = math.floor(self[i].tx / tw)
	local y = math.floor(self[i].ty / th)
	local z = math.floor(self[i].tz / (td or 1))
	return x, y, z
end

-- toString method
static.toString = function(self,i)
	local t = {}
	for j = (i or 1), (i or #self) do
		table.insert(t,j)
		table.insert(t,': ')
		table.insert(t,'[\n  x = ')
		table.insert(t,self[j].x)
		table.insert(t,'\n  y = ')
		table.insert(t,self[j].y)
		if self[j].z then
			table.insert(t,'\n  z = ')
			table.insert(t,self[j].z)
		end
		table.insert(t,'\n]')
	end
	return table.concat(t,'')
end

-- factory
local worldPosition = function()
	return setmetatable(
		{},
		{
			__index = static,
		}
	)
end

return worldPosition