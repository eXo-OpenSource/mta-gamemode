-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Actions/StateEvidenceTruck.lua
-- *  PURPOSE:     State Evidence Truck Class
-- *
-- ****************************************************************************

StateEvidenceTruck = inherit(Singleton)
StateEvidenceTruck.LoadTime = 30*1000 -- in ms
StateEvidenceTruck.Time = 10*60*1000 -- in ms
StateEvidenceTruck.spawnPos = Vector3(1591.18, -1685.65, 6.02)
StateEvidenceTruck.spawnRot = Vector3(0, 0, 0)
StateEvidenceTruck.Destination = Vector3(119.08, 1902.07, 18.3)

function StateEvidenceTruck:constructor(driver, money)
	self.m_Truck = TemporaryVehicle.create(428, StateEvidenceTruck.spawnPos, StateEvidenceTruck.spawnRot)
	self.m_Truck:setData("WeedTruck", true, true)
    self.m_Truck:setColor(0, 50, 0)
	self.m_Truck:setFrozen(true)
	self.m_Truck:setVariant(255, 255)
	self.m_Truck:setMaxHealth(1500, true)
	self.m_Truck:setBulletArmorLevel(2)
	self.m_Truck:setRepairAllowed(false)
	self.m_Truck:toggleRespawn(false)
	self.m_Truck:setAlwaysDamageable(true)
	self.m_Truck.m_DisableToggleHandbrake = true

	self.m_StartTime = getTickCount()
	self.m_StartPlayer = driver
end
