-- tile positions of an entity;
-- base case: only the first array index is used.
-- advanced case: using scissors to make portals possible.
-- z useful for simulating quadtree collision detection
-- (e.g. start with 0, if another entity is in that range, go one level deeper, and check there, etc...)

local static = {}

-- creates initial tile positions for an entity
static.init = function(self,n)
	for i = 1, (n or 1) do
		self[i] = {
			tx = 0,
			ty = 0,
			tz = 0, -- currently not used, but here for future compatibility
		}
	end
end

-- gets a tile position for an entity
static.get = function(self,i)
	local i = i or 1
	assert(self[i],"Error: " .. i .. ". tile position entry is nonexistent.")
	return self[i].tx, self[i].ty, self[i].tz
end

-- sets a tile position for an entity
static.set = function(self,i,tx,ty,tz)
	local i = i or 1
	assert(self[i],"Error: " .. i .. ". tile position entry is nonexistent.")
	local t = self[i]
	local tx,ty,tz = tx,ty,tz
	if type(tx) == 'table' then
		tz, ty, tx = tx[3], tx[2], tx[1]
	end
	t.tx = tx
	t.ty = ty
	t.tz = tz
end

-- converts tile position to world position
static.toWorldPosition = function(self,w,i)
	local i = i or 1
	assert(w,"Error: argument #1 (world) not given.")
	assert(self[i],"Error: " .. i .. ". tile position entry is nonexistent.")
	local tw,th,td = w.getTileDimensions()
	local x = self[i].tx * tw
	local y = self[i].ty * th
	local z = self[i].tz * (td or 0)
	return x, y, z
end

-- toString method
static.toString = function(self,i)
	local t = {}
	for j = (i or 1), (i or #self) do
		table.insert(t,j)
		table.insert(t,': ')
		table.insert(t,'[\n  tx = ')
		table.insert(t,self[j].tx)
		table.insert(t,'\n  ty = ')
		table.insert(t,self[j].ty)
		if self[j].tz then
			table.insert(t,'\n  tz = ')
			table.insert(t,self[j].tz)
		end
		table.insert(t,'\n]')
	end
	return table.concat(t,'')
end

-- factory
local tilePosition = function()
	return setmetatable(
		{},
		{
			__index = static,
		}
	)
end

return tilePosition