-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/RadioMouseMenu.lua
-- *  PURPOSE:     Item radio mouse menu class
-- *
-- ****************************************************************************
RadioMouseMenu = inherit(GUIMouseMenu)

function RadioMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	self:addItem(_"Musik ändern",
		function()
			if self:getElement() then
				StreamGUI:new("Radio Musik ändern", function(url) triggerServerEvent("itemRadioChangeURL", self:getElement(), url) end, function() triggerServerEvent("itemRadioStopSound", self:getElement()) end)
			end
		end
	)
	self:addItem(_"Aufnehmen",
		function()
			if self:getElement() then
				triggerServerEvent("worldItemCollect", self:getElement())
			end
		end
	)
end
