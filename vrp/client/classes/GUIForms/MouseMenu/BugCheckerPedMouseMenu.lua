-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/BugCheckerPedMouseMenu.lua
-- *  PURPOSE:     BugCheckerPedMouseMenu
-- *
-- ****************************************************************************
BugCheckerPedMouseMenu = inherit(GUIMouseMenu)

function BugCheckerPedMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	self:addItem("Mechaniker Walter"):setTextColor(Color.Orange)

	self:addItem("mich überprüfen - 25$",
		function()
			triggerServerEvent("factionStateCheckBug", localPlayer)
		end
	)
	self:addItem("Fahrzeug überprüfen - 50$",
		function()
			if localPlayer.vehicle then
				triggerServerEvent("factionStateCheckBug", localPlayer, localPlayer.vehicle)
			else
				ErrorBox:new(_"Du sitzt in keinem Fahrzeug!")
			end
		end
	)
end
