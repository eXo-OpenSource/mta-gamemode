-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBomb.lua
-- *  PURPOSE:     C4 bomb item class
-- *
-- ****************************************************************************
ItemSlam = inherit(ItemWorld)
ItemSlam.Map = {}

function ItemSlam:constructor()
	self.m_WorldItemClass = SlamWorldItem
end

function ItemSlam:destructor()
end



--[[
ItemSlam = inherit(Item)
ItemSlam.Map = { }
ItemSlam.EntityMap = {}
function ItemSlam:constructor()
	addRemoteEvents{"onSlamTouchLine", "onSlamToggleLaser", "onRequestSlams"}
	addEventHandler("onSlamTouchLine", root, bind(self.Event_onTouchLine, self))
	addEventHandler("onSlamToggleLaser", root, bind(self.Event_onSlamToggleLaser, self))
	addEventHandler("onRequestSlams", root, bind(self.Event_onRequestSlams, self))
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
		createExplosion( x, y, z, 8)
		createExplosion( x, y, z, 8)
		local id = self:getSlamIDFromObj( instance.m_Object )
		if id then
			table.remove(self.EntityMap, id)
		end
		for key, player in ipairs(getElementsByType("player")) do
			player:triggerEvent("syncItemSlams", ItemSlam.EntityMap)
		end
		delete(ItemSlam.Map[instance.m_Object])
	end
end

function ItemSlam:getSlamIDFromObj( instance )
	for i = 1, #ItemSlam.EntityMap do
		if ItemSlam.EntityMap[i] == instance then
			return i
		end
	end
	return false
end

function ItemSlam:Event_onRequestSlams( )
	if client then
		client:triggerEvent("syncItemSlams", ItemSlam.EntityMap)
	end
end

function ItemSlam:use(player)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventoryOld():removeItem(self:getName(), 1)
		local worldItem =  PlayerWorldItem:new(item, player, position, rotation, false, player)
		setElementDoubleSided(worldItem.m_Object, true)
		setElementFrozen(worldItem.m_Object, true)
		setElementData( worldItem.m_Object, "detonatorSlam", true)
		ItemSlam.Map[worldItem.m_Object] = worldItem
		ItemSlam.EntityMap[#ItemSlam.EntityMap+1] = worldItem.m_Object --// Table that is synced with the client containing the actual slam gtasa-objects
		for key, player in ipairs(getElementsByType("player")) do
			player:triggerEvent("syncItemSlams", ItemSlam.EntityMap)
		end
	end)
end

function ItemSlam:attachColShape()

end
]]
