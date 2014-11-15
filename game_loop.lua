--[[
	The CTR-CSVFR Game Loop
	by zorg
	v1.0 @ 2014; license: isc
--]]

-- Description: A constant tickrate - (frame)limitable (frame)skippable variable frame rate game loop.

--[[
Copyright (c) 2014, zorg <zorg@atw.hu>

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
--]]

-- Since the game loop somewhat barfs into love.timer's inner workings, we need to fix that by defining a function doing what they're supposed to do:
-- Redefine a few love.timer functions to correctly work with the new game loop. (step steps the frame's duration, so getFPS works as intended)

-- Return the delta time from settings
love.timer.getDelta = function()

	local gs = settings.getSettings('gameSettings')
	return gs._tickInterval

end

-- set up variables to deal with our new averaged delta time calculations
love.timer._avgDeltaV = 0
love.timer._avgDelta = {}
love.timer._avgDeltaN = 0
love.timer._lastDelta = 0

love.timer.getAverageDelta = function()
	return love.timer._avgDeltaV
end

-- note that the function is lagging behind by one calculation always, since we don't recalculate the sum after we modify the series.
love.timer.stepDelta = function()

	local gs = settings.getSettings('gameSettings')
	local sum = love.timer._avgDelta
	local n = love.timer._avgDeltaN
	local last = love.timer._lastDelta -- implements circular buffer, no need for table.remove, probable speedup.

	-- check if the series already exceeds one second
	local accum = 0
	for i=1,n do
		accum = accum + sum[i]
	end

	if accum > 1.0 then
	-- if it does, -remove- replace the first, move the pointer +1%n, and add the current, then return the sum divided by n
		---[[
		last = (last + 1) % n
		sum[last] = gs._tickInterval
		love.timer._lastDelta = last
		--]]
		--[[
		table.remove(sum,1)
		sum[n] = gs._tickInterval
		--]]
		return accum / n
	else
	-- else, add another element to the end, then return the sum with the new element, divided by n
		n = n + 1
		sum[n] = gs._tickInterval
		accum = accum + sum[n]
		love.timer._lastDelta = n
		love.timer._avgDeltaN = n
		return accum / n
	end
end



-- Return the game loop

return function()

	-- disable the garbage collector
	collectgarbage('stop')

	-- seed love's prng
	if love.math then
		love.math.setRandomSeed(os.time())
	end

	-- pump first event
	if love.event then
		love.event.pump()
	end

	-- if we defined love.load, execute it with the command line arguments as parameter.
	if love.load then love.load(arg) end

	-- make the table containing clientPacketRate, tickRate, maxFrameRate locals here; probably don't need the packetRate here.
	-- we store a pointer to the table, since we should be able to set at least the max framerate in-game without the need to reload this.
	local gs = settings.getSettings('gameSettings')

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end



	-- create locals
	local previousUpdate = love.timer.getTime()
	local previousRender = love.timer.getTime()
	local lag = 0.0
	local frameRate = 1.0
	local skippedFrames = 0

	-- Main loop time.
	while true do

		-- Calculate lag
		local currentUpdate = love.timer.getTime()
		local elapsedUpdate = currentUpdate - previousUpdate
		previousUpdate = currentUpdate
		lag = lag + elapsedUpdate

		-- Update - Constant Tick Rate
		local updateInterval = gs._tickInterval
		local updateIterations = 0

		while lag >= updateInterval do
			-- Bail out early, if iterations reach a stupidly high count - slowdown, but at least guarantee some visible feedback.
			if updateIterations > 3 then
				print("breakd: " .. lag)
				break
			end

			--print("update: " .. lag)

			-- Process events
			if love.event then
				love.event.pump()
				for e,a,b,c,d in love.event.poll() do
					if e == "quit" then
						if not love.quit or not love.quit() then
							if love.audio then
								love.audio.stop()
							end
							return
						end
					end
					love.handlers[e](a,b,c,d)
				end
			end

			-- calculate averaged delta
			if love.timer then
				love.timer.stepDelta()
			end

			-- update states
			if love.update then love.update(updateInterval) end

			-- if a module / object is double buffered, swap state( pointer)s so the read and write ones switch places.
			-- implement this as an entity properity or mixin or whatever, not as a global barf!
			if love.swap then love.swap() end

			lag = lag - updateInterval
			updateIterations = updateIterations + 1
		end


		-- Calculate Frame Interval
		local currentRender = love.timer.getTime()
		local elapsedRender = currentRender - previousRender
		previousRender = currentRender
		frameRate = frameRate + elapsedRender

		-- Render - Clamped Variable Frame Rate
		local frameInterval = gs._maxFrameInterval
		local maxFrameSkip = gs.maxFrameSkip

		-- Bail out early, if the time elapsed between frames is less than the inverse of the frame rate, aka the frame interval.
		-- ...or if the update lag's bigger than the update interval, and the max frameskip value is not reached.
		if --[[(frameRate > frameInterval) and--]] (lag < updateInterval or skippedFrames >= maxFrameSkip) then

			--print("render: " .. frameRate)

			if love.timer then
           		love.timer.step()
       		end

			if love.window and love.graphics and love.window.isCreated() then
				love.graphics.clear()
				love.graphics.origin()

				if love.draw then love.draw(lag/updateInterval, updateInterval) end

				-- this should really not be here just like this...
				love.graphics.setColor(255,255,255,255)
				love.graphics.print("render lag:", 0, 0)
				love.graphics.print("update lag:", 0, 12)
				love.graphics.print("memory (kB):", 0, 24)
				love.graphics.print(math.floor(frameRate*10000)/10000, 100, 0)
				love.graphics.print(math.floor(lag*10000)/10000, 100, 12)
				love.graphics.print(math.floor(collectgarbage('count')*100)/100, 100, 24)

				love.graphics.print(frameInterval - frameRate+updateInterval - lag, 100, 142)

				love.graphics.present()
			end

			frameRate = frameRate - frameInterval --0
			skippedFrames = 0

		elseif (lag >= updateInterval or frameRate > frameInterval) and (skippedFrames < maxFrameSkip) then

			print("skip'd: " .. skippedFrames)

			skippedFrames = skippedFrames + 1

		end

		collectgarbage('step',1)

		if love.timer then
			--love.timer.sleep(0.001)
			--local t = frameInterval - frameRate + updateInterval - lag
			local t = (frameInterval - frameRate)
			love.timer.sleep(t)
		end

	end

end