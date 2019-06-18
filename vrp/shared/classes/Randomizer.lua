-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Randomizer.lua
-- *  PURPOSE:     Static class to generate better random numbers
-- *
-- ****************************************************************************
Randomizer = inherit(Object)

function Randomizer:changeSeed()
	local seed = getTickCount()
	if self.m_LastSeed ~= seed then -- only change to a different seed from the last
		self.m_LastSeed = seed
		math.randomseed(seed)
	end
end

function Randomizer:get(min, max)
	self:changeSeed()
	return math.random(min, max)
end

function Randomizer:getRandomOf(n, opportunities)
	self:changeSeed()

	if n > #opportunities then
		return false
	end

	local result = {}
	for i = 1, n do
		local rand
		repeat
			rand = math.random(1, #opportunities)
		until not table.find(result, opportunities[rand])

		table.insert(result, opportunities[rand])
	end

	return result
end

function Randomizer:getRandomTableValue(tab)
	return tab[self:get(1, #tab)]
end

function Randomizer:nextDouble()
	return self:get(0, 10^6)/10^6
end
