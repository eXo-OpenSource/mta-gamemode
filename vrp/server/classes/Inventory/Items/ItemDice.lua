-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemDice.lua
-- *  PURPOSE:     Dice item class
-- *
-- ****************************************************************************
ItemDice = inherit(Item)

function ItemDice:constructor()
end

function ItemDice:destructor()

end

function ItemDice:use(player)
	player:meChat(true, "würfelt eine "..math.random(1,6).."!")
end
