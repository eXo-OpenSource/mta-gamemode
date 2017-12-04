-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemHealpack.lua
-- *  PURPOSE:     Healpack Item class
-- *
-- ****************************************************************************

ItemHealpack = inherit(Item)

function ItemHealpack:constructor()

end

function ItemHealpack:destructor()

end

function ItemHealpack:use(player)
	player:meChat(true, "benutzt ein Medikit!")
	player:setHealth(100)
end
