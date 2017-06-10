-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/RadioMouseMenu.lua
-- *  PURPOSE:     Item radio mouse menu class
-- *
-- ****************************************************************************
RadioMouseMenu = inherit(GUIMouseMenu)

function RadioMouseMenu:constructor(posX, posY, element)
	--reference code, now implemented in WorldItemMouseMenu
	--[[GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	self:addItem(_("Besitzer: %s", element:getData("Owner") or "Besitzer unbekannt")):setTextColor(Color.Red)
	self:addItem(_"Musik ändern",
		function()
			if self:getElement() then
				StreamGUI:new("Radio Musik ändern", function(url) triggerServerEvent("itemRadioChangeURL", self:getElement(), url) end, function() triggerServerEvent("itemRadioStopSound", self:getElement()) end)
			end
		end
	):setIcon(FontAwesomeSymbols.Music)

	self:addItem(_"Aufnehmen",
		function()
			if self:getElement() then
				triggerServerEvent("worldItemCollect", self:getElement())
			end
		end
	):setIcon(FontAwesomeSymbols.Double_Down)

	if localPlayer:getRank() >= RANK.Supporter then
		self:addItem(_"Admin: löschen",
			function()
				if self:getElement() then
					triggerServerEvent("worldItemDelete", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Trash)
	end]]
end
