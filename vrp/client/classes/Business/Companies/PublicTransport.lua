PublicTransport = inherit(Singleton)

function PublicTransport:constructor()
	addRemoteEvents{"busReachNextStop"}
	addEventHandler("busReachNextStop", root, bind(self.Event_busReachNextStop, self))
end


function PublicTransport:setBusDisplayText(vehicle, text, line)
	if not vehicle.Bus_TexReplace then
		vehicle.Bus_TexReplace = TextureReplace:new("coach92decals128", "files/images/Textures/Empty.png", true, 256, 256, vehicle)
		addEventHandler("onClientElementDestroy", vehicle, function() delete(vehicle.Bus_TexReplace) end)
	end

	dxSetRenderTarget(vehicle.Bus_TexReplace:getTexture(), true)
	dxDrawRectangle(0, 80, 256, 60, Color.Grey)
	dxDrawText(text, 0, 80, 256, 110, Color.Yellow, 1, VRPFont(25, Fonts.Digital), "center", "center", false, true)
	dxDrawText("Linie "..line, 10, 110, 246, 140, Color.Yellow, 1, VRPFont(20, Fonts.Digital), "left", "center", false, true)
	dxDrawText("Public Transport", 10, 110, 246, 140, Color.Yellow, 1, VRPFont(20, Fonts.Digital), "right", "center", false, true)
	dxSetRenderTarget(nil)
end

function PublicTransport:Event_busReachNextStop(vehicle, nextStopName, endStop, line)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)
	--[[if getDistanceBetweenPoints3D(vehicleX, vehicleY, vehicleZ, playerX, playerY, playerZ) > 300 then
		return
	end]]

	self:setBusDisplayText(vehicle, nextStopName, line)
	if getPedOccupiedVehicle(localPlayer) == vehicle then
		local text = nextStopName
		if endStop then
			text = nextStopName..". Endstation"
		end
		setTimer(function()
			playSound("files/audio/ept_notification.wav"):setVolume(0.8)
			setTimer(function()
				playSound("http://translate.google.com/translate_tts?ie=UTF-8&tl=de-De&q=Naechster%20Halt: "..text.."&client=tw-ob")
			end, 2000, 1)	
		end, 5000, 1)
	end
end
