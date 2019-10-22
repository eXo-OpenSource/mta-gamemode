-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Throwable/ItemThrowBottle.lua
-- *  PURPOSE:     ItemThrowBottle Class
-- *
-- ****************************************************************************
ItemThrowBottle = inherit(Item)
ItemThrowBottle.OffsetMatrix = -- bone attach offset
{
	position = {x=0, y=.05, z=0.05},
	rotation = {x=90, y=180, z=90}
}

ItemThrowBottle.EntityOffset = -- model offset on collision
{
	position = {x=-0, y=0, z=0},
	rotation = {x=0, y=0, z=0}
}

ItemThrowBottle.CustomBound = 
{
	x = 1, 
	y = 1, 
	z = 1
}

ItemThrowBottle.Model = 1486

function ItemThrowBottle:constructor()

end

function ItemThrowBottle:destructor()

end

function ItemThrowBottle:Event_throwCallback(player) 
	player:getInventory():removeItem("Flasche", 1)
	player:increaseStatistics("ThrownObject")
end

function ItemThrowBottle:use(player)
	if Fishing:getSingleton():isPlayerFishing(player) then return player:sendError(_("Pack erst deine Angel weg!")) end
	if not player:getThrowingObject() then 
		player:meChat(true, "zieht eine Flasche.")
		player:sendInfo(_("Die Flasche ist bereit!", player))
		ThrowObject:new(player, ItemThrowBottle.Model, 1654, ItemThrowBottle.OffsetMatrix)
			:setThrowCallback(bind(self.Event_throwCallback, self))
			:setSkillBased(true)
			:setEntityOffsetMatrix(ItemThrowBottle.EntityOffset)
			:setCustomBoundingBox(ItemThrowBottle.CustomBound)
			:updateCollision(false, true)
			:setDamage(0)
	else 
		if player:getThrowingObject():getModel() == ItemThrowBottle.Model then 
			player:getThrowingObject():delete()
			player:setThrowingObject(nil)
			player:meChat(true, "legt die Flasche weg.")
			player:sendInfo(_("Die Flasche wurde zurückgelegt!", player))
		end
	end
end
