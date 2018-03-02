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
	self.m_CallbackMap = 
	{
		["Tor"] =  ItemManager:getSingleton():getInstance("Tor").addWorldObjectCallback, 
		["Keypad"] =  ItemManager:getSingleton():getInstance("Keypad").addWorldObjectCallback,
		["Eingang"] =  ItemManager:getSingleton():getInstance("Eingang").addWorldObjectCallback,
	}
	local result = sql:queryFetch("SELECT * FROM ??_WorldItems", sql:getPrefix())
	local model, item, obj, value, interior, dimension, posX, posY, posZ, owner, id, worldItemInstance
	for k, row in pairs(result) do 
		id, model, item, value, interior, dimension, breakable, owner, locked = row.Id, row.Model, row.Item, row.Value, row.Interior, row.Dimension, row.Breakable, row.Owner, row.Locked
		posX, posY, posZ, rot = row.PosX, row.PosY, row.PosZ, row.Rotation
		worldItemInstance = PlayerWorldItem:new(ItemManager.Map[item], owner, Vector3(posX, posY, posZ), rot, breakable, owner, true, locked)
		worldItemInstance:setDataBaseId(id)
		worldItemInstance:setValue(value)
		worldItemInstance:setInterior(interior) 
		worldItemInstance:setDimension(dimension)
		worldItemInstance:setAnonymous(true)
		if self.m_CallbackMap[item] then 
			self.m_CallbackMap[item](ItemManager:getSingleton():getInstance(item), id, worldItemInstance)
		end
	end
end

function WorldItemManager:destructor()
	self:onDestruction()
	local obj, isPermanent, hasChanged, pos, rot, value, dump
	for obj, id in pairs(WorldItemManager.Map) do 
		if not obj.m_Delete then
			if obj and obj:isPermanent() then 
				pos = obj:getObject():getPosition()
				rot = obj:getObject():getRotation()
				value = obj:getValue()
				if id > 0 then
					if obj:hasChanged() then
						sql:queryExec("UPDATE ??_WorldItems SET PosX=?, PosY=?, PosZ=?, Rotation=?, Value=?, Locked=? WHERE Id=?", sql:getPrefix(), pos.x, pos.y, pos.z, rot.z, obj:getValue(), obj:isLocked(), id)
					end
				else 
					sql:queryExec("INSERT INTO ??_WorldItems (Item, Model, Owner, PosX, posY, posZ, Rotation, Value, Interior, Dimension, Breakable, Locked, Date) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())", sql:getPrefix(),
					obj:getItem():getName() or "Generic", obj:getModel(), obj:getOwner(), pos.x, pos.y, pos.z, rot.z, obj:getValue(), obj:getInterior(), obj:getDimension(), obj:isBreakable(), obj:isLocked())
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

