-- Lionblaster Boyon Mob Animation
-- by zorg
-- @2014

return {
	
	init = function(self)

		self.x = (self.indices.i-1) * 16
		self.y = (self.indices.j-1) * 16

		self.dx = 0
		self.dy = 0

		self.speed = 10.0

		self.frameDelay = 0.3
		self.frameTimer = 0.0
		self.frameDirection = 'forward'

		-- used in collision testing, everything is relative to x,y,w,h.
		self.boundingRect = {
			top = 0,
			left = 0,
			bottom = 0,
			right = 0
		}

		self.quadI = 1
		self.quadJ = 3
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

			if self.state == 'alive' then

				-- do calculations and stuff
				if self.actions.u then
					self.dy = -self.speed
				elseif self.actions.d then
					self.dy = self.speed
				elseif self.actions.r then
					self.dx = self.speed
				elseif self.actions.l then
					self.dx = -self.speed
				end

				self.x = self.x + self.dx * dt
				self.y = self.y + self.dy * dt

				self.frameTimer = self.frameTimer + dt

				-- make it bidi...
				if self.frameTimer >= self.frameDelay then
					self.frameTimer = 0.0
					if self.frameDirection == 'forward' and self.quadI == 3 then
						self.frameDirection = 'backward'
						self.quadI = (((self.quadI-1)+1)%3)-1
					elseif self.frameDirection == 'backward' and self.quadI == 1 then
						self.frameDirection = 'forward'
						self.quadI = (((self.quadI+1)-1)%3)+1
					elseif self.frameDirection == 'forward' and self.quadI ~= 3 then
						self.quadI = (((self.quadI-1)+1)%3)-1
					elseif self.frameDirection == 'backward' and self.quadI ~= 1 then
						self.quadI = (((self.quadI+1)-1)%3)+1
					end
				end

			end

			-- if the center of the sprite went to another grid cell, update the bin we're in
			if math.floor((self.x - self.quadW/2) / 16)+1 > self.indices.i then
				self.actions.r = false
				Lionblaster.Entity:moveEntity(self,self.indices.i+1,self.indices.j)
			elseif math.floor((self.x - self.quadW/2) / 16)+1 < self.indices.i then
				self.actions.l = false
				Lionblaster.Entity:moveEntity(self,self.indices.i-1,self.indices.j)
			elseif math.floor((self.y - self.quadH/2) / 16)+1 > self.indices.j then
				self.actions.d = false
				Lionblaster.Entity:moveEntity(self,self.indices.i,self.indices.j+1)
			elseif math.floor((self.y - self.quadH/2) / 16)+1 < self.indices.j then
				self.actions.u = false
				Lionblaster.Entity:moveEntity(self,self.indices.i,self.indices.j-1)
			end

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