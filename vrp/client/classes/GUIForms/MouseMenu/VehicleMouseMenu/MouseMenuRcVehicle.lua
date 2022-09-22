-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/MouseMenuRcVehicle.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
MouseMenuRcVehicle = inherit(GUIMouseMenu)

function MouseMenuRcVehicle:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	if owner then
		self:addItem(_("Besitzer: %s", owner)):setTextColor(Color.Red)
	end
	
	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)

	for i, rcVehicle in pairs(element:getData("RcVehicles")) do
		self:addItem(_("%s benutzen", getVehicleNameFromModel(rcVehicle)),
			function()
				if self:getElement() then
					if localPlayer.vehicle and localPlayer.vehicle == element then
						triggerServerEvent("vehicleToggleRC", self:getElement(), rcVehicle, true)
					else
						ErrorBox:new(_"Du musst im RC Van sitzen.")
					end
				end
			end
		):setTextColor(Color.White)
	end
	self:adjustWidth()
end
