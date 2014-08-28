-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu.lua
-- *  PURPOSE:     Player mouse menu class
-- *
-- ****************************************************************************
PlayerMouseMenu = inherit(GUIMouseMenu)

function PlayerMouseMenu:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	
	self:addItem("Name: "..getPlayerName(element)):setTextColor(Color.Red)
	
	self:addItem(_"Geld geben",
		function()
			if self:getElement() then
				SendMoneyGUI:new(function(amount) triggerServerEvent("playerSendMoney", self:getElement(), amount) end)
			end
		end
	)
	self:addItem(_"Handel starten",
		function()
			if self:getElement() then
				outputChatBox("Not implemented yet")
				--triggerServerEvent("playerStartTrade", self:getElement())
			end
		end
	)
	self:addItem(_"Im Handy speichern",
		function()
			if self:getElement() then
				outputChatBox("Not implemented yet")
			end
		end
	)
	
	if localPlayer:getRank() >= RANK.Moderator then
		self:addItem(_"Kick",
			function()
				outputChatBox("Not implemented yet")
				--[[if self:getElement() then
					triggerServerEvent("vehicleRepair", self:getElement())
				end]]
			end
		)
	end
end
