-- Lionblaster Soft Wall Animation
-- by zorg
-- @2014

return {
	
	init = function(self)

		self.x = (self.indices.i-1) * 16
		self.y = (self.indices.j-1) * 16

		-- used in collision testing, everything is relative to x,y,w,h.
		self.boundingRect = {
			top = 0,
			left = 0,
			bottom = 0,
			right = 0
		}

		self.quadI = 2
		self.quadJ = self.extra.world
		self.quadW = 16
		self.quadH = 16

		-- quads relate to the spritebatch's layout, so we need to do some calculations
		self.quad = love.graphics.newQuad(
			(self.quadI-1) * self.quadW,
			(self.quadJ-1) * self.quadW,
			self.quadW,
			self.quadH,
			self.layer:getImage():getWidth(),
			self.layer:getImage():getHeight()
		)

		self.spriteId = self.layer:add(self.quad, self.x, self.y)

		self.draw = function(self,dt)

			-- do calculations and stuff

			-- if the center of the sprite went to another grid cell, update the bin we're in

			-- update quad
			self.quad:setViewport(
				(self.quadI-1) * self.quadW,
				(self.quadJ-1) * self.quadW,
				self.quadW,
				self.quadH
			)
				
			-- update sprite on spritebatch
			self.layer:set(self.spriteId, self.quad, self.x, self.y)

		end

	end

}