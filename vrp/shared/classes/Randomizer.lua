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
