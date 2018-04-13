-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
FuelTankGUI = inherit(GUIForm3D)
inherit(Singleton, FuelTankGUI)
addRemoteEvents{"showFuelTankGUI", "closeFuelTankGUI", "updateFuelTankGUI"}

function FuelTankGUI:constructor(element, fuel, fuelTankSize)
	addEventHandler("onElementDestroy", element, function () delete(self) end, false)

	self.m_Fuel = fuel or 0
	self.m_FuelTankSize = fuelTankSize or 0
	self.m_FuelMultiplicator = self.m_FuelTankSize / 100

	local pos = element:getPosition()
	pos.z = pos.z + 1.5

	GUIForm3D.constructor(self, pos, element:getRotation(), Vector2(1, 0.34), Vector2(200, 70), 30, true)
end

function FuelTankGUI:onStreamIn(surface)
	local window = GUIWindow:new(0, 0, 200, 70, "Tankwagen", true, false, surface)
	self.m_ProgressBar = GUIProgressBar:new(5, 35, 190, 30, window):setProgress(self.m_Fuel)
	self.m_Label = GUILabel:new(5, 35, 190, 30, self.m_Fuel * self.m_FuelMultiplicator .. " / " .. self.m_FuelTankSize .. " Liter", window):setAlign("center", "center"):setColor(Color.Black)
end

function FuelTankGUI:updateFuel(fuel)
	self.m_Fuel = fuel
	self.m_ProgressBar:setProgress(self.m_Fuel)
	self.m_Label:setText(math.floor(self.m_Fuel * self.m_FuelMultiplicator) .. " / " .. self.m_FuelTankSize .. " Liter")
end

addEventHandler("showFuelTankGUI", root,
	function(...)
		FuelTankGUI:new(...)
	end
)

addEventHandler("closeFuelTankGUI", root,
	function()
		if FuelTankGUI:isInstantiated() then
			delete(FuelTankGUI:getSingleton())
		end
	end
)

addEventHandler("updateFuelTankGUI", root,
	function(fuel)
		if FuelTankGUI:isInstantiated() then
			FuelTankGUI:getSingleton():updateFuel(fuel)
		end
	end
)
