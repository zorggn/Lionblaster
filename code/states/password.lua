-- Lionblaster Continue (Password Input) State
-- by zorg
-- @2014

local state = {}

function state:quit()

	appendLog("GameState	: password.quit")

	-- don't quit, go back to title screen
	self.destination = Lionblaster.InstanceData.GameStates.Title
	self.subState = 'fadeout'
	return true
end

function state:init()

	appendLog("GameState	: password.init")

	self.subState = 'init'
	self.destination = false

	-- set transition vars
	self.transitions = {}

	self.transitions.initialColor =	{  0,  0,  0,  0}
	self.transitions.fadeInColor =	{ 81,113,211,255} -- color to fade into
	self.transitions.fadeOutColor =	{  0,  0,  0,  0} -- color to fade out to
	self.transitions.fadeInTime =	0.5 -- seconds
	self.transitions.fadeOutTime =	0.5 -- seconds

	-- create cursor
	self.cursor = {}
	self.cursor.quads = {}
	self.cursor.quads[0] = love.graphics.newQuad( 0, 0, 20, 22, 60, 22)
	self.cursor.quads[1] = love.graphics.newQuad(20, 0, 20, 22, 60, 22)
	self.cursor.quads[2] = love.graphics.newQuad(40, 0, 20, 22, 60, 22)
	self.cursor.quads[3] = self.cursor.quads[1]
	self.cursor.quads.current = 0
	self.cursor.image = love.graphics.newImage(Lionblaster.InstanceData.Assets.gfx.cursors.bomb)
	self.cursor.pointer = love.graphics.newSpriteBatch(self.cursor.image, 1, "stream")
	self.cursor.x = 0
	self.cursor.y = 0
	self.cursor.id = self.cursor.pointer:add(self.cursor.quads[0],0,0)

	-- input field
	self.input = {}
	for i=1,8 do self.input[i] = ' ' end
	self.input.current = 1

	self.map = {
		{'A','B','C','D','E','F','G','H','I','J'},
		{'K','L','M','N','O','P','Q','R','S','T'},
		{'U','V','W','X','Y','Z','<','>','(',')'},
	}
end

function state:enter(from)

	appendLog("GameState	: password.enter")

	--self.transitions.fadeInColor = Lionblaster.InstanceData.Classes.Utils.Color.load("timeOfDay")

	-- set fading things
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

	self.destination = false
	self.subState = 'fadein'

end

function state:leave()

	appendLog("GameState	: password.leave")

	-- clear input field
	self.input = {}
	for i=1,8 do self.input[i] = ' ' end
	self.input.current = 1

	-- reset cursor position
	self.cursor.x = 0
	self.cursor.y = 0

end

function state:update(dt)

	-- animate the cursor
	self.cursor.quads.current = (self.cursor.quads.current + dt * 8) % 4
	self.cursor.pointer:set(self.cursor.id,self.cursor.quads[math.floor(self.cursor.quads.current)],0,0)

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

	-- go to a game or to the title screen

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

	love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])

	-- draw cursor
	love.graphics.draw(self.cursor.pointer,43+self.cursor.x*16,80+self.cursor.y*20)

	-- draw text
	love.graphics.printf('Please Input Password.', 50, 50, 175, 'left')

	love.graphics.printf('A B C D E F G H I J', 50, 90, 175, 'left')
	love.graphics.printf('K L M N O P Q R S T', 50, 110, 175, 'left')
	love.graphics.printf('U V W X Y Z < >()', 50, 130, 175, 'left')

	-- draw character position indicator
	love.graphics.setColor(255,127,39,self.transitions.currentRGBA[4])
	love.graphics.rectangle('fill', 95+(self.input.current-1)*9, 158, 7, 2)

	love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])

	-- draw out input spaces and input
	for i=1,8 do
		love.graphics.printf('_'          , 95+(i-1)*9, 152, 175, 'left')
		love.graphics.printf(self.input[i], 95+(i-1)*9, 150, 175, 'left')
	end

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

	-- u/d/l/r: navigation between letters and bottom row fx buttons
	-- a: select a letter and add it to the position last edited, then jump forward one space
	-- b: jump back one space
	-- start: go back to the menu
	-- select: unused

	print(self.cursor.y,self.cursor.x)

	if self.subState == 'continue' or self.subState == 'fadein' then

		if getKey('up') then
			self.cursor.y = (self.cursor.y - 1) % 3
		elseif getKey('down') then
			self.cursor.y = (self.cursor.y + 1) % 3
		elseif getKey('left') then
			self.cursor.x = (self.cursor.x - 1) % 10
		elseif getKey('right') then
			self.cursor.x = (self.cursor.x + 1) % 10
		
		elseif getKey('a') then
			-- fill in current space with selected character
			if not (self.cursor.y == 2 and self.cursor.x > 5) then
				self.input[self.input.current] = self.map[self.cursor.y+1][self.cursor.x+1]
				self.input.current = (self.input.current < 8) and (self.input.current + 1) or self.input.current
			elseif --[[ self.cursor.y == 2 and --]] self.cursor.x == 6 then -- go back one
				print("triggered go back")
				self.input.current = (self.input.current > 1) and (self.input.current - 1) or self.input.current
			elseif --[[ self.cursor.y == 2 and --]] self.cursor.x == 7 then -- go forward one
				print("triggered go forward")
				self.input.current = (self.input.current < 8) and (self.input.current + 1) or self.input.current
			elseif --[[ self.cursor.y == 2 and --]] self.cursor.x == 8 then -- clear all
				for i=1,8 do self.input[i] = ' ' end
				self.input.current = 1
			elseif --[[ self.cursor.y == 2 and --]] self.cursor.x == 9 then -- try password
				local s = ''
				for i=1,8 do s = s .. self.input[i] end
				--print("\\_(°_o)/")
				for i=1,8 do
					for j=1,8 do
						if Lionblaster.InstanceData.Assets.lvl[i][j].password == s then
							Lionblaster.InstanceData.GameData = {}
							Lionblaster.InstanceData.GameData.type = (Lionblaster.PersistentData.Settings.gameMode == '91') and 1 or 3
							Lionblaster.InstanceData.GameData.stage = i
							Lionblaster.InstanceData.GameData.round = j
							Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Game)
							return
						end
					end
				end
			end
		elseif getKey('b') then
			-- go back one space if we can
			self.input.current = (self.input.current > 1) and (self.input.current - 1) or self.input.current
		
		elseif getKey('start') then
			-- return to title
			self.destination = Lionblaster.InstanceData.GameStates.Title
			self.subState = 'fadeout'
		
		elseif getKey('select') then
			-- unused
		end
 	end

 	print("key pressed: " .. key)
	print("input pos: " .. self.input.current)
	print("input: " .. (function() local s = '' for i=1,8 do s = s .. self.input[i] end return s end)())

end

return state