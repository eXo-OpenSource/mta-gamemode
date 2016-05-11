-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class
-- *
-- ****************************************************************************
PlantWeed = inherit(ItemGrowable)

function PlantWeed:constructor()
	PlantWeed.m_Map = {	}
end

function PlantWeed:destructor()

end

function PlantWeed:use( player )
	local x,y,z = getElementPosition( player )
	self.m_Obj = createObject( WEED_OBJECT, x,y,z - 0.5)
	PlantWeed.m_Map = 0
end

function PlantWeed:grow()
	local iScale = getObjectScale(	self.m_Obj )
	if iScale <= 1 then 
		iScale = iScale + self.m_Growth
	end
	if iScale >= 1 then 
		iScale = 1
	end
	setObjectScale( iScale )
end