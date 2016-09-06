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

	if element:getFaction() then
		local faction = element:getFaction()
		local color = faction:getColor()
		self:addItem(("Name: %s (%s)"):format(element:getName(), faction:getShortName())):setTextColor(rgb(color.r, color.g, color.b))
	else
		self:addItem(("Name: %s"):format(element:getName())):setTextColor(Color.Red)
	end

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
				TradeGUI:new(self:getElement())
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
	if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
		self:addItem(_"Fraktion >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenuFaction:new(posX, posY, element), element)
				end
			end
		)
	end
	if (localPlayer:getCompanyId() == 1 or localPlayer:getCompanyId() == 3) and localPlayer:getPublicSync("Company:Duty") == true then
		self:addItem(_"Unternehmen >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenuCompany:new(posX, posY, element), element)
				end
			end
		)
	end
	if localPlayer:getFactionId() == 4 and localPlayer:getPublicSync("Faction:Duty") == true then
		self:addItem(_"Medic: heilen",
			function()
				if self:getElement() then
					triggerServerEvent("factionRescueHealPlayerQuestion", localPlayer, self:getElement())
				end
			end
		)
	end

	if localPlayer:getRank() >= RANK.Supporter then
		self:addItem(_"Admin: Kick",
			function()
				if self:getElement() then
					triggerServerEvent("adminTriggerFunction", self:getElement(), "kick", self:getElement(), "You've been kicked!")
				end
			end
		)
	end
end
