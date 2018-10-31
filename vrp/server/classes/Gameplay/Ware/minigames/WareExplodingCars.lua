-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareExplodingCars.lua
-- *  PURPOSE:     WareExplodingCars class
-- *
-- ****************************************************************************
WareExplodingCars = inherit(Object)
WareExplodingCars.modeDesc = "Bleib am Leben in der Apokalypse!"
WareExplodingCars.time = 2.5
WareExplodingCars.possibleVehicles = 
{
	581, 448, 589, 419, 587, 533, 526, 516, 469, 574, 470, 503, 571
}

function WareExplodingCars:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	self.m_Vehicles = {}
	for key, p in ipairs(self.m_Super.m_Players) do
		p:setData("ware:dead", 0)
	end
	self.m_SpawnTimerBind = bind(self.spawnExplodingCars, self) 
	self.m_SpawnTimer = setTimer(self.m_SpawnTimerBind, 1000, 0)
end

function WareExplodingCars:spawnExplodingCars()
	local x,y,z,width,height = unpack(self.m_Super.m_Arena)
	local rx, ry, rz  = (x+5)+ math.random(0,width-5), (y+5)+ math.random(0,height-5), z+1
	local car = createVehicle(WareExplodingCars.possibleVehicles[math.random(1, #WareExplodingCars.possibleVehicles)], rx, ry, rz+5)
	car:setHealth(0)
	car:setTurnVelocity(0, 0.1, 2)
	setElementDimension(car, self.m_Super.m_Dimension)
	self.m_Vehicles[car] = true	
	for car, b in pairs(self.m_Vehicles) do 
		car:blow()
	end
end

function WareExplodingCars:onDeath( player, killer, weapon  )
	local isWareDead = player:getData("ware:dead")
	if isWareDead == 0 then
		player:setData("ware:dead", 1)
	end
end

function WareExplodingCars:destructor()
	local deadCount = 0
	if self.m_SpawnTimer and isTimer(self.m_SpawnTimer) then 
		killTimer(self.m_SpawnTimer)
	end
	for car, b in pairs(self.m_Vehicles) do 
		car:destroy()
	end
	for key, p in ipairs(self.m_Super.m_Players) do
		if p:getData("ware:dead") == 0 then
			self.m_Super:addPlayerToWinners(p)
		else
			deadCount = deadCount + 1
		end
	end
end
