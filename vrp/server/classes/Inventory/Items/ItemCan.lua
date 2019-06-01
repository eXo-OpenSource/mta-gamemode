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
	self.m_Cans = {}
end

function ItemCan:destructor()

end

function ItemCan:use( player, itemId, bag, place, itemName )
	if not player:getPublicSync("ItemCanEnabled") then
		if isElement(self.m_Cans[player]) then self.m_Cans[player]:destroy() end
		local fillstate = tonumber(player:getInventoryOld():getItemValueByBag(bag, place)) or 0
		self.m_Cans[player] = createObject(1902, 0, 0, 0)
		self.m_Cans[player]:setScale(0.5)
		exports.bone_attach:attachElementToBone(self.m_Cans[player], player, 12, 0, 0, 0.5, 180, 0, 0)
		player:triggerEvent("itemCanEnable", fillstate)
		bindKey(player, "x", "down", self.m_UseBind, bag, place)
		player:setPublicSync("ItemCanEnabled", true)
	else
		if isElement(self.m_Cans[player]) then self.m_Cans[player]:destroy() end
		player:triggerEvent("itemCanDisable", fillstate)
		unbindKey(player, "x", "down", self.m_UseBind)
		player:setPublicSync("ItemCanEnabled", false)
	end
end

function ItemCan:action(player, key, state, bag, place)
	if state == "down" then
		local itemName = "Kanne"
		local fillstate = tonumber(player:getInventoryOld():getItemValueByBag(bag, place)) or 0
		if fillstate < 1 then
			if isElementInWater( player ) then
				player:getInventoryOld():setItemValueByBag(bag, place, 10)
				player:triggerEvent("itemCanRefresh", 10)
				player:sendInfo("Kanne aufgefüllt!")
			else
				player:sendError("Sie befinden sich nicht im Wasser!")
			end
		else
			local plant = player:getData("Plant:Current")
			if plant then
				player:getInventoryOld():setItemValueByBag(bag, place, fillstate-1)
				player:triggerEvent("itemCanRefresh", fillstate-1)
				plant:waterPlant(player)
			else
				player:sendError("Keine Pflanze zum Bewässern in der Nähe!")
			end
		end
	end
end
