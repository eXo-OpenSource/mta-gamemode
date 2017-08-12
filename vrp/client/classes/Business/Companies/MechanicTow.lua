MechanicTow = inherit(Singleton)

function MechanicTow:constructor()
	self.m_Ped = createPed(50, 913.83, -1234.65, 16.98)
	setElementData(self.m_Ped, "clickable", true)
	self.m_Ped:setData("NPC:Immortal", true)
	self.m_Ped:setFrozen(true)
	self.m_Ped:setData("onClickEvent",
		function()
			self.ms_SelectionGUI = GUIButtonMenu:new("Fahrzeug Art")
			self.ms_SelectionGUI:addItem(_"Privat Fahrzeug", Color.LightBlue,
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "permanentVehicle")
				end
			)
			self.ms_SelectionGUI:addItem(_"Firma/Gruppen Fahrzeug", Color.LightBlue,
				function()
					triggerServerEvent("mechanicOpenTakeGUI", localPlayer, "groupVehicle")
				end
			)
		end
	)

	SpeakBubble3D:new(self.m_Ped, _"Fahrzeug freikaufen", _"Klicke mich an!")

	NonCollidingArea:new(894.25, -1188.40, 16.98, 10)
	NonCollidingArea:new(915.76, -1192.84, 16.72, 10)
	NonCollidingArea:new(908.032, -1259.658, 15, 15)
	-- NonCollidingArea:new(864.61, -1272.77, 15, 15)

	self.m_BugPed = createPed(50, 850.305, -1226.058, 17.269, 290)
	setElementData(self.m_BugPed, "clickable", true)
	self.m_BugPed:setData("BugChecker", true)
	self.m_BugPed:setData("NPC:Immortal", true)
	self.m_BugPed:setFrozen(true)

	SpeakBubble3D:new(self.m_BugPed, _"Ich kann Wanzen aufspüren", _"Klicke mich an!")

	self.m_RenderFuelHoles = {}
	addEventHandler("onClientElementStreamIn", root, bind(MechanicTow.onObjectStreamIn, self))
	addEventHandler("onClientRender", root, bind(MechanicTow.renderFuelHose, self))
end

function MechanicTow:onObjectStreamIn()
	if source:getModel() == 1826 then
		self.m_RenderFuelHoles[source] = true
	end
end

function MechanicTow:renderFuelHose()
	for element in pairs(self.m_RenderFuelHoles) do
		if isElement(element) then
			local vehicle = element:getData("attachedToVehicle")
			if vehicle then
				dxDrawLine3D(vehicle.position, element.position, Color.Black, 5)

				if localPlayer:getPrivateSync("hasFuelNozzle") then
					if localPlayer:getWorldVehicle() then
						self:drawTextBox("Halte die linke Maustaste gedrückt um das Fahrzeug zu betanken!", 2)
					end

					if (vehicle.position - element.position).length > 10 then
						self.m_RenderFuelHoles[element] = nil
						triggerServerEvent("mechanicRejectFuelNozzle", localPlayer)
					end
				end
			end
		else
			self.m_RenderFuelHoles[element] = nil
		end
	end
end

function MechanicTow:drawTextBox(text, count)
	local width, height = dxGetTextWidth(text, 1, "default") + 10, 16
	local x, y = screenWidth/2 - width/2, screenHeight/2 + count*20
	dxDrawRectangle(x, y, width, height, tocolor( 0, 0, 0, 90 ))
	dxDrawText(text, x, y, x+width, y+height, tocolor(255, 255, 255, 255), 1, "default", "center", "center", false, false, false, true, false)
end
