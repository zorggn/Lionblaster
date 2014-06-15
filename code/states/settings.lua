-- Lionblaster Settings State
-- by zorg
-- @2014

local state = {}

-- player
-- 0 name				________________ (16 chars max, spaces will be empty)
-- - skin
-- -  1 eyestyle		1  2  3  4  5  6
-- -  2 outline			Rx00 Gx00 Bx00 Ax00
-- -  3 pom-pom			Rx00 Gx00 Bx00 Ax00
-- -  4 hood			Rx00 Gx00 Bx00 Ax00
-- -  5 skin tone		Rx00 Gx00 Bx00 Ax00
-- -  6 arms			Rx00 Gx00 Bx00 Ax00
-- -  7 robe			Rx00 Gx00 Bx00 Ax00
-- -  8 belt			Rx00 Gx00 Bx00 Ax00
-- -  9 b. buckle		Rx00 Gx00 Bx00 Ax00
-- - 10 gloves			Rx00 Gx00 Bx00 Ax00
-- - 11 legs			Rx00 Gx00 Bx00 Ax00
-- - 12 shoes			Rx00 Gx00 Bx00 Ax00

-- graphics
-- 13 scale				1x   2x   3x   4x
-- 14 shader				<name>

-- audio
-- 15 bgm				- - - - - - - - - -
-- 16 sfx				- - - - - - - - - -

-- controls
-- 17 redefine controls

--
-- 18 back

-- 19 options in total
-- u/d moves between them, skipping categories (those get highlighted a bit as well...)
-- l/r selects sub-settings (or increases/decreases a setting, if not an RGBA option is selected)
-- a increases a setting (or goes into control redefinition state)
-- b decreases a setting (or does nothing when over control redefinition option)

-- Note: beware of mixed 0 and 1 based indices in the below code! (unusually more than usual inbound...)


function state:quit()

	appendLog("GameState	: settings.quit")

	-- don't quit, go back to title screen
	self.destination = Lionblaster.InstanceData.GameStates.Title
	self.subState = 'fadeout'
	return true
end

function state:init()

	appendLog("GameState	: settings.init")

	self.subState = 'init'
	self.destination = false

	-- set transition vars
	self.transitions = {}

	self.transitions.initialColor =	{  0,  0,  0,  0}
	self.transitions.fadeInColor =	{ 81,113,211,255} -- color to fade into
	self.transitions.fadeOutColor =	{  0,  0,  0,  0} -- color to fade out to
	self.transitions.fadeInTime =	0.5 -- seconds
	self.transitions.fadeOutTime =	0.5 -- seconds

	-- set other stuff

	self.spriteSheet = Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets[1]
	self.spriteQuad = love.graphics.newQuad(0, 0, 32, 32, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
	self.spriteFrames = (self.spriteSheet:getWidth() / 32)
	self.spriteCurrent = 0
	self.changedSkin = false

	self.stringToTable = function(s)
		local t = {}
		s:gsub(".",function(c) table.insert(t,string.upper(c)) end)
		return t
	end
	self.tableToString = function(t)
		local s = ''
		for _, v in ipairs(t) do
			s = s .. string.upper(v)
		end
		return s
	end

	self.map = {
		'A','B','C','D','E','F','G','H','I','J','K','L','M',
		'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
		'1','2','3','4','5','6','7','8','9','0','_','-'
	}
	self.map[0] = ' ' -- because modulo liek 0-based indices more

	self.reverseMap = {
		['A'] =  1, ['B'] =  2, ['C'] =  3, ['D'] =  4, ['E'] =  5, ['F'] =  6, ['G'] =  7, ['H'] =  8, ['I'] =  9, ['J'] = 10, ['K'] = 11, ['L'] = 12, ['M'] = 13, 
		['N'] = 14, ['O'] = 15, ['P'] = 16, ['Q'] = 17, ['R'] = 18, ['S'] = 19, ['T'] = 20, ['U'] = 21, ['V'] = 22, ['W'] = 23, ['X'] = 24, ['Y'] = 25, ['Z'] = 26, 
		['1'] = 27, ['2'] = 28, ['3'] = 29, ['4'] = 30, ['5'] = 31, ['6'] = 32, ['7'] = 33, ['8'] = 34, ['9'] = 35, ['0'] = 36, ['_'] = 37, ['-'] = 38, [' '] =  0,
	}

	-----------------------------------

	self.menu = {}

	self.menu.active = 0

	self.menu[0] = {}
	self.menu[0].active = false
	self.menu[0].text = 'Name'

	self.menu[0].value = self.stringToTable(Lionblaster.PersistentData.User.name)
	for i=1, #self.menu[0].value do self.menu[0].value[i] = self.map[self.reverseMap[self.menu[0].value[i]]] or ' ' end -- only alphanum, space and _- allowed
	self.menu[0].value[9] = nil -- only first 8 chars should ever be shown AND stored... (screen size limits lol, also need space for sprite preview)
	
	self.menu[0].charPointer = 1

	self.menu[0].left  = function(self)
		if self.active then
			--print('left before  | charnum: '..#self.value, 'current char: ' .. self.charPointer)
			self.charPointer = (((self.charPointer - 1) - 1) % #self.value) + 1
			--print('left after   | charnum: '..#self.value, 'current char: ' .. self.charPointer)
		end
	end
	self.menu[0].right = function(self)
		if self.active then
			--print('right before | charnum: '..#self.value, 'current char: ' .. self.charPointer)
			self.charPointer = (((self.charPointer - 1) + 1) % 8) + 1 -- so we can add characters to our name...
			if self.value[self.charPointer] == nil then
				self.value[self.charPointer] = ' '
			end
			--print('right after  | charnum: '..#self.value, 'current char: ' .. self.charPointer)
		end
	end
	self.menu[0].up = function(self)
		if self.active then
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			self.value[self.charPointer] = core.map[(core.reverseMap[self.value[self.charPointer]] + 1) % 39]
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[0].down = function(self)
		if self.active then
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			self.value[self.charPointer] = core.map[(core.reverseMap[self.value[self.charPointer]] - 1) % 39]
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[0].a = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
			--print('a before   | charnum: '..#self.value, 'current char: ' .. self.charPointer)
			-- check for spaces in final position, and nil them.
			for i=#self.value, 2, -1 do
				if self.value[i] == ' ' then self.value[i] = nil else break end
			end

			-- test for empty name...
			if self.value[1] == ' ' then
				appendLog("Error: Can't have empty names! Resetting to default...")
				self.value = {'S','H','I','R','O'}
			end

			self.charPointer = 1 -- for safety, in case old value had less characters.

			self.active = false
			Lionblaster.PersistentData.User.name = core.tableToString(self.value)
			--print('a after   | charnum: '..#self.value, 'current char: ' .. self.charPointer)
		else 
			self.oldValue = {}
			for i=1,#self.value do self.oldValue[i] = self.value[i] end
			self.active = true
		end
	end
	self.menu[0].b = function(self)
		if self.active then
			local core = Lionblaster.InstanceData.GameStates.GS.current()

			--print('b before   | charnum: '..#self.value, 'current char: ' .. self.charPointer)
			--print('name before: ' .. core.tableToString(self.value))

			-- check for spaces in final position, and nil them.
			for i=#self.value, 2, -1 do
				if self.value[i] == ' ' then self.value[i] = nil else break end
			end

			--print('name between finalposspacecheck and oldvaluecopyback: ' .. core.tableToString(self.value))

			for i=1,#self.oldValue do self.value[i] = self.oldValue[i] end

			--print('name after oldvaluecopyback before cutoffnilling: ' .. core.tableToString(self.value) .. ', oldlength: ' .. #self.oldValue)

			for i=#self.oldValue+1,#self.value do
				self.value[i] = nil
			end

			--print('name after cutoffnilling: ' .. core.tableToString(self.value) .. ', length: ' .. #self.value)

			self.charPointer = 1 -- for safety, in case old value had less characters.

			self.active = false
			--print('b after   | charnum: ' .. #self.value, 'current char: ' .. self.charPointer)
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = 18
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end

	-----------------------------------

	self.menu[1] = {}
	self.menu[1].active = false
	self.menu[1].text = 'Eye style'

	self.menu[1].value = math.min(math.max(Lionblaster.PersistentData.Skin.eyeStyle,0),5) -- stored as 0-5, rendered as 1-6 graphically here

	self.menu[1].left = function(self)
		if self.active then
			self.value = math.max(self.value - 1, 0)
		end
	end
	self.menu[1].right = function(self)
		if self.active then
			self.value = math.min(self.value + 1, 5)
		end
	end
	self.menu[1].up = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[1].down = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[1].a = function(self)
		if self.active then
			self.active = false
			Lionblaster.PersistentData.Skin.eyeStyle = self.value
			Lionblaster.InstanceData.GameStates.GS.current().changedSkin = true
		else 
			self.oldValue = self.value
			self.active = true
		end
	end
	self.menu[1].b = function(self)
		if self.active then
			self.value = self.oldValue
			self.active = false
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = 18
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end

	-----------------------------------

	-- RGBA manips inbound :C (Also, one should update the bomberman sprite thing as well...)
	-- less redundancy if we do a for loop... but first, a reference implementation
	-- Create a local table holding all the text fields and value persistent fields for these types of options so we can assign them in the loop

	local textTable = {false,"Outline","Pom-pom","Hood","Skin tone","Arms","Robe","Belt","Belt buckle","Gloves","Legs","Shoes"}
	local persistentTable = {
		false,
		Lionblaster.PersistentData.Skin.outline, Lionblaster.PersistentData.Skin.pomPom, Lionblaster.PersistentData.Skin.hood, 
		Lionblaster.PersistentData.Skin.skinTone, Lionblaster.PersistentData.Skin.arms, Lionblaster.PersistentData.Skin.robe,
		Lionblaster.PersistentData.Skin.belt, Lionblaster.PersistentData.Skin.beltBuckle, Lionblaster.PersistentData.Skin.gloves,
		Lionblaster.PersistentData.Skin.legs, Lionblaster.PersistentData.Skin.shoes
	}

	--------

	for i=2, 12 do

		self.menu[i] = {}
		self.menu[i].active = false
		self.menu[i].text = textTable[i]

		self.menu[i].value = persistentTable[i]

		self.menu[i].pointer = 1

		self.menu[i].left = function(self)
			if self.active then
				self.pointer = (((self.pointer - 1) - 1) % 4) + 1
			end
		end
		self.menu[i].right = function(self)
			if self.active then
				self.pointer = (((self.pointer - 1) + 1) % 4) + 1
			end
		end
		self.menu[i].up = function(self)
			if self.active then
				self.value[self.pointer] = (self.value[self.pointer] + 1) % 256
			else
				local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
				option = (option - 1) % 19
				Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
			end
		end
		self.menu[i].down = function(self)
			if self.active then
				self.value[self.pointer] = (self.value[self.pointer] - 1) % 256
			else
				local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
				option = (option + 1) % 19
				Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
			end
		end
		self.menu[i].a = function(self)
			if self.active then
				self.active = false
				persistentTable[i] = self.value
				Lionblaster.InstanceData.GameStates.GS.current().changedSkin = true
			else 
				self.oldValue = {}
				self.oldValue[1] = self.value[1]
				self.oldValue[2] = self.value[2]
				self.oldValue[3] = self.value[3]
				self.oldValue[4] = self.value[4]
				self.active = true
			end
		end
		self.menu[i].b = function(self)
			if self.active then
				self.value[1] = self.oldValue[1]
				self.value[2] = self.oldValue[2]
				self.value[3] = self.oldValue[3]
				self.value[4] = self.oldValue[4]
				self.active = false
			else
				local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
				option = 18
				Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
			end
		end

	end

	-----------------------------------

	self.menu[13] = {}
	self.menu[13].text = 'Scale'
	self.menu[13].active = false

	self.menu[13].value = math.min(math.max(Lionblaster.PersistentData.User.scale,1),4) -- [1,4]

	self.menu[13].left = function(self)
		if self.active then
			self.value = math.max(self.value - 1, 1)
		end
	end
	self.menu[13].right = function(self)
		if self.active then
			self.value = math.min(self.value + 1, 4)
		end
	end
	self.menu[13].up = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[13].down = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[13].a = function(self)
		if self.active then
			self.active = false
			Lionblaster.PersistentData.User.scale = self.value
			if not love.window.setMode(
				Lionblaster.PersistentData.Settings.width*Lionblaster.PersistentData.User.scale,
				Lionblaster.PersistentData.Settings.height*Lionblaster.PersistentData.User.scale,
				{borderless = false, vsync = true}
			) then
				appendLog("warning	: unable to resize window...")
			end
			Lionblaster.InstanceData.GameStates.GS.current().changedSkin = true -- needed because resizing messes up the char canvas for some reason...
			-- note that this still doesn't work...
		else 
			self.oldValue = self.value
			self.active = true
		end
	end
	self.menu[13].b = function(self)
		if self.active then
			self.value = self.oldValue
			self.active = false
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = 18
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end

	-----------------------------------

	self.menu[14] = {}
	self.menu[14].text = 'Shader'
	self.menu[14].active = false

	self.menu[14].value = math.min(math.max(Lionblaster.PersistentData.User.shader, 0), #Lionblaster.PersistentData.Shaders) -- # doesn't count the 0th element

	self.menu[14].left = function(self)
		if self.active then
			self.value = math.min(math.max(self.value - 1, 0), #Lionblaster.PersistentData.Shaders)
		end
	end
	self.menu[14].right = function(self)
		if self.active then
			self.value = math.min(math.max(self.value + 1, 0), #Lionblaster.PersistentData.Shaders)
		end
	end
	self.menu[14].up = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[14].down = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[14].a = function(self)
		if self.active then
			self.active = false
			Lionblaster.PersistentData.User.shader = self.value
		else 
			self.oldValue = self.value
			self.active = true
		end
	end
	self.menu[14].b = function(self)
		if self.active then
			self.value = self.oldValue
			self.active = false
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = 18
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end

	-----------------------------------

	self.menu[15] = {}
	self.menu[15].text = 'BGM'
	self.menu[15].active = false

	self.menu[15].value = math.min(math.max(Lionblaster.PersistentData.User.bgmVolume,0.0),1.0)

	self.menu[15].left = function(self)
		if self.active then
			self.value = math.max(self.value - 1/10, 0.0)
		end
	end
	self.menu[15].right = function(self)
		if self.active then
			self.value = math.min(self.value + 1/10, 1.0)
		end
	end
	self.menu[15].up = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[15].down = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[15].a = function(self)
		if self.active then
			self.active = false
			Lionblaster.PersistentData.User.bgmVolume = self.value
		else 
			self.oldValue = self.value
			self.active = true
		end
	end
	self.menu[15].b = function(self)
		if self.active then
			self.value = self.oldValue
			self.active = false
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = 18
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end

	self.menu[16] = {}
	self.menu[16].text = 'SFX'
	self.menu[16].active = false

	self.menu[16].value = math.min(math.max(Lionblaster.PersistentData.User.sfxVolume,0.0),1.0)

	self.menu[16].left = function(self)
		if self.active then
			self.value = math.max(self.value - 1/10, 0.0)
		end
	end
	self.menu[16].right = function(self)
		if self.active then
			self.value = math.min(self.value + 1/10, 1.0)
		end
	end
	self.menu[16].up = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[16].down = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[16].a = function(self)
		if self.active then
			self.active = false
			Lionblaster.PersistentData.User.sfxVolume = self.value
		else 
			self.oldValue = self.value
			self.active = true
		end
	end
	self.menu[16].b = function(self)
		if self.active then
			self.value = self.oldValue
			self.active = false
		else
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = 18
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end

	-----------------------------------

	self.menu[17] = {}
	self.menu[17].text = "Redefine"

	self.menu[17].up = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[17].down = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[17].a = function(self)
			-- go to that game state
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			core.destination = Lionblaster.InstanceData.GameStates.ControlSettings
			core.subState = 'fadeout'
	end
	self.menu[17].b = function(self)
		local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
		option = 18
		Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
	end

	-----------------------------------

	self.menu[18] = {}
	self.menu[18].text = "Back"

	self.menu[18].up = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option - 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[18].down = function(self)
		if not self.active then
			local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
			option = (option + 1) % 19
			Lionblaster.InstanceData.GameStates.GS.current().menu.active = option
		end
	end
	self.menu[18].a = function(self)
			-- go to that game state
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			core.destination = Lionblaster.InstanceData.GameStates.Title
			core.subState = 'fadeout'
	end
	-- redundand code
	--self.menu[18].b = function(self)
	--	local option = Lionblaster.InstanceData.GameStates.GS.current().menu.active
	--	option = 18
	--end

end

function state:enter(from)

	-- minor code duplication, but this is only ever needed here and once in init...
	local persistentTable = {
		false,
		Lionblaster.PersistentData.Skin.outline, Lionblaster.PersistentData.Skin.pomPom, Lionblaster.PersistentData.Skin.hood, 
		Lionblaster.PersistentData.Skin.skinTone, Lionblaster.PersistentData.Skin.arms, Lionblaster.PersistentData.Skin.robe,
		Lionblaster.PersistentData.Skin.belt, Lionblaster.PersistentData.Skin.beltBuckle, Lionblaster.PersistentData.Skin.gloves,
		Lionblaster.PersistentData.Skin.legs, Lionblaster.PersistentData.Skin.shoes
	}

	appendLog("GameState	: settings.enter")

	-- read in stuff just to be sure
	self.menu[0].value = self.stringToTable(Lionblaster.PersistentData.User.name)
	for i=1, #self.menu[0].value do self.menu[0].value[i] = self.map[self.reverseMap[self.menu[0].value[i]]] or ' ' end -- only alphanum, space and _- allowed
	self.menu[0].value[17] = nil -- only first 16 chars should ever be shown AND stored...

	self.menu[1].value = math.min(math.max(Lionblaster.PersistentData.Skin.eyeStyle,0),5)

	for i=2, 12 do
		self.menu[i].value[1] = math.min(math.max(persistentTable[i][1], 0), 255)
		self.menu[i].value[2] = math.min(math.max(persistentTable[i][2], 0), 255)
		self.menu[i].value[3] = math.min(math.max(persistentTable[i][3], 0), 255)
		self.menu[i].value[4] = math.min(math.max(persistentTable[i][4], 0), 255)
	end

	self.menu[13].value = math.min(math.max(Lionblaster.PersistentData.User.scale,1),4)

	self.menu[14].value = math.min(math.max(Lionblaster.PersistentData.User.shader, 0), #Lionblaster.PersistentData.Shaders) -- # doesn't count the 0th element

	self.menu[15].value = math.min(math.max(Lionblaster.PersistentData.User.bgmVolume,0.0),1.0)
	self.menu[16].value = math.min(math.max(Lionblaster.PersistentData.User.sfxVolume,0.0),1.0)

	-- if coming from redefinition, then select that as the selected one, else the first
	if from == Lionblaster.InstanceData.GameStates.ControlSettings then
		self.menu.active = 17
	else
		self.menu.active =  0
	end

	--self.transitions.fadeInColor = Lionblaster.InstanceData.Classes.Utils.Color.load("timeOfDay")

	-- set fading things
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

	self.destination = false
	self.subState = 'fadein'

end

function state:leave()

	appendLog("GameState	: settings.leave")

end

function state:update(dt)

	-- update the character sprite's orientation (only the first 8 since we want only rotation)

	self.spriteCurrent = (self.spriteCurrent + dt*1.5) % 8 -- self.spriteFrames
	self.spriteQuad:setViewport(math.floor(self.spriteCurrent)*32, 0, 32, 32)

	-- fade-in sequence

	if self.subState == 'fadein' then
		self.transitions.fadeCounter = self.transitions.fadeCounter + (dt / self.transitions.fadeInTime)
		for i=1,4 do
			self.transitions.currentRGBA[i] = self.transitions.initialColor[i] * (1.0 - self.transitions.fadeCounter)
											+ self.transitions.fadeInColor[i] * (      self.transitions.fadeCounter)
			self.transitions.currentRGBA[i] = math.min(math.max(math.floor(self.transitions.currentRGBA[i]), 0),255)
		end
		-- if we finished fading in
		if self.transitions.fadeCounter >= 1.0 then
			self.transitions.fadeCounter = 0.0
			self.subState = 'continue'
		end
	end

	-- fade-out sequence (not called for title)

	if self.subState == 'fadeout' then
		self.transitions.fadeCounter = self.transitions.fadeCounter + (dt / self.transitions.fadeOutTime)
		for i=1,4 do
			self.transitions.currentRGBA[i] = self.transitions.fadeInColor[i]  * (1.0 - self.transitions.fadeCounter)
											+ self.transitions.fadeOutColor[i] * (      self.transitions.fadeCounter)
			self.transitions.currentRGBA[i] = math.min(math.max(math.floor(self.transitions.currentRGBA[i]), 0),255)
		end
		-- if we finished fading out
		if self.transitions.fadeCounter >= 1.0 then
			self.transitions.fadeCounter = 0.0
			self.subState = 'leave'
		end
	end

	-- nop

	if self.subState == 'continue' then end

	-- go to the control settings or to the title screen

	if self.subState == 'leave' then
		Lionblaster.InstanceData.GameStates.GS.switch(self.destination)
	end

end

function state:draw()

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	-- transition color set
	love.graphics.setColor(self.transitions.currentRGBA)

	love.graphics.setBackgroundColor(self.transitions.currentRGBA)

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	---------------

	-- draw out menu option texts

	local yHeight = 9
	local xPos = 0
	local yPos = 0

	love.graphics.setColor(0,0,0,self.transitions.currentRGBA[4])
	love.graphics.printf("--  Player  --", xPos, yPos, 174, 'left')
	yPos = yPos + yHeight
	

	for i=0,18 do

		-- print out option names
		if i == self.menu.active then
			love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
		else
			love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
		end

		love.graphics.printf(self.menu[i].text, xPos, yPos, 174, 'left')
		yPos = yPos + yHeight

		-- increment yPos when necessary because of category labels being printed...
		love.graphics.setColor(0,0,0,self.transitions.currentRGBA[4])
		if i == 0 then
			love.graphics.printf("--   Skin   --", xPos, yPos, 174, 'left')
			yPos = yPos + yHeight
		elseif i == 12 then
			love.graphics.printf("-- Graphics --", xPos, yPos, 174, 'left')
			yPos = yPos + yHeight
		elseif i == 14 then
			love.graphics.printf("--   Audio  --", xPos, yPos, 174, 'left')
			yPos = yPos + yHeight
		elseif i == 16 then
			love.graphics.printf("-- Controls --", xPos, yPos, 174, 'left')
			yPos = yPos + yHeight
		elseif i == 17 then
			yPos = yPos + yHeight
		end
	end

	-- print out the name

	xPos = 128
	yPos = 9

	for i=1, #self.menu[0].value do
		if i == self.menu[0].charPointer and self.menu[0].active then
			love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
		else
			love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
		end
		love.graphics.printf(self.menu[0].value[i], xPos + ((i-1) * 9), yPos, 174, 'left')
	end

	-- print out the eye style

	yPos = yPos + yHeight * 2

	for i=0, 5 do
		if self.menu[1].value == i then
			love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
		else
			love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
		end
		love.graphics.printf((i+1), xPos + (i * 20), yPos, 174, 'left')
	end

	-- print out the RGB shits...

	yPos = yPos + yHeight

	-- by Lostgallifreyan, modified by zorg for any positive base up to 64
	local function Dec2Any(dec, base, minSize)
		local minSize = minSize or 0
		local base = base or 16
		assert(base > 0,"Base can't be non-positive!")
		local map = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#-"
		local result = ""
		local i = 0
		local d = 0

		if base == 1 then
			for i=1, dec do
				result = result .. '0'
			end
		else 
			while dec > 0 do
				i = i + 1
				dec, d = math.floor(dec / base),(dec % base) + 1 -- 1-based map indexing
				result = string.sub(map,d,d) .. result
			end
			while result:len() < minSize do result = '0' .. result end
		end
		return result
	end

	for i=2,12 do
		for j=1,4 do
			local s = ''
			if self.menu[i].pointer == j and self.menu[i].active then
				if j==1 then
					love.graphics.setColor(self.menu[i].value[1], 0, 0, self.transitions.currentRGBA[4])
				elseif j == 2 then
					love.graphics.setColor(0, self.menu[i].value[2], 0, self.transitions.currentRGBA[4])
				elseif j == 3 then
					love.graphics.setColor(0, 0, self.menu[i].value[3], self.transitions.currentRGBA[4])
				else
					love.graphics.setColor(self.menu[i].value[4], self.menu[i].value[4], self.menu[i].value[4], self.transitions.currentRGBA[4])
				end
			else
				love.graphics.setColor(191, 191, 191, self.transitions.currentRGBA[4])
			end
			s = (j == 1) and 'R' or ((j == 2) and 'G' or ((j == 3) and 'B' or 'A'))
			love.graphics.print(s .. Dec2Any(self.menu[i].value[j],16,2), xPos + ((j-1) * 34), yPos)
		end
		yPos = yPos + yHeight
	end

	-- print out scale values

	yPos = yPos + yHeight

	for i=1, 4 do
		if self.menu[13].value == i then
			love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
		else
			love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
		end
		love.graphics.printf(i .. "x", xPos + ((i-1) * 29), yPos, 174, 'left')
	end

	-- print out the currently selected shader

	yPos = yPos + yHeight

	if self.menu[14].active then
		love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
	else
		love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
	end
	love.graphics.printf(Lionblaster.PersistentData.Shaders[self.menu[14].value].name, xPos, yPos, 174, 'left')

	-- print out BGM and SFX volume bars

	yPos = yPos + yHeight * 2

	for i=1,10 do
		if self.menu[15].value >= i/10 then
			if self.menu[15].active then
				love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
			else
				love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
			end
		else
			if self.menu[15].active then
				love.graphics.setColor(127,127,127,self.transitions.currentRGBA[4])
			else
				love.graphics.setColor(  0,  0,  0,self.transitions.currentRGBA[4])
			end
		end
		love.graphics.print("-", xPos + ((i-1) * 12), yPos)
	end

	yPos = yPos + yHeight

	for i=1,10 do
		if self.menu[16].value >= i/10 then
			if self.menu[16].active then
				love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
			else
				love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
			end
		else
			if self.menu[16].active then
				love.graphics.setColor(127,127,127,self.transitions.currentRGBA[4])
			else
				love.graphics.setColor(  0,  0,  0,self.transitions.currentRGBA[4])
			end
		end
		love.graphics.print("-", xPos + ((i-1) * 12), yPos)
	end

	---------------

	-- Render a preview of the character
	-- should only run this if we changed the skin!

	if self.changedSkin then

		Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets[1]:clear()

		-- call the baker :3
		bake(Lionblaster.InstanceData.Assets.gfx.spriteMaps.players.playerComponents,
					Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets[1]
				)

		self.changedSkin = false

	end

	-- draw out our sprite rotating
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(self.spriteSheet, self.spriteQuad, 228, 192)

	---------------

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	-- transition fading
	love.graphics.setAlpha(255-self.transitions.currentRGBA[4])
	love.graphics.rectangle('fill', 0, 0, Lionblaster.PersistentData.Settings.width, Lionblaster.PersistentData.Settings.height)

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	--drawDebug()

end

function state:keypressed(key,isRepeat)

	local ctrMap = Lionblaster.PersistentData.ControlList
	local getKey = function(inputID)
		for i=1,#ctrMap do
			if ctrMap[i][inputID] == key then return true end
		end
		return false
	end

	-- there are functions for every selectable menupoint, we just need to call them if they exist
	if getKey('up') then
		if self.menu[self.menu.active].up   then self.menu[self.menu.active]:up()   end
	elseif getKey('down') then
		if self.menu[self.menu.active].down then self.menu[self.menu.active]:down() end
	elseif getKey('left') then
		if self.menu[self.menu.active].left then self.menu[self.menu.active]:left() end
	elseif getKey('right') then
		if self.menu[self.menu.active].right then self.menu[self.menu.active]:right() end
	elseif getKey('a') then
		if self.menu[self.menu.active].a then self.menu[self.menu.active]:a() end
	elseif getKey('b') then
		if self.menu[self.menu.active].b then self.menu[self.menu.active]:b() end
	elseif getKey('start') then
		-- return to title
		self.destination = Lionblaster.InstanceData.GameStates.Title
		self.subState = 'fadeout'
	elseif getKey('select') then
		-- unused
	end

	--print('self menu active ==' .. self.menu.active)

end

return state