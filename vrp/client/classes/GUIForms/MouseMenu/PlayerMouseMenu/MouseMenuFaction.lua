-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/PlayerMouseMenu/MouseMenuFaction.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
PlayerMouseMenuFaction = inherit(GUIMouseMenu)

function PlayerMouseMenuFaction:constructor(posX, posY, element)
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
	if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
		if localPlayer:isInVehicle() then
			self:addItem(_"Fraktion: ins Fahrzeug zerren",
				function()
					if self:getElement() then
						if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
							triggerServerEvent("factionStateGrabPlayer", localPlayer, self:getElement())
						end
					end
				end
			):setIcon(FontAwesomeSymbols.Bolt)
			if element:isInVehicle() and element.vehicle == localPlayer.vehicle then
				self:addItem(element:getData("isTied") and "Fraktion: Spieler entfesseln" or "Fraktion: Spieler fesseln",
					function()
						if self:getElement() then
							if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
								triggerServerEvent("factionStateTie", localPlayer, self:getElement())
							end
						end
					end
				):setIcon(FontAwesomeSymbols.UserLock)
			end
		end

		self:addItem(_"Fraktion: Spieler durchsuchen",
			function()
				if self:getElement() then
					if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
						triggerServerEvent("factionStateFriskPlayer", localPlayer, self:getElement())
					end
				end
			end
		):setIcon(FontAwesomeSymbols.Search)

		if element:getPublicSync("cuffed") then
			self:addItem(_"Fraktion: Handschellen abnehmen",
				function()
					if self:getElement() then
						if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
							triggerServerEvent("factionStateUncuff", localPlayer, self:getElement())
						end
					end
				end
				):setIcon(FontAwesomeSymbols.Hands)
		else
			self:addItem(_"Fraktion: Handschellen anlegen",
				function()
					if self:getElement() then
						if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
							triggerServerEvent("factionStateCuff", localPlayer, self:getElement())
						end
					end
				end
			):setIcon(FontAwesomeSymbols.Hands)
		end

		if element:getData("VSE:IsPassenger") then
			self:addItem(_"Fraktion: Aus Fahrzeug zerren",
				function()
					if self:getElement() then
						if element:getData("VSE:Vehicle") then
							if Vector3(localPlayer:getPosition() - element:getData("VSE:Vehicle"):getPosition()):getLength() < 10 then
								triggerServerEvent("factionStateDragFromVehicle", localPlayer, self:getElement())
							end
						end
					end
				end
			):setIcon(FontAwesomeSymbols.Hands)
		end

		self:addItem(_"Fraktion: Alkoholtest durchführen",
			function()
				if self:getElement() then
					if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
						triggerServerEvent("factionStateStartAlcoholTest", localPlayer, self:getElement())
					end
				end
			end
		):setIcon(FontAwesomeSymbols.Beer)

		self:addItem(_"Fraktion: nach Lizenz fragen",
			function()
				if self:getElement() then
					if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
						triggerServerEvent("factionStateShowLicenses", localPlayer, self:getElement())
					end
				end
			end
		):setIcon(FontAwesomeSymbols.IDCard)

		self:addItem(_"Fraktion: illegales abnehmen",
			function()
				if self:getElement() then
					if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
						triggerServerEvent("factionStateTakeDrugs", localPlayer, self:getElement())
					end
				end
			end
		):setIcon(FontAwesomeSymbols.Check)

		self:addItem(_"Fraktion: Waffen abnehmen",
			function()
				if self:getElement() then
					if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
						triggerServerEvent("factionStateTakeWeapons", localPlayer, self:getElement())
					end
				end
			end
		):setIcon(FontAwesomeSymbols.Check)
		if element:getWanteds() ~= 0 and element:getWanteds() < 4 then
			self:addItem(_"Fraktion: Ticket anbieten",
			function()
				if self:getElement() then
					if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
						triggerServerEvent("factionStateTicket", localPlayer, self:getElement())
					end
				end
			end
			):setIcon(FontAwesomeSymbols.Ticket)
		end

		if localPlayer:getFaction():getId() == 3 then
			if PermissionsManager:getSingleton():hasPlayerPermissionsTo("faction", "setPaNote") then
				self:addItem(_"Fraktion: GWD-Note vergeben",
					function()
						if self:getElement() then
							StateFactionNoteGUI:new(self:getElement())
						end
					end
				):setIcon(FontAwesomeSymbols.File)
			end
		elseif localPlayer:getFaction():getId() == 2 then
			self:addItem(_"Fraktion: Wanze verstecken",
				function()
					if self:getElement() then
						if Vector3(localPlayer:getPosition() - element:getPosition()):getLength() < 10 then
							triggerServerEvent("factionStateAttachBug", self:getElement())
						end
					end
				end
			):setIcon(FontAwesomeSymbols.Bug)
		end
	end

	self:adjustWidth()
end
