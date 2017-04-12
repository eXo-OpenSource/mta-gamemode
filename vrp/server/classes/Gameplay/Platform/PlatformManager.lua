-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/PlatformManager.lua
-- *  PURPOSE:     Training Manager class
-- *
-- ****************************************************************************

PlatformManager = inherit(Object)

PlatformManager.Map = {}

--//1321.26, -1644.13, 13.55
function PlatformManager:constructor( x,y,z )
	self.m_Pickup = createPickup(x, y, z, 3, 1239,-1)
	PlatformManager.Map[#PlatformManager.Map+1] = self
	self.m_MapId = #PlatformManager.Map
	addEventHandler("onPlayerPickupHit",self.m_Pickup, bind(self.Event_onPickupHit, self))
end

function PlatformManager:Event_onPickupHit( player )
	local dimension = source:getDimension() == player:getDimension()
	if dimension then 
		player:triggerEvent("Training:onHitPickup", self.m_MapId)
	end
end

function PlatformManager:destructor()

end
