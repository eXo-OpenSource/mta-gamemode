-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Karma.lua
-- *  PURPOSE:     (static) Karma calculation
-- *
-- ****************************************************************************
Karma = {}

function Karma.calcKarma(currentKarma, modifyKarma, factor)
	local offsetkarma = math.abs(currentKarma, modifyKarma)
	
	-- http://www.wolframalpha.com/input/?i=-1%2F20x^2%2B1
	local changekarma = -1/20*(offsetkarma^2)+1
	
	if changekarma < 0 then 
		changekarma = 0
	end
	
	return changekarma * factor
end