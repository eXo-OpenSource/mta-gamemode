PublicTransport = inherit(Singleton)

function PublicTransport:constructor()
	addRemoteEvents{"busReachNextStop"}
	addEventHandler("busReachNextStop", root, bind(self.Event_busReachNextStop, self))
	self.m_ActiveBusVehicles = {}
	self.m_ActiveLines = {}

	self.m_Event_BusStopStreamIn = bind(PublicTransport.busStopStreamIn, self)
	self.m_Event_BusStopStreamOut = bind(PublicTransport.busStopStreamOut, self)
	self:registerBusStopObjects()
end


function PublicTransport:setBusDisplayText(vehicle, text, line)
	--[[if not vehicle.Bus_TexReplace then
		vehicle.Bus_TexReplace = FileTextureReplacer:new(vehicle, "Empty.png", "coach92decals128")
		vehicle.Bus_TexReplace:setTextureToRenderTarget(256, 256, false)

		addEventHandler("onClientElementDestroy", vehicle, function() delete(vehicle.Bus_TexReplace) end)
	end

	dxSetRenderTarget(vehicle.Bus_TexReplace:getTexture(), true)
	dxDrawRectangle(0, 80, 256, 60, Color.Grey)
	dxDrawText(text, 0, 80, 256, 110, Color.Yellow, 1, VRPFont(25, Fonts.Digital), "center", "center", false, true)
	if line then
		dxDrawText("Linie "..line, 10, 110, 246, 140, Color.Yellow, 1, VRPFont(20, Fonts.Digital), "left", "center", false, true)
	end
	dxDrawText("Public Transport", 10, 110, 246, 140, Color.Yellow, 1, VRPFont(20, Fonts.Digital), "right", "center", false, true)
	dxSetRenderTarget(nil)]]
end

function PublicTransport:busStopStreamIn(obj)
	local source = source -- scope to local
	if obj then source = obj end
	if not source.m_BusCol then
		source.m_BusCol = createColSphere(source.position, 3)
		addEventHandler("onClientColShapeHit", source.m_BusCol, function(hit, dim)
			if not dim then return end
			if hit ~= localPlayer or localPlayer.vehicle then return end
			InfoBox:new(_"Klicke auf die Bushaltestelle, um den Busfahrplan einzusehen.")
		end)
	end
end

function PublicTransport:busStopStreamOut()
	if source.m_BusCol then	
		source.m_BusCol:destroy()
		source.m_BusCol = nil
	end
end

function PublicTransport:Event_busReachNextStop(vehicle, nextStopName, endStop, line)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(vehicle)
	local playerX, playerY, playerZ = getElementPosition(localPlayer)

	self:setBusDisplayText(vehicle, nextStopName, line)
	self:updateLineCounter(vehicle, line)

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

function PublicTransport:updateLineCounter(vehicle, line)
	if EPTBusData.lineData then -- check if line data is instantiated
		if line and not self.m_ActiveLines[line] then self.m_ActiveLines[line] = 0 end
		if self.m_ActiveBusVehicles[vehicle] and not line then -- vehicle offduty
			local line = self.m_ActiveBusVehicles[vehicle]
			self.m_ActiveLines[line] = self.m_ActiveLines[line] - 1
			if self.m_ActiveLines[line] == 0 then
				ShortMessage:new(_("Buslinie %d (%s) wird leider nicht mehr bedient.", line, EPTBusData.lineData.lineDisplayData[line].displayName), _"Public Transport", {230, 170, 0})
			end
			self.m_ActiveBusVehicles[vehicle] = nil
		elseif not self.m_ActiveBusVehicles[vehicle] and line then -- vehicle onduty
			self.m_ActiveBusVehicles[vehicle] = line
			if self.m_ActiveLines[line] == 0 then
				ShortMessage:new(_("Buslinie %d (%s) wird wieder bedient.", line, EPTBusData.lineData.lineDisplayData[line].displayName), _"Public Transport", {230, 170, 0})
			end
			self.m_ActiveLines[line] = self.m_ActiveLines[line] + 1
		end
	end
end


function PublicTransport:getActiveBusVehicles()
	return self.m_ActiveBusVehicles
end

function PublicTransport:setActiveBusVehicles(tblVehs)
	self.m_ActiveBusVehicles = tblVehs
	for veh, line in pairs(tblVehs) do
		self:updateLineCounter(veh, line)
	end
end

function PublicTransport:registerBusStopObjects()
	--[[
		local object = createObject(1257, x, y, z, rx, ry, rz)
			object:setData("EPT_bus_station", stationName, true)
			object:setData("EPT_bus_station_lines", lines, true)
	]]
	for i,v in pairs(getElementsByType("bus_stop", resourceRoot)) do
		if v:getData("object") then
			addEventHandler("onClientElementStreamIn", v:getData("object"), self.m_Event_BusStopStreamIn, false)
			addEventHandler("onClientElementStreamOut",v:getData("object"), self.m_Event_BusStopStreamOut, false)
			if v:getData("object"):isStreamedIn() then
				self:busStopStreamIn(v:getData("object"))
			end
		end
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
	)

	self:addItem(_"Linie 2 bedienen",
		function()
			if self:getElement() then
				triggerServerEvent("publicTransportChangeBusDutyState", self:getElement(), "dutyLine", 2)
			end
		end
	)

	self:addItem(_"Sonderfahrt",
		function()
			if self:getElement() then
				triggerServerEvent("publicTransportChangeBusDutyState", self:getElement(), "dutySpecial")
			end
		end
	)

	self:addItem(_"Dienst beenden",
		function()
			if self:getElement() then
				triggerServerEvent("publicTransportChangeBusDutyState", self:getElement(), "offDuty")
			end
		end
	)


	self:adjustWidth()
end