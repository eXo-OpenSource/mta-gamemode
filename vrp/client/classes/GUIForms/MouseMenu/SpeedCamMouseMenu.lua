-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/RadioMouseMenu.lua
-- *  PURPOSE:     Item radio mouse menu class
-- *
-- ****************************************************************************
SpeedCamMouseMenu = inherit(GUIMouseMenu)

function SpeedCamMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
		self:addItem(_("Einnahmen: %d$", getElementData(element, "earning")))

		self:addItem(_"Abbauen",
			function()
				if self:getElement() then
					triggerServerEvent("worldItemCollect", self:getElement())
				end
			end
		)
	end
end

addEvent("ItemSpeedCamMenu", true)
addEventHandler("ItemSpeedCamMenu", root,
	function()
		local cx, cy = getCursorPosition()
		ClickHandler:getSingleton():addMouseMenu(SpeedCamMouseMenu:new(cx*screenWidth, cy*screenHeight, source), source)
	end
)
