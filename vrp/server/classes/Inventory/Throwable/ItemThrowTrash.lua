-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Throwable/ItemThrowTrash.lua
-- *  PURPOSE:     ItemThrowTrash Class
-- *
-- ****************************************************************************
ItemThrowTrash = inherit(Item)
ItemThrowTrash.OffsetMatrix = -- bone attach offset
{
	position = {x=.14, y=0, z=.29},
	rotation = {x=0, y=180, z=0}
}

ItemThrowTrash.EntityOffset = -- model offset on collision
{
	position = {x=-0, y=0, z=.08},
	rotation = {x=0, y=0, z=0}
}

ItemThrowTrash.CustomBound = 
{
	x = 1, 
	y = 1, 
	z = 1
}

ItemThrowTrash.Model = 1265

function ItemThrowTrash:constructor()

end

function ItemThrowTrash:destructor()

end

function ItemThrowTrash:Event_throwCallback(player) 
	player:getInventory():removeItem("Abfall", 1)
	player:increaseStatistics("ThrownObject")
end

function ItemThrowTrash:use(player)
	if Fishing:getSingleton():isPlayerFishing(player) then return player:sendError(_("Pack erst deine Angel weg!")) end
	if not player:getThrowingObject() then 
		player:meChat(true, "zieht einen Müllsack.")
		player:sendInfo(_("Der Beutel ist bereit!", player))
		ThrowObject:new(player, ItemThrowTrash.Model, ItemThrowTrash.Model, ItemThrowTrash.OffsetMatrix)
			:setThrowCallback(bind(self.Event_throwCallback, self))
			:setSkillBased(true)
			:setEntityOffsetMatrix(ItemThrowTrash.EntityOffset)
			:setCustomBoundingBox(ItemThrowTrash.CustomBound)
			:updateCollision(false, true)
			:setScale(Vector3(0.7, 0.7, 0.8))
			
	else 
		if player:getThrowingObject():getModel() == ItemThrowTrash.Model then 
			player:getThrowingObject():delete()
			player:setThrowingObject(nil)
			player:meChat(true, "legt den Müllsack weg.")
			player:sendInfo(_("Der Müllsack wurde zurückgelegt!", player))
		end
	end
end
