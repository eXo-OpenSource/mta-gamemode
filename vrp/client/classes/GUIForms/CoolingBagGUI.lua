-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
CoolingBagGUI = inherit(GUIForm)
inherit(Singleton, CoolingBagGUI)

addRemoteEvents{"showCoolingBag"}

function CoolingBagGUI:constructor(bagName, value)
	GUIForm.constructor(self, screenWidth/2-150, screenHeight/2-200, 300, 400)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, bagName, true, true, self)

	self.m_Size = GUILabel:new(self.m_Width*0.02, 0, 50, 30, ("%s/%s"):format(value and #value or 0, FISHING_BAGS[bagName].max), self.m_Window)

	self.m_GridList = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.96, self.m_Height*0.88, self.m_Window)
	self.m_GridList:addColumn(_"Fisch", 0.6)
	self.m_GridList:addColumn(_"Größe [cm]", 0.4)

	if value then
		for _, v in pairs(value) do
			self.m_GridList:addItem(v[1], v[2])
		end
	end
end

addEventHandler("showCoolingBag", root,
	function(...)
		if not CoolingBagGUI:isInstantiated() then
			CoolingBagGUI:new(...)
		end
	end
)
