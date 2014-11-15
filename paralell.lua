--[[
	serialization module
	by zorg
	v1.0 @ 2014; license: isc
--]]

-- Description: Handles file io and folder structure shenanigans.

--[[
Copyright (c) 2014, zorg <zorg@atw.hu>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--]]



--[[
	external modules
--]]

local log = require('hbms').log
local ser = require 'src.lib.gvx.ser'
local bb = require 'bb'

--[[
	localized love lib calls
--]]



--[[
	locals (private)
--]]



--[[
	this module
--]]

local serial = {}

--[[
	members/methods (public)
--]]

-- If the user folder doesn't have subfolders made yet, create them
serial.initUserFolderStructure = function()
	-- Highscore files
	if not love.filesystem.isDirectory('hsc') then
		love.filesystem.createDirectory('hsc')
		log('notice:	folder /HSC created')
	else
		log('notice:	folder /HSC already exists')
	end
	-- Settings files
	if not love.filesystem.isDirectory('ini') then
		love.filesystem.createDirectory('ini')
		log('notice:	folder /INI created')
	else
		log('notice:	folder /INI already exists')
	end
	-- Logs
	if not love.filesystem.isDirectory('log') then
		love.filesystem.createDirectory('log')
		log('notice:	folder /LOG created')
	else
		log('notice:	folder /LOG already exists')
	end
	-- Languages (i18n/l10n)
	if not love.filesystem.isDirectory('lng') then
		love.filesystem.createDirectory('lng')
		log('notice:	folder /LNG created')
	else
		log('notice:	folder /LNG already exists')
	end
	-- Game modifications
	if not love.filesystem.isDirectory('mod') then
		love.filesystem.createDirectory('mod')
		log('notice:	folder /MOD created')
	else
		log('notice:	folder /MOD already exists')
	end
	-- Recorded animation sequences
	if not love.filesystem.isDirectory('mov') then
		love.filesystem.createDirectory('mov')
		log('notice:	folder /MOV created')
	else
		log('notice:	folder /MOV already exists')
	end
	-- Replay files
	if not love.filesystem.isDirectory('rpl') then
		love.filesystem.createDirectory('rpl')
		log('notice:	folder /RPL created')
	else
		log('notice:	folder /RPL already exists')
	end
	-- Save files
	if not love.filesystem.isDirectory('sav') then
		love.filesystem.createDirectory('sav')
		log('notice:	folder /SAV created')
	else
		log('notice:	folder /SAV already exists')
	end
	-- Screenshots
	if not love.filesystem.isDirectory('scr') then
		love.filesystem.createDirectory('scr')
		log('notice:	folder /SCR created')
	else
		log('notice:	folder /SCR already exists')
	end
end

-- Ser hooks

serial.export = function(t,path,file,mode,enc)
	local s = ser(t)
	if enc then s = bb:encode(s) end
	local b, e
	if mode == 'a' then
		b, e = love.filesystem.append(path..file,s)
	else
		if not (mode == 'o') then
			if love.filesystem.exists(path..file) then
				log('error:	file "'.. path..file ..'" already exist!, can\'t overwrite!')
				return false
			end
		b = love.filesystem.write(path..file,s)
		end
	end
	if not b then
		log('error:	exporting to "' .. path..file .. '" failed: ' .. tostring(e))
		return false
	end
	return true
end

serial.import = function(path,file,dec)
	local b, c, r
	b, c = pcall(love.filesystem.load, path..file)
	if not b then
		log('error:	file"' .. path..file .. '" could not be loaded: ' .. tostring(c))
		return false
	else
		if dec then c = bb:decode(s) end
		b, r = pcall(c)
		if not b then 
			log('error:	the loaded chunk could not be executed: ' .. tostring(r))
			return false
		end
		return b
	end
end

--[[
	Return the module
--]]

return serial