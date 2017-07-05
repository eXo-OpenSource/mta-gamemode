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
	if line then
		dxDrawText("Linie "..line, 10, 110, 246, 140, Color.Yellow, 1, VRPFont(20, Fonts.Digital), "left", "center", false, true)
	end
	dxDrawText("Public Transport", 10, 110, 246, 140, Color.Yellow, 1, VRPFont(20, Fonts.Digital), "right", "center", false, true)
	dxSetRenderTarget(nil)
end

function PublicTransport:Event_busReachNextStop(vehicle, nextStopName, endStop, line)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)

	self:setBusDisplayText(vehicle, nextStopName, line)
	if getPedOccupiedVehicle(localPlayer) == vehicle and line then
		if not getElementData(vehicle, "i:warn") then
			Indicator:getSingleton():switchIndicatorState("warn")
		end

		local text = nextStopName
		if endStop then
			text = nextStopName..". Endstation"
		end
		setTimer(function()
			if localPlayer.vehicle ~= vehicle then return end
			playSound("files/audio/ept_notification.wav"):setVolume(0.8)
			setTimer(function()
				if localPlayer.vehicle ~= vehicle then return end
				if getElementData(vehicle, "i:warn") then
					Indicator:getSingleton():switchIndicatorState("warn")
				end
				playSound("http://translate.google.com/translate_tts?ie=UTF-8&tl=de-De&q=Naechster%20Halt: "..text.."&client=tw-ob")
			end, 2000, 1)	
		end, 5000, 1)
	end
end




BusLineMouseMenu = inherit(GUIMouseMenu)

function BusLineMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1)

	 self:addItem(_"Anzeigetafel ändern"):setTextColor(Color.Red)

	self:addItem(_"Linie 1 bedienen",
		function()
			if self:getElement() then
				triggerServerEvent("publicTransportChangeBusDutyState", self:getElement(), "dutyLine", 1)
			end
		end
	):setIcon(FontAwesomeSymbols.Arrows)

	self:addItem(_"Linie 2 bedienen",
		function()
			if self:getElement() then
				triggerServerEvent("publicTransportChangeBusDutyState", self:getElement(), "dutyLine", 2)
			end
		end
	):setIcon(FontAwesomeSymbols.Arrows)

	self:addItem(_"Sonderfahrt",
		function()
			if self:getElement() then
				triggerServerEvent("publicTransportChangeBusDutyState", self:getElement(), "dutySpecial")
			end
		end
	):setIcon(FontAwesomeSymbols.Arrows)

	self:addItem(_"Dienst beenden",
		function()
			if self:getElement() then
				triggerServerEvent("publicTransportChangeBusDutyState", self:getElement(), "offDuty")
			end
		end
	):setIcon(FontAwesomeSymbols.Arrows)


	self:adjustWidth()
end