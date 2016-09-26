-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/PerformanceStatsGUI.lua
-- *  PURPOSE:     Performance statistics GUI class
-- *
-- ****************************************************************************
PerformanceStatsGUI = inherit(GUIForm)
inherit(Singleton, PerformanceStatsGUI)

function PerformanceStatsGUI:constructor()
	GUIForm.constructor(self, screenWidth-5-screenWidth*0.3, screenHeight*0.3, screenWidth*0.3, screenHeight*0.3)

	self.m_Fields = {}

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Performance Stats", true, false, self)

	self:addField("FreeVideoMemory", function() return ("%sMB"):format(dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField("VideoMemoryUsedByRenderTargets", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByRenderTargets) end)
	self:addField("VideoMemoryUsedByTextures", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByTextures) end)
	self:addField("VideoMemoryUsedByFonts", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByFonts) end)

	self.m_RefreshTimer = false
	self:refresh()

	self:onShow()
end

function PerformanceStatsGUI:refresh()
	for k, v in ipairs(self.m_Fields) do
		v.label:setText(v.func())
	end
end

function PerformanceStatsGUI:addField(name, getFunc)
	self.m_Fields[#self.m_Fields + 1] = {func = getFunc}

	GUILabel:new(self.m_Width*0.02, #self.m_Fields*self.m_Height*0.12, self.m_Width*0.6, self.m_Height*0.11, name..":", self.m_Window)
	self.m_Fields[#self.m_Fields].label = GUILabel:new(self.m_Width*0.65, #self.m_Fields*self.m_Height*0.12, self.m_Width*0.32, self.m_Height*0.11, "", self.m_Window):setAlignX("right")
end

function PerformanceStatsGUI:onShow()
	self.m_RefreshTimer = setTimer(bind(self.refresh, self), 1000, 0)
end

function PerformanceStatsGUI:onHide()
	killTimer(self.m_RefreshTimer)
	self.m_RefreshTimer = false
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		PerformanceStatsGUI:new():setVisible(false)
		bindKey(core:get("KeyBindings", "KeyTogglePerformanceStats", "F10"), "down",
			function()
				PerformanceStatsGUI:getSingleton():setVisible(not PerformanceStatsGUI:getSingleton():isVisible())
			end
		)
	end
)
