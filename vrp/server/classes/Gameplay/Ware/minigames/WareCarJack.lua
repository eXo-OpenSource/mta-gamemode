-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareCarJack.lua
-- *  PURPOSE:     WareCarJack class
-- *
-- ****************************************************************************
WareCarJack = inherit(Object)
WareCarJack.modeDesc = "Schnapp dir ein Fahrzeug!"
WareCarJack.timeScale = 1
local allowedCars = 
{
 468,
 522,
 510
}

local allowedWeapons = 
{
	24,25,31,34,35,38,18,16
}

function WareCarJack:constructor( super )
	self.m_Super = super
	self.m_Super.m_Successors = {}
	self:createCar()
end

function WareCarJack:createCar()
	if self.m_Super.m_Arena then 
		local x,y,z,width,height = unpack(self.m_Super.m_Arena)
		if x and y and z and width and height then
			local randCar = allowedCars[math.random(1, #allowedCars)]
			local carAmount = math.floor(#self.m_Super.m_Players / 3)
			self.m_Cars = {}
			if carAmount == 0 then carAmount = 1 end
			for i = 1, carAmount do 
				self.m_Cars[i] = createVehicle(randCar,x+5+math.random(0,width-10), y+5+math.random(0,height-10), z+3)
				setElementDimension(self.m_Cars[i], self.m_Super.m_Dimension)
				self.m_Cars[i]:setEngineState(true)
			end
			local x,y,z,width,height = unpack(self.m_Super.m_Arena)
		end
	end
end

function WareCarJack:destructor()
	local pVeh
	for key, p in ipairs(self.m_Super.m_Players) do 
		pVeh = getPedOccupiedVehicle(p)
		if pVeh then 
			if getVehicleOccupant(pVeh,0) == p then 
				self.m_Super:addPlayerToWinners( p) 
			end
		end
	end
	for i = 1, #self.m_Cars do 
		destroyElement(self.m_Cars[i])
	end
end