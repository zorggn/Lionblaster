-- Bubble Babble (by Antti Huma)
-- Implemented in lua by zorg
-- @2014

local bit = require("bit")

local bb = {}

bb.consonants = {[0] = 'b','c','d','f','g','h','k','l','m','n','p','r','s','t','v','z','x'}
bb.vowels = {[0] = 'a','e','i','o','u','y'}
bb.iconsonants = {
	['b'] = 0,
	['c'] = 1,
	['d'] = 2,
	['f'] = 3,
	['g'] = 4,
	['h'] = 5,
	['k'] = 6,
	['l'] = 7,
	['m'] = 8,
	['n'] = 9,
	['p'] = 10,
	['r'] = 11,
	['s'] = 12,
	['t'] = 13,
	['v'] = 14,
	['z'] = 15,
	['x'] = 16,
}
bb.ivowels = {
	['a'] = 0,
	['e'] = 1,
	['i'] = 2,
	['o'] = 3,
	['u'] = 4,
	['y'] = 5,
}

function bb.dec2waybyte(self,a1,a2,offset)
	assert(a1<=16,"Corrupt string at offset " .. offset)
	assert(a2<=16,"Corrupt string at offset " .. offset)
	return bit.bor(bit.lshift(a1,4),a2)
end

function bb.dec3waybyte(self,a1,a2,a3,offset,c)
	local high2 = (a1-(c%6)+6)%6
	assert(high2<4,"Corrupt string at offset " .. offset)
	assert(a2<=16,"Corrupt string at offset " .. offset)
	local mid4 = a2
	local low2 = (a3-(math.floor(c/6)%6)+6)%6
	assert(low2<4,"corrupt string at offset " .. offset)
	return bit.bor(bit.lshift(high2,6),bit.lshift(mid4,2),low2)
end

function bb.decTuple(self,src,pos) -- for some reason, pos is not used
	local tuple = {}
	tuple[1] = self.ivowels[string.sub(src,1,1)]
	tuple[2] = self.iconsonants[string.sub(src,2,2)]
	tuple[3] = self.ivowels[string.sub(src,3,3)]
	if string.len(src) > 3 then
		tuple[4] = self.iconsonants[string.sub(src,4,4)]
		tuple[5] = '-'
		tuple[6] = self.iconsonants[string.sub(src,6,6)]
	end
	return tuple
end

function bb.detect(self,src)
	if string.sub(src,1,1) ~= 'x' or string.sub(src,-1,-1) ~= 'x' then return false end
	if string.len(src) ~= 5 and string.len(src)%6 ~= 5 then return false end
	-- if it doesnt match the CVCVC- pattern, it's not a legit bb code.
	--code would go here, though the function is unused so it doesn't matter much...
end

function bb.decode(self,src)
	assert(type(src) == 'string')
	local seed = 1 -- chksum

	assert(string.sub(src,1,1) == 'x',"Corrupt string at offset 0: must begin with an 'x'")
	assert(string.sub(src,-1,-1) == 'x',"Corrupt string at offset 0: must end with an 'x'")
	assert(string.len(src) == 5 or string.len(src)%6 == 5,"Corrupt string at offset 0: wrong length")

	-- probably could be optimized
	local spluk = {}
	local hurf = string.sub(src,2,-2)
	while true do
		spluk[#spluk+1] = string.sub(hurf,1,6)
		string.reverse(hurf)
		hurf = string.sub(hurf,7,-1)
		string.reverse(hurf)
		if hurf == '' then break end
	end

	local lastTuple = #spluk -- -1
	local result = ''

	for k,v in ipairs(spluk) do
		local pos = (k-1)*6
		v = self:decTuple(v,pos)
		for g,w in pairs(v) do
		end
		if k==lastTuple then
			if v[2] == 16 then
				--print"ends with x, no extra info byte"
				assert(v[1] == seed%6, "Corrupt string at offset $pos (checksum)")
				assert(v[3] == math.floor(seed/6), "Corrupt string at offset " .. (pos+3) .. " (checksum)")
			else
				--print"decode remaining byte"
				local byte = self:dec3waybyte(v[1],v[2],v[3],pos,seed)
				result = result .. string.char(byte)
			end
		else
			--print"decode infix tuple"
			local byte1 = self:dec3waybyte(v[1],v[2],v[3],pos,seed)
			local byte2 = self:dec2waybyte(v[4],v[6],pos)

			result = result .. string.char(byte1)
			result = result .. string.char(byte2)

			seed = (seed * 5 + byte1 * 7 + byte2) % 36
		end
	end
	return result
end

function bb.encode(self,input)
	assert(type(input) == 'string')
	local seed = 1 -- chksum
	local result = 'x'
	local i = 1
	while true do

		if i > string.len(input) then
			result = result .. self.vowels[(seed%6)]
			result = result .. self.consonants[16]
			result = result .. self.vowels[(math.floor(seed/6))]
			break
		end

		local byte1 = string.byte(string.sub(input, i, i))

		result = result .. self.vowels[math.floor((bit.band(bit.arshift(byte1,6),3)+seed)%6)]
		result = result .. self.consonants[bit.band(bit.arshift(byte1,2),15)]
		result = result .. self.vowels[((bit.band(byte1,3)+math.floor(seed/6))%6)]

		i = i + 1

		if i > string.len(input) then break end

		local byte2 = string.byte(string.sub(input, i, i))

		result = result .. self.consonants[bit.band(bit.arshift(byte2,4),15)]
		result = result .. '-'
		result = result .. self.consonants[bit.band(byte2,15)]

		seed = (seed * 5 + byte1 * 7 + byte2) % 36

		i = i + 1

	end

	result = result .. 'x'
	return result
end

return bb