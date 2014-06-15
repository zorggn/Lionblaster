-- Lionblaster Camera Class
-- by zorg
-- @2014


---dagkadjglajklgkadklgjk


local camera = {}

-- focus on the entity, this helper function exists to reduce code duplication
function camera:lockOnEntity()

	local x = self.focus.x
	local y = self.focus.y
	local w = self.focus.quadW
	local h = self.focus.quadH

	-- calculate the camera from the entity's x,y values; this needs to be the center of the map though (offset by the sprite's w/2 & h/2 though)
	self.x = (-x - (w/2)) - self.width / 2
	self.x = (-y - (h/2)) - self.height / 2

	-- clamp camera at edges
	if self.x > 0 then self.x = 0 end
	if self.x <= self.width then self.x = self.width end
	if self.y > 0 then self.y = 0 end
	if self.y <= self.height then self.y = self.height end
end

-- init function, binds the camera to an entity
function camera:create(entity, i, j, zoom, width, height)

	-- the camera's own properities
	self.x = -(i*16)
	self.y = -(j*16)

	-- the entity the camera focuses on (not the id, the entity itself)
	self.focus = entity

	--these stay constant through a level; it needs to be changed if the map size changes though.
	self.width = -(i*16)+208 -- 48 chopped off of 256 as left border
	self.height = -(j*16)+176 -- 48 chopped off of 224 as top border and hud

	-- the zooming factor
	self.zoom = zoom

	-- do the transform
	self:lockOnEntity()
end

--change the followed entity; TODO: implement that if multiple are added, then it tries to lock on the average middle of them, and if they wander
--too far away from each other, it should dynamically zoom out, and in if they are getting closer again... all this inside the lockOnEntity function.
function camera:setEntity(entity)
	self.focus = entity
end

--change the camera's zooming ratio
function camera:setZoom(zoom)
	self.zoom = zoom
end

-- the update function for the camera; called from the variadic tick part of the game state update loop.
function camera:update(dt)

	-- do the transform
	self:lockOnEntity()
end

function camera:enable()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
end

function camera:disable()
	love.graphics.pop()
end

return camera