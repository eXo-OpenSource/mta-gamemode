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
	self.m_Elements = {
		["player"] = "Spieler",
		["ped"] = "Peds",
		["vehicle"] = "Fahrzeuge",
		["object"] = "Objekte",
		["pickup"] = "Pickups",
		["marker"] = "Marker",
		["colshape"] = "Colshape",
		["texture"] = "Texturen",
		["shader"] = "Shader",

	}

	GUIForm.constructor(self, screenWidth-30-screenWidth*0.3, screenHeight*0.3, screenWidth*0.3, screenHeight*0.4)
	self.m_Fields = {}
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	local dxStats = self.m_TabPanel:addTab(_"DxStats")
	self:addField(dxStats, "VideoCardName", function() return tostring(dxGetStatus().VideoCardName) end)
	self:addField(dxStats, "VideoCardRAM", function() return ("%sMB"):format(dxGetStatus().VideoCardRAM) end)
	self:addField(dxStats, "UsedVideoMemory", function() return ("%sMB"):format(dxGetStatus().VideoCardRAM - dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField(dxStats, "FreeVideoMemory", function() return ("%sMB"):format(dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField(dxStats, "VideoMemoryUsedByRenderTargets", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByRenderTargets) end)
	self:addField(dxStats, "VideoMemoryUsedByTextures", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByTextures) end)
	self:addField(dxStats, "VideoMemoryUsedByFonts", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByFonts) end)
	self:addField(dxStats, "VideoCardNumRenderTargets", function() return tostring(dxGetStatus().VideoCardNumRenderTargets) end)

	local elements = self.m_TabPanel:addTab(_"Elemente")
	for type, name in pairs(self.m_Elements) do
		self:addField(elements, name, function() return ("%d/%d"):format(#getElementsByType(type, root, true), #getElementsByType(type)) end)
	end

	local cache = self.m_TabPanel:addTab(_"Cache")
	self:addField(cache, "CacheTextureReplace", function() return tostring(table.size(TextureReplace.Cache)) end)
	cache.m_Gridlist = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.16, self.m_Width*0.96, self.m_Height*0.73, cache)
	cache.m_Gridlist:addColumn("TexturePath", 0.65)
	cache.m_Gridlist:addColumn("MemUsage", 0.20)
	cache.m_Gridlist:addColumn("Usage", 0.15)
	self.m_TabCache = cache

	self.m_RefreshTimer = false
	self:refresh()
	self:onShow()
end
function PerformanceStatsGUI:refresh()
	for parentId, parent in pairs(self.m_Fields) do
		for k, v in ipairs(parent) do
			v.label:setText(v.func())
		end
	end

	if self.m_TabCache.m_Gridlist then
		self.m_TabCache.m_Gridlist:clear()
		for hash, data in pairs(TextureReplace.Cache) do
			self.m_TabCache.m_Gridlist:addItem(data.path:sub(#data.path - 35, #data.path), ("%d MB"):format(data.memusage), data.counter)
		end
	end
end
function PerformanceStatsGUI:addField(parent, name, getFunc)
	if not self.m_Fields[parent] then self.m_Fields[parent] = {} end
	self.m_Fields[parent][#self.m_Fields[parent] + 1] = {func = getFunc}
	GUILabel:new(self.m_Width*0.02, #self.m_Fields[parent]*self.m_Height*0.08, self.m_Width*0.7, self.m_Height*0.08, name..":", parent)
	self.m_Fields[parent][#self.m_Fields[parent]].label = GUILabel:new(self.m_Width*0.50, #self.m_Fields[parent]*self.m_Height*0.08, self.m_Width*0.47, self.m_Height*0.08, "", parent):setAlignX("right")
end
function PerformanceStatsGUI:onShow()
	self.m_RefreshTimer = setTimer(bind(self.refresh, self), 1000, 0)
end
function PerformanceStatsGUI:onHide()
	if isTimer(self.m_RefreshTimer) then killTimer(self.m_RefreshTimer) end
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
