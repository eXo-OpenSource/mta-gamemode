-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Karma.lua
-- *  PURPOSE:     (static) Karma calculation
-- *
-- ****************************************************************************
Karma = {}
local MAX_KARMA = 150 -- both directions

function Karma.calcKarma(currentKarma, modifyKarma, factor)
	if modifyKarma >= MAX_KARMA then
		return MAX_KARMA
	end

	local offsetkarma = math.abs(currentKarma - modifyKarma)
	
	-- http://www.wolframalpha.com/input/?i=-x^2%2B1 (f(0) = 1; f(1) = 0)
	local changekarma = -(math.abs(currentKarma/MAX_KARMA)^2) + 1 -- changekarma is always between 0 and 1
	
	-- Apply new value change factor on 
	return offsetkarma * changekarma * (factor or 1)
end

-- Below: Karma values from -50 to 50 indicating what you're able to do 
-- 		   with different Karma values, nicely in one place
Karma.POLICE_VEHICLE_NORMAL	= 5
Karma.POLICE_RANGER			= 10
Karma.POLICE_ENFORCER		= 20
Karma.POLICE_SWAT			= 25
Karma.POLICE_SWAT_TANK		= 40
Karma.POLICE_HELICOPTER		= 50