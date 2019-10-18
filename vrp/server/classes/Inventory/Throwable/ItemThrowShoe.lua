-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Throwable/ItemThrowShoe.lua
-- *  PURPOSE:     ItemThrowShoe Class
-- *
-- ****************************************************************************
ItemThrowShoe = inherit(Item)
ItemThrowShoe.OffsetMatrix = 
{
	position = {x=-.1, y=.06, z=.5},
	rotation = {x=0, y=180, z=270}
}
ItemThrowShoe.Model = 1901
function ItemThrowShoe:constructor()

end

function ItemThrowShoe:destructor()

end

function ItemThrowShoe:Event_throwCallback(player) 
	player:getInventory():removeItem("Schuh", 1)
end

function ItemThrowShoe:use(player)
	if not player:getThrowingObject() then 
		player:meChat(true, "zieht einen Schuh.")
		player:sendInfo(_("Der Schuh ist bereit!", player))
		ThrowObject:new(player, ItemThrowShoe.Model, 1654, ItemThrowShoe.OffsetMatrix):setThrowCallback(bind(self.Event_throwCallback, self))
	else 
		if player:getThrowingObject():getModel() == ItemThrowShoe.Model then 
			player:getThrowingObject():delete()
			player:setThrowingObject(nil)
			player:meChat(true, "legt den Schuh weg.")
			player:sendInfo(_("Der Schuh wurde zurückgelegt!", player))
		end
	end
end
