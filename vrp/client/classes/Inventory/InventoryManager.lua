-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/InventoryManager.lua
-- *  PURPOSE:     InventoryManager Class
-- *
-- ****************************************************************************
InventoryManager = inherit(Singleton)

addRemoteEvents{"onInventorySync"}

function InventoryManager:constructor()
	self.m_OnInventorySync = bind(self.Event_onInventorySync, self)
	self.m_SyncHookPlayer = Hook:new()
	self.m_SyncHook = Hook:new()
	self.m_CachedInventories = {}
	self.m_PlayerInventoryId = 0

	setTimer(function(self)
		self.m_PlayerInventoryGUI = InventoryGUI:new(_"Inventory", DbElementType.Player, 4123) -- because fuck it
		self.m_PlayerInventoryGUI:hide()

		bindKey("k", "up", bind(function()
			self.m_PlayerInventoryGUI:toggle()
		end, self))
	end, 100, 1, self)


	addEventHandler("onInventorySync", root, self.m_OnInventorySync)
end

function InventoryManager:Event_onInventorySync(inventoryData, items)
	self.m_CachedInventories[inventoryData.Id] = {
		data = inventoryData;
		items = items;
	}

	if inventoryData.ElementType == DbElementType.Player and inventoryData.ElementId == localPlayer:getPrivateSync("Id") then
		self.m_PlayerInventoryId = inventoryData.Id
		self.m_SyncHookPlayer:call(inventoryData, items)
	end
	self.m_SyncHook:call(inventoryData, items)
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

function InventoryManager:onItemLeft(inventoryId, item, slot)
	if item ~= nil then
		playSound("files/audio/Inventory/move-pickup.mp3")
		GUIItemDragging:getSingleton():setItem(item, slot)
	end
end

function InventoryManager:onItemRight(inventoryId, item)
	if self.m_PlayerInventoryId == inventoryId then
		if not getKeyState("lshift") then
			triggerServerEvent("onItemUse", localPlayer, inventoryId, item.Id)
		else
			triggerServerEvent("onItemUseSecondary", localPlayer, inventoryId, item.Id)
		end
	end
end


function InventoryManager:isHovering()
	return true
end
