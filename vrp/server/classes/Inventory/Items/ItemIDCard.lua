-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemIDCard.lua
-- *  PURPOSE:     Id Card
-- *
-- ****************************************************************************
ItemIDCard = inherit(Item)

function ItemIDCard:constructor()

end

function ItemIDCard:destructor()

end

function ItemIDCard:use(player)
	player:triggerEvent("closeInventory")
	player:triggerEvent("showIDCard")
end
