-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        shared/classes/Randomizer.lua
-- *  PURPOSE:     Static class to generate better random numbers
-- *
-- ****************************************************************************
Randomizer = inherit(Object)

function Randomizer:changeSeat()
	math.randomseed(getTickCount())
end

function Randomizer:get(min, max)
	self:changeSeat()
	return math.random(min, max)
end

function Randomizer:getRandomOf(n, opportunities)
	if n > #opportunities then
		return false
	end

	local result = {}
	for i = 1, n do
		-- Todo: Try optimizing the following
		local rand
		repeat
			rand = math.random(1, #opportunities)
		until not table.find(result, opportunities[rand])

		table.insert(result, opportunities[rand])
	end

	return result
end

function Randomizer:getRandomTableValue(tab)
	return tab[math.random(1, #tab)]
end

function Randomizer:nextDouble()
	return self:get(0, 10^6)/10^6
end
