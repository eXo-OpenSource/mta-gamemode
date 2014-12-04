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
	
	self:addItem(_"URL ändern",
		function()
			if self:getElement() then
				InputBox:new(_"Radio URL ändern", "Bitte gib eine neue Stream-URL ein:", function(url) triggerServerEvent("itemRadioChangeURL", self:getElement(), url) end)
			end
		end
	)
	self:addItem(_"Aufnehmen",
		function()
			if self:getElement() then
				outputChatBox("Todo: Not implemented yet")
				--triggerServerEvent("itemRadioCollect", self:getElement())
			end
		end
	)
end
