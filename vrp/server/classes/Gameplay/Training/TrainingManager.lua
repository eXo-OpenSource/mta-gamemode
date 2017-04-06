-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Deathmatch/TrainingManager.lua
-- *  PURPOSE:     Training Manager class
-- *
-- ****************************************************************************

TrainingManager = inherit(Object)

TrainingManager.Map = {}

--//1321.26, -1644.13, 13.55
function TrainingManager:constructor( x,y,z )
	self.m_Pickup = createPickup(x, y, z, 3, 1239,-1)
	TrainingManager.Map[#TrainingManager.Map+1] = self
	self.m_MapId = #TrainingManager.Map
	addEventHandler("onPlayerPickupHit",self.m_Pickup, bind(self.Event_onPickupHit, self))
end

function TrainingManager:Event_onPickupHit( player )
	local dimension = source:getDimension() == player:getDimension()
	if dimension then 
		player:triggerEvent("Training:onHitPickup", self.m_MapId)
	end
end

function TrainingManager:destructor()

end
