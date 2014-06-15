--[[
	Lionblaster '91-mode intro
	@2014
	by zorg
--]]

scene = {}

function scene:enter()
	self.timer = 0.0
	-- create assets
	print('calling goAway soon... this is in the script though :3')
	--hax for now
	self:goAway()
end

function scene:leave()
	-- delete assets

end

function scene:update(dt)
	self.timer = self.timer + dt






end

function scene:draw()

end

return scene