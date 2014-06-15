-- Lionblaster Game State
-- by zorg
-- @2014

local state = {}


function state:quit()

	appendLog("GameState	: game.quit")

	-- don't quit, go back to either the title screen, or the multi room
	if Lionblaster.InstanceData.GameData.type ~= 2 then
		self.destination = Lionblaster.InstanceData.GameStates.Title
	else
		self.destination = Lionblaster.InstanceData.GameStates.Room
	end
	self.subState = 'fadeout'
	return true

end

function state:init()

	appendLog("GameState	: game.init")

	self.subState = 'init'
	self.destination = false

	-- set transition vars
	self.transitions = {}

	self.transitions.initialColor =	{  0,  0,  0,  0}
	self.transitions.fadeInColor =	{ 81,113,211,255} -- color to fade into
	self.transitions.fadeOutColor =	{  0,  0,  0,  0} -- color to fade out to
	self.transitions.fadeInTime =	0.5 -- seconds
	self.transitions.fadeOutTime =	0.5 -- seconds

end

function state:enter(from)

	appendLog("GameState	: game.enter")

	-- Do some passthrough shit before we even load anything in

	if from == Lionblaster.InstanceData.GameStates.Game then
		-- continuation
		if Lionblaster.InstanceData.GameData.type == 1 or Lionblaster.InstanceData.GameData.type == 3 then
			if Lionblaster.InstanceData.GameData.round == 8 and Lionblaster.InstanceData.GameData.stage < 8 then
				Lionblaster.InstanceData.GameData.stage = Lionblaster.InstanceData.GameData.stage + 1
				Lionblaster.InstanceData.GameData.round = 1
				Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Stage)
			elseif Lionblaster.InstanceData.GameData.round < 8 then
				Lionblaster.InstanceData.GameData.round = Lionblaster.InstanceData.GameData.round + 1
				Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Round)
			elseif Lionblaster.InstanceData.GameData.round == 8 and Lionblaster.InstanceData.GameData.stage == 8 then
				if Lionblaster.InstanceData.GameData.type == 1 then
					Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Cinema,'Credits91')
				elseif Lionblaster.InstanceData.GameData.type == 3 then
					Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Cinema,'Credits93')
				end
			end
		elseif Lionblaster.InstanceData.GameData.type == 2 then
			if Lionblaster.InstanceData.GameData.round < Lionblaster.InstanceData.GameData.limit then
				Lionblaster.InstanceData.GameData.round = Lionblaster.InstanceData.GameData.round + 1
				Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Round)
			else
				-- remove internal Lionblaster.InstanceData.GameData components, but not the whole!
				Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Results)
			end
		end

	end

	if from == Lionblaster.InstanceData.GameStates.Title then
		if Lionblaster.InstanceData.GameData.type == 1 then
			Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Cinema,'Intro91')
		elseif Lionblaster.InstanceData.GameData.type == 3 then
			Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Cinema,'Intro93')
		end
	elseif from == Lionblaster.InstanceData.GameStates.Password then
		if Lionblaster.InstanceData.GameData.round == 1 then
			Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Stage)
		else
			Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Round)
		end
	elseif from == Lionblaster.InstanceData.GameStates.Room then
		Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Round)
	elseif from == Lionblaster.InstanceData.GameStates.Stage then
		Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Round)
	elseif from == Lionblaster.InstanceData.GameStates.Cinema then
		if Lionblaster.InstanceData.GameData.stage == 1 and Lionblaster.InstanceData.GameData.round == 1 then
			Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Stage)
		elseif Lionblaster.InstanceData.GameData.stage == 8 and Lionblaster.InstanceData.GameData.round == 8 then
			-- Change current game type (91 -> 93, 93 -> 91EX, 91EX -> 93EX, 93EX -> 91)
			if Lionblaster.InstanceData.GameData.type == 1 then
				if not Lionblaster.PersistentData.Settings.isHardmode then
					Lionblaster.PersistentData.Settings.completedMode91 = true
					Lionblaster.PersistentData.Settings.gameMode = '93'
				else
					Lionblaster.PersistentData.Settings.completedMode91EX = true
					Lionblaster.PersistentData.Settings.gameMode = '93'
				end
			elseif Lionblaster.InstanceData.GameData.type == 3 then
				if not Lionblaster.PersistentData.Settings.isHardmode then
					Lionblaster.PersistentData.Settings.completedMode93 = true
					Lionblaster.PersistentData.Settings.gameMode = '91'
					Lionblaster.PersistentData.Settings.isHardmode = true
				else
					Lionblaster.PersistentData.Settings.completedMode93EX = true
					Lionblaster.PersistentData.Settings.gameMode = '91'
					Lionblaster.PersistentData.Settings.isHardmode = false
				end
			end
			-- remove internal Lionblaster.InstanceData.GameData components, but not the whole!
			Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Title)
		end
	elseif from == Lionblaster.InstanceData.GameStates.Round then

		-- Actual game stuff

		if Lionblaster.InstanceData.GameData.type ~= 2 then

			-- Singleplayer

		else

			-- Mutliplayer

		end
	end

	-- set fading things
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

	self.destination = false
	self.subState = 'fadein'

end

function state:leave()

	appendLog("GameState	: game.leave")

end

function state:update(dt)

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

	-- game running

	if self.subState == 'continue' then

		-- Game Code

	end

	-- go to either the title screen, or to the room (or to the lobby if there was a net error)

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

	-- ...

	---------------

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	-- transition fading
	love.graphics.setAlpha(255-self.transitions.currentRGBA[4])
	love.graphics.rectangle('fill', 0, 0, Lionblaster.PersistentData.Settings.width, Lionblaster.PersistentData.Settings.height)

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	--drawDebug()

end

function state:keypressed(key,isRepeat)

end

return state