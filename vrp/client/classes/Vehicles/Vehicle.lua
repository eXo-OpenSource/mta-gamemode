-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Vehicle.lua
-- *  PURPOSE:     Vehicle class
-- *
-- ****************************************************************************
Vehicle = inherit(MTAElement)
registerElementClass("vehicle", Vehicle)

function Vehicle:constructor()
end

function Vehicle:getFuel()
	return 100
end

addEvent("vehicleEngineStart", true)
addEventHandler("vehicleEngineStart", root,
	function()
		playSound("files/audio/Enginestart.mp3")
	end
)
