-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Inventory/Drugs/PlantWeed.lua
-- *  PURPOSE:     Weed-Seed class
-- *
-- ****************************************************************************
PlantWeed = inherit(ItemGrowable)
local growRate = 0.1
local rem = table.remove
local growInterval = 10000
addEvent("PlantWeed:getClientCheck", true)
function PlantWeed:constructor()
	self.m_Map = {	}
	self.m_ActivePlant = {	}
	self.m_BindRemoteFunc = bind( PlantWeed.getClientCheck, self )
	self.m_BindGrowFunc = bind( PlantWeed.grow, self )
	self.m_GrowTimer = setTimer( self.m_BindGrowFunc, growInterval,0  )
	addEventHandler("PlantWeed:getClientCheck",root, self.m_BindRemoteFunc)
end

function PlantWeed:destructor()
end

function PlantWeed:use( player )
	player:triggerEvent( "PlantWeed:sendClientCheck" , WEED_OBJECT )
end

function PlantWeed:grow()
	local iScale,obj, data
	self:syncGrow( client )
	for i = 1,#self.m_ActivePlant do 
		obj = self.m_ActivePlant[i]
		data = obj:getData("Plant:Hydration")
		if data then 
			if data >= 1 then
				iScale = getObjectScale( obj )
				iScale = iScale + ( iScale * growRate )
				if iScale >= 1 then 
					iScale = 1
					rem( self.m_ActivePlant, i )
				end
				setObjectScale( obj, iScale)
			end
		end
	end
end

function PlantWeed:getClientCheck( bool, z_pos )
	if bool then
		local x,y,z = getElementPosition( source )
		self.m_Map[#self.m_Map+1] = createObject( WEED_OBJECT, x,y,z_pos)
		self.m_ActivePlant[#self.m_ActivePlant+1] = self.m_Map[#self.m_Map]
		setObjectScale( self.m_Map[#self.m_Map], 0.1)
		setElementCollisionsEnabled( self.m_Map[#self.m_Map], false)
		ItemGrowable.m_WaterPlants[#ItemGrowable.m_WaterPlants+1] = self.m_Map[#self.m_Map]
	else outputChatBox("Du bist nicht auf dem richtigen Untergrund!", source)
	end
end

function PlantWeed:syncGrow( client )
	if not client then 
		local bTab = getElementsByType( "player" )
		local player
		for i = 1, #bTab do 
			player = bTab[i] 
			player:triggerEvent("PlantWeed:syncPlantMap",self.m_ActivePlant )
		end
	else 
		client:triggerEvent("PlantWeed:syncPlantMap",self.m_ActivePlant )
	end
end