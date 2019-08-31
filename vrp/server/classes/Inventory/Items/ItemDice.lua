-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemDice.lua
-- *  PURPOSE:     Dice item class
-- *
-- ****************************************************************************
ItemDice = inherit(ItemNew)

function ItemDice:use()
	local player = self.m_Inventory:getPlayer()

	if not player then return false end

	player:meChat(true, "würfelt eine "..math.random(1,6).."!")

	return true
end
