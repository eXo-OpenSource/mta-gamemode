-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Item.lua
-- *  PURPOSE:     Item Super Class
-- *
-- ****************************************************************************
ItemNew = inherit(Object)

ItemNew.constructor = pure_virtual

function ItemNew:virtual_constructor(inventory, itemData, item)
    self.m_Inventory = inventory
    self.m_ItemData = itemData
    self.m_Item = item
end

function ItemNew:getTechnicalName()
    return self.m_ItemData.TechnicalName
end
--[[
function Item:setName(name)
	self.m_ItemName = name
end

function Item:loadItem()
	local itemData = InventoryManagerOld:getSingleton():getItemDataForItem(self.m_ItemName)
	if itemData then
		self.m_ItemTasche = itemData["Tasche"]
		self.m_ItemIcon = itemData["Icon"]
		self.m_ItemItemMax = itemData["Item_Max"]
		self.m_ItemWegwerf = itemData["Wegwerf"]
		self.m_ItemHandel = itemData["Handel"]
		self.m_ItemStack_max = itemData["Stack_max"]
		self.m_ItemVerbraucht = itemData["Verbraucht"]
		self.m_ItemModel = itemData["ModelID"]
	else
		outputDebug("Could not load Item "..self.m_ItemName)
	end
end

function Item:getName()
	return self.m_ItemName
end

function Item:expire()
end

function Item:getModelId()
	return self.m_ItemModel ~= 0 and self.m_ItemModel or 2969
end

function Item:place(owner, pos, rotation, amount)
	local worldItem = WorldItem:new(self, owner, pos, rotation)
	return worldItem
end

function Item:startObjectPlacing(player, callback, hideObject, customModel)
	if player.m_PlacingInfo then
		player:sendError(_("Du kannst nur ein Objekt zur selben Zeit setzen!", player))
		return false
	end
	if player:getData("inJail") or player:getData("inAdminPrison") then
		player:sendError(_("Du kannst hier keine Objekte platzieren.", player)) 
		return false
	end

	-- Start the object placer on the client
	player:triggerEvent("objectPlacerStart", customModel or self:getModelId(), "itemPlaced", hideObject)
	player.m_PlacingInfo = {item = self, callback = callback}
	return true
end

addEvent("itemPlaced", true)
addEventHandler("itemPlaced", root,
	function(x, y, z, rotation, moved)
		local placingInfo = client.m_PlacingInfo
		if placingInfo then
			if x then
				client:sendShortMessage(_("%s %s.", client, placingInfo.item:getName(), moved and "verschoben" or "platziert"), nil, nil, 1000)
				placingInfo.callback(placingInfo.item, Vector3(x, y, z), rotation)
			else
				client:sendShortMessage(_("Vorgang abgebrochen.", client), nil, nil, 1000)
				placingInfo.callback(placingInfo.item, false) 
			end
			client.m_PlacingInfo = nil
		end
	end
)
]]