-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/Items/SlamWorldItem.lua
-- *  PURPOSE:
-- *
-- ****************************************************************************
SlamWorldItem = inherit(PlayerWorldItem)
SlamWorldItem.Map = {}
addRemoteEvents{"onSlamTouchLine", "onSlamToggleLaser"}

function SlamWorldItem.onPlace(player, placingInfo, position, rotation)
	if not position then return end
	player:getInventory():takeItem(placingInfo.item.Id, 1)
	player:sendInfo(_("%s hinzugefügt!", player, placingInfo.itemData.Name))
	local int = player:getInterior()
	local dim = player:getDimension()
	SlamWorldItem:new(placingInfo.itemData, player:getId(), player:getId(), DbElementType.Player, position, rotation, dim, int, true, "#####", {locked = false}, false, false)
end

function SlamWorldItem:constructor(itemData, placedBy, elementId, elementType, position, rotation, dimension, interior, isPermanent, value, metadata, breakable, locked, databaseId)
    SlamWorldItem.Map[self.m_Id] = self

	local object = self:getObject()

	setElementDoubleSided(object, true)
	setElementFrozen(object, true)
	setElementData(object, "detonatorSlam", true)
	-- ItemSlam.Map[object] = worldItem

	addEventHandler("onSlamTouchLine", object, bind(self.Event_onTouchLine, self))
	addEventHandler("onSlamToggleLaser", object, bind(self.Event_onSlamToggleLaser, self))
end

function SlamWorldItem:Event_onSlamToggleLaser()
	local object = self:getObject()

	local toggleLaser = not (getElementData(object, "Slam:laserEnabled"))
	setElementData(object, "Slam:laserEnabled", toggleLaser)

	if toggleLaser then
		triggerClientEvent("itemRadioChangeURLClient", object, "files/audio/Items/slam_arm.ogg")
	end
end

function SlamWorldItem:Event_onTouchLine()
	self:detonateSlam(client)
end

function SlamWorldItem:detonateSlam(detonatedBy)
	local x,y,z = getElementPosition(self.m_Object)

	createExplosion(x, y, z, 8)
	createExplosion(x, y, z, 8)

	delete(self)
end
