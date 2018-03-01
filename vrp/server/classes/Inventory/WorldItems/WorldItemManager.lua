-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/WorldItems/PermanentWorldItem.lua
-- *  PURPOSE:     This class represents an item in the world (drop and collectable)
-- *
-- ****************************************************************************
WorldItemManager = inherit(Singleton) 
WorldItemManager.Map = {}

function WorldItemManager:constructor() 
	local result = sql:queryFetch("SELECT * FROM ??_WorldItems", sql:getPrefix())
	local model, item, obj, interior, dimension, posX, posY, posZ, owner, id, worldItemInstance
	for k, row in pairs(result) do 
		id, model, item, interior, dimension, breakable, owner, locked = row.Id, row.Model, row.Item, row.Interior, row.Dimension, row.Breakable, row.Owner, row.Locked
		posX, posY, posZ, rot = row.PosX, row.PosY, row.PosZ, row.Rotation
		worldItemInstance = PlayerWorldItem:new(ItemManager.Map[item], owner, Vector3(posX, posY, posZ), rot, breakable, owner, true, locked)
		worldItemInstance:setDataBaseId(id)
	end
end


function WorldItemManager:destructor() 
	local obj, isPermanent, hasChanged, pos, rot, dump
	for obj, id in pairs(WorldItemManager.Map) do 
		if not obj.m_Delete then
			if obj and obj:isPermanent() and obj:hasChanged() then 
				pos = obj:getObject():getPosition()
				rot = obj:getObject():getRotation()
				if id > 0 then
					sql:queryExec("UPDATE ??_WorldItems SET PosX=?, PosY=?, PosZ=?, Rotation=?, Locked=?", sql:getPrefix(), pos.x, pos.y, pos.z, rot.z, obj:isLocked())
				else 
					sql:queryExec("INSERT INTO ??_WorldItems (Item, Model, Owner, PosX, posY, posZ, Rotation, Interior, Dimension, Breakable, Locked, Date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", sql:getPrefix(),
					obj:getItem():getName() or "Generic", obj:getModel(), obj:getOwner(), pos.x, pos.y, pos.z, rot.z, obj:getInterior(), obj:getDimension(), obj:isBreakable(), obj:isLocked())
				end
			end
		else
			if id > 0 then
				sql:queryExec("DELETE FROM ??_WorldItems WHERE Id=?", sql:getPrefix(), id)
			end
		end
	end
end

