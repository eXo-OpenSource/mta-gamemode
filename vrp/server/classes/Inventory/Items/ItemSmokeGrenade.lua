-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemBomb.lua
-- *  PURPOSE:     C4 bomb item class
-- *
-- ****************************************************************************
ItemSmokeGrenade = inherit(Item)
ItemSmokeGrenade.Map = { }
local SMOKE_CHECK_INTERVAL = 10000
local SMOKE_DURATION = 30000

function ItemSmokeGrenade:constructor()
	setTimer(bind(self.checkSmokeRemove, self), SMOKE_CHECK_INTERVAL, 0)
end

function ItemSmokeGrenade:destructor()

end

function ItemSmokeGrenade:use(player)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventory():removeItem(self:getName(), 1)
		local worldItem = createObject(item:getModelId(), position.x , position.y, position.z)
		setElementDoubleSided(worldItem, true)
		setElementFrozen(worldItem, true)
		worldItem.m_CreationTime = getTickCount()
		ItemSmokeGrenade.Map[#ItemSmokeGrenade.Map+1] = worldItem
		worldItem.m_SmokeEntity = createObject(2780, position.x, position.y, position.z, 0, 0, rotation)
		setElementCollisionsEnabled(worldItem.m_SmokeEntity, false)
		setElementAlpha( worldItem.m_SmokeEntity, 0)
		setElementFrozen(worldItem.m_SmokeEntity, true)
		setObjectScale(worldItem.m_SmokeEntity, 1)
		attachElements(worldItem.m_SmokeEntity, worldItem)
		triggerClientEvent("itemRadioChangeURLClient", worldItem, "files/audio/smoke_explode.ogg")
	end)
end

function ItemSmokeGrenade:checkSmokeRemove() 
	local now = getTickCount()
	for i = 1, #ItemSmokeGrenade.Map do 
		if ItemSmokeGrenade.Map[i] and isElement(ItemSmokeGrenade.Map[i]) then
			if now >= ItemSmokeGrenade.Map[i].m_CreationTime + SMOKE_DURATION then 
				destroyElement(ItemSmokeGrenade.Map[i].m_SmokeEntity)
				destroyElement(ItemSmokeGrenade.Map[i]) 
				ItemSmokeGrenade.Map[i] = nil
			end
		else 
			ItemSmokeGrenade.Map[i] = nil
		end
	end
end