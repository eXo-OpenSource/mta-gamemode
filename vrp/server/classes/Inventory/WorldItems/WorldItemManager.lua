-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/WorldItemManager.lua
-- *  PURPOSE:     This class manages WorldItems
-- *
-- ****************************************************************************
WorldItemManager = inherit(Singleton)
WorldItemManager.Map = {}

function WorldItemManager:constructor()
	WorldItemManager.ItemClasses = {
		keypad = KeyPadWorldItem;
	--	door = DoorWorldItem;
	--	entrance = EntranceWorldItem;
	--	furniture = FurnitureWorldItem;
	}

	local result = sql:queryFetch("SELECT * FROM ??_world_items", sql:getPrefix())

	for k, row in pairs(result) do
		local itemData = ItemManager.get(row.Item)
		if WorldItemManager.ItemClasses[row.Item] then
			WorldItemManager.ItemClasses[row.Item]:new(itemData, row.Owner, Vector3(row.PosX, row.PosY, row.PosZ), row.Rotation, row.Breakable, row.Owner, true, row.Locked, row.Value, row.Interior, row.Dimension, row.Id)
		else
			outputServerLog(inspect(WorldItemManager.ItemClasses))
			error(string.format("Invalid world item '%s' @ WorldItemManager:constructor", tostring(row.Item)))
		end
	end
end

function WorldItemManager:destructor()
	local obj, isPermanent, hasChanged, pos, rot, value, dump
	for obj, id in pairs(WorldItemManager.Map) do
		if not obj.m_Delete then
			if obj and obj:isPermanent() then
				pos, rot, value = obj:getObject():getPosition(), obj:getObject():getRotation(), obj:getValue()
				if id > 0 then
					if obj:hasChanged() then
						sql:queryExec("UPDATE ??_world_items SET PosX = ?, PosY = ?, PosZ = ?, Rotation = ?, Value = ?, Locked = ? WHERE Id = ?", sql:getPrefix(), pos.x, pos.y, pos.z, rot.z, obj:getValue(), obj:isLocked(), id)
					end
				else
					sql:queryExec("INSERT INTO ??_world_items (Item, Model, Owner, PosX, posY, posZ, Rotation, Value, Interior, Dimension, Breakable, Locked, Date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", sql:getPrefix(),
					obj:getItem().TechnicalName or "Generic", obj:getModel(), obj:getOwner(), pos.x, pos.y, pos.z, rot.z, obj:getValue(), obj:getInterior(), obj:getDimension(), obj:isBreakable(), obj:isLocked())
				end
			end
		else
			if id > 0 then
				sql:queryExec("DELETE FROM ??_world_items WHERE Id = ?", sql:getPrefix(), id)
			end
		end
	end
end

addEvent("itemPlaced", true)
addEventHandler("itemPlaced", root,
	function(x, y, z, rotation, moved)
		local placingInfo = client.m_PlacingInfo
		if placingInfo then
			if x then
				if moved then
					client:sendShortMessage(_("%s %s.", client, placingInfo.item.m_ItemName, "verschoben"), nil, nil, 1000)

					if placingInfo.callback then
						placingInfo.callback(placingInfo.item, Vector3(x, y, z), rotation)
					end
				else
					client:sendShortMessage(_("%s %s.", client, placingInfo.item.Name, "platziert"), nil, nil, 1000)

					if placingInfo.worldItemClass and placingInfo.worldItemClass.onPlace then
						placingInfo.worldItemClass.onPlace(client, placingInfo, Vector3(x, y, z), rotation)
					end
				end
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
