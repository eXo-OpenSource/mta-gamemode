-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/ItemEmptyCan.lua
-- *  PURPOSE:     Item Donutbox Class
-- *
-- ****************************************************************************
ItemDonutBox = inherit(Item)

function ItemDonutBox:constructor()
end

function ItemDonutBox:destructor()
end

function ItemDonutBox:use(player, itemId, bag, place, itemName)
	local inventory = player:getInventory()
	local donutsLeft = inventory:getSpecialItemData(itemName) or 9
	if donutsLeft and (donutsLeft-1) >= 0 then
		player:sendMessage(("#4F4F65%d/9 Donuts are left!"):format(donutsLeft-1))

		-- set count -1
		inventory:setSpecialItemData(itemName, donutsLeft-1)

		-- use item donut
		if inventory.m_ClassItems["Donut"] then
			local instance = ItemManager.Map["Donut"]
			if instance.use then
				if instance:use(client) == false then
					return false
				end
			end
		end
	else
		-- remove item
		inventory:removeItemFromPlace(bag, place, 1)
	end
end
