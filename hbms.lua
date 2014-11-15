--[[
	HBMS - Generic Debug and Profiling Module (Heisen-Bohr-Mändel-Schrödinger)
	by zorg
	v1.0 @ 2014; license: isc
--]]

-- Description: This is where debugging and profiling functions reside.

--[[
Copyright (c) 2014, zorg <zorg@atw.hu>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--]]



--[[
	external modules
--]]

--local imap = require 'imap'
local mppg = require 'mppg'
local settings = require 'settings'

--[[
	localized love lib calls
--]]



--[[
	locals (private)
--]]

-- Debuggging related

local previousTime = 0
local printToConsole = true





--[[
	this module
--]]

local hbms = {}

--[[
	members/methods (public)
--]]

hbms.initialize = function()

	-- initialize previousTime variable
	previousTime = love.timer.getTime()

	-- If the debug log already exists, append a newline to it, if it's missing from the end.
	if love.filesystem.isFile('log.txt') then

		-- fast way to get the last two characters
		local data = love.filesystem.newFile('log.txt','r')
		data:open('r')
		data:seek(data:getSize()-1)
		local last = data:read(2)
		
		-- if it's not an empty line, add another newline char
		if last ~= '\n\n' then
			love.filesystem.append('log.txt', "\n")
		end

	end

	-- indicate session start in log file
	hbms.log("logging session begun @ " .. os.date("%c", os.time()) .. '\n')

	-- do some information dump of the system for reporting reasons
	hbms.log("OS: " .. love.system.getOS())
	hbms.log("CPU cores: " .. love.system.getProcessorCount())
	local state, percent, seconds = love.system.getPowerInfo()
	hbms.log("Power State: " .. state .. ((state ~= 'unknown' and state ~= 'nobattery' and percent and seconds) and percent .. "%, " .. seconds .. " seconds." or "") .. '\n')
	
	local name, version, vendor, device = love.graphics.getRendererInfo()
	hbms.log("Graphics Card: " .. device .. " by " .. vendor)
	hbms.log("Renderer: " .. name .. " version " .. version .. '\n')

	local displayCount = love.window.getDisplayCount()
	hbms.log("Total number of displays: " .. displayCount)
	for i=1, displayCount do
		local w,h = love.window.getDesktopDimensions(i)
		hbms.log(i .. ". display dimensions: " .. w .. ' x ' .. h .. (i == displayCount and '\n' or ''))
	end

	local username
	username = os.getenv("USERNAME") -- win
	username = username or os.getenv("USER") -- nix/osx
	username = username or os.getenv("LOGNAME") -- nix/osx
	username = username or os.getenv("$USERNAME") -- nix/osx
	username = username or os.getenv("$USER") -- nix/osx
	username = username or os.getenv("$LOGNAME") -- nix/osx

	hbms.log("Working Directory: " .. love.filesystem.getWorkingDirectory() .. '\n')
	hbms.log("User: " .. (username or "'undefined'"))
	hbms.log("User Directory: " .. love.filesystem.getUserDirectory())
	hbms.log("AppData Directory: " .. love.filesystem.getAppdataDirectory())
	hbms.log("Game Identity: " .. love.filesystem.getIdentity() .. '\n')
	hbms.log("Fused Game: " .. (love.filesystem.isFused() and 'yes' or 'no'))
	hbms.log("Save Directory: " .. love.filesystem.getSaveDirectory())

end

hbms.finalize = function()

	-- indicate session end in log file
	hbms.log("logging session ended @ " .. os.date("%c", os.time()))

end

-- Toggle whether logging prints to console or not
hbms.toggleLogToConsole = function()

	printToConsole = not printToConsole
	print("Console logging " .. printToConsole and "enabled." or "disabled.")

end

-- Append to log, with timestamp
hbms.log = function(text)

	-- use love's timer stuff because it's more precise than os.clock (albeit a tad slower, takes ~145% the time os.clock takes)
	local currentTime = love.timer.getTime()

	local delta = currentTime - previousTime
	delta = math.floor(delta * 1000000) / 1000000

	local pre,delimiter,post = string.match(("" .. delta), "(%d+)(%.+)(%d*)")
	-- fix positioning and missing trailing zeroes
	if string.len(pre) < 9 then
		for i=1, 9-pre:len() do
			pre = ' ' .. pre
		end
	end
	if string.len(post) < 6 then
		for i=1, 6-post:len() do
			post = post .. '0'
		end
	end
	delta = pre .. delimiter .. post

	-- Create/Open the log file, and append str to it as a line
	love.filesystem.append('log.txt', delta .. "	: " .. text .. "\n")

	-- Print it to the console, if that flag is set
	if printToConsole then
		print(delta .. " : " .. text)
	end
end

-- simple profiling to test code snippets' execution time
hbms.benchmark = function(iterations, code)

	-- we can't use asserts when the error message is a function, since it will always be evaluated before the function itself
	if type(iterations) ~= 'number' then
		hbms.log("error:	hbms.benchmark iterations parameter must be a number")
	end
	if iterations <= 0 or iterations % 1 ~= 0 then
		hbms.log("error:	hbms.benchmark iterations parameter must be a positive integer")
	end
	if type(code) ~= 'function' then
		hbms.log("error:	hbms.benchmark iterations parameter must be a function")
	end

	local osClock, loveClock

	osClock, loveClock = os.clock(), love.timer.getTime()

	for i=1,iterations do
		code()
	end
	hbms.log("benchmark:	" .. (os.clock()-osClock), ('/' .. (love.timer.getTime()-loveClock)))

end

-- performance graph related functions

-- fuck it, just alias it to a member
hbms.graph = mppg

-- system requirements related functions

hbms.checkCompatibility = function()

	-- if value is boolean, convert to either -inf or inf, so we can compare

	local sr = settings.getSettings('systemRequirements')

	-- limits
	local maxPointSize = love.graphics.getSystemLimit('pointsize')
	local minPointSize = type(sr.minPointSize) == 'number' and sr.minPointSize or ((type(sr.minPointSize) == 'boolean' and sr.minPointSize) and (1/0) or -(1/0))
	if minPointSize > maxPointSize then
		hbms.log("error:	point size needed (".. sr.minPointSize ..") is not supported")
		return false
	end

	local maxTextureSize = love.graphics.getSystemLimit('texturesize')
	local minTextureSize = type(sr.minTextureSize) == 'number' and sr.minTextureSize or ((type(sr.minTextureSize) == 'boolean' and sr.minTextureSize) and (1/0) or -(1/0))
	if minTextureSize > maxTextureSize then
		hbms.log("error:	texture size needed (".. sr.minTextureSize ..") is not supported")
		return false
	end

	local maxActiveCanvases = love.graphics.getSystemLimit('multicanvas')
	local minActiveCanvases = type(sr.minActiveCanvases) == 'number' and sr.minActiveCanvases or ((type(sr.minActiveCanvases) == 'boolean' and sr.minActiveCanvases) and (1/0) or -(1/0))
	if minActiveCanvases > maxActiveCanvases then
		hbms.log("error:	needed number of simultaneously active canvases not supported")
		return false
	end

	local maxCanvasAntialiasSamples = love.graphics.getSystemLimit('canvasfsaa')
	local minCanvasAntialiasSamples = type(sr.minCanvasAntialiasSamples) == 'number' and sr.minCanvasAntialiasSamples or ((type(sr.minCanvasAntialiasSamples) == 'boolean' and sr.minCanvasAntialiasSamples) and (1/0) or -(1/0))
	if minCanvasAntialiasSamples > maxCanvasAntialiasSamples then
		hbms.log("error:	needed antialias samples not supported")
		return false
	end

	-- features

	-- supported needed result -> not supported and needed

	-- Supported on nearly every system / gpu

	if not love.graphics.isSupported('subtractive') and sr.subtractive then
		hbms.log("error:	subtractive blend mode needed, but not supported")
		return false
	end

	if not love.graphics.isSupported('mipmap') and sr.mipmap then
		hbms.log("error:	mip-mapping needed, but not supported")
		return false
	end
	
	if not love.graphics.isSupported('dxt') and sr.dxt then
		hbms.log("error:	dxt format not supported")
		return false
	end

	-- Supported on systems having at least a DX9.0c+ capable GPU with OpenGL 2.1+ drivers

	if not love.graphics.isSupported('canvas') and sr.canvas then
		hbms.log("error:	canvas needed, but not supported")
		return false
	end

	if not love.graphics.isSupported('multicanvas') and sr.multicanvas then
		hbms.log("error:	multiple active canvases needed, but not supported")
		return false
	end
	
	if not love.graphics.isSupported('npot') and sr.npot then
		hbms.log("error:	non-power of two textures needed, but not supported") -- wasn't it stated that this is moot now?
		return false
	end

	if not love.graphics.isSupported('shader') and sr.shader then
		hbms.log("error:	shaders not supported")
		return false
	end

	-- Supported on systems having at least a DX10+ capable GPU with OpenGL 3+ drivers

	if not love.graphics.isSupported('hdrcanvas') and sr.hdrcanvas then
		hbms.log("error:	HDR canvas needed, but not supported")
		return false
	end

	if not love.graphics.isSupported('srgb') and sr.srgb then
		hbms.log("error:	gamma-correct sRGB needed, but not supported")
		return false
	end

	if not love.graphics.isSupported('bc5') and sr.bc5 then
		hbms.log("error:	bc5 format not supported")
		return false
	end

	-- passed all the tests
	return true

end

--[[
	Return the module
--]]

return (function() hbms.initialize() return hbms end)()