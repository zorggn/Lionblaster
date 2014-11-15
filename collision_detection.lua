--[[
	Collision Detection module
	by zorg
	v1.0 @ 2014; license: isc
--]]

-- Description: This module implements various algorithms to deal with detecting collisions between objects.
--              The algorithms return both a flag whether collision happened or not, and some extra values as well, if it did.
--              There are 6 types of collision maps: Point, Line, Circle, Axis-Aligned Rectangle, Ellipse, Simple Polygon.
--				Points: Have one coordinate {x,y}; also returns the point itself
--				Lines: Have two coordinates {x1,y1, x2,y2}; also returns either one or two intersections
--				Circles: Have one coordinate and a scalar representing the radius {cx,cy, r}; also returns one or two intersections
--				AARects: Have one coordinate and a width and height scalar {x,y,w,h}; doesn't return anything else
--				Ellipses: Have -- yeah, look this up again; won't return anything extra
--				Polygons: Have n coordinates, (ordered) {x1,y1, ... xn, yn}; maybe returns the first intersecting point, maybe not.

--[[
Copyright (c) 2014, zorg <zorg@atw.hu>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--]]

-- TODO: Test these thoroughly.

--[[
	external modules
--]]



--[[
	localized love lib calls
--]]



--[[
	locals (private)
--]]

-- all the used collision detection algorithms

local cdPointPoint = function(a, b)
	local onEachother = ((a.x == b.x) and (a.y == b.y))
	if onEachother then
		return true, {a.x,a.y}
	else
		return false
	end
end

local cdPointLine = function(a, b)
	local onLine = ((a.x - b.x1) / (b.x2 - b.x1) == (a.y - b.y1) / (b.y2 - b.y1))
	if onLine then
		return true, {a.x,a.y}
	else
		return false
	end
end

local cdPointCircle = function(a, b)
	local onPerimeter = ((a.x - b.cx)^2 + (a.y - b.cy)^2) == (b.r^2)
	if onPerimeter then
		return true, {a.x,a.y}
	else
		return false
	end
end

local cdPointAARect = function(a, b)
	local onSides = (a.x > b.x1) and (a.y > b.y1) and (a.x < b.x2) and (a.y < b.y2)
	if onSides then
		return true, {a.x,a.y}
	else
		return false
	end
end

local cdPointEllipse = function(a, b)
	-- TODO: test this whether it works
	local onPerimeter = ((a.x - b.cx)/b.e)^2 + ((a.y - b.cy)/b.f)^2 == 1
	if onPerimeter then
		return true, {a.x, a.y}
	else
		return false
	end
end

local cdPointPolygon = function(a, b)
	-- TODO
	return false
end



local cdLineLine = function(a, b)
	local denominator = (((b.y2 - b.y1) * (a.x2 - a.x1)) - ((b.x2 - b.x1) * (a.y2 - a.y1)))

	-- lines are paralell
	if denominator == 0 then return false end

	local ua = (((b.x2 - b.x1) * (a.y1 - b.y1)) - ((b.y2 - b.y1) * (a.x1 - b.x1))) / denom
	local ub = (((a.x2 - a.x1) * (a.y1 - b.y1)) - ((a.y2 - a.y1) * (a.x1 - b.x1))) / denom

	-- if intersection is outside the given line segments
	if ua < 0 or ua > 1 or ub < 0 or ub > 1 then return false end

	-- else return the point
	return true, {a.x1 + ua * (a.x2 - a.x1), a.y1 + ua * (a.y2 - a.y1)}

end

local cdLineCircle = function(a, b)
	-- transform the line segment's coordinate pair so it's relative to the circle's center's.
	local x1,y1,x2,y2 = a.x1 - b.cx, a.y1 - b.cy, a.x2 - b.cx, a.y2 - b.cy

	-- pre-calculate the distance between the two "normalized" coordinates
	local dx,dy = x2-x1, y2-y1

	local a = dx^2 + dy^2
	local b = 2 * (dx * x1 + dy * y1)
	local c = x1^2 + y1^2 - b.r^2

	local delta = b^2 - 4 * a * c

	if delta < 0 then
		-- no intersections
		return false
	elseif delta == 0 then
		-- one intersection
		local u = -b / (2 * a)
		return true, {a.x1 + u * dx, a.y1 + u * dy}
	else
		-- two intersections
		local sqrtDelta = math.sqrt(delta)
		local u1 = (-b + sqrtDelta) / (2 * a)
		local u2 = (-b - sqrtDelta) / (2 * a)
		return true, {a.x1 + u1 * dx, a.y1 + u1 * dy}, {a.x1 + u2 * dx, a.y1 + u2 * dy}
	end

end

local cdLineAARect = function(a, b)
	local  x1,  y1, dx,  dy  = a.x1, a.y1, a.x2 - a.x1, a.y2 - a.y1
    local rx1, ry1, rx2, ry2 = b.x,  b.y,  b.x  + b.w,  b.y  + b.h
    --assert(dx == 0 or dx == 0) -- degenerate line <- not really needed, since lua can handle division by zero...

    --local p,q = {},{}
    p[1] = -dx      q[1] =  x1 - rx1
    p[2] =  dx      q[2] = rx2 -  x1
    p[3] = -dy      q[3] =  y1 - ry1
    p[4] =  dy      q[4] = ry2 -  y1

    --local
    u1,u2 = -1/0, 1/0 -- -math.infinity, math.infinity

    for i=1,4 do
        if p[i] == 0 then
        	-- line is paralell to our rectangle
            if q[i] < 0 then return false end
        else
            local t = q[i] / p[i]
            -- a little experiment here, making both brances possible to execute, instead of an else branch; we'll see what happens.
            if p[i] < 0 and u1 < t then u1 = t end
            if p[i] > 0 and u2 > t then u2 = t end
        end
    end

    -- not intersecting general case
    if u1 > u2 then return false end

    -- these denote the function of the infinite lines from which we extract the points where the collision happened
    local sofi,sifo = {},{} -- started outside, started inside
    sofi = {x1+u1*dx, y1+u1*dy}
    sifo = {x1+u2*dx, y1+u2*dy}

    -- enters then leaves
    if 0 <= u1 and u1 < u2 and u2 <= 1 then return true, sofi, sifo end

    -- enters from outside
    if 0 <= u1 and u1 <= 1 then return true, sofi, nil end

    -- exits from inside
    if 0 <= u2 and u2 <= 1 then return true, nil, sifo end

    -- whole line is inside, technically not intersecting with the rectangle...
    if u1 < 0 and 1 < u2 then return false end

    -- return false because we're touching the extended invisible infinite continuation of our line.
    return false

end

local cdLineEllipse = function(a, b)
	-- TODO
	return false
end

local cdLinePolygon = function(a, b)
	-- TODO
	return false
end



local cdCircleCircle = function(a, b)
	-- return early, if the circles don't collide
	local test = ((b.cx - a.cx)^2 + (b.cy - a.cy)^2) <= ((a.r^2) + (b.r^2))
	if not test then return false end

	-- TODO: return the intersection points as well!
	return true

end

local cdCircleAARect = function(a, b)
	local cx = math.clamp(a.cx,b.x1,b.x2)
	local cy = math.clamp(a.cy,b.y1,b.y2)
	local dx = a.cx - cx
	local dy = a.cy - cy
	return (dx^2)+(dy^2) < (a.r^2)
end



local cdAARectAARect = function(a, b)
	return (a.x1 < b.x2 and b.x1 < a.x2 and a.y1 < b.y2  and b.y1 < a.y2)
end

-- no code duplication, and less branching!
local swapArguments = {
	["line,point"]      = true,
	["circle,point"]    = true,
	["aarect,point"]    = true,
	["ellipse,point"]   = true,
	["polygon,point"]   = true,

	["circle,line"]     = true,
	["aarect,line"]     = true,
	["ellipse,line"]    = true,
	["polygon,line"]    = true,

	["aarect,circle"]   = true,
	["ellipse,circle"]  = true,
	["polygon,circle"]  = true,

	["ellipse,aarect"]  = true,
	["polygon,aarect"]  = true,

	["polygon,ellipse"] = true,
}

-- a list of type-specific collision testing algos;
-- "swapped" ones included, since we're swapping the params, and it's more speed efficient that way.
local test = {
	["point,point"]     = cdPointPoint,				-- done
	["point,line"]      = cdPointLine,				-- done
	["point,circle"]    = cdPointCircle,			-- done
	["point,aarect"]    = cdPointAARect,			-- done
	["point,ellipse"]   = cdPointEllipse,
	["point,polygon"]   = cdPointPolygon,

	["line","point"]	= cdPointLine,				-- swap
	["line,line"]       = cdLineLine,				-- done
	["line,circle"]     = cdLineCircle,				-- done
	["line,aarect"]     = cdLineAARect,				-- done
	["line,ellipse"]    = cdLineEllipse,
	["line,polygon"]    = cdLinePolygon,

	["circle","point"]	= cdPointCircle,			-- swap
	["circle","line"]	= cdLineCircle,				-- swap
	["circle,circle"]   = cdCircleCircle,			-- done
	["circle,aarect"]   = cdCircleAARect,			-- done
	["circle,ellipse"]  = cdCircleEllipse,
	["circle,polygon"]  = cdCirclePolygon,

	["aarect","point"]	= cdPointAARect,			-- swap
	["aarect","line"]	= cdLineAARect,				-- swap
	["aarect","circle"]	= cdCircleAARect,			-- swap
	["aarect,aarect"]   = cdAARectAARect,			-- done
	["aarect,ellipse"]  = cdAARectEllipse,
	["aarect,polygon"]  = cdAARectPolygon,

	["ellipse,ellipse"] = cdEllipseEllipse,
	["ellipse,polygon"] = cdEllipsePolygon,

	["polygon,polygon"] = cdPolygonPolygon,
}

--[[
	this module
--]]

local collision = {}

--[[
	members/methods (public)
--]]

-- these work on collision maps, not the "parent" entities.
collision.collide = function(object, other)
	local collided, pointEnter, pointExit
	local key = object.type .. ',' .. other.type
	if swapArguments(key) then
		collided, pointEnter, pointExit = test[key](other,object)
	else
		collided, pointEnter, pointExit = test[key](object,other)
	end

	-- to be resolved elsewhere
	return collided, pointEnter, pointExit
end

--[[
	return the module
--]]

return collision