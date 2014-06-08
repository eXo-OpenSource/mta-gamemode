-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Karma.lua
-- *  PURPOSE:     (static) Karma calculation
-- *
-- ****************************************************************************
Karma = {}

function Karma.calcKarma(currentKarma, modifyKarma, factor)
	local offsetkarma = math.abs(currentKarma - modifyKarma)
	
	-- http://www.wolframalpha.com/input/?i=-1%2F20x^2%2B1
	local changekarma = -1/20*(offsetkarma^2)+1
	
	if changekarma < 0 then 
		changekarma = 0
	end
	
	return changekarma * factor
end

-- Below: Karma values from -50 to 50 indicating what you're able to do 
-- 		   with different Karma values, nicely in one place
Karma.POLICE_VEHICLE_NORMAL	= 5
Karma.POLICE_RANGER			= 10
Karma.POLICE_ENFORCER		= 20
Karma.POLICE_SWAT			= 25
Karma.POLICE_SWAT_TANK		= 40
Karma.POLICE_HELICOPTER		= 50