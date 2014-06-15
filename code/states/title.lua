-- Lionblaster Title State
-- by zorg
-- @2014

-- comparison between 91 and 93 title sceens:
-- - text should be the same (contrary to original) -> menus dont need to be different at all -> no memleak
-- - background image is unchanged, since it has both graphics inside it. -> no memleak
-- - music is different, but that is handled by loading a different track into a source -> no memleak

local state = {}

function state:quit()

	appendLog("GameState	: title.quit")

	if self.subState ~= 'intro' and self.subState ~= 'outro' then return false end
	return true
end

function state:init()

	appendLog("GameState	: title.init")

	-- set sub-state
	self.subState = 'init'

	-- only scroll the background if we've come from the preloader screen
	-- scroll direction depends on game mode
	self.yOffset = 0

	-- set transition vars
	self.transitions = {}

	self.transitions.initialColor =	{  0,  0,  0,  0}
	self.transitions.fadeInColor =	{ 81,113,211,255} -- color to fade into
	self.transitions.fadeOutColor =	{  0,  0,  0,  0} -- color to fade out to
	self.transitions.fadeInTime =	0.5 -- seconds
	self.transitions.fadeOutTime =	0.5 -- seconds

	-- Create a variable that will hold the OS time in seconds (modulo a day)
	-- By default, the time transition starts at noon, so we need to compensate for that as well...
	local h = os.date('%H')
	local m = os.date('%M')
	local s = os.date('%S')
	self.timeOffset = h * 3600 + m * 60 + s -- in seconds
	self.timeOffset = (self.timeOffset + 43200) % 86400

	----------------------------------------------------------------------------

	-- create graphics components
	self.background = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.backgrounds.title)

	-- .........memleak-prevention because i don't want to call gc.collect twice everytime i enter this game state.
	self.pointer91 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.cursors.pointerTriangle)
	self.pointer93 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.cursors.pointerCircle)

	-- create the menu
	self.menu = {}
	self.menu.active = 0
	self.menu.count = 10

	self.menu[0] = {
	text = 'New Game',
	destination = Lionblaster.InstanceData.GameStates.Game
	}
	self.menu[1] = {
	text = 'Continue',
	destination = Lionblaster.InstanceData.GameStates.Password,
	params = Lionblaster.PersistentData.Settings.gameMode
	}

	-- deal with persistents relating to hardmode
	if (Lionblaster.PersistentData.Settings.completedMode93
	or  Lionblaster.PersistentData.Settings.completedMode91EX)
	and Lionblaster.PersistentData.Settings.isHardmode
	then
		self.menu[0].text = 'New Game EX'
		self.menu[1].text = 'Continue EX'
	else
		self.menu[0].text = 'New Game'
		self.menu[1].text = 'Continue'
	end

	self.menu[2] = {
	text = 'Change Game',
	destination = Lionblaster.InstanceData.GameStates.Title,
	params = (Lionblaster.PersistentData.Settings.gameMode == '91') and '93' or '91'
	}
	self.menu[3] = {
	text = 'Multiplayer',
	destination = Lionblaster.InstanceData.GameStates.Lobby,
	}
	self.menu[4] = {
	text = 'Beastiary',
	destination = Lionblaster.InstanceData.GameStates.Beastiary,
	}
	self.menu[5] = {
	text = 'Settings',
	destination = Lionblaster.InstanceData.GameStates.Settings,
	}
	self.menu[6] = {
	text = 'Replays',
	destination = Lionblaster.InstanceData.GameStates.ReplayManager,
	}
	self.menu[7] = {
	text = 'Music Room',
	destination = Lionblaster.InstanceData.GameStates.MusicRoom,
	}
	self.menu[8] = {
	text = 'Credits',
	destination = Lionblaster.InstanceData.GameStates.Cinema,
	params = 'Credits'
	}
	self.menu[9] = {
	text = 'Exit',
	destination = 'quit'
	}

	-- id-by-text getter
	self.getMenuItemByText = function(text)
		for i=0,self.menu.count-1 do
			if self.menu[i].text == text then return i end
		end
		error("no menu entry found with text: " .. text)
	end

end

function state:enter(from)

	appendLog("GameState	: title.enter")

	-- check which game we're currently in
	if Lionblaster.PersistentData.Settings.gameMode == '91' then

		self.pointer = self.pointer91

		-- queue the relevant title theme
		-- Lionblaster.InstanceData.Classes.AudioEngine:queue(8,1.0,1.0,2.0,3.0)

	else --if Lionblaster.PersistentData.Settings.gameMode == '93' then

		self.pointer = self.pointer93

		-- queue the relevant title theme
		-- Lionblaster.InstanceData.Classes.AudioEngine:queue(24,1.0,1.0,2.0,3.0)

	end

	-- deal with persistents relating to hardmode
	if (Lionblaster.PersistentData.Settings.completedMode93
	or  Lionblaster.PersistentData.Settings.completedMode91EX)
	and Lionblaster.PersistentData.Settings.isHardmode
	then
		self.menu[0].text = 'New Game EX'
		self.menu[1].text = 'Continue EX'
	else
		self.menu[0].text = 'New Game'
		self.menu[1].text = 'Continue'
	end

	-- check if we're at game start or if we changed games
	if self.subState == 'init' or self.subState == 'gamechange' then
		self.transitions.initialColor =	{  0,  0,  0,255}
		self.subState = 'intro'
	else
		self.transitions.initialColor =	{  0,  0,  0,  0}
		self.subState = 'fadein'
		
	end

	-- create transition variables
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

end

function state:leave()

	appendLog("GameState	: preloader.leave")

end

function state:update(dt)

	-- intro - bg panning animation

	if self.subState == 'intro' then

		if Lionblaster.PersistentData.Settings.gameMode == '91' then

			self.yOffset = self.yOffset - (dt*97.4)
			if self.yOffset < -448 then
				self.yOffset = -448
				self.subState = 'continue'
			end

		else --if Lionblaster.PersistentData.Settings.gameMode == '93' then

			self.yOffset = self.yOffset + (dt*97.4)
			if self.yOffset > 448 then
				self.yOffset = 448
				self.subState = 'continue'
			end

		end
	end

	-- outro - bg panning animation (called only for title)

	if self.subState == 'outro' then
		if Lionblaster.PersistentData.Settings.gameMode == '91' then

			self.yOffset = self.yOffset + (dt*97.4)

			if self.yOffset > 0 then
				self.yOffset = 0
				-- mute music
				Lionblaster.PersistentData.Settings.gameMode = '93'
				self.subState = 'leave'
			end

		else --if Lionblaster.PersistentData.Settings.gameMode == '93' then

			self.yOffset = self.yOffset - (dt*97.4)

			if self.yOffset < 0 then
				self.yOffset = 0
				-- mute music
				Lionblaster.PersistentData.Settings.gameMode = '91'
				self.subState = 'leave'
			end

		end
	end

	-- fade-in sequence

	if self.subState == 'fadein' then
		self.transitions.fadeCounter = self.transitions.fadeCounter + (dt / self.transitions.fadeInTime)
		for i=1,4 do
			self.transitions.currentRGBA[i] = self.transitions.initialColor[i] * (1.0 - self.transitions.fadeCounter)
											+ self.transitions.fadeInColor[i] * (      self.transitions.fadeCounter)
			self.transitions.currentRGBA[i] = math.min(math.max(math.floor(self.transitions.currentRGBA[i]), 0),255)
			--print(((i == 1) and "red" or ((i == 2) and "green" or ((i == 3) and "blue" or "alpha"))) .. " channel value = " .. self.transitions.currentRGBA[i])
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
			--print(((i == 1) and "red" or ((i == 2) and "green" or ((i == 3) and "blue" or "alpha"))) .. " channel value = " .. self.transitions.currentRGBA[i])
		end
		-- if we finished fading out
		if self.transitions.fadeCounter >= 1.0 then
			self.transitions.fadeCounter = 0.0
			self.subState = 'leave'
		end
	end

	-- continue within the state

	if self.subState == 'continue' then end -- this is practically a nop, i just like to define every (sub)state.

	-- leave the state (called for every menu selection)

	if self.subState == 'leave' then
		if self.menu[self.menu.active].destination == 'quit' then
			-- quit the game
			love.event.quit()
		else
			-- create a standard GameData table for the game...
			if self.menu[self.menu.active].destination == Lionblaster.InstanceData.GameStates.Game then
				Lionblaster.InstanceData.GameData.type = (Lionblaster.PersistentData.Settings.gameMode == '91') and 1 or 3
				Lionblaster.InstanceData.GameData.stage = 1
				Lionblaster.InstanceData.GameData.round = 1
			end
			-- any other gamestate, including the title (we already set the gamemode persistent in the keypressed callback)
			-- we do need to set the substate though
			if self.menu[self.menu.active].destination == Lionblaster.InstanceData.GameStates.Title then
				self.subState = 'gamechange'
			end
			Lionblaster.InstanceData.GameStates.GS.switch(self.menu[self.menu.active].destination,self.menu[self.menu.active].params)
		end
	end
end


function state:draw()

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	-- transition color set
	love.graphics.setColor(self.transitions.currentRGBA)

	--love.graphics.setBackgroundColor(self.transitions.currentRGBA)

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	-- Easter Egg - Background Day/Night Cycle
	local cycleLength = 86400 -- 60 * 60 * 24

	local cycleMoment = (math.cos(2 * math.pi * (self.timeOffset + Lionblaster.InstanceData.elapsedTime) / cycleLength) + 1) / 2
	local warp = (1 - (Lionblaster.InstanceData.elapsedTime / cycleLength)) % 1

	local h = (82 + (255 * warp)) % 255
	local s = (191 * cycleMoment) + 64
	local l = s --(191 * cycleMoment) + 64
	local r,g,b = Lionblaster.InstanceData.Classes.Utils.Color.HSLtoRGB(h,s,l)

	love.graphics.setBlendMode('additive')
	love.graphics.setColor(r,g,b,self.transitions.currentRGBA[4])

	love.graphics.draw(self.background, 0, -448 + self.yOffset) -- correction so 0 will be midpoint's top coord

	self.transitions.fadeInColor = {r,g,b,255}
	Lionblaster.InstanceData.Classes.Utils.Color.save("timeOfDay",{r,g,b,255})

	love.graphics.setBlendMode('alpha')
	love.graphics.setColor(255, 255, 255, self.transitions.currentRGBA[4])

	if self.subState ~= 'intro' and self.subState ~= 'outro' then
		for i=0,self.menu.count-1 do
			if self.menu[i].text == "Change Game" and not Lionblaster.PersistentData.Settings.completedMode91 then
				-- don't render this
			elseif self.menu[i].text == "Music Room" and not Lionblaster.PersistentData.Settings.unlockedMusicBox then
				-- don't render this
			else
				love.graphics.printf(self.menu[i].text, 64, 116 + (9 * i), 128, 'justify')
			end
		end
		-- draw the pointer
		love.graphics.draw(self.pointer, 48, 116 + (9 * self.menu.active))
	end

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	-- transition fading
	--love.graphics.setAlpha(255-self.transitions.currentRGBA[4])
	--love.graphics.rectangle('fill', 0, 0, Lionblaster.PersistentData.Settings.width, Lionblaster.PersistentData.Settings.height)

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	drawDebug()
end

function state:keypressed(key,isRepeat)

	local ctrMap = Lionblaster.PersistentData.ControlList
	local getKey = function(inputID)
		for i=1,#ctrMap do
			if ctrMap[i][inputID] == key then return true end
		end
		return false
	end

	-- only register keypresses at continue sub-state
	if self.subState == 'continue' then

		if getKey('up') then
			self.menu.active = (self.menu.active - 1) % self.menu.count
			-- hack to hide the game mode if the 91 game hasn't been completed yet
			if self.menu[self.menu.active].text == "Change Game" and not Lionblaster.PersistentData.Settings.completedMode91 then
				self.menu.active = (self.menu.active - 1) % self.menu.count
			end
			-- music room hack
			if self.menu[self.menu.active].text == "Music Room" and not Lionblaster.PersistentData.Settings.unlockedMusicBox then
				self.menu.active = (self.menu.active - 1) % self.menu.count
			end
			-- other hacks to follow?
		elseif getKey('down') then
			self.menu.active = (self.menu.active + 1) % self.menu.count
			-- other hacks to follow?

			-- music room hack
			if self.menu[self.menu.active].text == "Music Room" and not Lionblaster.PersistentData.Settings.unlockedMusicBox then
				self.menu.active = (self.menu.active + 1) % self.menu.count
			end
			-- hack to hide the game mode if the 91 game hasn't been completed yet
			if self.menu[self.menu.active].text == "Change Game" and not Lionblaster.PersistentData.Settings.completedMode91 then
				self.menu.active = (self.menu.active + 1) % self.menu.count
			end
		elseif getKey('left') then
			-- not all menupoints have alternatives, and those that have may be contidional

			-- easy/hard game mode switching | dependent on a lot of things :c
			if self.menu[self.menu.active].text == "New Game" then -- Lionblaster.PersistentData.Settings.isHardmode == false
				if Lionblaster.PersistentData.Settings.completedMode93 and Lionblaster.PersistentData.Settings.gameMode == '91' then
					Lionblaster.PersistentData.Settings.isHardmode = true
					self.menu[self.menu.active].text = "New Game EX"
					self.menu[getMenuItemByText("Continue")].text = "Continue EX"
				elseif Lionblaster.PersistentData.Settings.completedMode91EX and Lionblaster.PersistentData.Settings.gameMode == '93' then
					Lionblaster.PersistentData.Settings.isHardmode = true
					self.menu[self.menu.active].text = "New Game EX"
					self.menu[getMenuItemByText("Continue")].text = "Continue EX"
				end
			elseif self.menu[self.menu.active].text == "New Game EX" then -- Lionblaster.PersistentData.Settings.isHardmode == true
				if Lionblaster.PersistentData.Settings.gameMode == '91' then
					Lionblaster.PersistentData.Settings.isHardmode = false
					self.menu[self.menu.active].text = "New Game"
					self.menu[getMenuItemByText("Continue EX")].text = "Continue"
				else --if Lionblaster.PersistentData.Settings.gameMode == '93' then
					Lionblaster.PersistentData.Settings.isHardmode = false
					self.menu[self.menu.active].text = "New Game"
					self.menu[getMenuItemByText("Continue EX")].text = "Continue"
				end
			end

		elseif getKey('right') then
			-- not all menupoints have alternatives, and those that have may be contidional

			-- easy/hard game mode switching | dependent on a lot of things :c
			if self.menu[self.menu.active].text == "New Game" then -- Lionblaster.PersistentData.Settings.isHardmode == false
				if Lionblaster.PersistentData.Settings.completedMode93 and Lionblaster.PersistentData.Settings.gameMode == '91' then
					Lionblaster.PersistentData.Settings.isHardmode = true
					self.menu[self.menu.active].text = "New Game EX"
					self.menu[getMenuItemByText("Continue")].text = "Continue EX"
				elseif Lionblaster.PersistentData.Settings.completedMode91EX and Lionblaster.PersistentData.Settings.gameMode == '93' then
					Lionblaster.PersistentData.Settings.isHardmode = true
					self.menu[self.menu.active].text = "New Game EX"
					self.menu[getMenuItemByText("Continue")].text = "Continue EX"
				end
			elseif self.menu[self.menu.active].text == "New Game EX" then -- Lionblaster.PersistentData.Settings.isHardmode == true
				if Lionblaster.PersistentData.Settings.gameMode == '91' then
					Lionblaster.PersistentData.Settings.isHardmode = false
					self.menu[self.menu.active].text = "New Game"
					self.menu[getMenuItemByText("Continue EX")].text = "Continue"
				else --if Lionblaster.PersistentData.Settings.gameMode == '93' then
					Lionblaster.PersistentData.Settings.isHardmode = false
					self.menu[self.menu.active].text = "New Game"
					self.menu[getMenuItemByText("Continue EX")].text = "Continue"
				end
			end

		elseif getKey('a') or getKey('start') or getKey('select') then
			-- select the active menu option (except if it is the game changing one)
			if self.menu[self.menu.active].text == "Change Game" then
				self.subState = 'outro'
			else
			    self.subState = 'fadeout'
			end
			print("selected an option, subState is: " .. self.subState )
			-- fade music out
			-- -
		elseif getKey('b') then
			-- select exit as active menu... why not a shortcut :3
			for i=0,self.menu.count-1 do
				if self.menu[i].text == 'Exit' then
					self.menu.active = i
					break
				end
			end
		end

	elseif self.subState == 'intro' then

		-- except for impatient people who want to skip the scrolling intro...
		if getKey('a') or getKey('start') or getKey('select') then
			if Lionblaster.PersistentData.Settings.gameMode == '91' then
				self.yOffset = -448
			else --if Lionblaster.PersistentData.Settings.gameMode == '93' then
				self.yOffset = 448
			end
			self.subState = 'continue'
		end
	end

end

-- Only cheaters beyond this line...

do
	local text = ''
	function state:textinput(t)
		-- note, only works in single player (no multi cheating :3)
		text = text .. t

		-- consecutively type in the code; mistyping clears the buffer
		if
			text ~= 'h' and
			text ~= 'hu' and
			text ~= 'hud' and
			text ~= 'huds' and
			text ~= 'hudso' and
			text ~= 'hudson' and
			text ~= 'hudsons' and
			text ~= 'hudsonso' and
			text ~= 'hudsonsof' and
			text ~= 'hudsonsoft'
		then
			text = ''
		end

		if
			text == 'hudsonsoft'
		then
			Lionblaster.InstanceData.devMindset = not Lionblaster.InstanceData.devMindset

			if Lionblaster.InstanceData.devMindset then
				-- play "/" sfx
			else
				-- play "\" sfx
			end

			text = ''
		end
	end
end

return state