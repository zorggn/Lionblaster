-- Lionblaster Round State
-- by zorg
-- @2014

-- Show a neat round logo, then go back to the game stage; That is all.

local state = {}

function state:quit()

	appendLog("GameState	: round.quit")

	-- don't quit, instead, end the state early with fade out.
	--audio.fadeout(self.transitions.fadeOutTime)...
	self.subState = 'fadeout'

end

function state:init()

	appendLog("GameState	: round.init")

	self.subState = 'init'
	self.destination = false

	-- set transition vars
	self.transitions = {}

	self.transitions.initialColor =	{  0,  0,  0,  0}
	self.transitions.fadeInColor =	{  0,  0,  0,255} -- color to fade into
	self.transitions.fadeOutColor =	{  0,  0,  0,  0} -- color to fade out to
	self.transitions.fadeInTime =	0.5 -- seconds
	self.transitions.fadeOutTime =	0.5 -- seconds

end

function state:enter(from)

	appendLog("GameState	: round.enter")

	self.destination = from

	self.counter = 0

	-- set fading things
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

	self.subState = 'fadein'

end

function state:leave()

	appendLog("GameState	: round.leave")

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

end

function state:draw()

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	-- transition color set
	love.graphics.setColor(self.transitions.currentRGBA)

	love.graphics.setBackgroundColor(self.transitions.currentRGBA)

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	---------------

	-- Draw out the text in "STAGE - ROUND format"

	love.graphics.push()
	love.graphics.scale(2.0,2.0)
	love.graphics.setColor(0,255,0)
	love.graphics.printf('Round ' .. Lionblaster.InstanceData.GameData.stage .. " - " .. Lionblaster.InstanceData.GameData.round, 
		0, Lionblaster.PersistentData.Settings.height/4-6,
		Lionblaster.PersistentData.Settings.width/2, "center")
	love.graphics.pop()

	---------------

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	-- transition fading
	love.graphics.setAlpha(255-self.transitions.currentRGBA[4])
	love.graphics.rectangle('fill', 0, 0, Lionblaster.PersistentData.Settings.width, Lionblaster.PersistentData.Settings.height)

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

	if getKey('a') or getKey('start') then
		--audio.fadeout(self.transitions.fadeOutTime)...
		self.subState = 'fadeout'
	end

end

return state