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
	self.m_GridList:addColumn(_"Fisch", 0.43)
	self.m_GridList:addColumn(_"Größe (cm)", 0.3)
	self.m_GridList:addColumn(_"Qualität", 0.17)

	--self.m_GridList.m_Columns[3]:setFont(FontAwesome(20))--:setFontSize(1)

	if value then
		for _, v in pairs(value) do
			local item = self.m_GridList:addItem(v.fishName, v.size, (FontAwesomeSymbols.Star):rep(v.quality + 1))
			item:setColumnFont(3, FontAwesome(20), 1):setColumnColor(3, v.quality == 0 and Color.Brown or (v.quality == 1 and Color.LightGrey or Color.Yellow))
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
