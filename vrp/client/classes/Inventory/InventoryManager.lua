-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Inventory/InventoryManager.lua
-- *  PURPOSE:     InventoryManager Class
-- *
-- ****************************************************************************
InventoryManager = inherit(Singleton)

addRemoteEvents{"onInventorySync", "openInventory"}

function InventoryManager:constructor()
	self.m_SyncHookPlayer = Hook:new()
	self.m_SyncHook = Hook:new()
	self.m_CachedInventories = {}
	self.m_PlayerInventoryId = 0
	self.m_OpenInventoryGUIs = {}

	setTimer(function()
		localPlayer:setPrivateSyncChangeHandler("Id", function()
			local id = localPlayer:getPrivateSync("Id")
			if id and id ~= 0 then
				localPlayer:setPrivateSyncChangeHandler("Id", nil)
				InventoryManager:getSingleton().m_PlayerInventoryGUI = InventoryGUI:new(_"Inventory", DbElementType.Player, id)
				InventoryManager:getSingleton().m_PlayerInventoryGUI:hide()


				bindKey("i", "up", bind(function()
					self.m_PlayerInventoryGUI:toggle()
				end, InventoryManager:getSingleton()))
			end
		end)
	end, 100, 1)

	addEventHandler("onInventorySync", root, bind(self.Event_onInventorySync, self))
	addEventHandler("openInventory", root, bind(self.Event_openInventory, self))
end

function InventoryManager:Event_openInventory(title, elementType, elementId)
	local inventory = InventoryGUI:new(title, elementType, elementId)
	--[[
		screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2
	]]
	self.m_PlayerInventoryGUI:open()
	self.m_PlayerInventoryGUI:setAbsolutePosition(screenWidth/2-self.m_PlayerInventoryGUI.m_Width - 5, screenHeight/2-self.m_PlayerInventoryGUI.m_Height/2)
	inventory:setAbsolutePosition(screenWidth/2 + 5, screenHeight/2-inventory.m_Height/2)
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
