-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUDSpeedo.lua
-- *  PURPOSE:     HUD speedometer class
-- *
-- ****************************************************************************
HUDSpeedo = inherit(Singleton)

function HUDSpeedo:constructor()
	self.m_Size = 256
	--self.m_FuelSize = 96
	self.m_Draw = bind(self.draw, self)

	-- Add event handlers
	addEventHandler("onClientPlayerVehicleEnter", localPlayer, function(vehicle, seat)
		if seat == 0 then
			--if vehicle.m_Fuel == nil then vehicle.m_Fuel = 100 end
			self:show()
		end
	end)

	addEventHandler("onClientPlayerVehicleExit", localPlayer, function(vehicle, seat)
		if seat == 0 then
			self:hide()
		end
	end)

end

function HUDSpeedo:show()
	addEventHandler("onClientRender", root, self.m_Draw)
end

function HUDSpeedo:hide()
	removeEventHandler("onClientRender", root, self.m_Draw)
end

function HUDSpeedo:draw()
	if not isPedInVehicle(localPlayer) then
		self:hide()
		return
	end
	
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle:getFuel() then return end
	local vx, vy, vz = getElementVelocity(vehicle)
	local speed = (vx^2 + vy^2 + vz^2) ^ 0.5 * 161
	local drawX, drawY = screenWidth - self.m_Size, screenHeight - self.m_Size
	
	--dxSetBlendMode("add")
	-- draw the main speedo
	dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main.png")
	dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/main_needle.png", speed * 270/240)
	
	-- draw the gear level
	--dxDrawText(getVehicleCurrentGear(vehicle), drawX+158, drawY+108, 20, 20, tocolor(255, 255, 255), 2.5, "default")
	
	-- draw the engine icon
	if getVehicleEngineState(vehicle) then
		dxDrawImage(drawX, drawY, self.m_Size, self.m_Size, "files/images/Speedo/engine.png")
	end
	
	-- draw the fuel-o-meter
	--dxDrawImage(drawX-86, drawY+136, self.m_FuelSize, self.m_FuelSize, "files/images/Speedo/fuel.png")
	--dxDrawImage(drawX-86, drawY+136, self.m_FuelSize, self.m_FuelSize, "files/images/Speedo/fuel_needle.png", vehicle:getFuel() * 180/100)
	--dxSetBlendMode("blend")
end