--[[
	utility module
	by zorg
	v1.0 @ 2014; license: isc
--]]

-- Description: All the extra utils one might need for coding included here, categorized.
--				If a game doesn't need something from here, feel free to comment it out.

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

local function calcPolygonSignedArea(mesh)
	local A = 0
	local n = #mesh
	for i=1, n do
		A = A + (mesh[i].x * mesh[(i%n)+1].y - mesh[(i%n)+1].x * mesh[i].y)
	end
	return 0.5 * A
end

local function getPolygonCentroid(mesh)
	-- Asserts regarding polygon being closed and non-self-intersecting left as excercise to the reader :3
	local A = calcPolygonSignedArea(mesh)
	local Cx = 0
	local Cy = 0
	local n = #mesh
	for i=1, n do
		Cx = Cx + ((mesh[i].x + mesh[(i%n)+1].x) * (mesh[i].x * mesh[(i%n)+1].y - mesh[(i%n)+1].x * mesh[i].y))
	end
	for i=1, n do
		Cy = Cy + ((mesh[i].y + mesh[(i%n)+1].y) * (mesh[i].x * mesh[(i%n)+1].y - mesh[(i%n)+1].x * mesh[i].y))
	end
	Cx = 1/(6*A) * Cx
	Cy = 1/(6*A) * Cy
	return Cx, Cy
end

-- Motion Blur -> NewFrame = OldFrame * a + ThisFrame * (1-a) -- or, both this and my old method of more than 1 old frame.

--[[
	this module
--]]



--[[
	members/methods (public)
--]]



--[[
	Return the module
--]]

return 