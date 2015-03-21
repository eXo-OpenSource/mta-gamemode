-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/DrivingSchool.lua
-- *  PURPOSE:     Driving school class
-- *
-- ****************************************************************************
DrivingSchool = inherit(Singleton)
local DRIVERSLICENSE_PRICE = 80000

function DrivingSchool:constructor()
	self.m_InteriorEnterExit = InteriorEnterExit:new(Vector3(1052.5, -1524, 13.5), Vector3(-2027, -104.2, 1035.1), -90, 90, 3)
	
	addEvent("buyDriversLicense", true)
	addEventHandler("buyDriversLicense", root,
		function()
			if client:hasPilotsLicense() then
				client:sendWarning(_("Du hast bereits einen Flugschein!", client))
				return
			end
			
			if client:getVehicleLevel() < 8 then
				client:sendError(_("Du braucht min. Fahrzeuglevel 8", client))
				return
			end
			
			if client:getMoney() < DRIVERSLICENSE_PRICE then
				client:sendError(_("Du hast nicht genügend Geld!", client))
				return
			end
			
			client:setHasPilotsLicense(true)
			client:takeMoney(DRIVERSLICENSE_PRICE)
			client:sendSuccess(_("Herzlichen Glückwunsch! Du besitzt nun einen Flugschein!", client))
		end
	)
end

function DrivingSchool:destructor()
	delete(self.m_InteriorEnterExit)
end
