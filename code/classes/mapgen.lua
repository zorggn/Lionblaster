-- Lionblaster Map (HashTable) Generator Class
-- by zorg
-- @2014

MapGen = {}

function MapGen:init(Entity)
	self.prng = love.math.newRandomGenerator()
	self.Entity = Entity
end

function MapGen:generateRectangular(parameter)

	-- note: every entity list in the hashtable's cells will have the world's texture as the first entity (i.e. grass on world 1)
	--       everything else will follow, so if additional hard walls will be placed (a certain sudden death overtime mode), then
	--       that action can also safely toggle the "shaded" alt texture for the world tile below it (if it exists, of course).

	-- hold the passed parameters in a local variable (r,s,w,h,i,m -- round, stage, width, height, item, mob)
	local p = parameter

	-- check if we have a playerCount param, if not, set it to 0 (since no real players for beastiary... although this should never be nil)
	if p.playerCount == nil then p.playerCount = 0 end

	-- seed the randgen with a given seed or a random value
	--...

	-- create the hash table, with the needed dimensions (+2,+2 for borders on 4 sides, but that extra tidbit can be deferred to the end)
	local t = {}

	self.Entity:assignHashTable(t)

	for i = 1, p.w do
		t[i] = {}

		for j = 1, p.h do
			t[i][j] = {}	

			-- tile placement, always on index 1 (shading can be toggled later by appropriate methods)
			if (i-1)%2==1 and (j-2)%2==1 and not j==1 then
				-- place a shaded variant of the tile
				--[[ t[i][j][1] = ]] self.Entity:addEntity(i,j,'Map','tile','static','floor',{['world'] = p.s, ['shaded'] = true})
			else
				-- place an unshaded variant
				--[[ t[i][j][1] = ]] self.Entity:addEntity(i,j,'Map','tile','static','floor',{['world'] = p.s, ['shaded'] = false})
			end

			-- wall placement; guaranteed to be on index 2 (when creating it here)
			if (i-1)%2==1 and (j-1)%2==1 then
				-- hard wall placement
				--[[ t[i][j][2] = ]] self.Entity:addEntity(i,j,'Map','hWall','static','hwall',{['world'] = p.s})
			else
				-- soft wall placement

				if  (p.playerCount >= 1) and (i <     3 and j <     3) or 
					(p.playerCount >= 2) and (i > p.w-3 and j > p.h-3) or 
					(p.playerCount >= 3) and (i > p.w-3 and j <     3) or 
					(p.playerCount >= 4) and (i <     3 and j > p.h-3) or 
					(self.prng:random() > p.swf)
				then
					-- do nothing
				else
					-- place down soft wall (not on any round 8)
					if p.r < 8 then
						--[[ t[i][j][2] = ]] self.Entity:addEntity(i,j,'Map','sWall','static','swall',{['world'] = p.s})
					end
				end
			end
		end
	end

	-- create additional data regarding the world
	t.width =  p.w + 2 -- including the borders for collisions to work
	t.heigth = p.h + 2 --         -         "        -

	-- place mobs randomly (not on player spawn positions)

	for i,v in ipairs(p.m) do
		local ii = self.prng:random(1,p.w)
		local jj = self.prng:random(1,p.h)
		local placed = false
		local counter = 0
		repeat
			counter = counter + 1
			-- don't place mobs near players
			if not (
				((p.playerCount >= 1) and (ii <     3 and jj <     3)) or 
				((p.playerCount >= 2) and (ii > p.w-3 and jj > p.h-3)) or 
				((p.playerCount >= 1) and (ii < p.w-3 and jj <     3)) or 
				((p.playerCount >= 2) and (ii <     3 and jj > p.h-3)) or
				(t[ii][jj][#t[ii][jj]].type == 'swall' or
				 t[ii][jj][#t[ii][jj]].type == 'hwall')
				)
			then
				--[[ t[i][j][#t[i][j]+1] = ]] --self.Entity:addEntity(i,j,'Mobs',v,v,'mob',nil)
				self.Entity:addEntity(ii,jj,'Mobs','boyon','boyon','mob',nil) -- for now :V
				break
			end
			if counter > p.w*p.h then break end -- inf loop fixage
			-- try another position
			ii = self.prng:random(1,p.w)
			jj = self.prng:random(1,p.h)
		until placed
	end

	-- place players, link camera to the local player(s)

	local localPlayer = 1
	for iter=1,p.playerCount do
		local ii =
					(iter == 1 or iter == 4) and 1   or
					(iter == 2 or iter == 3) and p.w
		local jj =
					(iter == 1 or iter == 3) and 1   or
					(iter == 2 or iter == 4) and p.h
		
		local pe = self.Entity:addEntity(ii,jj,'Players','bomberman','bomberman',{['skin'] = Lionblaster.PersistentData.UserList[iter].skin or nil})
		if iter == localPlayer then Lionblaster.Camera:create(pe,ii,jj,1.0) end
	end

	-- place the map-specific powerup item(s)

		-- can wait

	-- place the portal(under a soft wall, if not on stage 8; if yes, then it will be placed in the boss' death code)

		-- can wait

	-- no need to return the map via conventional means...

	-- the hashTable containing an array of arrays of array that holds entities at the specific 2D position on the grid,
	-- along with the map's width and height in cells (starting from 1,1... that being a corner border on rectangular maps)
	-- on custom maps, the map's true size needs to be as big as the most extreme existing tiles created (effectively containing nil cells)

end

return MapGen