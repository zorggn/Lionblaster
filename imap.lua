--[[
	input map and state module
	by zorg
	v1.0 @ 2014; license: isc
--]]

-- Description: This module stores the input states, and one can either set callbacks to the given functions, or test for specific states themselves.
--              Users should not use love's key/mouse/joystick pressed/released and isDown and related functions at all, since this already handles them.

--[[
Copyright (c) 2014, zorg <zorg@atw.hu>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--]]

-- TODO: Encapsulate stuff to Keyboard, Mouse and Joystick objects for clearer code.

--[[
	external modules
--]]

local log = require('hbms').log
local paralell = require 'paralell'

--[[
	localized love lib calls
--]]



--[[
	locals (private)
--]]

--[[
-- keyboard, mouse and joystick constants used by LOVE (with a few extras).

local mouseConstants =		{
	'l','m','r','wd','wu','x1','x2',	-- mouse buttons
	'a',								-- mouse axes
}

local keyConstants =		{
	'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',
	'0','1','2','3','4','5','6','7','8','9',
	' ','!','"','#','$','&',"'",'(',')','*','+',',','-','.','/',':',';','<','=','>','?','@','[','\\',']','^','_','`',
	'kp0','kp1','kp2','kp3','kp4','kp5','kp6','kp7','kp8','kp9','kp.','kp,','kp/','kp*','kp-','kp+','kpenter','kp=',
	'up','down','left','right','home','end','pageup','pagedown',
	'insert','backspace','tab','clear','return','delete',
	'f1','f2','f3','f4','f5','f6','f7','f8','f9','f10','f11','f12','f13','f14','f15','f16','f17','f18',
	'numlock','capslock','scrolllock','lshift','rshift','lctrl','rctrl','lalt','ralt','lgui','rgui','mode',
	'pause','escape','help','printscreen','sysreq','menu','application','power','currencyunit','undo',
	'www','mail','calculator','computer','appsearch','apphome','appback','appforward','apprefresh','appbookmarks',
	'unknown', -- all other keys return this with keypressed;
}

local joystickConstants =	{
	'a',										-- denotes an analog axis, may be a stick or a trigger or anything
	'b',										-- a digital button, with two distinct states
	'c','u','d','l','r','lu','ld','ru','rd',	-- hat positions
}

--[
-- Hack, because i am 100% certain i will not type out these by hand.
local reverseLookups
function reverseLookups()
	local t = {}
	for i,k in ipairs(mouseConstants) do
		t[k] = true
	end
	mouseConstants = t

	t = {}
	for i,k in ipairs(keyConstants) do
		t[k] = true
	end
	keyConstants = t

	t = {}
	for i,k in ipairs(joystickConstants) do
		t[k] = true
	end
	joystickConstants = t
	reverseLookups = nil
end
reverseLookups()
--]]



-- physical controllers, and their data are stored here; serialized.

local controllers = {}

-- return the ordinal where the joystick is in
local reverseLookup = function(joystick)
	for i,v in ipairs(controllers) do
		if v.id == joystick:getID() then
			return i
		end
	end
	return false
end

-- mappings are stored here; e.g. for two playable characters, one has two separate maps; serialized.

local maps = {}

--[[
	this module
--]]

local imap = {}

--[[
	members/methods (public)
--]]

-- serialization

imap.import = function()
	local t
	-- import the controllers we have used previously
	t = paralell.import('ini','controllers.lua')
	if t then
		controllers = t
	end
	-- import the mappings we have used previously
	t = paralell.import('ini','mappings.lua')
	if t then
		maps = t
	end
end

imap.export = function()
	-- export the controllers we have used previously (without the joystick object and the connected boolean)
	local t = {}
	for i,v in ipairs(controllers) do
		t[i] = {}
		t[i].id = v.id
		t[i].guid = v.guid
		t[i].name = v.name
	end
	paralell.export(t,'ini','controllers.lua','o')
	-- export the mappings we have used previously
	paralell.export(maps,'ini','mappings.lua','o')
end

-- called from love.load, so joystickadded was not yet called for every already-connected controller.
imap.initialize = function()
	-- check whether the keyboard, mouse or joystick modules are enabled in conf.lua or not.
	if not love.keyboard then log("warning:	love.keyboard module not enabled!") end
	if not love.mouse    then log("warning:	love.mouse module not enabled!")	end
	if not love.joystick then log("warning:	love.joystick module not enabled!") end
	
	-- load in settings, if extant, from the user's save folder
	imap.import()

	-- remap joysticks based on os-dependant guid (handled in imap.joystickadded)
end

imap.finalize = function()
	-- save settings to the user's save folder
	imap.export()
end

-- controller detection

imap.joystickadded = function(joystick)
	-- this id is the same for the lifetime of the -game-, so it's perfect to detect plugged/unplugged controllers.
	local id = joystick:getID()
	local os = love.system.getOS()
	local guid = joystick:getGUID()
	local name = joystick:getName()

	for i,v in ipairs(controllers) do
		if v.id == id then
			-- the controller was disconnected, but it already exists in the table.
			v.connected = true
			return
		elseif (v.guid[os] == guid or v.name == name) and not v.connected then
			-- assign the controller to the first fitting slot, preferrably by guid, not by name.
			v.joystick = joystick
			v.connected = true
			return
		end
	end

	-- make a new controller object, since we didn't find any extant that fit the one connected.
	local t = {}
	t.joystick = joystick
	t.id = id
	t.guid = {}
	t.guid[os] = guid
	t.name = name
	t.connected = true
	controllers[#controllers+1] = t

	print(t.name, t.guid[os], t.connected, t.id)
end

imap.joystickremoved = function(joystick)
	-- set the controller's state to disconnected
	local id = joystick:getID()
	for i,v in ipairs(controllers) do
		if v.id == id then
			v.connected = false
			return
		end
	end
end

-- map methods

imap.newMap = function(name)
	-- return early if map already exists.
	if maps[name] then return false end

	local map = {}
	-- integer keys hold the mappings, with {name, device, control, id} settable fields.
	map.n = 0

	-- callbacks
	map.isPressed =  function(name, amount) end
	map.isHeld =     function(name, amount) end
	map.isReleased = function(name) end
	map.isFree =     function(name) end

	map.setMapping = imap.setMapping

	maps[name] = map

	return maps[name]
end

imap.delMap = function(name)
	-- return early if map doesn't exist
	if not maps[name] then return false end

	maps[name] = nil

	return true
end

-- getter/setter

imap.setMapping = function(map,name,device,control,id)
	assert(map ~= nil)

	local n = map.n
	-- if the mapping exists, and device, control, id are all nil, then unset the mapping
	local m = false
	for i=1, n do
		if map[i].name == name then
			m = i
			break
		end
	end
	if m then
		if map.name and device == nil and control == nil and id == nil then
			-- nil the table; move references back one.
			for i=m, n-1 do
				map[i] = map[i+1]
			end
			map[n] = nil

			return true
		else
			-- return since we can't delete a nonexistent table, nor create one with no map
			return false
		end
	end

	-- (re-)define the mapping
	local t = {}

	t.name = name
	t.device = device
	t.control = control
	t.id = id
	t.state = 4 -- timba, at rest

	n = n + 1
	map[n] = t
	map.n = n

	return true
end

imap.getMapping = function(map,name)
	assert(map ~= nil)
	
	local n = map.n
	local m = false

	for i=1,n do
		if map[i].name == name then
			m = i
			break
		end
	end
	if m then
		return map[m].device, map[m].control, map[m].id -- device, control, id
	else
		return 
	end
end

-- callback hooks

imap.keypressed = function(key,isrepeat) -- string
	if isrepeat then return end
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == 'k' and v.control == key then
				print(i,v.device,v.control,tostring(v.id))
				-- set it to pressed if it was not held
				if v.state ~= 2 then v.state = 1 end
				-- execute callback
				w.isPressed(v.name,1.0)
			end
		end
	end
end

imap.keyreleased = function(key) -- string
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == 'k' and v.control == key then
				-- set it to released, if it was not free
				if v.state ~= 4 then v.state = 3 end
				-- execute callback
				w.isReleased(v.name)
			end
		end
	end
end

imap.mousepressed = function(x,y,button) -- number, number, string
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == 'm' then
				if v.control == 'a' then
					-- axes
					v.dx = x - (v.x or x)
					v.dy = -(y - (v.y or y)) -- coordinate system is inverted on the y axis
					-- state
					if v.dx ~= 0 or v.dy ~= 0 then
						if v.state ~= 2 then v.state = 1 end
						-- execute callback
						w.isPressed(v.name,math.atan2(v.dx,v.dy))
					else
						if v.state ~= 4 then v.state = 3 end
						-- execute callback
						w.isReleased(v.name)
					end
					-- assign new values after callback
					v.x = x
					v.y = y
				elseif v.control == button then
					--buttons
					if v.state ~= 2 then v.state = 1 end
					-- execute callback
					w.isPressed(v.name,1.0)
					-- HACK: since the mouse wheel actions don't generate released messages, call those after 1 update tick.
					if v.control == 'wd' or v.control == 'wu' then
						v._timeout = 2
					end
				end
			end
		end
	end

end

imap.mousereleased = function(x,y,button) -- number, number, string
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == 'm' then
				if v.control == 'a' then
					-- axes
					v.dx = x - (v.x or x)
					v.dy = -(y - (v.y or y)) -- coordinate system is inverted on the y axis
					-- state
					if v.dx ~= 0 or v.dy ~= 0 then
						if v.state ~= 2 then v.state = 1 end
						-- execute callback
						w.isPressed(v.name,math.atan2(v.dx,v.dy))
					else
						if v.state ~= 4 then v.state = 3 end
						-- execute callback
						w.isReleased(v.name)
					end
					-- assign new values after callback
					v.x = x
					v.y = y
				elseif v.control == button then -- note: never gets called with 'wd' and 'wu'; hack above and below.
					-- buttons
					if v.state ~= 4 then v.state = 3 end
					-- execute callback
					w.isReleased(v.name)
				end
			end
		end
	end
end

imap.joystickpressed = function(joystick,button) -- Joystick, number
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == reverseLookup(joystick) then
				if v.control == 'b' and v.id == button then
					-- button
					if v.state ~= 2 then v.state = 1 end
					-- execute callback
					w.isPressed(v.name,1.0)
				end 
			end
		end
	end
end

imap.joystickreleased = function(joystick,button) -- Joystick, number
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == reverseLookup(joystick) then
				if v.control == 'b' and v.id == button then
					-- button
					if v.state ~= 4 then v.state = 3 end
					-- execute callback
					w.isReleased(v.name)
				end 
			end
		end
	end
end

imap.joystickhat = function(joystick,hat,direction) -- Joystick, number, string
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == reverseLookup(joystick) then
				if v.control == direction and v.id == hat then
					-- hat
					if direction ~= 'c' then
						if v.state ~= 2 then v.state = 1 end
						-- execute callback
						w.isPressed(v.name,1.0) 
					else
						if v.state ~= 4 then v.state = 3 end
						-- execute callback
						w.isReleased(v.name)
					end
				end
			end
		end
	end
end

imap.joystickaxis = function(joystick,axis,value) -- Joystick, number, number
	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == reverseLookup(joystick) then
				if v.control == 'a' and v.id == axis then
					--axis
					v.dv = value - (v.v or value)
					-- state
					if value ~= 0 then
						if v.v and v.v == 0 then
							if v.state ~= 2 then v.state = 1 end
							-- execute callback
							w.isPressed(v.name,value)
						elseif v.v and v.v ~= 0 then
							v.state = 2
							w.isHeld(v.name,value)
						end
					elseif value == 0 then
						if v.v and v.v ~= 0 then
							if v.state ~= 4 then v.state = 3 end
							-- execute callback
							w.isReleased(v.name)
						elseif v.v and v.v == 0 then
							v.state = 4
							w.isFree(v.name)
						end
					end
					-- assign new value after callback
					v.v = value
				end 
			end
		end
	end
end

-- goes at the end of the update callback!
imap.update = function(dt)

	for k,w in pairs(maps) do
		for i,v in ipairs(w) do
			if v.device == 'k' then
				-- keyboard part
				if love.keyboard.isDown(v.control) then
					if v.state == 1 then v.state = 2 end
					-- execute callback
					w.isHeld(v.name,1.0)
				else
					if v.state == 3 then v.state = 4 end
					-- execute callback
					w.isFree(v.name)
				end
			elseif v.device == 'm' then
				-- mouse part
				if v.control == 'a' then
					-- axes
					local x = love.mouse.getX()
					local y = love.mouse.getY()
					v.dx = x - (v.x or x)
					v.dy = -(y - (v.y or y)) -- coordinate system is inverted on the y axis
					-- execute callback - isFree if the mouse hasn't moved
					if v.dx ~= 0 or v.dy ~= 0 then
						v.state = 2
						w.isHeld(v.name,math.atan2(v.dx,v.dy))
					else
						v.state = 4
						w.isFree(v.name)
					end
					-- assign new values after callback
					v.x = x
					v.y = y
				elseif v.control == 'wd' or v.control == 'wu' then
					-- special case for mouse wheel
					if v._timeout == 2 then
						w.isHeld(v.name,1.0)
						v._timeout = 1
						break
					elseif v._timeout == 1 then
						w.isReleased(v.name)
						v._timeout = 0
						break
					else
						w.
						w.isFree(v.name)
					end
				else
					-- buttons
					if v.state == 1 then
						v.state = 2
						w.isHeld(v.name,1.0)
					elseif v.state == 3 then
						v.state = 4
						w.isFree(v.name)
					end
				end
				--[[
				loop through all joysticks, and call their :getAxis, :getHat and :isDown methods
			elseif v.device == reverseLookup(joystick) then
				-- joystick part
				-- no axis testing in here <- um, yes there is.
				if v.control == 'b' and v.id == button then
					-- button
					if v.state == 1 then
						v.state = 2
						w.isHeld(v.name,1.0)
					elseif v.state == 3 then
						v.state = 4
						w.isFree(v.name)
					end
				elseif v.control ~= 'a' and v.control ~= 'b' then
					-- hat
					if v.control == 'c' then
						if v.state == 3 then v.state = 4 end
						w.isFree(v.name)
					else
						if v.state == 1 then v.state = 2 end
						w.isHeld(v.name,1.0)
					end
				end
				--]]
			end
		end
	end
end



--[[
	Return the module (with auto-initialization)
--]]

return (function() imap.initialize() return imap end)()