-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Jobs/JobBusDriver.lua
-- *  PURPOSE:     Bus driver job class
-- *
-- ****************************************************************************
JobBusDriver = inherit(Job)

function JobBusDriver:constructor()
	Job.constructor(self, 1797, -1756, 12.5, "files/images/Blips/Bus.png", "files/images/Jobs/HeaderRoadSweeper.png", _"Busfahrer", _([[
		Als Busfahrer fährst du von Haltestelle zu Haltestelle und verdienst dabei Geld.
		Wenn du an Haltestellen zusätzlich Spieler einsteigen lässt, steigt dein Verdienst.
	]]))
	
	addEvent("busReachNextStop", true)
	addEventHandler("busReachNextStop", root, bind(self.Event_busReachNextStop, self))
end

function JobBusDriver:start()
end

function JobBusDriver:stop()
end

function JobBusDriver:setBusDisplayText(vehicle, text)
	if not vehicle.Bus_TexReplace then
		vehicle.Bus_TexReplace = TextureReplace:new("coach92decals128", "files/images/CoachTexture.png", true, 256, 256)
		addEventHandler("onClientElementDestroy", vehicle, function() delete(vehicle.Bus_TexReplace) end)
	end
	
	dxSetRenderTarget(vehicle.Bus_TexReplace:getTexture(), true)
	dxDrawText("Nächster Halt:\n"..text, 5*2, 90*2, 123*2, 125*2, Color.Red, 1, VRPFont(35), "left", "top", false, true)
	dxSetRenderTarget(nil)
end

function JobBusDriver:Event_busReachNextStop(vehicle, nextStopName)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	if getDistanceBetweenPoints3D(vehicleX, vehicleY, vehicleZ, playerX, playerY, playerZ) > 300 then
		return
	end

	self:setBusDisplayText(vehicle, nextStopName)
	
	if getPedOccupiedVehicle(localPlayer) == vehicle then
		playSound("http://translate.google.com/translate_tts?tl=en&q=Next station: "..nextStopName)
	end
end