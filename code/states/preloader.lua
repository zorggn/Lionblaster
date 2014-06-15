-- Lionblaster Preloader State
-- by zorg
-- @2014

local state = {}

function state:quit()

	appendLog("GameState	: preloader.quit")

	-- Can't quit while the preloader's working, since we don't want to allow the elapsedTime to be added here...
	-- unless caused by an error; then it won't be added.
	return true
end

function state:init()
	-- Runs only once.

	appendLog("GameState	: preloader.init")

	-- set sub-state
	self.subState = 'init'

	-- this elapsedTime is local to the state.
	self.elapsedTime = 0.0 -- seconds; 

	-- set transition vars
	self.transitions = {}

	self.transitions.initialColor =	{  0,  0,  0,  0}
	self.transitions.fadeInColor =	{  0,  0,  0,255} -- color to fade into
	self.transitions.fadeOutColor =	{  0,  0,  0,  0} -- color to fade out to
	self.transitions.fadeInTime =	2.0 -- seconds
	self.transitions.fadeOutTime =	2.0 -- seconds

	self.coAccum = 0 -- how many times has the coroutine returned

	----------------------------------------------------------------------------

	-- Create a coroutine that will load in all the needed assets, if they exist.
	self.co = coroutine.create(
		function(x)

			appendLog('notice	: entered preloader coroutine...')

			local y = coroutine.yield
			local folder = ''
			local files = ''

			---------------------------

			-- Search for shaders in save folder, if it exists... if it does, import them (two ways)
			-- .lua -> search for a shader member, and assume that's a l.g.newShader call, put result in .shader
			-- .frag -> call l.g.newShader "manually" and put result in .shader
			-- shaders.name <string>
			-- shaders.shader <shader>
			local shaders = Lionblaster.PersistentData.Shaders

			folder = '/shaders/'

			if love.filesystem.isDirectory(folder) then
				local shader = love.filesystem.getDirectoryItems(folder)
				for i, s in ipairs(shader) do
					local name = string.match(s, "^(%w+)")
					local ext  = string.match(s, "(%w+)$")
					--if ext == 'lua' then
					--	shaders[#shaders+1] = {}
					--	shaders[#shaders].name = name
					--	shaders[#shaders].ex = require(folder .. s)
					--	shaders[#shaders].shader = shaders[#shaders].ex.shader
					if ext == 'frag' then
						shaders[#shaders+1] = {}
						shaders[#shaders].name = name
						shaders[#shaders].shader = love.graphics.newShader(folder .. s)
					end
				end
			end

			-- create graphical locals and table stucture

			Lionblaster.InstanceData.Assets.gfx.spriteMaps = {}
			local sm = Lionblaster.InstanceData.Assets.gfx.spriteMaps

			Lionblaster.InstanceData.Assets.gfx.cursors = {}
			local cur = Lionblaster.InstanceData.Assets.gfx.cursors

			Lionblaster.InstanceData.Assets.gfx.backgrounds = {}
			local bg = Lionblaster.InstanceData.Assets.gfx.backgrounds

			y(1)

			-- load in default graphics stuff...

			folder = '/gfx/'
			if love.filesystem.isDirectory(folder) then

				appendLog('notice	: default graphics folder found, loading assets...')

				-- backgrounds
				bg.title = love.image.newImageData(folder .. 'bg_title.png')
				bg.stage91 = love.image.newImageData(folder .. 'bg_stage91.png')

				y(1)

				-- cursors
				cur.pointerTriangle = love.image.newImageData(folder .. 'cursor_pointertriangle.png')
				cur.pointerCircle = love.image.newImageData(folder .. 'cursor_pointercircle.png')
				cur.bomb = love.image.newImageData(folder .. 'cursor_bomb.png')
				cur.head = love.image.newImageData(folder .. 'cursor_head.png')

				y(1)

				-- ingame data
				folder = folder .. 'game/'
				files = {}

				sm.tiles = {}
				files = love.filesystem.getDirectoryItems(folder .. 'tile/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'tile/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.tiles[index] = love.image.newImageData(folder .. 'tile/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.effects = {}
				files = love.filesystem.getDirectoryItems(folder .. 'effect/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'effect/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.effects[index] = love.image.newImageData(folder .. 'effect/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.items = {}
				files = love.filesystem.getDirectoryItems(folder .. 'item/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'item/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.items[index] = love.image.newImageData(folder .. 'item/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.bombs = {}
				files = love.filesystem.getDirectoryItems(folder .. 'bomb/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'bomb/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.bombs[index] = love.image.newImageData(folder .. 'bomb/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.explosions = {}
				files = love.filesystem.getDirectoryItems(folder .. 'explosion/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'explosion/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.explosions[index] = love.image.newImageData(folder .. 'explosion/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.mobs = {}
				files = love.filesystem.getDirectoryItems(folder .. 'mob/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'mob/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.mobs[index] = love.image.newImageData(folder .. 'mob/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.players = {}
				files = love.filesystem.getDirectoryItems(folder .. 'player/')
				for i, file in ipairs(files) do
					print(i,file)
					if love.filesystem.isFile(folder .. 'player/' .. file) then
						print("WORKS")
						local index = string.match(file, "^(%w+)")
						sm.players[index] = love.image.newImageData(folder .. 'player/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.overlay = {}
				files = love.filesystem.getDirectoryItems(folder .. 'overlay/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'overlay/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.overlay[index] = love.image.newImageData(folder .. 'overlay/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

				sm.hudicons = {}
				files = love.filesystem.getDirectoryItems(folder .. 'hudicon/')
				for i, file in ipairs(files) do
					if love.filesystem.isFile(folder .. 'hudicon/' .. file) then
						local index = string.match(file, "^(%w+)")
						sm.hudicons[index] = love.image.newImageData(folder .. 'hudicon/' .. file)
					end
					y(#files > 0 and 1.0/#files or 0)
				end

			else

				appendLog("error	: default graphics folder not found, exiting game...")
				love.event.quit(true)
				y(0)

			end

			-- load in default music stuff...

			local bgm = Lionblaster.InstanceData.Assets.bgm

			folder = '/bgm/'
			if love.filesystem.isDirectory(folder) then

				appendLog('notice	: default music folder found, loading assets...')

				files = love.filesystem.getDirectoryItems(folder)
				for i, file in ipairs(files) do
					if love.filesystem.isFile(file) then
						local index, _, name = string.match(file, "^(%d+)(%s%-%s+)([%g%s]*)")
						bgm[index] = {}
						if love.system.getOS() == 'OS X' then
							bgm[index].data = love.sound.newSoundData(folder .. file)
						else
							bgm[index].data = love.sound.newDecoder(folder .. file)
						end
						bgm[index].name = name
					end
					y(#files > 0 and 1.0/#files or 0)
				end

			else

				appendLog("error	: default music folder not found, exiting game...")
				love.event.quit(true)
				y(0)

			end

			-- load in default sound effect stuff...

			local sfx = Lionblaster.InstanceData.Assets.sfx

			folder = '/sfx/'
			if love.filesystem.isDirectory(folder) then

				appendLog('notice	: default sound effect folder found, loading assets...')

				files = love.filesystem.getDirectoryItems(folder)
				for i, file in ipairs(files) do
					if love.filesystem.isFile(file) then
						local index, _, name = string.match(file, "^(%d+)(%s%-%s+)([%g%s]*)")
						sfx[index] = {}
						sfx[index].data = love.sound.newSoundData(folder .. file) -- always loaded
						sfx[index].name = name
					end
					y(#files > 0 and 1.0/#files or 0)
				end

			else

				appendLog("error	: default sound effect folder not found, exiting game...")
				love.event.quit(true)
				y(0)

			end

			-- load in the cinema data

			local cine = Lionblaster.InstanceData.Assets.cine

			folder = '/code/scripts/'
			if love.filesystem.isDirectory(folder) then

				appendLog('notice	: cinema scripts folder found, loading assets...')

				files = love.filesystem.getDirectoryItems(folder)
				for i, file in ipairs(files) do
					if love.filesystem.isFile(file) then
						local index = string.match(file, "^(%w+)")
						cine[index] = folder .. file
					end
					y(#files > 0 and 1.0/#files or 0)
				end

			else

				appendLog("error	: cinema scripts folder not found, exiting game...")
				love.event.quit(true)
				y(0)

			end

			-- load in the level data

			local lvl = Lionblaster.InstanceData.Assets.lvl

			folder = '/code/levels/'
			if love.filesystem.isDirectory(folder) then

				appendLog('notice	: levels folder found, loading assets...')

				files = love.filesystem.getDirectoryItems(folder)
				for i, dir in ipairs(files) do
					if love.filesystem.isDirectory(dir) then
						-- directories in levels folder root are taken as level collections, and are loaded into one sub-table
						level[dir] = {}
						local files_ = love.filesystem.getDirectoryItems(folder .. dir)
						for j, file in ipairs(files_) do
							if love.filesystem.isFile(file) then
								local index = string.match(file, "^(%w+)")
								lvl[dir][index] = folder .. dir .. file
							end
							y(#files_ > 0 and 1.0/#files_ or 0)
						end
					elseif love.filesystem.isFile(dir) then
						-- files in levels folder root are init scripts containing whole worlds that will generate all underlying levels
						lvl[dir] = require(folder .. string.match(dir, "^(%w+)"))
						y(#files > 0 and 1.0/#files or 0)
					end
				end

			else

				appendLog("error	: levels folder not found, exiting game...")
				love.event.quit(true)
				y(0)

			end


			-- Prebake local player spritesheet
			if string.upper(Lionblaster.PersistentData.User.name) == 'SHIRO' then
				appendLog('notice	: default player skin selected')

				Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets = {}
				Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets[1] = love.graphics.newCanvas(Lionblaster.InstanceData.Assets.gfx.spriteMaps.players.shiro:getWidth(),32)

				bake(Lionblaster.InstanceData.Assets.gfx.spriteMaps.players.shiro,
					Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets[1],
					true
				)

				y(0)
			else
				appendLog('notice	: baking player skin...')

				Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets = {}
				Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets[1] = love.graphics.newCanvas(Lionblaster.InstanceData.Assets.gfx.spriteMaps.players.playerComponents:getWidth(),32)

				bake(Lionblaster.InstanceData.Assets.gfx.spriteMaps.players.playerComponents,
					Lionblaster.InstanceData.GameData.PrebakedPlayerSpriteSheets[1]
				)

				y(11)
			end

		end


	)
end

function state:enter()

	appendLog("GameState	: preloader.enter")

	-- create transition variables
	self.transitions.currentRGBA = {}
	for i=1,4 do self.transitions.currentRGBA[i] = self.transitions.initialColor[i] end
	self.transitions.fadeCounter = 0.0 -- fadein -> 0.0 -> 1.0; fadeout -> 0.0 -> 1.0

	-- create loader text vars
	self.loader = {}

	self.loader.text = "loading"
	self.loader.dotCount = 0
	self.loader.dotString = ""

	-- start fading in
	self.subState = 'fadein'

end

function state:leave()

	appendLog("GameState	: preloader.leave")

	-- reset timer, we start counting game time from the title screen state.
	Lionblaster.InstanceData.elapsedTime = 0.0

	-- clean up coroutine and vars
	self.co = nil
	-- self = nil -- ropblem, officer? :3 -- do lets keep this here so we can check where we came from in the title state, hmm?

	-- enable text input
	love.keyboard.setTextInput(true)
	love.keyboard.setKeyRepeat(true)

end

function state:update(dt)

	self.elapsedTime = self.elapsedTime + dt

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

	-- fade-out sequence

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

	-- update state of indicator except if the substate is leave

	if self.subState ~= 'leave' then
		local num = self.loader.dotString:len()
		if num < math.floor(self.loader.dotCount) then
			for i=1,self.loader.dotCount - num do
				self.loader.dotString = self.loader.dotString .. '.'
			end
		end
	end

	-- resume the coroutine

	if self.subState == 'continue' --[[or self.subState == 'fadein'--]] then
		self.transitions.fadeCounter = self.transitions.fadeCounter + (dt / 3.0) -- stay time.
		if self.co and coroutine.status(self.co) ~= 'dead' then
			local a,b = coroutine.resume(self.co)
			if b ~= nil then
				print(b)
				self.loader.dotCount = self.loader.dotCount + b 
			end
		else
			-- both the coroutine must be dead, and the counter must reach 3 seconds (we normalized it to 0.0-1.0 above)
			if self.transitions.fadeCounter >= 1.0 then
				self.transitions.fadeCounter = 0.0
				self.subState = 'fadeout'
			end
		end
	end

	-- leave this state if the coroutine has finished

	if self.subState == 'leave' then
		Lionblaster.InstanceData.GameStates.GS.switch(Lionblaster.InstanceData.GameStates.Title)
	end

end

function state:draw()

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	-- transition color set
	love.graphics.setColor(self.transitions.currentRGBA)

	love.graphics.setBackgroundColor(self.transitions.currentRGBA)

	Lionblaster.InstanceData.Classes.Utils.Color.push()

	-- LOVE2D text
	love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
	love.graphics.print("Made with       ", 64, 106)
	love.graphics.setColor(127,127,255,(math.abs(math.sin(self.elapsedTime*math.pi/1000))*255)*self.transitions.currentRGBA[4])
	love.graphics.print("           .    ", 61,  99)
	love.graphics.print("           .    ", 66,  99)
	love.graphics.setColor(255,255,  0,self.transitions.currentRGBA[4])
	love.graphics.print("          LOVE  ", 64, 106)
	--if     (self.elapsedTime > 1.400 and self.elapsedTime < 1.425) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.25)
	--elseif (self.elapsedTime > 2.150 and self.elapsedTime < 2.300) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.33)
	--elseif (self.elapsedTime > 2.425 and self.elapsedTime < 2.475) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.5)
	--elseif (self.elapsedTime > 2.525 and self.elapsedTime < 2.550) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.25)
	if     (self.elapsedTime > 2.283 and self.elapsedTime < 2.328) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.25)
	elseif (self.elapsedTime > 3.096 and self.elapsedTime < 3.150) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.33)
	elseif (self.elapsedTime > 3.258 and self.elapsedTime < 3.311) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.5)
	elseif (self.elapsedTime > 5.989 and self.elapsedTime < 6.068) then love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.925)
	else                                                                love.graphics.setColor(255,  0,  0,self.transitions.currentRGBA[4]*0.0625)
	end
	love.graphics.print("              2D", 64, 106)

	-- credit strings
	if self.subState == 'continue' or self.subState == 'fadeout' then
		local alpha1 = 0
		local alpha2 = 0
		local alpha3 = 0

		local function fader(time, begin, current, dt)
			return current * dt/time + begin
		end

		-- ser
		if     self.elapsedTime < 2.0 then
			alpha1 = 0
		elseif self.elapsedTime < 3.0 then
			alpha1 = fader(1.0,0,255,self.elapsedTime-2.0)
		elseif self.elapsedTime < 4.0 then
			alpha1 = 255
		elseif self.elapsedTime < 5.0 then
			alpha1 = fader(1.0,255,-255,self.elapsedTime-2.0)
		else
			alpha1 = 0
		end
		love.graphics.setColor(255,255,255,alpha1)
		love.graphics.print("robin:ser", 42 - self.transitions.fadeInTime + (10 * self.elapsedTime), 141)

		-- hump.gamestates
		if     self.elapsedTime < 2.5 then
			alpha2 = 0
		elseif self.elapsedTime < 3.5 then
			alpha2 = fader(1.0,0,255,self.elapsedTime-2.5)
		elseif self.elapsedTime < 4.5 then
			alpha2 = 255
		elseif self.elapsedTime < 5.5 then
			alpha2 = fader(1.0,255,-255,self.elapsedTime-2.5)
		else
			alpha2 = 0
		end
		love.graphics.setColor(255,255,255,alpha2)
		love.graphics.print("vrld:hump.gamestates", 75 + self.transitions.fadeInTime - ((10 * self.elapsedTime) % 5), 155)

		-- radarchart
		if     self.elapsedTime < 3.0 then
			alpha3 = 0
		elseif self.elapsedTime < 4.0 then
			alpha3 = fader(1.0,0,255,self.elapsedTime-3.0)
		elseif self.elapsedTime < 5.0 then
			alpha3 = 255
		elseif self.elapsedTime < 6.0 then
			alpha3 = fader(1.0,255,-255,self.elapsedTime-3.0)
		else
			alpha3 = 0
		end
		love.graphics.setColor(255,255,255,alpha3)
		love.graphics.print("josefnpat:radarchart", 32 + math.cos(self.elapsedTime * math.pi * 4), 169 + math.sin(self.elapsedTime * math.pi * 4))

	end

	-- loading...
	love.graphics.setColor(255,255,255,self.transitions.currentRGBA[4])
	love.graphics.printf(self.loader.text .. self.loader.dotString, 10, 204, 246, 'right')

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	-- transition fading
	love.graphics.setAlpha(255-self.transitions.currentRGBA[4])
	love.graphics.rectangle('fill', 0, 1, Lionblaster.PersistentData.Settings.width, Lionblaster.PersistentData.Settings.height)

	Lionblaster.InstanceData.Classes.Utils.Color.pop()

	drawDebug()

end


function state:keypressed(key,isRepeat)
	print("triggered at " .. self.elapsedTime)
end

function state:keyreleased(key)
	print("released at " .. self.elapsedTime)
end


return state