-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/Managers/ItemCanManager.lua
-- *  PURPOSE:     Item Can Manager class
-- *
-- ****************************************************************************

ItemCanManager = inherit(Singleton)

function ItemCanManager:constructor()
	self.m_CanObjects = {}
	self.m_Cans = {}

	self.m_UseCan = bind(self.useCan, self)
end

function ItemCanManager:toggleCan(player, itemId)
	if self.m_CanObjects[player] then
		if isElement(self.m_CanObjects[player]) then self.m_CanObjects[player]:destroy() end
		self.m_CanObjects[player] = nil

		player:triggerEvent("itemCanDisable")

		unbindKey(player, "x", "down", self.m_UseCan)
	else
		self.m_Cans[player] = itemId
		self.m_CanObjects[player] = createObject(1902, 0, 0, 0)
		self.m_CanObjects[player]:setScale(0.5)
		exports.bone_attach:attachElementToBone(self.m_CanObjects[player], player, 12, 0, 0, 0.5, 180, 0, 0)

		local item = player:getInventory():getItem(itemId)
		player:triggerEvent("itemCanEnable", itemId)

		bindKey(player, "x", "down", self.m_UseCan, bag, place)
	end
end

function ItemCanManager:useCan(player, key, state)
	if state == "down" then
		local itemId = self.m_Cans[player]
		if not itemId then return end

		local item = player:getInventory():getItem(itemId)
		local fillstate = tonumber(item.Durability) or 0

		if fillstate < 1 then
			if isElementInWater( player ) then
				player:getInventory():setItemDurability(itemId, 10)
				player:sendInfo("Kanne aufgefüllt!")
			else
				player:sendError("Sie befinden sich nicht im Wasser!")
			end
		else
			local plant = player:getData("Plant:Current")
			if plant then
				player:getInventory():decreaseItemDurability(itemId)
				plant:waterPlant(player)
			else
				player:sendError("Keine Pflanze zum Bewässern in der Nähe!")
			end
		end
	end
end
