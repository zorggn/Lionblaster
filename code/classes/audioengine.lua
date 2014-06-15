-- Lionblaster Audio Engine
-- by zorg
-- @2014

--needed features: (all done)
--two separate arrays, one for bgm, other for sfx
--sfx methods: play(which,volume,speed)
--bgm methods: queue(which,volume,speed,fadeout,fadein)
--update callback: sfx-es are played instantaneously, and more can be played paralell; bgms will be faded out before the other gets called

-- todo: make code more comprehensible...

local ae = {}

-- sfx related
ae.sfx = {}

-- bgm related
ae.bgm = {}
ae.triggered = false
ae.curr = nil
ae.next = nil
ae.fadein = 0.0
ae.fadeout = 0.0
ae.fadevol = 1.0
ae.fadetype = 'none'

function ae.play(self,idx,vol,efg)  -- this way, one type of sfx can only be played once at a time... maybe this will be adjusted later.
	if not Lionblaster.Assets.sfx[idx].data then return end

	if self.sfx[idx] then
		if self.sfx[idx]:isPlaying() then
			self.sfx[idx]:rewind()
		elseif self.sfx[idx]:isStopped() then
			self.sfx[idx]:play()
		end
	else
		local sfx = love.audio.newSource(Lionblaster.Assets.sfx[idx].data)
		sfx:setVolume(vol)
		sfx:setPitch(efg)
		self.sfx[idx] = sfx
		sfx:play()
	end
end

function ae.queue(self,idx,vol,efg,fdi,fdo) -- efg -> portamento up/down/tone~ /trackers
	if not Lionblaster.Assets.bgm[idx].data then return end

	print('bgm data found')
	
	self.next = idx
	self.fadein = fdi
	
	-- if there's something playing, then fade that out, else just set fadeout to 0
	if self.curr ~= nil then
		if not self.bgm[self.curr]:isStopped() then
			--self.fadeout = fdo / self.bgm[self.curr]:getVolume() -- hopefully this will avoid abrupt volume spikes when rapidly queueing stuff
			self.fadeout = fdo -- this is in time, no reason to divide by the volume of the currently playing track... not this & not here anyway.
		else
			self.fadeout = 0
		end
	end

	-- check whether we already had this track playing
	if self.bgm[idx] then
		-- if so, just update values
		self.bgm[idx]:setLooping(Lionblaster.Assets.bgm[idx].loop)
		self.bgm[idx]:setVolume(vol)
		self.bgm[idx]:setPitch(efg)
	else
		-- otherwise create a source, put that into the table
		local bgm = love.audio.newSource(Lionblaster.Assets.bgm[idx].data)
		bgm:setLooping(Lionblaster.Assets.bgm[idx].loop)
		bgm:setVolume(vol)
		bgm:setPitch(efg)
		self.bgm[idx] = bgm
	end

	--trigger the change (play/restart)
	self.triggered = true

	print('debug data: queue',ae.triggered, ae.curr, ae.next, ae.fadein, ae.fadeout, ae.fadevol, ae.fadetype)

end

function ae.stop(self,fdo)
	-- set next to nothing
	self.next = nil
	self.fadeout = fdo or 0
	-- trigger the change
	self.triggered = true
end

do
local fiv -- the final volume of the track we need to fade into.
function ae.update(self,dt)


	--[[
		
		if there's nothing playing and something queued:

			current = next
			next = nil
			play current

			0-fadein->vol

		if there's something playing and something queued:

			vol-fadeout->0

			stop current
			current = next
			next = nil
			play current

			0-fadein->vol

	--]]

	-- something in the queue
	if self.triggered then

		if self.curr == nil and self.next == nil then return end

		if self.curr == nil then	-- if nothing's playing

			self.curr = self.next
			self.next = nil

			fiv = self.bgm[self.curr]:getVolume()
			--print('fadein final volume:',fiv)
			self.bgm[self.curr]:setVolume(0)
			self.fadevol = 0.0

			self.fadetype = 'in'
			self.bgm[self.curr]:play()

			self.triggered = false

			--print('debug data: trignil',ae.triggered, ae.curr, ae.next, ae.fadein, ae.fadeout, ae.fadevol, ae.fadetype)
		else						-- if something's playing
			fiv = self.bgm[self.curr]:getVolume()
			self.fadetype = 'out'
			self.triggered = false
			--print('debug data: trignum',ae.triggered, ae.curr, ae.next, ae.fadein, ae.fadeout, ae.fadevol, ae.fadetype)
		end
	else
		if self.fadetype == 'in' then
			if self.fadevol < fiv then
				self.fadevol = self.fadevol + (fiv / self.fadein) * dt
				if self.fadevol > fiv then
					self.fadevol = fiv
					self.fadetype = 'none'
				end
				self.bgm[self.curr]:setVolume(self.fadevol)
			end
			--print('debug data: fadein',ae.triggered, ae.curr, ae.next, ae.fadein, ae.fadeout, ae.fadevol, ae.fadetype)
		elseif self.fadetype == 'out' then
			if self.bgm[self.curr]:isStopped() then
				self.fadetype = 'none'
				self.curr = nil
				self.triggered = true
				return
			end
			if self.fadevol > 0 then
				self.fadevol = self.fadevol - (fiv / self.fadeout) * dt
				if self.fadevol < 0 then
					self.fadevol = 0.0
					self.bgm[self.curr]:stop()
					self.fadetype = 'none'
					self.curr = nil
					self.triggered = true
					return
				end
				self.bgm[self.curr]:setVolume(math.max(math.min(self.fadevol,1),0))
			end
			--print('debug data: fadeout',ae.triggered, ae.curr, ae.next, ae.fadein, ae.fadeout, ae.fadevol, ae.fadetype)
		end
	end
end
end

return ae