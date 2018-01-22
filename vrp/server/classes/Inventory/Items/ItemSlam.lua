-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBomb.lua
-- *  PURPOSE:     C4 bomb item class
-- *
-- ****************************************************************************
ItemSlam = inherit(Item)
ItemSlam.Map = { }

function ItemSlam:constructor()
	addRemoteEvents{"onSlamTouchLine", "onSlamToggleLaser"}
	addEventHandler("onSlamTouchLine", root, bind(self.Event_onTouchLine, self))
	addEventHandler("onSlamToggleLaser", root, bind(self.Event_onSlamToggleLaser, self))
end

function ItemSlam:Event_onSlamToggleLaser( object ) 
	if ItemSlam.Map[object] then 
		local toggleLaser = not (getElementData(object, "Slam:laserEnabled")) 
		setElementData(object, "Slam:laserEnabled", toggleLaser)
		if toggleLaser then
			triggerClientEvent("itemRadioChangeURLClient", object, "files/audio/Items/slam_arm.ogg")
		end
	end
end

function ItemSlam:Event_onTouchLine( object ) 
	if ItemSlam.Map[object] then 
		self:detonateSlam( ItemSlam.Map[object], client )
	end
end

function ItemSlam:destructor()

end

function ItemSlam:detonateSlam( instance, detonatedBy ) 
	if instance then 
		local x,y,z = getElementPosition( instance.m_Object )
		createExplosion( x, y, z, 8, detonatedBy)
		delete(ItemSlam.Map[instance.m_Object])
	end
end

function ItemSlam:use(player)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventory():removeItem(self:getName(), 1)
		local worldItem =  PlayerWorldItem:new(item, player, position, rotation, false, player)
		setElementDoubleSided(worldItem.m_Object, true)
		setElementFrozen(worldItem.m_Object, true)
		setElementData( worldItem.m_Object, "detonatorSlam", true)
		ItemSlam.Map[worldItem.m_Object] = worldItem
	end)
end

function ItemSlam:attachColShape() 

end
