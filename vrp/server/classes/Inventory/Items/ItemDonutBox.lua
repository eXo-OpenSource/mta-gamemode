-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/ItemEmptyCan.lua
-- *  PURPOSE:     Item Donutbox Class
-- *
-- ****************************************************************************
ItemDonutBox = inherit(ItemNew)

function ItemDonutBox:use(player, itemId, bag, place, itemName)
	local player = self.m_Inventory:getPlayer()
	if not player then return false end
	local itemId = self.m_Item.Id

	local donutsLeft = self.m_Inventory:getItemDurability(itemId)
	local donutsMax = self.m_Inventory:getItemMaxDurability(itemId)

	if donutsLeft and donutsLeft > 0 then
		local donut = ItemFood:new(self.m_Inventory, ItemManager.get("donut"), nil)
		local consumed = donut:use()
		if consumed then
			player:sendMessage(("#4F4F65%d/%d Donuts übrig!"):format(donutsLeft-1, donutsMax))

			-- set count -1
			self.m_Inventory:decreaseItemDurability(itemId)
			return true
		end
	else
		player:sendMessage(("#4F4F65Die Donut Box ist leer!"))
		return true, true
	end
end
