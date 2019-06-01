-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MouseMenu/VehicleMouseMenu/MouseMenuFactionItems.lua
-- *  PURPOSE:     Player mouse menu - faction class
-- *
-- ****************************************************************************
VehicleMouseMenuFactionItems = inherit(GUIMouseMenu)

function VehicleMouseMenuFactionItems:constructor(posX, posY, element)
	GUIMouseMenu.constructor(self, posX, posY, 300, 1) -- height doesn't matter as it will be set automatically
	local owner = getElementData(element, "OwnerName")
	if owner then
		self:addItem(_("Besitzer: %s", owner)):setTextColor(Color.Red)
	end

	self:addItem(_"<<< Zurück",
		function()
			if self:getElement() then
				delete(self)
				ClickHandler:getSingleton():addMouseMenu(VehicleMouseMenu:new(posX, posY, element), element)
			end
		end
	)

	if localPlayer:getFaction() and localPlayer:getFaction():isStateFaction() and localPlayer:getPublicSync("Faction:Duty") == true then
		if getElementData(element, "factionTrunk") then
			local trunk = getElementData(element, "factionTrunk")
			for item, amount in pairs(trunk) do
				if amount > 0 then
					self:addItem(_("%s nehmen", item),
						function()
							if self:getElement() then
								triggerServerEvent("factionStateTakeItemFromVehicle", self:getElement(), item)
							end
						end
					)
				end
			end
		end
		for item, amount in pairs(FACTION_TRUNK_MAX_ITEMS) do
			if InventoryOld:getSingleton():getItemAmount(item) > 0 then
				self:addItem(_("%s reinlegen", item),
					function()
						if self:getElement() then
							triggerServerEvent("factionStatePutItemInVehicle", self:getElement(), item, 1, true)
						end
					end
				)
			end
		end
	end

	self:adjustWidth()
end
