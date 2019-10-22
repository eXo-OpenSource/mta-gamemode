-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu/MouseMenu.lua
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
	):setIcon(FontAwesomeSymbols.Money)

	self:addItem(_"Handel starten",
		function()
			if self:getElement() then
				TradeGUI:new(self:getElement())
			end
		end
	):setIcon(FontAwesomeSymbols.Handshake)

	self:addItem(_"Spielen >>>",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenuGames:new(posX, posY, element), element)
			end
		end
	):setIcon(FontAwesomeSymbols.Gamepad)

	if localPlayer:getFaction() then
		if localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true  then
			self:addItem(_"Fraktion >>>",
				function()
					if self:getElement() then
						delete(self)
						ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenuFaction:new(posX, posY, element), element)
					end
				end
			):setIcon(FontAwesomeSymbols.Group)
		elseif localPlayer:getFaction() and localPlayer:getFaction():isEvilFaction() and element:getFaction() ~= localPlayer:getFaction() and not (element.vehicle and localPlayer:isSurfOnCar(element.vehicle)) then
			self:addItem(_"Fraktion: Spieler überfallen",
				function()
					if self:getElement() then
						triggerServerEvent("factionEvilStartRaid", localPlayer, self:getElement())
					end
				end
			):setIcon(FontAwesomeSymbols.Bolt)
		end
	end

	if (localPlayer:getCompanyId() == 1 or localPlayer:getCompanyId() == 3) and localPlayer:getPublicSync("Company:Duty") == true then
		self:addItem(_"Unternehmen >>>",
			function()
				if self:getElement() then
					delete(self)
					ClickHandler:getSingleton():addMouseMenu(PlayerMouseMenuCompany:new(posX, posY, element), element)
				end
			end
		):setIcon(FontAwesomeSymbols.Building)
	end

	if localPlayer:getRank() >= RANK.Supporter then
		self:addItem(_"Admin: kicken",
			function()
				if self:getElement() then
					InputBox:new(_("Spieler %s kicken", self:getElement():getName()),
						_("Aus welchem Grund möchtest du den Spieler %s vom Server kicken?", self:getElement():getName()),
						function (reason)
							if reason then
								triggerServerEvent("adminPlayerFunction", localPlayer, "rkick", self:getElement(), reason)
							else
								ErrorBox:new("Kein Grund angegeben!")
							end
						end)
				end
			end
		):setIcon(FontAwesomeSymbols.Star)
		self:addItem(_"Admin: ent/freezen",
			function()
				if self:getElement() then
					triggerServerEvent("adminPlayerFunction", localPlayer, "freeze", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Star)
		self:addItem(_"Admin: specten",
			function()
				if self:getElement() then
					triggerServerEvent("adminPlayerFunction", localPlayer, "spect", self:getElement())
				end
			end
		):setIcon(FontAwesomeSymbols.Star)
	end

	
	if localPlayer:getRank() >= RANK.Moderator then
		self:addItem(_"Admin: Wegschmeißen",
		function()
			if self:getElement() then
				triggerServerEvent("adminPlayerFunction", localPlayer, "throwaway", self:getElement())
			end
		end
		):setIcon(FontAwesomeSymbols.Star)
	end

	self:adjustWidth()
end
