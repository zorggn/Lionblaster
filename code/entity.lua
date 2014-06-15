-- Lionblaster Entity Class
-- by zorg
-- @2014

Entity = {}

function Entity:assignHashTable(hashTable)
	-- the hashTable containing an array of arrays of array that holds entities at the specific 2D position on the grid,
	-- along with the map's width and height in cells (starting from 1,1... that being a corner border on rectangular maps)
	-- on custom maps, the map's true size needs to be as big as the most extreme existing tiles created (effectively containing nil cells)
	self.hashTable = hashTable
end

function Entity:createLayers() -- layers are represented by a parameter in the hashtable's cells (also these are the SpriteBatches...)
	self.Layer = {}
	self.Layer.Map = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.tile),				 4096,	 "static")
	self.Layer.Effects = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.effects),		 1024,	"dynamic")
	self.Layer.Items = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.items),			  256,	"dynamic")
	self.Layer.Bombs = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.bombs),			 2048,	"dynamic")
	self.Layer.Explosions = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.explosions),	 4096,	"dynamic")
	self.Layer.Mobs = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.mobs),				  256,	"dynamic")
	self.Layer.Players = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.players),		  256,	"dynamic")
	self.Layer.Overlay = love.graphics.newSpriteBatch(love.graphics.newImage(Lionblaster.Assets.gfx.spriteMaps.overlay),		 1024,	"dynamic")
end

-- No moveLayer function, since it'd be moving the whole spritebatches...

function Entity:clearLayer(name) -- removes everything from a layer, if name is nil then clears all layers.
	if name ~= nil then
		if type(self.Layer[name]) == 'table' then
			self.Layer[name]:clear()
		end
	else
	    for k,v in pairs(self.Layer) do
	    	v:clear()
	    end
	end
end

function Entity:setLayer(name,type) -- type is 'static' or 'dynamic'; static doesn't run collisionchecks.
	if type(self.Layer[name]) == 'table' then
			if type == 'static' then
				self.Layer[name].collisionType = 'static'
			else
			    self.Layer[name].collisionType = 'dynamic'
			end
		end
end

function Entity:setType(entity,type)
	entity.type = type
end

function Entity:addEntity(i,j,layer,animation,behaviour,type,extra) -- i,j are tilegrid coords, x,y would be pixel; returns the entity's id.

	-- Create a new entry at i,j, returns a globalized id (SpriteBatch id-s are per-SpriteBatch...)

	local e = #self.hashTable[i][j] + 1

	self.hashTable[i][j][e] = {}

	local entity = self.hashTable[i][j][e]

	-- save a pointer to the hash table as well, so we can get the map's width and height in cells
	entity.map = self.hashTable

	-- The type is there for logic reasons, not all mobs are to be regarded as mobs :3
	-- besides, we need a way to handle collisions between different types in the code :v
	entity.type = type

	-- Store all of the hashtable indices for convenience
	entity.indices = {
		['i'] = i,
		['j'] = j,
		['e'] = e
	}

	-- the behaviour component will update these values, and the animation update ill use these as references.
	-- (the two modules can not cross-interact, since this way, we can pair different animations with different behaviour.)
	entity.actions = {
		['u'] = false, ['l'] = false, ['r'] = false, ['d'] = false,
		['a'] = false, ['b'] = false, ['st'] = false, ['sl'] = false
	}

	-- some extra info that may be used by either animation or behaviour
	-- e.g. the round number -> used to set the tile image for the map
	-- or whether we should apply a camera to an entity or not

	entity.extra = extra or {}

	-- the animation component will use this to create the sprite on the correct spritebatch.
	entity.layer = self.Layer[layer] 

	-- animation will create at least these:
	--entity.x, .y, .width, .height
	--entity.quad -- as the size of the sprite
	--entity.boundingRect -- as a table holding the relative top, left, width and height of the bounding rectangle used for collision testing.
	--entity.spriteId -- also create the sprite on the layer supplied by self.layer
	--entity.draw()

	entity.animation = require('code.animation.'..animation)
	entity.animation.init(entity)

	-- behaviour will create at least these:
	--entity.update()
	--entity.colliding(otherEntity)

	entity.behaviour = require('code.behaviour.'..behaviour)
	entity.behaviour.init(entity)

	-- for whatever future-reason, return the entity
	return entity

end

-- No changeEntityLayer function either, since spritebatches can only hold one image as a tilemap.

function Entity:moveEntity(entity,i,j) -- moves the entity from one bin to another
	local entity = entity
	self.hashTable[entity.indices.i][entity.indices.j][entity.indices.e] = nil
	entity.indices.i = i
	entity.indices.j = j
	local e = #self.hashTable[i][j]+1
	entity.indices.e = e
	self.hashTable[i][j][e] = entity
end

function Entity:removeEntity(entity) -- removes an entity from the map.

	-- first thing's first, set the spritebatch with a pointlike quad so it's essentially invisible
	-- (no guard is necessary since entity.quad must be created in createEntity! (in animation.init actually...))
	entity.quad:setViewport(0,0,0,0)
	self.Layer[entity.layer]:set(entity.spriteId, entity.quad, 0, 0)

	-- we need to reorder the remaining entities in the bin before nilling out this one.
	local ee = entity.indices.e
	if #self.hashTable[entity.indices.i][entity.indices.j] == ee then

		-- only one entity is in the bin, or the entity is at the end
		self.hashTable[entity.indices.i][entity.indices.j][e] = nil
	else

		-- we need to move all others down by one, after the entity we're removing
		for k = entity.indices.e + 1, #self.hashTable[entity.indices.i][entity.indices.j] do
			self.hashTable[entity.indices.i][entity.indices.j][k-1] = self.hashTable[entity.indices.i][entity.indices.j][k]
		end

		-- delete the last since it's a duplicate
		self.hashTable[entity.indices.i][entity.indices.j][#self.hashTable[entity.indices.i][entity.indices.j]] = nil
	end

end

-- A modifyBehaviour function so we can load another behaviour for an entity

-- A modifyAnimation function so we can load another animation for an entity

function Entity:update(dt)

	-- iterate over each hashTable bin, and do the update routines
	for i,v in ipairs(self.hashTable) do
		for j,u in ipairs(v) do
			for e,w in ipairs(u) do
				w:update(dt)
				-- if one's layer is dynamic, then iterate over the same bin, and the ones closest to the entity (that aren't nil of course)
				if w.layer.collisionType == 'dynamic' then
					for ii = i-1, i+1 do
						for jj = j-1, j+1 do
							local uu = self.hashTable[ii][jj]
							for ee,ww in ipairs(uu) do
								-- if there's a collision between the entities, then send a collision event to the current entity in the outer loop.
								if self:checkCollision(w,ww) then
									-- if it's a tile, then it's NOT a collision
									if ww.type ~= 'tile' then
										print('colliding!',w,ww)
										w:colliding(ww)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function Entity:draw(dt)

	-- bind the spritebatches (order doesn't matter)
	for _,v in pairs(self.Layer) do
		v:bind()
	end

	-- do the draw routines for all the entities
	for i,v in ipairs(self.hashTable) do
		for j,u in ipairs(v) do
			for e,w in ipairs(u) do
				w:draw(dt)
			end
		end
	end

	-- unbind them (order doesn't matter)
	for _,v in pairs(self.Layer) do
		v:unbind()
	end

	-- draw out the spritebatches in this specific order
	love.graphics.draw(self.Layer.Map, 0.5, 0.5)
	love.graphics.draw(self.Layer.Effects, 0.5, 0.5)
	love.graphics.draw(self.Layer.Items, 0.5, 0.5)
	love.graphics.draw(self.Layer.Bombs, 0.5, 0.5)
	love.graphics.draw(self.Layer.Explosions, 0.5, 0.5)
	love.graphics.draw(self.Layer.Mobs, 0.5, 0.5)
	love.graphics.draw(self.Layer.Players, 0.5, 0.5)
	love.graphics.draw(self.Layer.Overlay, 0.5, 0.5)
end

function Entity:checkCollisions(e1,e2) -- internal, called from update

	-- the entities' boundingRect.x, .y, .width and .height are used to determine whether they are colliding. (x,y is left and top) 
	return e1.x + e1.boundingRect.x < e2.x + e2.boundingRect.x + e2.width  - e2.boundingRect.width  and
		   e2.x + e2.boundingRect.x < e1.x + e1.boundingRect.x + e1.width  - e1.boundingRect.width  and
		   e1.y + e1.boundingRect.y < e2.y + e2.boundingRect.y + e2.height - e2.boundingRect.height and
		   e2.y + e2.boundingRect.y < e1.y + e1.boundingRect.y + e1.height - e1.boundingRect.height

end

-----------------------------------------
-- After an entity is created:
	-- entity.actions = {u,l,r,d,a,b,st,sl} -- modified by entity.update
-- entity.animation = require('code.animation.'..animation)
	-- this defines entity.draw

-- entity.behaviour = require('code.behaviour.'..behaviour)
	-- this defines entity.update, which only modifies entity.actions -- (it can query other information too though...)
	-- and entity.collision(otherEntity) -- (what to do when collided with something...)

return Entity