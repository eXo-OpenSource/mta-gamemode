-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/Prison.lua
-- *  PURPOSE:     Client Prison class
-- *
-- ****************************************************************************

local PrisonCenter = Vector3(-224.32, 2371.44, 5688.73)
local Prison = {}
local PrisonCountdown

addEvent("playerPrisoned", true)
addEventHandler("playerPrisoned", root,
	function(PrisonTime)
		Prison.startCountdown(PrisonTime)
	end
)

function Prison.startCountdown(PrisonTime)
	if PrisonCountdown then delete(PrisonCountdown) end
	PrisonCountdown = Countdown:new(PrisonTime*60, "Prison")
	PrisonCountdown:addTickEvent(function()
			toggleControl("fire", false)
			toggleControl("aim_weapon", false)
			toggleControl("jump", false)
			if getDistanceBetweenPoints3D(localPlayer:getPosition(), PrisonCenter) > 100 then
				localPlayer:setPosition(PrisonCenter)
			end
		end)
end

addEvent("playerLeftPrison", true)
addEventHandler("playerLeftPrison", root,
	function()
		if PrisonCountdown then delete(PrisonCountdown) end
	end
)
