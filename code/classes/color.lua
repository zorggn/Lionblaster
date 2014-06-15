--[[
	Color Utils
	by zorg
	@2014
--]]

-- Color management

local Color = {}

do
	local colorStack = {}
	local colorHeap = {}

	function Color.push()
		local temp = {}
		temp[1], temp[2], temp[3], temp[4] = love.graphics.getColor()
		colorStack[#colorStack+1] = temp
	end

	function Color.pop()
		assert(#colorStack>0,"Error: Trying to pop a color from an empty stack.\n" ..
			"	Check if you have the same # of saveColor() and restoreColor() functions!")
		--local r,g,b,a = unpack(colorStack[stackCounter])
		--love.graphics.setColor(r,g,b,a)
		love.graphics.setColor(colorStack[#colorStack])
		colorStack[#colorStack] = nil
	end

	function Color.save(name,color)
		local temp = {}
		colorHeap[name] = color
	end

	function Color.load(name)
		assert(colorHeap[name]~=nil,"Error: Trying to access nonexistent color.")
		return colorHeap[name]
	end
end

function Color.check(color1, color2, check_alpha)
	return (color1[1] == color2[1] and color1[2] == color2[2] and color1[3] == color2[3]
		and ((not check_alpha) or (check_alpha and (color1[4] and color2[4] and (color1[4] == color2[4])))))
end

-- function from löve2D wiki's snippets, page created by kraftman
function Color.HSVtoRGB(h, s, v, a)
	if s <= 0 then return v,v,v,a end
	h, s, v = h/256*6, s/255, v/255
	local c = v*s
	local x = (1-math.abs((h%2)-1))*c
	local m,r,g,b = (v-c), 0,0,0
	if h < 1     then r,g,b = c,x,0
	elseif h < 2 then r,g,b = x,c,0
	elseif h < 3 then r,g,b = 0,c,x
	elseif h < 4 then r,g,b = 0,x,c
	elseif h < 5 then r,g,b = x,0,c
	else              r,g,b = c,0,x
	end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

-- function from löve2D wiki's snippets, by Taehl
function Color.HSLtoRGB(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

-- by santos from 0.9.0 release forum thread (i added an alpha parameter to it)
function Color.DECtoRGB(n, a)
   local r = math.floor(n / (256*256))
   local g = math.floor((n - (r * (256*256))) / 256)
   local b = n - (r * 256*256) - (g * 256)
   local a = a or 255
   return r, g, b, a
end

function Color.NUMtoRGB(n) -- includes alpha
	local a = math.floor((n / 2 ^ 24) % 256)
	local r = math.floor((n / 2 ^ 16) % 256)
	local g = math.floor((n / 2 ^  8) % 256)
	local b = math.floor( n           % 256)
	return r, g, b, a
end

function Color:random(r,g,b,a)
	if not self.prng then self.prng = love.math.newRandomGenerator(rand(os.time)*(2^32-1),rand(os.time)*(2^32-1)) end
	return self.prng:random(0,255), self.prng:random(0,255), self.prng:random(0,255), (a and self.prng:random(0,255) or nil)
end

function Color:setSeed(l,h)
	if not self.prng then self.prng = love.math.newRandomGenerator(l,(h or l))
	else self.prng:setSeed(l,(h or l)) end
end

return Color