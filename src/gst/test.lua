--[[
	Test Gamestate
	by zorg
	v1.0 @ 2014; license: isc
--]]



--[[
Copyright (c) 2014, zorg <zorg@atw.hu>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--]]



--[[
	external modules
--]]



--[[
	localized love lib calls
--]]



--[[
	locals (private)
--]]


local newPlaceholderImage
newPlaceholderImage = function(r,g,b)
	local map = {
		0,0,0,1,1,0,0,0,
		0,0,0,1,1,0,0,0,
		0,0,0,1,1,0,0,0,
		0,0,0,1,1,0,0,0,
		0,0,0,1,1,0,0,0,
		0,0,0,0,0,0,0,0,
		0,0,0,1,1,0,0,0,
		0,0,0,1,1,0,0,0,
	}

	local data = love.image.newImageData(8,8)
	for i=0,63 do
		data:setPixel(i%8,math.floor(i/8),r,g,b,(map[i+1] == 1) and 191 or 63)
	end

	local image = love.graphics.newImage(data)
	image:setFilter('nearest','nearest',16)
	--image:setMipmapFilter('nearest',0)

	return image
end



--[[
	this state
--]]

local s = {}

--[[
	members/methods (public)
--]]

s.name = 'Test State'

s.init = function(self)

	-- serialization module
	ser = require 'paralell'

	-- create folder structure if nonexistent
	--ser.initUserFolderStructure()

	-- if settings were saved, load them
	--settings.load()

	-- create the window; l.g and l.w calls are safe from this point


	-- as defined in settings
	hbms.checkCompatibility()

	-----------------------------------------------------------------

	---[[

	-- create a placeholder image
	--placeholder = newPlaceholderImage(255,255,255)

	-- create a canvas
	--canvas = love.graphics.newCanvas(320, 240)
	--canvas:setFilter('nearest','nearest',16)

	--a = 0

	--]]

	-- test imap stuff

	--[[

	s.char = {x = 200, y = 200, color = {255,255,255}}

	s.p1 = imap.newMap('player1')

	s.p1:setMapping('up','k','up')
	s.p1:setMapping('down','k','down')
	s.p1:setMapping('left','k','left')
	s.p1:setMapping('right','k','right')
	s.p1:setMapping('a','k','x')
	s.p1:setMapping('b','k','y')
	s.p1:setMapping('focus','k','lshift')
	s.p1:setMapping('mouse','m','a')
	s.p1:setMapping('ja',1,'a',1)
	s.p1:setMapping('jb',1,'b',1)
	s.p1:setMapping('jh',1,'h','u')

	function s.p1.isPressed(name, amount)

		if name == 'ja' then
			print(amount)
		end

		if name == 'up' then
			s.char.y = s.char.y - 2 * amount
		elseif name == 'down' then
			s.char.y = s.char.y + 2 * amount
		elseif name == 'left' then
			s.char.x = s.char.x - 2 * amount
		elseif name == 'right' then
			s.char.x = s.char.x + 2 * amount
		elseif name == 'a' then
			s.char.color = {0,0,255}
		elseif name == 'b' then
			s.char.color = {255,255,255}
		elseif name == 'mouse' then
			s.char.o = amount
		end
	end
	function s.p1.isHeld(name, amount)
		if name == 'up' then
			s.char.y = s.char.y - 2 * amount
		elseif name == 'down' then
			s.char.y = s.char.y + 2 * amount
		elseif name == 'left' then
			s.char.x = s.char.x - 2 * amount
		elseif name == 'right' then
			s.char.x = s.char.x + 2 * amount
		elseif name == 'mouse' then
			s.char.o = amount
		end
	end

	--]]

	component = require 'src.component'

end

s.enter = function(from)

	print(from.name and from.name or 'nil')

end

--local bullets = {}

s.update = function(self,dt)

	--[[

	a = a + dt * math.pi / 4 * (1.5 + math.sin((2*(a-0.5))))

	frame = frame + 1

	--]]


	--[[
	--if #bullets < 5000 then
	if love.mouse.isDown('l') then
		--for i=1,50 do
		local b = {}
		b.color = {love.math.random(0,255),love.math.random(0,255),love.math.random(0,255),127}
		b.r = 8
		b.x = love.mouse.getX()
		b.y = love.mouse.getY()
		b.dx = math.random(-5,5)
		b.dy = love.math.random(-5,5)
		b.a = 1.0
		b.l = 0
		if b.dx == 0 and b.dy == 0 then
			b.dx = 0.1
		end
		bullets[#bullets+1] = b
		--end
	end

	if love.mouse.isDown('r') then
		for i=1,50 do
			bullets[#bullets] = nil
		end
	end

	for i,v in ipairs(bullets) do
		v.l = v.l + dt

		local nx = v.x + v.dx
		local ny = v.y + v.dy
		if nx < 0 or nx > 768 then
			v.dx = -v.dx
		end
		if ny < 0 or ny > 672 then
			v.dy = -v.dy
		end
		v.x = v.x + v.dx --* math.random()
		v.y = v.y + v.dy --* love.math.random()
	end
	--]]
    
end

s.draw = function(self,lerp)

	--[[
	love.graphics.print(#bullets,0,240)

	love.graphics.setBlendMode('additive')
	for i,v in ipairs(bullets) do
		love.graphics.setColor(v.color)
		love.graphics.circle('fill',v.x,v.y,v.r)
	end

	local dt = love.timer.getDelta()
	--]]

	--[[
	local b = a + dt * math.pi / 4 * lerp
	--love.graphics.setColor(((255-b)*100)%256,(b*400)%256,((1/b)*600)%256)
	love.graphics.draw(placeholder,256+(100*math.cos(b)),256+(100*math.sin(-b)),b,128/8,128/8,4,4)
	--]]

	--[[
	love.graphics.setColor(255,255,255)
	love.graphics.circle('fill', 200+joystick:getAxis(1)*50, 200+joystick:getAxis(2)*50, 75,100)
	love.graphics.circle('fill', 400+joystick:getAxis(4)*50, 200+joystick:getAxis(3)*50, 75,100)
	for i=1,12 do
		love.graphics.printf(joystick:isDown(i) and i or '', 300, 400, 500, 'center')
	end
	love.graphics.print(joystick:getHat(1), 350, 400)
	--]]

	--[[
	love.graphics.setColor(s.char.color)
	love.graphics.circle('fill',s.char.x, s.char.y, 20)
	love.graphics.setColor(255,255,255)
	love.graphics.draw(placeholder,s.char.x,s.char.y,s.char.o,16,16,4,4)
	--]]

end

--[[
	Return the state
--]]

return s