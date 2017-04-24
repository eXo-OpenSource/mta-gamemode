-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/PassengerMouseMenu.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
PassengerMouseMenu = inherit(GUIMouseMenu)
PassengerMouseMenu.Names = {
	[0] = "Fahrer",
	[1] = "Beifahrer",
}
function PassengerMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	if owner then
		self:addItem(_("Besitzer: %s (Admin)", owner)):setTextColor(Color.Red)
	end

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)
	for seat, occupant in pairs(element.occupants) do
		if occupant == localPlayer then
			self:addItem(_("%s: %s", PassengerMouseMenu.Names[seat] or "Rücksitz", occupant:getName())):setTextColor(Color.LightBlue)
		else
			self:addItem(_("%s: %s", PassengerMouseMenu.Names[seat] or "Rücksitz", occupant:getName()),
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenu:new(posX, posY, occupant), occupant)
				end
			end
			)
		end
	end

	self:adjustWidth()
end
