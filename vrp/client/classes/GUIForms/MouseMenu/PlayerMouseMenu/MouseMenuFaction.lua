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
						triggerServerEvent("factionStateGrabPlayer", localPlayer, self:getElement())
					end
				end
			)
		end
		self:addItem(_"Fraktion: Spieler durchsuchen",
			function()
				if self:getElement() then
					triggerServerEvent("factionStateFriskPlayer", localPlayer, self:getElement())
				end
			end
		)
		self:addItem(_"Fraktion: nach Lizenz fragen",
			function()
				if self:getElement() then
					triggerServerEvent("factionStateShowLicenses", localPlayer, self:getElement())
				end
			end
		)
		self:addItem(_"Fraktion: Drogen abnehmen",
			function()
				if self:getElement() then
					triggerServerEvent("factionStateTakeDrugs", localPlayer, self:getElement())
				end
			end
		)
		self:addItem(_"Fraktion: Waffen abnehmen",
			function()
				if self:getElement() then
					triggerServerEvent("factionStateTakeWeapons", localPlayer, self:getElement())
				end
			end
		)
		if localPlayer:getFaction():getId() == 3 then
			self:addItem(_"Fraktion: GWD-Note vergeben",
				function()
					if self:getElement() then
						StateFactionNoteGUI:new(self:getElement())
					end
				end
			)
		elseif localPlayer:getFaction():getId() == 2 then
			self:addItem(_"Fraktion: Wanze verstecken",
				function()
					if self:getElement() then
						triggerServerEvent("factionStateAttachBug", self:getElement())
					end
				end
			)
		end
	end

	self:adjustWidth()
end
