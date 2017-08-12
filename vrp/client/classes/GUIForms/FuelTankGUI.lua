-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
FuelTankGUI = inherit(GUIForm3D)
inherit(Singleton, FuelTankGUI)

function FuelTankGUI:constructor(element)
	addEventHandler("onElementDestroy", element, function () delete(self) end, false)

	local pos = element:getPosition()
	pos.z = pos.z + 1.5

	GUIForm3D.constructor(self, pos, element:getRotation(), Vector2(1, 0.34), Vector2(200, 70), 30, true)
end

function FuelTankGUI:onStreamIn(surface)
	local window = GUIWindow:new(0, 0, 200, 70, "Tankwagen", true, false, surface)
	GUIProgressBar:new(5, 35, 190, 30, window):setProgress(12)
	GUILabel:new(5, 35, 190, 30, "60 / 500 Liter", window):setAlign("center", "center")
end
