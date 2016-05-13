-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class
-- *
-- ****************************************************************************
PlantWeed = inherit(ItemGrowable)
addEvent("PlantWeed:getClientCheck", true)
function PlantWeed:constructor()
	PlantWeed.m_Map = {	}
	self.m_BindRemoteFunc = bind( PlantWeed.getClientCheck, self )
	addEventHandler("PlantWeed:getClientCheck",root, self.m_BindRemoteFunc)
end

function PlantWeed:destructor()
end

function PlantWeed:use( player )
	PlantWeed.m_Map = 0
	player:triggerEvent( "PlantWeed:sendClientCheck" , WEED_OBJECT )
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

function PlantWeed:getClientCheck( bool, z_pos )
	if bool then
		local x,y,z = getElementPosition( source )
		self.m_Obj = createObject( WEED_OBJECT, x,y,z_pos)
	else outputChatBox("Du bist nicht auf dem richtigen Untergrund!", source)
	end
end