-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Throwable/ItemThrowShoe.lua
-- *  PURPOSE:     ItemThrowShoe Class
-- *
-- ****************************************************************************
ItemThrowShoe = inherit(Item)
ItemThrowShoe.OffsetMatrix = -- bone attach offset
{
	position = {x=-.25, y=.06, z=.32},
	rotation = {x=0, y=180, z=270}
}

ItemThrowShoe.EntityOffset = -- model offset on collision
{
	position = {x=-0, y=0.15, z=-.2},
	rotation = {x=0, y=0, z=0}
}

ItemThrowShoe.CustomBound = 
{
	x = 0.3, 
	y = 0.05, 
	z = .8
}

ItemThrowShoe.Model = 1901

function ItemThrowShoe:constructor()

end

function ItemThrowShoe:destructor()

end

function ItemThrowShoe:Event_throwCallback(player) 
	player:getInventory():removeItem("Schuh", 1)
	player:increaseStatistics("ThrownObject")
end

function ItemThrowShoe:use(player)
	if Fishing:getSingleton():isPlayerFishing(player) then return player:sendError(_("Pack erst deine Angel weg!")) end
	if not player:getThrowingObject() then 
		player:meChat(true, "zieht einen Schuh.")
		player:sendInfo(_("Der Schuh ist bereit!", player))
		ThrowObject:new(player, ItemThrowShoe.Model, 1654, ItemThrowShoe.OffsetMatrix)
			:setThrowCallback(bind(self.Event_throwCallback, self))
			:setSkillBased(true)
			:setEntityOffsetMatrix(ItemThrowShoe.EntityOffset)
			:setCustomBoundingBox(ItemThrowShoe.CustomBound)
			:setDamage(0)
	else 
		if player:getThrowingObject():getModel() == ItemThrowShoe.Model then 
			player:getThrowingObject():delete()
			player:setThrowingObject(nil)
			player:meChat(true, "legt den Schuh weg.")
			player:sendInfo(_("Der Schuh wurde zurückgelegt!", player))
		end
	end
end
