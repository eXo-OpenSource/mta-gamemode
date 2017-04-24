-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu/MouseMenuGames.lua
-- *  PURPOSE:     Player mouse menu - game class
-- *
-- ****************************************************************************
PlayerMouseMenuGames = inherit(GUIMouseMenu)

function PlayerMouseMenuGames:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically

	if element:getFaction() then
		local faction = element:getFaction()
		local color = faction:getColor()
		self:addItem(("Name: %s (%s)"):format(element:getName(), faction:getShortName())):setTextColor(rgb(color.r, color.g, color.b))
	else
		self:addItem(("Name: %s"):format(element:getName())):setTextColor(Color.Red)
	end

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenu:new(posX, posY, element), element)
			end
		end
	)

	self:addItem(_"Schere-Stein-Papier spielen",
    function()
        if self:getElement() then
            triggerServerEvent("rockPaperScissorsQuestion", localPlayer, self:getElement())
        end
    end
	)
	self:addItem(_"Pong spielen",
		function()
			if self:getElement() then
				triggerServerEvent("pongQuestion", localPlayer, self:getElement())
			end
		end
	)
	self:addItem(_"Schach spielen",
		function()
			if self:getElement() then
				triggerServerEvent("chessQuestion", localPlayer, self:getElement())
			end
		end
	)

	self:adjustWidth()
end
