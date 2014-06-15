--[[
	General Utils
	by zorg
	@2013
--]]

-- Todo: just rename this shit to colorutils or something, and have Utils table be and empty table, and add shit to it in love.load().

local Utils = {}

-- Color management

Utils.color = {}

do
	local colorStack = {}
	local stackCounter = 0

	function Utils.color.save()
		stackCounter = stackCounter + 1
		local temp = {}
		temp[1], temp[2], temp[3], temp[4] = love.graphics.getColor()
		colorStack[stackCounter] = temp
	end

	function Utils.color.restore()
		assert(stackCounter>0,"Error: Trying to pop a color from an empty stack.\n" ..
			"	Check if you have the same # of saveColor() and restoreColor() functions!")
		--local r,g,b,a = unpack(colorStack[stackCounter])
		--love.graphics.setColor(r,g,b,a)
		love.graphics.setColor(colorStack[stackCounter])
		stackCounter = stackCounter - 1
	end
end

function Utils.color.check(color1, color2, check_alpha)
	return (color1[1] == color2[1] and color1[2] == color2[2] and color1[3] == color2[3]
		and ((not check_alpha) or (check_alpha and (color1[4] and color2[4] and (color1[4] == color2[4])))))
end

function Utils.color.HSVtoRGB(h, s, v, a)											-- function from löve2D wiki's snippets, page created by kraftman
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

function Utils.color.HSLtoRGB(h, s, l, a)											-- function from löve2D wiki's snippets, by Taehl
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

function Utils.color.DECtoRGB(n, a)													-- by santos from 0.9.0 release forum thread (i added an alpha parameter to it)
   local r = math.floor(n / (256*256))
   local g = math.floor((n - (r * (256*256))) / 256)
   local b = n - (r * 256*256) - (g * 256)
   local a = a or 255
   return r, g, b, a
end

return Utils