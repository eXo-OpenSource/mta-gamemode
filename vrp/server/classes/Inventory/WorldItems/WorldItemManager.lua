-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/WorldItemManager.lua
-- *  PURPOSE:     This class manages WorldItems
-- *
-- ****************************************************************************
WorldItemManager = inherit(Singleton)
WorldItemManager.Map = {}

WorldItemManager.ItemClasses = {
	keypad = KeyPadWorldItem;
--	door = DoorWorldItem;
--	entrance = EntranceWorldItem;
--	furniture = FurnitureWorldItem;
}

function WorldItemManager:constructor()
	--[[self.m_CallbackMap = -- functions that are called once a specific world-item is created for an item
	{
		["Tor"] =  ItemManager:getSingleton():getInstance("Tor").addWorldObjectCallback,
		["Keypad"] =  ItemManager:getSingleton():getInstance("Keypad").addWorldObjectCallback,
		["Eingang"] =  ItemManager:getSingleton():getInstance("Eingang").addWorldObjectCallback,
		["Einrichtung"] = ItemManager:getSingleton():getInstance("Einrichtung").addWorldObjectCallback,
	}]]
	local result = sql:queryFetch("SELECT * FROM ??_WorldItems", sql:getPrefix())
	local model, item, obj, value, interior, dimension, posX, posY, posZ, owner, id, worldItemInstance
	for k, row in pairs(result) do
		id, model, item, value, interior, dimension, breakable, owner, locked = row.Id, row.Model, row.Item, row.Value, row.Interior, row.Dimension, row.Breakable, row.Owner, row.Locked
		posX, posY, posZ, rot = row.PosX, row.PosY, row.PosZ, row.Rotation
		local itemData = ItemManager.get(item)
		worldItemInstance = PlayerWorldItem:new(itemData, owner, Vector3(posX, posY, posZ), rot, breakable, owner, true, locked, value, interior, dimension, id)
		--[[worldItemInstance:setDataBaseId(id)
		worldItemInstance:setValue(value)
		worldItemInstance:setInterior(interior)
		worldItemInstance:setDimension(dimension)]]
	end
end

function WorldItemManager:destructor()
	self:onDestruction()
	local obj, isPermanent, hasChanged, pos, rot, value, dump
	for obj, id in pairs(WorldItemManager.Map) do
		if not obj.m_Delete then
			if obj and obj:isPermanent() then
				pos, rot, value = obj:getObject():getPosition(), obj:getObject():getRotation(), obj:getValue()
				if id > 0 then
					if obj:hasChanged() then
						sql:queryExec("UPDATE ??_WorldItems SET PosX=?, PosY=?, PosZ=?, Rotation=?, Value=?, Locked=? WHERE Id=?", sql:getPrefix(), pos.x, pos.y, pos.z, rot.z, obj:getValue(), obj:isLocked(), id)
					end
				else
					sql:queryExec("INSERT INTO ??_WorldItems (Item, Model, Owner, PosX, posY, posZ, Rotation, Value, Interior, Dimension, Breakable, Locked, Date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", sql:getPrefix(),
					obj:getItem().TechnicalName or "Generic", obj:getModel(), obj:getOwner(), pos.x, pos.y, pos.z, rot.z, obj:getValue(), obj:getInterior(), obj:getDimension(), obj:isBreakable(), obj:isLocked())
				end
			end
		else
			if id > 0 then
				sql:queryExec("DELETE FROM ??_WorldItems WHERE Id=?", sql:getPrefix(), id)
			end
		end
	end
end

function WorldItemManager:onDestruction()
	if ItemManager.Map["Keypad"] then
		ItemManager.Map["Keypad"]:delete()
	end
	if ItemManager.Map["Tor"] then
		ItemManager.Map["Tor"]:delete()
	end
	if ItemManager.Map["Eingang"] then
		ItemManager.Map["Eingang"]:delete()
	end
	if ItemManager.Map["Transmitter"] then
		ItemManager.Map["Transmitter"]:delete()
	end
end


addEvent("itemPlaced", true)
addEventHandler("itemPlaced", root,
	function(x, y, z, rotation, moved)
		local placingInfo = client.m_PlacingInfo
		if placingInfo then
			if x then

				client:sendShortMessage(_("%s %s.", client, placingInfo.item.m_Item.Name, moved and "verschoben" or "platziert"), nil, nil, 1000)
				placingInfo.callback(placingInfo, Vector3(x, y, z), rotation, client)
				--[[
				if placingInfo.callback then
					client:sendShortMessage(_("%s %s.", client, placingInfo.item.m_Item.Name, moved and "verschoben" or "platziert"), nil, nil, 1000)
					placingInfo.callback(placingInfo.item, Vector3(x, y, z), rotation)
				else
					client:sendShortMessage(_("%s %s.", client, placingInfo.itemData.Name, moved and "verschoben" or "platziert"), nil, nil, 1000)
				end]]
			else
				client:sendShortMessage(_("Vorgang abgebrochen.", client), nil, nil, 1000)
				if placingInfo.callback then
					placingInfo.callback(placingInfo.item, false)
				end
			end
			client.m_PlacingInfo = nil
		end
	end
)
