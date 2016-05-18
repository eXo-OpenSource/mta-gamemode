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
local SQL_Q1 = "INSERT INTO ??_plants ( ID, PlantKey, PlantName, Owner, x, y, z, content, value2) VALUES ( ?, ? , ? , ?, ?, ?, ?, ?, ? )"
local SQL_Q2 = "SELECT * FROM ??_plant"

ItemGrowable.m_PlantIndex = 
{
	["Weed"] =  PlantWeed,
}

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

function ItemGrowable:savePlants( )
	local obj, plant, x,y,z, owner, unique, bcheck, id
	local notInserted = 0
	for i = 1,#ItemGrowable.m_PlantIndex do 
		obj = ItemGrowable.m_PlantIndex[i]
		for i2 = 1, #obj.m_Map do
			plant = obj.m_Map[i2]
			x,y,z = getElementPosition( plant )
			owner = plant.m_Owner 
			unique = plant.m_UniqueIndex
			bcheck = self:isPlantInSQL( plant )
			if not bcheck then
				--sql:queryExec( SQL_Q1, sql:getPrefix())
			end
		end
	end
end

function ItemGrowable:loadPlants( )
	local x, y, z, plant, scale, owner, index, id
	local num = 0
	local res = sql:queryFetch( SQL_Q2 , sql:getPrefix() )
	for k, v in pairs( res ) do
		x,y,z = v.x, v.y, v.z
		owner = v.Owner
		scale = v.content
		index = v.PlantKey
		id = v.ID
		plant = v.PlantName
		if self.m_PlantIndex[ plant ] then
			self.m_PlantIndex[ plant ]:createNew( owner, index, x,y,z, scale)
		end
		num = num + 1
	end
	self.m_SQLTable = res
	self.m_SQLROWS = num
end

function ItemGrowable:isPlantInSQL( plant )
	local index
	for k, v in pairs( self.m_SQLTable ) do
		index = v.PlantKey
		if index == plant.m_UniqueIndex then
			return true
		end
	end
	return false
end