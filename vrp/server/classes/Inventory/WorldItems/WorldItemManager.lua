-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/WorldItemManager.lua
-- *  PURPOSE:     This class manages WorldItems
-- *
-- ****************************************************************************
WorldItemManager = inherit(Singleton)

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
			WorldItemManager.ItemClasses[row.Item]:new(itemData, row.PlacedBy, row.ElementId, row.ElementType, Vector3(row.PosX, row.PosY, row.PosZ), Vector3(row.RotX, row.RotY, row.RotZ),row.Dimension, row.Interior, true, row.Value, row.Metadata, row.Breakable, row.Locked, row.Id)
		else
			outputServerLog(inspect(WorldItemManager.ItemClasses))
			error(string.format("Invalid world item '%s' @ WorldItemManager:constructor", tostring(row.Item)))
		end
	end
end

function WorldItemManager:destructor()
	self:save()
end

function WorldItemManager:save()
	local changes = {
		insert = {},
		remove = {},
		update = {}
	}

	for objId, dirtySince in pairs(WorldItem.DirtyMap) do
		local obj = WorldItem.Map[objId]
		local internalId = obj.m_Id
		local pos, rot
		if obj:getObject() and isElement(obj:getObject()) then
			pos, rot = obj:getObject():getPosition(), obj:getObject():getRotation()
		end
		local item, model, placedBy = obj.m_Item.TechnicalName, obj:getModel(), obj.m_PlacedBy
		local elementId, elementType = obj.m_ElementId, obj.m_ElementType
		local interior, dimension, breakable = obj:getInterior(), obj:getDimension(), obj:isBreakable()
		local locked, creationDate, value = obj.m_Locked, obj.m_CreationDate, obj.m_Value
		local metadata = nil

		if obj.m_Metadata then
			metadata = toJSON(obj.m_Metadata, true)
		end

		if obj.m_DatabaseId and obj.m_DatabaseId ~= 0 then
			if obj.m_Delete then
				table.insert(changes.remove, {
					Id = obj.m_DatabaseId
				})
			else
				table.insert(changes.update, {
					Id = obj.m_DatabaseId,
					Item = item,
					Model = model,
					ElementId = elementId,
					ElementType = elementType,
					PlacedBy = placedBy,
					PosX = pos.x,
					PosY = pos.y,
					PosZ = pos.z,
					RotX = rot.x,
					RotY = rot.y,
					RotZ = rot.z,
					Interior = interior,
					Dimension = dimension,
					Value = value,
					Metadata = metadata,
					Breakable = breakable,
					Locked = locked,
					UpdatedAt = dirtySince
				})
			end
		else
			if not obj.m_Delete then
				table.insert(changes.insert, {
					InternalId = internalId,
					Item = item,
					Model = model,
					ElementId = elementId,
					ElementType = elementType,
					PlacedBy = placedBy,
					PosX = pos.x,
					PosY = pos.y,
					PosZ = pos.z,
					RotX = rot.x,
					RotY = rot.y,
					RotZ = rot.z,
					Interior = interior,
					Dimension = dimension,
					Value = value,
					Metadata = metadata,
					Breakable = breakable,
					Locked = locked,
					CreatedAt = creationDate
				})
			end
		end

		WorldItem.DirtyMap[objId] = nil
	end

	local queries = ""
	local queriesParams = {}

	for k, v in pairs(changes.update) do
		local query = "UPDATE ??_world_items SET "
		table.insert(queriesParams, sql:getPrefix())

		local params = ""

		for field, value in pairs(v) do
			if field ~= "Id" then
				if params ~= "" then params = params .. ", " end
				if field == "CreatedAt" or field == "UpdatedAt" then
					params = params .. field .. " = FROM_UNIXTIME(?)"
				elseif field == "Metadata" and not value then
					params = params .. field .. " = ??"
					value = "NULL"
				else
					params = params .. field .. " = ?"
				end
				table.insert(queriesParams, value)
			end
		end

		query = query .. params .. " WHERE Id = ?;"
		table.insert(queriesParams, v.Id)

		if queries ~= "" then queries = queries .. " " end
		queries = queries .. query
	end

	if #changes.remove > 0 then
		if queries ~= "" then queries = queries .. " " end
		queries = queries .. "DELETE FROM ??_world_items WHERE Id IN (?" .. string.rep(", ?", #changes.remove - 1) .. ")"
		table.insert(queriesParams, sql:getPrefix())
		for k, v in pairs(changes.remove) do
			table.insert(queriesParams, v.Id)
		end
	end

	if queries ~= "" then
		sql:queryExec(queries, unpack(queriesParams))
	end

	for k, v in pairs(changes.insert) do
		local query = "INSERT INTO ??_world_items "
		table.insert(queriesParams, sql:getPrefix())

		local fields = ""
		local params = ""

		for field, value in pairs(v) do
			if field ~= "InternalId" then
				if fields ~= "" then fields = fields .. ", " end
				if params ~= "" then params = params .. ", " end

				fields = fields .. field

				if field == "CreatedAt" or field == "UpdatedAt" then
					params = params .. "FROM_UNIXTIME(?)"
				elseif field == "Metadata" and not value then
					params = params .. "??"
				else
					params = params .. "?"
				end

				table.insert(queriesParams, value)
			end
		end

		query = query .. "(" .. fields .. ") VALUES (" .. params .. ")"

		sql:queryExec(query, unpack(queriesParams))
		local id = sql:lastInsertId()

		if WorldItem.Map[v.InternalId] then
			WorldItem.Map[v.InternalId]:setDatabaseId(id)
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
						placingInfo.worldItemClass.onPlace(client, placingInfo, Vector3(x, y, z), Vector3(0, 0, rotation))
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
