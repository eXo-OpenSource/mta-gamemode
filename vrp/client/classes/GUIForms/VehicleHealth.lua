-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/VehicleHealth.lua
-- *  PURPOSE:     VehicleHealth Progress Bar class
-- *
-- ****************************************************************************
VehicleHealth = inherit(GUIForm)
inherit(Singleton, VehicleHealth)

function VehicleHealth:constructor()
	GUIForm.constructor(self, screenWidth/2-187/2, 150, 187, 30, false)
	self.m_Progress = GUIProgressBar:new(0,0,self.m_Width, self.m_Height,self)
	self.m_Progress:setForegroundColor(tocolor(50,200,255))
	self.m_Progress:setBackgroundColor(tocolor(180,240,255))
	self.m_VehicleHealthLabel = GUILabel:new(0, 0, self.m_Width, self.m_Height, tostring(self.m_Health), self):setAlignX("center"):setAlignY("center"):setFont(VRPFont(self.m_Height*0.75)):setColor(Color.Black)
end

function VehicleHealth:startVehicleHealth(max)
	self.m_Max = max or 700
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
	local i = 1000-self.m_Max
	self.m_Health = math.floor((localPlayer.vehicle.health-i)/self.m_Max*100)
	self.m_VehicleHealthLabel:setText("Zustand: "..self.m_Health.."%")
	self.m_Progress:setProgress(math.max(0, self.m_Health))
end

function VehicleHealth:stopVehicleHealth()
	if self.m_Timer and isTimer(self.m_Timer) then
		killTimer(self.m_Timer)
		self.m_Timer = nil
		delete(self)
	end
end

addEvent("VehicleHealth", true)
addEventHandler("VehicleHealth", root,
	function(max)
		VehicleHealth:getSingleton():startVehicleHealth(max)
	end
)

addEvent("VehicleHealthStop", true)
addEventHandler("VehicleHealthStop", root,
	function(seconds)
		if VehicleHealth:isInstantiated() then
			VehicleHealth:getSingleton():stopVehicleHealth()
		end
	end
)
