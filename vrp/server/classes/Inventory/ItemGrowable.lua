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