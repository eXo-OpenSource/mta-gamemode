-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareRamp.lua
-- *  PURPOSE:     WareRamp class
-- *
-- ****************************************************************************
WareRamp = inherit(Object)
WareRamp.modeDesc = "Springe durch den Ring!"
WareRamp.timeScale = 1.5

function WareRamp:constructor( super )
	self.m_Super = super
	self.m_Vehicles = {}
	local x,y,z,width,height = unpack(self.m_Super.m_Arena)
	if x and y and z and width and height then
		for key, p in ipairs(self.m_Super.m_Players) do
			self.m_Vehicles[p] = TemporaryVehicle.create(468,x+5+math.random(width*0.5),y+5+math.random(height*0.5),z+4, 0, 0, math.random(0,360))
			self.m_Vehicles[p]:setDimension(self.m_Super.m_Dimension)
			self.m_Vehicles[p]:setEngineState(true)
			nextframe(function() p:warpIntoVehicle(self.m_Vehicles[p]) end)
		end
	end
	self:createRamp()
end

function WareRamp:createRamp()
	self.m_Ramp = createObject(13641, 24.74, 17.54, 502.27, 0, 0, 320)
	self.m_Ramp:setDimension(self.m_Super.m_Dimension)
	self.m_Col = createColSphere(36.7, 8.2, 512.7, 7)
	self.m_Col:setDimension(self.m_Super.m_Dimension)
	addEventHandler("onColShapeHit", self.m_Col, function(hitElement, dim)
		if hitElement and isElement(hitElement) and hitElement:getType() == "player" and dim then
			if hitElement.vehicle and hitElement.vehicle:getModel() == 468 then
				setTimer(function(player)
					self.m_Super:addPlayerToWinners(player)
					player.vehicle:destroy()
				end, 1000, 1, hitElement)
			end
		end
	end)
end

function WareRamp:destructor()
	for index, veh in pairs(self.m_Vehicles) do
		if isElement(veh) then veh:destroy() end
	end
	if self.m_Ramp then self.m_Ramp:destroy() end
	if self.m_Col then self.m_Col:destroy() end
end
