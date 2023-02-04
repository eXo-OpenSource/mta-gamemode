-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/VehicleMouseMenuFaction.lua
-- *  PURPOSE:     Vehicle mouse menu - faction class
-- *
-- ****************************************************************************
VehicleMouseMenuFaction = inherit(GUIMouseMenu)

function VehicleMouseMenuFaction:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	
	self:addItem(("Besitzer: %s"):format(owner)):setTextColor(Color.Red)

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)

	if localPlayer:getFaction():getId() == 2 then
		self:addItem(_"Wanze anbringen",
				function()
					if self:getElement() then
						if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
							triggerServerEvent("factionStateAttachBug", self:getElement())
						end
					end
				end
			):setIcon(FontAwesomeSymbols.Bug)
		end
	if localPlayer.vehicleSeat == 0 and getElementData(element, "StateVehicle") then
		self:addItem(_("Radar %s", getElementData(element, "speedCamEnabled") and "stoppen" or "starten"),
			function()
				if self:getElement() then
					triggerServerEvent("SpeedCam:onStartClick", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Video)
	end

	if element:getData("OwnerType") == "player" or element:getData("OwnerType") == "group" then
		self:addItem(_"Fraktion: Illegale Tunings entfernen",
			function()
				if self:getElement() then
					if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
						triggerServerEvent("factionStateRemoveIllegalTunings", localPlayer, self:getElement())
					end
				end
			end
		):setIcon(FontAwesomeSymbols.Car)
	end

	self:adjustWidth()
end