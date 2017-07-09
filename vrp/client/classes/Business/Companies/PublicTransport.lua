PublicTransport = inherit(Singleton)

function PublicTransport:constructor()
	addRemoteEvents{"busReachNextStop"}
	addEventHandler("busReachNextStop", root, bind(self.Event_busReachNextStop, self))
end


function PublicTransport:setBusDisplayText(vehicle, text)
	if not vehicle.Bus_TexReplace then
		vehicle.Bus_TexReplace = TextureReplace:new("coach92decals128", "files/images/Textures/CoachTexture.png", true, 256, 256)
		addEventHandler("onClientElementDestroy", vehicle, function() delete(vehicle.Bus_TexReplace) end, false)
	end

	dxSetRenderTarget(vehicle.Bus_TexReplace:getTexture(), true)
	dxDrawText("Nächster Halt:\n"..text, 5*2, 90*2, 123*2, 125*2, Color.Red, 1, VRPFont(35), "left", "top", false, true)
	dxSetRenderTarget(nil)
end

function PublicTransport:Event_busReachNextStop(vehicle, nextStopName)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	if getDistanceBetweenPoints3D(vehicleX, vehicleY, vehicleZ, playerX, playerY, playerZ) > 300 then
		return
	end

	self:setBusDisplayText(vehicle, nextStopName)

	if getPedOccupiedVehicle(localPlayer) == vehicle then
		playSound("http://translate.google.com/translate_tts?ie=UTF-8&tl=de-De&q=Naechster%20Halt: "..nextStopName.."&client=tw-ob")
	end
end
