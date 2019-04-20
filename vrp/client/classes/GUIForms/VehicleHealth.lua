-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleHealth.lua
-- *  PURPOSE:     VehicleHealth Progress Bar class
-- *
-- ****************************************************************************
VehicleHealth = inherit(GUIForm)
inherit(Singleton, VehicleHealth)

addRemoteEvents{"VehicleHealth", "VehicleHealthStop"}

function VehicleHealth:constructor()
	GUIForm.constructor(self, screenWidth/2-187/2, 150, 187, 30, false)
	self.m_Progress = GUIProgressBar:new(0,0,self.m_Width, self.m_Height,self)
	self.m_Progress:setForegroundColor(tocolor(50,200,255))
	self.m_Progress:setBackgroundColor(tocolor(180,240,255))
	self.m_VehicleHealthLabel = GUILabel:new(0, 0, self.m_Width, self.m_Height, tostring(self.m_Health), self):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.75)):setColor(Color.Black)
end

function VehicleHealth:startVehicleHealth()
	self.m_Max = localPlayer.vehicle:getMaxHealth()
	self.m_Min = VEHICLE_TOTAL_LOSS_HEALTH
	self:refresh()
	self.m_Timer = setTimer(
		function()
			self:refresh()
		end,
		250,
		0
	)
end

function VehicleHealth:refresh()
	if not localPlayer:isInVehicle() then self:stopVehicleHealth() return end

	self.m_Health = localPlayer.vehicle:getHealthInPercent()
	self.m_VehicleHealthLabel:setText("Zustand: "..self.m_Health.."%")
	self.m_Progress:setProgress(self.m_Health)
end

function VehicleHealth:stopVehicleHealth()
	if self.m_Timer and isTimer(self.m_Timer) then
		killTimer(self.m_Timer)
		self.m_Timer = nil
		delete(self)
	end
end

addEventHandler("VehicleHealth", root,
	function()
		VehicleHealth:getSingleton():startVehicleHealth()
	end
)

addEventHandler("VehicleHealthStop", root,
	function()
		if VehicleHealth:isInstantiated() then
			VehicleHealth:getSingleton():stopVehicleHealth()
		end
	end
)
