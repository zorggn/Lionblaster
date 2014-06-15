-- Lionblaster Stage State
-- by zorg
-- @2014

-- Show a nice graphic of the game's stages (91 or 93), then go back to the game stage; That is all.

local state = {}

function state:quit()

	appendLog("GameState	: stage.quit")

	-- don't quit, instead, end the state early with fade out.
	--audio.fadeout(self.transitions.fadeOutTime)...
	self.subState = 'fadeout'

end

function state:init()

	appendLog("GameState	: stage.init")

	self.subState = 'init'
	self.destination = false

	-- set transition vars
	self.transitions = {}

	self.transitions.initialColor =	{  0,  0,  0,  0}
	self.transitions.fadeInColor =	{  0,  0,  0,255} -- color to fade into
	self.transitions.fadeOutColor =	{  0,  0,  0,  0} -- color to fade out to
	self.transitions.fadeInTime =	0.5 -- seconds
	self.transitions.fadeOutTime =	0.5 -- seconds

	-- add in bg and "cursor" for both 91 and 93 version (no such thing for the latter, instead, two versions of the bg, but we'll cheat then...)

	self.bg91 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.backgrounds.stage91)
	self.fg91 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.cursors.head)

	--self.bg93 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.backgrounds.stage93)
	--self.ps93 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.cursors.stage93stars)
	--self.ol93 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.backgrounds.stage93overlay)
	--self.fg93 = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.cursors.finalstage93)

	self.red =    {255,  0,  0,255}
	self.yellow = {255,255,  0,255}

end

function state:enter(from)

	appendLog("GameState	: stage.enter")

	self.destination = from

	if Lionblaster.InstanceData.GameData.type == 1 then
		self.bg = self.bg91
	elseif Lionblaster.InstanceData.GameData.type == 3 then
		self.bg = self.bg93
	end

	self.counter = 0
	self.textColor = self.red

	-- set fading things
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

	self.subState = 'fadein'

end

function state:leave()

	appendLog("GameState	: stage.leave")

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
		self.counter = self.counter + dt
		if self.counter > 5 then
			--audio.fadeout(self.transitions.fadeOutTime)...
			self.subState = 'fadeout'
		end
	end

	-- go back to the game state

	if self.subState == 'leave' then
		Lionblaster.InstanceData.GameStates.GS.switch(self.destination)
	end

	-- Always update the head icon's size, modulo something per dt...
	-- Or, if playing the 93 version, do a starfield effect shit and update THAT constantly
	if Lionblaster.InstanceData.GameData.type == 1 then
		local counter = self.counter * 6 % 4
		if counter < 1 then
			self.multiplier = 1.0
			self.textColor = self.red
		elseif counter < 2 then
			self.multiplier = 1.25
			self.textColor = self.red
		elseif counter < 3 then
			self.multiplier = 1.5
			self.textColor = self.yellow
		elseif counter < 4 then
			self.multiplier = 1.25
			self.textColor = self.yellow
		end
	elseif Lionblaster.InstanceData.GameData.type == 3 then
		-- To Be Coded...
	end



end

function state:draw()

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	-- transition color set
	love.graphics.setColor(self.transitions.currentRGBA)

	love.graphics.setBackgroundColor(self.transitions.currentRGBA)

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	---------------

	-- draw out the background, the starfield if '93, the foreground, the unlocked base if it's warranted...

	love.graphics.setColor(255,255,255)

	if Lionblaster.InstanceData.GameData.type == 1 then

		love.graphics.draw(self.bg91,0,0)

		if     Lionblaster.InstanceData.GameData.stage == 1 then
			love.graphics.draw(self.fg91,13,140,0,self.multiplier,self.multiplier)
		elseif Lionblaster.InstanceData.GameData.stage == 2 then
			love.graphics.draw(self.fg91,60,114,0,self.multiplier,self.multiplier)
		elseif Lionblaster.InstanceData.GameData.stage == 3 then
			love.graphics.draw(self.fg91,66,170,0,self.multiplier,self.multiplier)
		elseif Lionblaster.InstanceData.GameData.stage == 4 then
			love.graphics.draw(self.fg91,116,122,0,self.multiplier,self.multiplier)
		elseif Lionblaster.InstanceData.GameData.stage == 5 then
			love.graphics.draw(self.fg91,162,116,0,self.multiplier,self.multiplier)
		elseif Lionblaster.InstanceData.GameData.stage == 6 then
			love.graphics.draw(self.fg91,206,144,0,self.multiplier,self.multiplier)
		elseif Lionblaster.InstanceData.GameData.stage == 7 then
			love.graphics.draw(self.fg91,214,106,0,self.multiplier,self.multiplier)
		elseif Lionblaster.InstanceData.GameData.stage == 8 then
			love.graphics.draw(self.fg91,228,70,0,self.multiplier,self.multiplier)
		else
			love.graphics.draw(self.fg91,229,44,0,self.multiplier,self.multiplier)
		end

		-- Draw ROUND N at the bottom of the screen

		love.graphics.push()
		love.graphics.scale(2.0,2.0)
		love.graphics.setColor(self.textColor)
		love.graphics.printf('Stage ' .. Lionblaster.InstanceData.GameData.stage, 
			0,
			Lionblaster.PersistentData.Settings.height/2 - Lionblaster.PersistentData.Settings.height/16,
			--7*(Lionblaster.PersistentData.Settings.height/8)-6,
			Lionblaster.PersistentData.Settings.width/2,
			"center")
		love.graphics.pop()

	elseif Lionblaster.InstanceData.GameData.type == 3 then

		love.graphics.draw(self.bg93,0,0)
		-- draw starfield
		-- draw stage planets
		-- if last stage, draw the middle stage as its true form

	end


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

	if getKey('a') or getKey('start') then
		--audio.fadeout(self.transitions.fadeOutTime)...
		self.subState = 'fadeout'
	end

end

return state