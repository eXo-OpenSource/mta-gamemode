-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/InventoryManager.lua
-- *  PURPOSE:     InventoryManager Class
-- *
-- ****************************************************************************
InventoryManager = inherit(Singleton)

addEvent("onInventoryItemLeft")
addEvent("onInventoryItemRight")
addRemoteEvents{"onInventorySync"}

function InventoryManager:constructor()
	self.m_OnInventorySync = bind(self.Event_onInventorySync, self)
	self.m_OnInventoryLeft = bind(self.Event_onItemLeft, self)
	self.m_OnInventoryRight = bind(self.Event_onItemRight, self)
	self.m_SyncHookPlayer = Hook:new()
	self.m_SyncHook = Hook:new()
	self.m_CachedInventories = {}
	self.m_PlayerInventoryId = 0

	addEventHandler("onInventorySync", root, self.m_OnInventorySync)
	addEventHandler("onInventoryItemLeft", root, self.m_OnInventoryLeft)
	addEventHandler("onInventoryItemRight", root, self.m_OnInventoryRight)
end

function InventoryManager:Event_onInventorySync(inventoryId, elementId, elementType, size, items)
	self.m_CachedInventories[inventoryId] = {
		inventoryId = inventoryId,
		elementId = elementId,
		elementType = elementType,
		size = size,
		items = items
	}

	if elementType == 1 and elementId == localPlayer:getPrivateSync("Id") then
		self.m_PlayerInventoryId = inventoryId
		self.m_SyncHookPlayer:call(inventoryId, elementId, elementType, size, items)
	end
	self.m_SyncHook:call(inventoryId, elementId, elementType, size, items)
end

function InventoryManager:getPlayerInventory()
	return self.m_CachedInventories[self.m_PlayerInventoryId]
end

function InventoryManager:getPlayerHook()
	return self.m_SyncHookPlayer
end

function InventoryManager:getHook()
	return self.m_SyncHook
end

function InventoryManager:Event_onItemLeft(inventoryId, item)
	outputChatBox(item.Slot .. " item left")
end

function InventoryManager:Event_onItemRight(inventoryId, item)
	if self.m_PlayerInventoryId == inventoryId then
		if not getKeyState("lshift") then
			triggerServerEvent("onItemUse", localPlayer, inventoryId, item.Id)
		else
			triggerServerEvent("onItemUseSecondary", localPlayer, inventoryId, item.Id)
		end
	end
end
