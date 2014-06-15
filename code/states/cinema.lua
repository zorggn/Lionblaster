-- Lionblaster Cinema State
-- by zorg
-- @2014

-- Open the script defined by the parameter given to switch(), then switch back to the game state.

local state = {}

function state:init()
	-- nothing substantial to do here, since every script loaded will do its thing in the enter method
	-- we can create the script's table though (just so we don't pollute the state table, even though we wouldn't exactly...)
	self.script = {}
end

function state:goAway()
	--after the script cleared out the assets, clear the table as well
	self.script = {}

	--go to the game state or to the title, if we were watching the credits cinematic
	   Lionblaster.InstanceData.GameStates.GS.switch(self.destination)
end

function state:enter(from, parameter)
	-- load in the script defined by the parameter (script is a table having an enter, leave, update and draw functions, and a coroutine;
	-- hopefully with luajit, it can be yielded through boundaries...) or maybe no boundaries exist, idk
	self.script = require('code.scripts.'..parameter)
	assert(self.script ~= nil or type(self.script) == 'table','error: script not found')

	-- give the script access to the goAway function (and where we came from too...)
	self.script.destination = from
	self.script.goAway = self.goAway

	-- hook the update and draw fx-es to it
	self.update = self.script.update
	self.draw = self.script.draw
	-- start the script
	self.script:enter()
end

return state