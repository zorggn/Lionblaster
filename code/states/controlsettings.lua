-- Lionblaster Control Redefinition State
-- by zorg
-- @2014

local state = {}

function state:quit()

	appendLog("GameState	: controlsettings.quit")

	-- don't quit, go back to settings screen
	self.destination = Lionblaster.InstanceData.GameStates.Settings
	self.subState = 'fadeout'
	return true

end

function state:init()

	appendLog("GameState	: controlsettings.init")

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

	self.selectedCL = 1

	self.inputAssigning = false

	-----------------------------------

	self.menu = {}
	self.menu.active = 0

	-------- Input

	self.menu[0] = {}
	self.menu[0].active = false
	self.menu[0].text = 'Input'

	self.menu[0].value = self.selectedCL

	self.menu[0].left  = function(self)
		if self.active then
			self.value = math.min(1, ((self.value - 1 - 1) % #Lionblaster.PersistentData.ControlList) + 1)
		end
	end
	self.menu[0].right = function(self)
		if self.active then
			self.value = math.max(#Lionblaster.PersistentData.ControlList, ((self.value + 1 - 1) % #Lionblaster.PersistentData.ControlList) + 1)
		end
	end
	self.menu[0].up = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
		else
			local option = core.menu.active
			option = (option - 1) % 11
			core.menu.active = option
		end
	end
	self.menu[0].down = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
		else
			local option = core.menu.active
			option = (option + 1) % 11
			core.menu.active = option
		end
	end
	self.menu[0].a = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
			core.selectedCL = self.value
			local inputTable = {'left','right','up','down','a','b','start','select'}
			for i=2,9 do
				core.menu[i].value = Lionblaster.PersistentData.ControlList[core.selectedCL][inputTable[i-1]]
			end
			self.active = false
		else 
			self.oldValue = self.value
			self.active = true
		end
	end
	self.menu[0].b = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
			self.value = self.oldValue
			self.active = false
		else
			local option = core.menu.active
			option = 10
			core.menu.active = option
		end
	end

	-------- Type

	self.menu[1] = {}
	self.menu[1].active = false
	self.menu[1].text = 'Type'

	self.menu[1].value = Lionblaster.PersistentData.ControlList[self.selectedCL].controllerID

	self.menu[1].left  = function(self)
		if self.active then
			self.value = (self.value == 'keyboard') and 'controller' or 'keyboard'
		end
	end
	self.menu[1].right = function(self)
		if self.active then
			self.value = (self.value == 'keyboard') and 'controller' or 'keyboard'
		end
	end
	self.menu[1].up = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
		else
			local option = core.menu.active
			option = (option - 1) % 11
			core.menu.active = option
		end
	end
	self.menu[1].down = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
		else
			local option = core.menu.active
			option = (option + 1) % 11
			core.menu.active = option
		end
	end
	self.menu[1].a = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
			self.active = false
		else 
			self.oldValue = self.value
			self.active = true
		end
	end
	self.menu[1].b = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if self.active then
			self.value = self.oldValue
			self.active = false
		else
			local option = core.menu.active
			option = 10
			core.menu.active = option
		end
	end

	-------- Input Definitions

	local inputTable = {'left','right','up','down','a','b','start','select'}

	for i=2,9 do
		self.menu[i] = {}
		self.menu[i].active = false
		self.menu[i].text = inputTable[i-1]

		self.menu[i].value = Lionblaster.PersistentData.ControlList[self.selectedCL][inputTable[i-1]]

		self.menu[i].up = function(self)
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			if self.active then
			else
				if not core.inputAssigning then
					local option = core.menu.active
					option = (option - 1) % 11
					core.menu.active = option
				end
			end
		end
		self.menu[i].down = function(self)
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			if self.active then
			else
				if not core.inputAssigning then
					local option = core.menu.active
					option = (option + 1) % 11
					core.menu.active = option
				end
			end
		end
		self.menu[i].a = function(self)
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			if self.active then
				if core.inputAssigning then
					self.active = false
					-- assignment happened
					core.inputAssigning = false
					return
				end
			else 
				self.active = true
				-- do assignment
				core.inputAssigning = true
			end
		end
		self.menu[i].b = function(self)
			local core = Lionblaster.InstanceData.GameStates.GS.current()
			if self.active then
			else
				local option = core.menu.active
				option = 10
				core.menu.active = option
			end
		end
	end

	self.menu[10] = {}
	self.menu[10].text = "Back"

	self.menu[10].up = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if not self.active then
			local option = core.menu.active
			option = (option - 1) % 11
			core.menu.active = option
		end
	end
	self.menu[10].down = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		if not self.active then
			local option = core.menu.active
			option = (option + 1) % 11
			core.menu.active = option
		end
	end
	self.menu[10].a = function(self)
		local core = Lionblaster.InstanceData.GameStates.GS.current()
		-- go to that game state
		core.destination = Lionblaster.InstanceData.GameStates.Settings
		core.subState = 'fadeout'
	end

end

function state:enter()

	appendLog("GameState	: controlsettings.enter")

	--self.transitions.fadeInColor = Lionblaster.InstanceData.Classes.Utils.Color.load("timeOfDay")

	-- set fading things
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

	self.destination = false
	self.subState = 'fadein'

end

function state:leave()

	appendLog("GameState	: controlsettings.leave")

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

	-- nop

	if self.subState == 'continue' then end

	-- go to the settings menu

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
	love.graphics.printf("--  Input Redefinition  --", xPos, yPos, 256, 'center')
	yPos = yPos + yHeight * 2
	

	for i=0,10 do

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
			yPos = yPos + yHeight
		elseif i == 1 then
			yPos = yPos + yHeight
			yPos = yPos + yHeight
			love.graphics.printf("-- Input Map --", xPos, yPos, 256, 'center')
			yPos = yPos + yHeight
			yPos = yPos + yHeight
		elseif i == 9 then
			yPos = yPos + yHeight
		end
	end

	-- print out the input id

	xPos = 128
	yPos = 9 * 2

	if self.menu.active == 0 then
		love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
	else
		love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
	end
	love.graphics.printf('#' .. self.menu[0].value, xPos-64, yPos, 174, 'left')

	-- print out the controller type

	yPos = yPos + yHeight * 2

	if self.menu[1].value == 'keyboard' then
		love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
		love.graphics.printf('keyboard', xPos-64, yPos, 174, 'left')
		love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
		love.graphics.printf('controller', xPos+32, yPos, 174, 'left')
	else
		love.graphics.setColor(191,191,191,self.transitions.currentRGBA[4])
		love.graphics.printf('keyboard', xPos-64, yPos, 174, 'left')
		love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
		love.graphics.printf('controller', xPos+32, yPos, 174, 'left')
	end
	
	-- print out the ctrl map things

	yPos = yPos + yHeight * 5

	for i=2,9 do
		if self.inputAssigning == true and self.menu.active == i then
			love.graphics.setColor(255,  31,  31, self.transitions.currentRGBA[4])
		else
			love.graphics.setColor(191, 191, 191, self.transitions.currentRGBA[4])
		end
		if self.menu[i].value == ' ' then
			love.graphics.printf('Space', xPos, yPos, 174, 'left')
		else
			love.graphics.printf(self.menu[i].value, xPos, yPos, 174, 'left')
		end
		yPos = yPos + yHeight
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

	if not self.inputAssigning then
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
			-- return to settings
			self.destination = Lionblaster.InstanceData.GameStates.Settings
			self.subState = 'fadeout'
		elseif getKey('select') then
			-- unused
		end
	else
		-- assign the pressed key to the slot
		self.menu[self.menu.active].value = key
		self.menu[self.menu.active]:a()
	end

end

return state