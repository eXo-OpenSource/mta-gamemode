-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/ItemGrowable.lua
-- *  PURPOSE:     Growable Super class
-- *
-- ****************************************************************************
ItemGrowable = inherit(Item)
ItemGrowable.m_WaterPlants = {	}
--CONSTANTS--
WEED_OBJECT = 3409
local SQL_Q1 = "INSERT INTO ??_plants (  PlantKey, PlantName, Owner, x, y, z, content, value2) VALUES (  ? , ? , ?, ?, ?, ?, ?, ? )"
local SQL_Q2 = "UPDATE ??_plants SET content = ?, value2 = ? WHERE PlantKey =?"
local SQL_Q3 = "SELECT * FROM ??_plants"
local SQL_Q4 = "DELETE FROM ??_plants WHERE PlantKey = ?"

ItemGrowable.m_Map = 
{
	
}

ItemGrowable.m_RemoveKeys = {	}

function ItemGrowable:constructor()
	
end

function ItemGrowable:destructor()

end

function ItemGrowable:use( player )

end

function ItemGrowable:getClientCheck( bool )

end

function ItemGrowable:removeWaterPlant( obj )
	local plant
	for i = 1,#ItemGrowable.m_WaterPlants do 
		plant = ItemGrowable.m_WaterPlants[i]
		if plant == obj then 
			table.remove( ItemGrowable.m_WaterPlants, i )
		end
	end
end

function ItemGrowable:getNextWaterPlant( player )
	local ep = getElementPosition
	local x,y = ep( player )
	local dist, minObj, px, py, obj
	local minDist = 6
	local df = getDistanceBetweenPoints2D
	for i = 1,#ItemGrowable.m_WaterPlants do 
		obj = ItemGrowable.m_WaterPlants[i]
		px, py = ep( obj )
		dist = df( px, py, x, y)
		if dist <= 5 then 
			if dist <= minDist then 
				minObj = obj
				minDist = dist
			end
		end
	end
	return minObj or nil
end

function ItemGrowable:savePlantSQL( )
	local x, y, z, owner, index, bcheck, scale, plant, obj, name
	for name, obj in pairs( ItemGrowable.m_Map )  do
		if obj then 
			for index2 = 1, #obj.m_Map do 
				plant = obj.m_Map[index2]
				if plant then
					x,y,z = getElementPosition( plant )
					owner = plant.m_Owner
					index = plant.m_UniqueIndex
					bcheck = ItemGrowable:isPlantInSQL( plant )
					scale = getObjectScale( plant )
					if not bcheck then
						bcheck = sql:queryExec( SQL_Q1, sql:getPrefix(), index, name, owner, x, y, z, scale, 0)
					else
						bcheck = sql:queryExec( SQL_Q2, sql:getPrefix(), scale, 0)
					end
					if not bcheck then
						print("[SQL-Error] Could not edit/create Plant: "..index)
					end
				end
			end
		end
	end
end

function ItemGrowable:isPlantInSQL( plant )
	for k, v in pairs( self.m_SQLt ) do
		if v.PlantKey == plant.m_UniqueIndex then 
			return true
		end
	end
	return false
end

function ItemGrowable:loadPlantSQL(  )
	local result = sql:queryFetch(SQL_Q3, sql:getPrefix() )
	local owner, x,y,z, name,index, scale, value
	if result then
		for k, v in pairs( result ) do
			owner = v.Owner
			x,y,z = v.x, v.y, v.z
			index = v.PlantKey
			name = v.PlantName
			scale = v.content
			value = v.value2
			if self.m_Map[ name ] then 
				self.m_Map[ name ]:createNew( owner, index, x, y, z, scale)
				outputChatBox("Planted")
			end
		end
	end
	self.m_SQLt = result
end

function ItemGrowable:removePlants( )
	local key, bcheck
	for index = 1, #self.m_RemoveKeys do
		key = self.m_RemoveKeys[index]
		if key then
			bcheck = sql:queryExec( SQL_Q4, sql:getPrefix(), key)
			if not bcheck then 
				print("[SQL-Error] Could not remove Plant: "..key)
			end
		end
	end
end



