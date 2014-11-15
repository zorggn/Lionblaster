--[[
	Bomberman ingame test project
	Main
	by zorg @ 2014
--]]

-- Protips (LuaJIT optimizations):
-- localize whole modules, not individual methods
-- # is slow, save the value somewhere, and use that instead
-- table.unpack is slow, unpack tables with [] instead
-- math.max and math.min are slow, use conditionals and <,> instead
-- and-or short-circuiting is a bit faster than nil-checking
-- x*x (n times) is a bit faster than vs x^n
-- % is a lot faster than math.fmod (but fmod return negative for negative numbers, % returns positive)
-- function parameters and locals defined outside that function in the same scope have about the same speed...
--     but param ones are created dynamically so they will be slower if called many times.
-- loop speed order for array-like table: ipairs < # < localized # << pairs < for i=1,constant
-- making a table's members local instead of direct access does not give a speedup
-- insert speed order for array-like table: t[i] < t[ctr++] << table.insert(t,i) < t[#t+1]
-- creating a table with placeholder array values {true,...} before assigning stuff to it is EXTREMELY FASTER than creating an empty local,
--     since no extra one-by-one allocation overhead; it will be pre-allocated :3

-- For the net part:
-- "Cull" messages to clients that are outside select others' viewports, unless they are designated as global.

-- TODO:
-- Put code in its place...
-- Console - one global override key; when that's pressed, all input is redirected to the console; idea: push it as a gamestate.
-- GameStates - put everything into its own state -> less separate modules, more states -> better structure.
-- If more than one state needs to access/modify something, that's a separate module.

-------------------------------------------------------------------------------------------------------------------------------------------

-- Load in the settings module
settings = require 'settings'

-- The custom game loop
love.run = require 'game_loop'



-- load in necessary libraries, and then switch to a gamestate.
love.load = function(args)

	-- debug module
	hbms = require 'hbms'

	-- input state and mapper module
	imap = require 'imap'

	-- gamestates module
	state = require 'src.lib.vrld.hump.gamestate'

	testState = require 'src.gst.test' -- TODO: give these a metatable, with empty callbacks so it won't error on undefined calls.

	state.switch(testState)

end

local function __NULL__() end

love.update = function(dt)
	
	local current = state.current()
	;(current.update or __NULL__)(current,dt)

	imap.update(dt)

end

love.draw = function(lerp,dt)

	love.graphics.print("Average Delta:", 0, 36)
	love.graphics.print("Delta:", 0, 48)
	love.graphics.print("FPS:", 0, 60)
	love.graphics.print("Current State:", 0, 72)

	love.graphics.print(love.timer.getAverageDelta(), 100, 36)
	love.graphics.print(love.timer.getDelta(), 100, 48)
	love.graphics.print(love.timer.getFPS(), 100, 60)
	love.graphics.print(tostring(state.current().name), 100, 72)

	-- Render everything to a canvas
	
	local current = state.current()
	;(current.draw or __NULL__)(current,lerp,dt)

	-- Draw tiling background

	-- Draw canvas over background

	-- If enabled, draw the console on top of everything <- should be just state.push instead, and the console's code calling the previous
	-- state's draw above.

end

love.keypressed = function(key)

	local key = key

	-- if the console key was pushed, toggle it

	imap.keypressed(key,isrepeat)

	-- temporary exit button
	if key == 'escape' then love.quit() end

	local current = state.current()
	;(current.keypressed or __NULL__)(current,key)

end

love.keyreleased = function(key)

	imap.keyreleased(key)

end

love.joystickaxis = function(joystick, axis, value)
	imap.joystickaxis(joystick,axis,value)
end

love.joystickhat = function(joystick, hat, direction)
	imap.joystickhat(joystick, hat, direction)
end

love.joystickpressed = function(joystick,button)
	imap.joystickpressed(joystick,button)
end

love.joystickadded = function(joystick)
	imap.joystickadded(joystick)
end

love.resize = function(w,h)
	
	-- we're only scaling our main canvas, nothing else.

end

love.quit = function()

	local r

	local current = state.current()
	r = (current.quit or __NULL__)(current)

	-- abort quitting
	if r then return true end

	-- disable quitting on the preloader
	-- if state.current().name == 'preloader' then return true end

	-- ...

	-- close things

	--imap.finalize()

	hbms.finalize()

end