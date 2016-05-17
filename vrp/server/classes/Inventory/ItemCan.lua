-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/ItemEmptyCan.lua
-- *  PURPOSE:     Item Empty Watering-Can class
-- *
-- ****************************************************************************

ItemCan = inherit(Item)

function ItemCan:constructor( )
	self.m_UseBind = bind(self.action, self)
end

function ItemCan:destructor()

end

function ItemCan:use( player, itemId, bag, place, itemName )
	if not player:getPublicSync("ItemCanEnabled") then
		local fillstate = player:getInventory():getSpecialItemData(itemName) or 0
		ItemCan.player = createObject(1902, 0, 0, 0)
		ItemCan.player:setScale(0.5)
		exports.bone_attach:attachElementToBone(ItemCan.player, player, 12, 0, 0, 0.5, 180, 0, 0)
		player:triggerEvent("itemCanEnable", fillstate)
		bindKey(player, "x", "down", self.m_UseBind)
		player:setPublicSync("ItemCanEnabled", true)
	else
		if isElement(ItemCan.player) then ItemCan.player:destroy() end
		player:triggerEvent("itemCanDisable", fillstate)
		unbindKey(player, "x", "down", self.m_UseBind)
		player:setPublicSync("ItemCanEnabled", false)
	end
end

function ItemCan:action(player, key, state)
	if state == "down" then
		local itemName = "Kanne"
		local fillstate = 0
		if player:getInventory():getSpecialItemData(itemName) then
			fillstate = tonumber(player:getInventory():getSpecialItemData(itemName))
		end
		if fillstate < 1 then
			if isElementInWater( player ) then
				player:getInventory():setSpecialItemData(itemName, 10)
				player:triggerEvent("itemCanRefresh", 10)
				player:sendInfo("Kanne aufgefüllt!")
			else
				player:sendError("Sie befinden sich nicht im Wasser!")
			end
		else
			local plant = ItemGrowable:getNextWaterPlant( player )
			if plant then
				player:getInventory():setSpecialItemData(itemName, fillstate-1)
				player:triggerEvent("itemCanRefresh", fillstate-1)
				local bHyd = plant:getData( "Plant:Hydration")
				plant:setData( "Plant:Hydration", bHyd + 1, true)
				setPedAnimation( player, "bomber", "BOM_Plant_Loop", 2000, true, false)
				if plant.m_OnWaterRemoteEvent then
					player:triggerEvent( plant.m_OnWaterRemoteEvent, plant )
				end
			else
				player:sendError("Keine Pflanze zum Bewässern in der Nähe!")
			end
		end
	end
end
