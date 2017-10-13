-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/LastDriverMouseMenu.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
LastDriverMouseMenu = inherit(GUIMouseMenu)

function LastDriverMouseMenu:constructor(posX, posY, element)
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
	):setIcon(FontAwesomeSymbols.Back)

	local max = 5
	local count = 0

	for i = #getElementData(element, "lastDrivers"), 1, -1 do
		if max > count then
			self:addItem(getElementData(element, "lastDrivers")[i]):setTextColor(Color.White):setIcon(FontAwesomeSymbols.Player)
		end
		count = count +1
	end

	self:adjustWidth()
end
