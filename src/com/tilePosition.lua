-- tile positions of an entity;
-- base case: only the first array index is used.
-- advanced case: using scissors to make portals possible.

local static = {}

-- creates initial tile positions for an entity
static.init = function(self,n)
	for i = 1, n do
		self[i] = {
			tx = 0,
			ty = 0,
			tz = 0, -- currently not used, but here for future compatibility
		}
	end
end

-- sets a tile position for an entity
static.set = function(self,i,tx,ty,tz)
	assert(self[i],"Error: " .. i .. ". tile position entry is nonexistent.")
	local t = self[i]
	t.tx = tx
	t.ty = ty
	t.tz = tz
end

-- converts tile position to world position
static.toWorldPosition = function(self,w,i)
	local i = i or 1
	assert(w,"Error: argument #1 (world) not given.")
	assert(self[i],"Error: " .. i .. ". tile position entry is nonexistent.")
	local tw,th,td = world.getTileDimensions()
	local x = self[i].tx * tw
	local y = self[i].ty * th
	local z = self[i].tz * (td or 0)
	return x, y, z
end

local tilePosition = function()
	return setmetatable(
		{},
		{
			__newindex = static,
		}
	)
end

return tilePosition