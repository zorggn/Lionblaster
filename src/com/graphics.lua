-- the entity's graphics data
-- could probably tear this apart more, but for now, this will suffice
-- and yes, this can only draw images (and image regions) for now, no meshes.

local static = {}

-- creates initial hierarchy structure for entity
static.init = function(self)
	-- this always exists as a fallback, and is always overwritten when a set happens, and the tables differ.
	current = {
		-- dimensions
		w = 1,
		h = 1,
		-- offsets (translation)
		ox = 0,
		oy = 0,
		-- orientation (rotation) and centre offsets
		phi = 0,
		cx = 0,
		cy = 0,
		-- scale
		sx = 1.0,
		sy = 1.0,
		-- flip
		fv = false,
		fh = false,
		fd = false,
		-- image or atlas/tilemap, with an optional quad
		--image = nil
		-- quad = nil
		-- 3D rotation, not implemented
		--[[
			r = {
				-- horiz., vert., diag. flip; z-axis rotation; x, y shearing; x, y mindpoint scale multiplier
				hf,vf,df,phi,kx,ky,kw,kh = false,false,false,0.0,0.0,0.0,1.0,1.0
			}
		--]]
	}

	-- these are the separate graphical states for an entity
	state = {}

	-- string:number pairs for easier handling
	stateEnums = {['default'] = 1}

	-- which graphics state we are in
	currentState = 1

	state[1] = {

		-- graphics data - state fallback
		graphics = current, -- if we edit a state's graphics, we want the fallback to be the last setting, so if it isn't do graphics.current = g.

		-- animation data
		animation = {
			frameCount = 1, -- how many frames are in this set; 1 makes it static, so framedelay, and loop properities are moot in that case.
			currentFrame = 1, -- which frame are we on
			frameDelay = 0.0, -- how long, in seconds, should a frame stay in place (granularity up to the defined frameRate, not the tickRate)
			biDirectional = false, -- if true, do the animation in reverse as well.
			isLooping = true, -- if false, it one-shots through the frames
			loopStart = 1,
			loopEnd = 1,
			resetOnSwitch = true, -- if true, it will reset currentFrame to 1, else it will be left alone.
		},

		-- the frames of a state
		frame = {},

		frame[1] = {
			graphics = current,
			frameDelay = 0.0,
		}
	}
end

-- switch the graphics state
static.switchState = function(self,state,frame)
	local state = state
	if type(state) ~= 'number' then
		state = self.stateEnums[state]
		assert(state,"Error: no graphics state found with that name.")
	end
	assert(self.state[state].animation.frameCount >= frame,"Error: specified frame doesn't exist in the target animation")
	self.currentState = state
	self.state[state].animation.currentFrame = frame
end

-- toString method
static.toString = function(self)
	local t = {}
	table.insert(t,'hierarchy:\n')

	table.insert(t,'parent: ')
	table.insert(t,self.parent or 'nil')
	table.insert(t,'\n')
	table.insert(t,'children:')
	if #self.children then
		table.insert(t,' nil')
	else
		table.insert(t,'\n')
		for i,v in ipairs(self.children) do
			table.insert(t,'  ')
			table.insert(t,i)
			table.insert(t,'. ')
			table.insert(t,v)
		end
	end
	return table.concat(t,'')
end

-- factory
local graphics = function()
	return setmetatable(
		{},
		{
			__index = static,
		}
	)
end

return graphics