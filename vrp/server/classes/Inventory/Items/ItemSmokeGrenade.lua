-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Items/ItemSmokeGrenade.lua
-- *  PURPOSE:     Smoke Grenade Item
-- *
-- ****************************************************************************
ItemSmokeGrenade = inherit(Item)
ItemSmokeGrenade.Map = { }
local SMOKE_CHECK_INTERVAL = 10000
local SMOKE_DURATION = 60000

addRemoteEvents{"onPlayerEnterTearGas", "onPlayerLeaveTearGas", "onPlayerRequestSmoke"}
function ItemSmokeGrenade:constructor()
	addEventHandler("onPlayerEnterTearGas", root, bind(self.Event_onPlayerEnterTear, self))
	addEventHandler("onPlayerLeaveTearGas", root, bind(self.Event_onPlayerLeaveTear, self))
	addEventHandler("onPlayerRequestSmoke", root, bind(self.Event_requestSync, self))
	setTimer(bind(self.checkSmokeRemove, self), SMOKE_CHECK_INTERVAL, 0)
end

function ItemSmokeGrenade:destructor()

end

function ItemSmokeGrenade:Event_onPlayerEnterTear()
	if client then 
		client:setWalkingStyle(69)
	end
end


function ItemSmokeGrenade:Event_onPlayerLeaveTear()
	if client then 
		client:setWalkingStyle(0)
	end
end


function ItemSmokeGrenade:use(player)
	local result = self:startObjectPlacing(player,
	function(item, position, rotation)
		if item ~= self or not position then return end
		player:getInventoryOld():removeItem(self:getName(), 1)
		local worldItem = createObject(item:getModelId(), position.x , position.y, position.z)
		worldItem:setDoubleSided(true)
		worldItem:setFrozen(true)
		worldItem.m_CreationTime = getTickCount()
		worldItem.m_SmokeEntity = createObject(2780, position.x, position.y, position.z, 0, 0, rotation)
		worldItem.m_SmokeEntity:setCollisionsEnabled(false)
		worldItem.m_SmokeEntity:setAlpha(0)
		worldItem.m_SmokeEntity:setFrozen(true)
		worldItem.m_SmokeEntity:attach(worldItem)
		worldItem:setDimension(player:getDimension())
		worldItem:setInterior(player:getInterior())
		worldItem.m_SmokeEntity:setDimension(player:getDimension())
		worldItem.m_SmokeEntity:setInterior(player:getInterior())
		ItemSmokeGrenade.Map[worldItem] = {worldItem.m_SmokeEntity, self:createNameTagZone(worldItem)}
		triggerClientEvent("itemRadioChangeURLClient", worldItem, "files/audio/smoke_explode.ogg")
		self:sync()
	end)
end

function ItemSmokeGrenade:sync()
	for k, p in ipairs(getElementsByType("player")) do 
		p:triggerEvent("ItemSmokeSync", ItemSmokeGrenade.Map)
	end
end

function ItemSmokeGrenade:createNameTagZone(worldItem)
	if worldItem and isElement(worldItem) then
		worldItem.m_ColZone = createColSphere(worldItem:getPosition(), 3)
		local elementsWithinColShape = getElementsWithinColShape(worldItem.m_ColZone, "player")
		worldItem.m_SmokeMarker = createMarker(worldItem:getPosition(), "corona", 0, 0, 0, 0, 0)
		worldItem.m_SmokeMarker:setData("isSmokeShape", true, true)
		worldItem.m_SmokeMarker:setData("smokeCol", worldItem.m_ColZone, true)
		for k, p in ipairs(elementsWithinColShape) do 
			if (p:getDimension() == worldItem.m_ColZone:getDimension()) and (p:getInterior() == worldItem.m_ColZone:getInterior()) then
				if p.setPublicSync then p:setPublicSync("inSmokeGrenade", true) end
				p.m_LastSmokeColShape = worldItem.m_ColZone
			end
		end
		addEventHandler("onColShapeHit", worldItem.m_ColZone, 
		function(player, dimension) 
			if player and dimension then 
				player.m_LastSmokeColShape = source
				if player.setPublicSync then
					player:setPublicSync("inSmokeGrenade", true)
				end
			end
		end)
		addEventHandler("onColShapeLeave", worldItem.m_ColZone, 
		function(player, dimension) 
			if player and dimension then 
				if player.m_LastSmokeColShape == source then
					if player.setPublicSync then
						player:setPublicSync("inSmokeGrenade", false)
					end
				end
			end
		end)
		addEventHandler("onElementDestroy", worldItem.m_ColZone, 
		function()
			local elementsWithinColShape = getElementsWithinColShape(source, "player")
			for k, p in ipairs(elementsWithinColShape) do 
				if (p:getDimension() == source:getDimension()) and (p:getInterior() == source:getInterior()) then 
					if p.m_LastSmokeColShape == source then 
						if p.setPublicSync then
							p:setPublicSync("inSmokeGrenade", false)
						end
					end
				end
			end
		end)
		return worldItem.m_ColZone
	end
	return
end

function ItemSmokeGrenade:checkSmokeRemove() 
	local now = getTickCount()
	for smoke, bool in pairs(ItemSmokeGrenade.Map) do 
		if smoke and isElement(smoke) then
			if now >= smoke.m_CreationTime + SMOKE_DURATION then 
				smoke.m_SmokeEntity:destroy()
				smoke.m_ColZone:destroy()
				ItemSmokeGrenade.Map[smoke] = nil
				smoke:destroy()
			end
		else 
			if smokeEntity[1] and isElement(smokeEntity[1]) then 
				smokeEntity[1]:destroy()
				smokeEntity[2]:destroy()
			end
			ItemSmokeGrenade.Map[smoke] = nil
		end
	end
end

function ItemSmokeGrenade:Event_requestSync()
	client:triggerEvent("ItemSmokeSync", ItemSmokeGrenade.Map)
end