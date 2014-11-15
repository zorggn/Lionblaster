-- Bomb entity factory

local entity = require 'src.entity'

local bomb = {}

-- we pass the entity to it so it can copy its own bomb data from it
bomb.new = function(player)

	-- all of the below components should only get their data from the player entity.
	local e = entity.new(
	'tilePosition',						-- where it is on the grid
	'worldPosition',					-- where it is in the world with pixel precision
	'graphics',							-- includes graphics for one animation
	'hierarchy',						-- parent = player, children = explosion tiles
	'pushable',							-- can be pushed, by players that have a push or kick powerup only
	'exploder',							-- after fuse is done, hides itself and creates explosion entities with parameters
	)

	--  make a "class" function that copies over a component's data, along with others that would be helpful
	--e.tilePosition = player.tilePosition:copy(1)

	--e.worldPosition = player.tilePosition:toWorldPosition(world,1)

	-- ...

end

return bomb