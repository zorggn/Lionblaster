--[[
	settings module
	by zorg
	v1.0 @ 2014; license: isc
--]]

-- Description: This is where the game and user settings are stored along with the system requirements.

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

-- System Requirements
-- If something here fails an assertion when checking, then the game can't run correctly on the current computer; false means not required / don't care.

local systemRequirements = {

	-- minimum client area dimensions; gb/c: 160x144; gba: 240x160; nes: 256x240(224); snes: 256/512x224/239
	minViewportWidth			= 256,
	minViewportHeight			= 224,
	-- maximum client area dimensions; in the usual case, this should be equal to the above set values, unless for games like OpenTTD. (=math.huge)
	maxViewportWidth			= math.huge,
	maxViewportHeight			= math.huge,
	-- minimum window dimensions; the one in conf lua doesn't count, since at the setMode call, these values will be used instead.
	minWindowWidth				= 256,
	minWindowHeight				= 224,
	-- maximum window dimensions; leave at math.huge for unlimited, or equal to the above for logically non-resizable.
	maxWindowWidth				= math.huge,
	maxWindowHeight				= math.huge,
	-- the per-axis positive/negative scaling options: tile, box, stretch, none, crop
	vxLtwx						= '',
	vyLtwy						= '',
	vxGtwx						= 'box',
	vyGtwy						= 'box',
	-- the alignments of the viewport inside the window; this also sets the anchors to either 0, length/2 or length.
	xAlignment						= 'left', -- left, center, right
	yAlignment						= 'top', -- top, middle, bottom


	-- graphic limits
	minPointSize				= false,
	minTextureSize				= 2048,
	minActiveCanvases			= 1, -- keyword: active, as in simultaneously; one should be supported at least.
	minCanvasAntialiasSamples	= false,
	-- graphic features
	canvas						= true,
	multicanvas					= false,
	hdrcanvas					= false,
	srgb						= false,
	npot						= true,
	subtractive					= true,
	shader						= false,
	mipmap						= false,
	dxt							= false,
	bc5							= false

}

-- Game Settings
-- Game data modifiable by the user can be stored here.

local gameSettings = {
	-- in px; the dimensions of the window the user will see through.
	windowWidth =	256,
	windowHeight =	224,

	-- in FPS; the limit of how many frames to render in one second
	maxFrameRate = 75,
	_maxFrameInterval = 1 / 75, -- 0,013.

	-- in TPS; the fixed time step used for updating the game; USERS SHOULD NOT EDIT THIS VALUE!
	tickRate = 60,--25,
	_tickInterval = 1 / 60, -- 0,016.

	-- in PPS; the rate the client sends packets to the server (includes frame indices, so hopefully no desync issues with this)
	clientPacketRate = 4,

	-- the maximum number of skippable render frames
	maxFrameSkip = 3,

	-- input mapping - maybe these should be stored in the imap module instead? or better yet, don't store separately just import/export directly!
	-- k - keyboard, m - mouse, 1-n - joysticks ; key / hat (c,d,l,ld,lu,r,rd,ru,u) / axis ([xyz][ +-]) / button ; controlid
	inputMap = {

		[0] = {
			Console =	{'k','0'},
			Console =	{'k','`'},
		},

		[1] = {
			Up =		{'k','up'},
			Down =		{'k','down'},
			Left =		{'k','left'},
			Right =		{'k','right'},
			Shot =		{'k','x'},
			Bomb =		{'k','y'},
			Focus =		{'k','lshift'},
			Select =	{'k',' '},
			Start =		{'k','enter'},
		},

		[2] = {
			Up =		{'m','y-'},
			Down =		{'m','y+'},
			Left =		{'m','x-'},
			Right =		{'m','x+'},
			Shot =		{'m','l'},
			Bomb =		{'m','m'},
			Focus = 	{'m','r'},
			Select =	{'m','x1'},
			Start =		{'m','x2'},
		},

		[3] = {
			Up =		{1,'u',1},
			Up =		{1,'lu',1},
			Up =		{1,'ru',1},
			Down =		{1,'d',1},
			Down =		{1,'ld',1},
			Down =		{1,'rd',1},
			Left =		{1,'l',1},
			Left =		{1,'lu',1},
			Left =		{1,'ld',1},
			Right =		{1,'r',1},
			Right =		{1,'ru',1},
			Right =		{1,'rd',1},
			Shot =		{1,'b',1},
			Bomb =		{1,'b',3},
			Focus = 	{1,'b',8},
			Select =	{1,'b',5},
			Start =		{1,'b',6},
		},
	}
}

-- User Settings
-- If the game is such, user data can be stored here.

local userSettings = {
	


}

--[[
	this module
--]]

local settings = {}

--[[
	members/methods (public)
--]]

settings.getSettings = function(group)
	if group == 'systemRequirements' then
		return systemRequirements
	elseif group == 'gameSettings' then
		return gameSettings
	elseif group == 'userSettings' then
		return userSettings
	end
end

settings.setSettings = function(group,setting,value)
	if group == 'systemRequirements' or group == 'gameSettings' or group == 'userSettings' then
		if group[setting] then
			group[setting] = value
		end
	end
end

--[[
	Return the module
--]]

return settings