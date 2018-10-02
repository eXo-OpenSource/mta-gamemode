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
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Debug Tools (F10 to close)", true, false, self)
	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel({"Dx Stats", "Elements", "Cache", "Perf. Stats", "Network"}) -- fügt Tabs hinzu und gibt ihnen eine füllende Breite
	self.m_Fields = {}
	self.m_TabDxStats = self.m_Tabs[1]
	self:addField(self.m_TabDxStats, "VideoCardName", function() return tostring(dxGetStatus().VideoCardName) end)
	self:addField(self.m_TabDxStats, "VideoCardRAM", function() return ("%sMB"):format(dxGetStatus().VideoCardRAM) end)
	self:addField(self.m_TabDxStats, "UsedVideoMemory", function() return ("%sMB"):format(dxGetStatus().VideoCardRAM - dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField(self.m_TabDxStats, "FreeVideoMemory", function() return ("%sMB"):format(dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField(self.m_TabDxStats, "VideoMemoryUsedByRenderTargets", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByRenderTargets) end)
	self:addField(self.m_TabDxStats, "VideoMemoryUsedByTextures", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByTextures) end)
	self:addField(self.m_TabDxStats, "VideoMemoryUsedByFonts", function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByFonts) end)
	self:addField(self.m_TabDxStats, "VideoCardNumRenderTargets", function() return tostring(dxGetStatus().VideoCardNumRenderTargets) end)

	self.m_TabElements = self.m_Tabs[2]
	for type, name in pairs(self.m_Elements) do
		self:addField(self.m_TabElements, name, function() return ("%d/%d"):format(#getElementsByType(type, root, true), #getElementsByType(type)) end)
	end

	self.m_TabCache = self.m_Tabs[3]
	self:addField(self.m_TabCache, "CacheTextureReplace", function() return tostring(table.size(TextureCache.Map)) end)
	self.m_TabCache.m_Gridlist = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.73, self.m_TabCache)
	self.m_TabCache.m_Gridlist:addColumn("Name", 0.85)
	self.m_TabCache.m_Gridlist:addColumn("Count", 0.15)
	self.m_TabCache.m_Gridlist:setItemHeight(math.min(self.m_Height*0.08, 20))
	self.m_TabCache.m_Gridlist:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))

	self.m_TabPerformance = self.m_Tabs[4]
	GUILabel:new(self.m_Width*0.02, 0, self.m_Width*0.7, self.m_Height*0.08, "PerformanceDump    filter:", self.m_TabPerformance)
	self.m_PerformanceEdit = GUIEdit:new(self.m_Width*0.5, self.m_Width*0.01, self.m_Width*0.48, self.m_Height*0.08-self.m_Width*0.01, self.m_TabPerformance)
	self.m_TabPerformance.m_Gridlist = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.73, self.m_TabPerformance)
	self.m_TabPerformance.m_Gridlist:addColumn("%", 0.1)
	self.m_TabPerformance.m_Gridlist:addColumn("Source", 0.75)
	self.m_TabPerformance.m_Gridlist:addColumn("Timing", 0.15)
	self.m_TabPerformance.m_Gridlist:setItemHeight(math.min(self.m_Height*0.08, 20))
	self.m_TabPerformance.m_Gridlist:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))

	self.m_TabNetwork = self.m_Tabs[5]
	for ___, type in pairs({"bytesReceived", "bytesSent", "packetsReceived", "packetsSent", "packetlossTotal", "packetlossLastSecond", "messagesInSendBuffer", "messagesInResendBuffer"}) do
		self:addField(self.m_TabNetwork, type, function() return getNetworkStats()[type] end)
	end
	self:addField(self.m_TabNetwork, "Ping", function() return getPlayerPing(localPlayer) end)
	self:addField(self.m_TabNetwork, "Monitor-Warnpunkte", function() return NetworkMonitor:getSingleton():getWarnCount() end)
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

	if isCursorShowing() then return end
	if self.m_TabCache.m_Gridlist then
		self.m_TabCache.m_Gridlist:clear()
		for path, data in pairs(TextureCache.Map) do
			local item = self.m_TabCache.m_Gridlist:addItem(path:gsub("files/images/Textures", ""), data:getUsage())
			item:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))
			item.onLeftDoubleClick = function()
				local blips = {}
				local text = _"Folgende Elemente benutzen diese Textur:"
				for i, instance in pairs(data.m_Instances) do
					text = ("%s\n#%d %s"):format(text, i, inspect(instance.m_Element))
					local blip = Blip:new("Marker.png", instance.m_Element.position.x, instance.m_Element.position.y, 400, BLIP_COLOR_CONSTANTS.Red)
					blip:setZ(instance.m_Element.position.z)
					blip:setDisplayText(inspect(instance.m_Element))
					table.insert(blips, blip)
				end
				ShortMessage:new(text, _("Textur Info (%s)", path:gsub("files/images/Textures", "")), Color.Red, -1, function()
					for i, v in pairs(blips) do 
						v:delete()
					end
				end)
			end
		end
	end
	if self.m_TabPerformance.m_Gridlist then
		self.m_TabPerformance.m_Gridlist:clear()
		local __, f = getPerformanceStats("Lua timing", "d", self.m_PerformanceEdit:getText())
		for i, data in ipairs(f) do
			if data[2] ~= "-" then
				local item = self.m_TabPerformance.m_Gridlist:addItem(data[2], data[1], data[3])
				item:setFont(VRPFont(math.min(self.m_Height*0.08, 20)))
				item.onLeftDoubleClick = function()
					setClipboard(data[1])
					ShortMessage:new(data[1].." in die Zwischenablage gelegt!")
				end
			end
		end
	end
end

function PerformanceStatsGUI:addField(parent, name, getFunc)
	if not self.m_Fields[parent] then self.m_Fields[parent] = {} end
	self.m_Fields[parent][#self.m_Fields[parent] + 1] = {func = getFunc}
	GUILabel:new(self.m_Width*0.02, (#self.m_Fields[parent]-1)*self.m_Height*0.08, self.m_Width*0.7, self.m_Height*0.08, name..":", parent)
	self.m_Fields[parent][#self.m_Fields[parent]].label = GUILabel:new(self.m_Width*0.50, (#self.m_Fields[parent]-1)*self.m_Height*0.08, self.m_Width*0.47, self.m_Height*0.08, "", parent):setAlignX("right")
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
				PerformanceStatsGUI:getSingleton().m_TabElements:setEnabled(localPlayer:getRank() >= ADMIN_RANK_PERMISSION["showDebugElementView"])
				PerformanceStatsGUI:getSingleton().m_TabPerformance:setEnabled(localPlayer:getRank() >= 1)
			end
		)
	end
)


--[[
PerformanceStatsGUI = inherit(GUIForm)
inherit(Singleton, PerformanceStatsGUI)

function PerformanceStatsGUI:constructor()
	
	local screenWidth, screenHeight = 1920, 1080
	
	self.m_Width = screenWidth*0.3	-- width of the window
	self.m_Height = 50 + screenWidth*0.2	-- height of the window
	
	local col = math.floor(self.m_Height/15)
	local m = math.floor(col/3)
	
	local dxStats = dxGetStatus()
	local memTotal = dxStats.VideoCardRAM
	local memFree = dxStats.VideoMemoryFreeForMTA
	local memForFonts = dxStats.VideoMemoryUsedByFonts
	local memForTextures = dxStats.VideoMemoryUsedByTextures
	local memForRTs = dxStats.VideoMemoryUsedByRenderTargets 

	GUIForm.constructor(self, screenWidth-self.m_Width-m, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Performance und Debug", true, false, self)
	self.m_Tabs = self.m_Window:addTabPanel({"Ressourcen", "Elemente", "Textur-Cache"})

	GUILabel:new(m, m, self.m_Width-m*2, col, "Ressourcenverteilung", self.m_Tabs[1])
	local barSize = self.m_Width-m*2
	local barX = m
	DxRectangle:new(barX, m*2 + col, barSize, col, Color.PrimaryNoClick, self.m_Tabs[1])
	--actual values of bars
	DxRectangle:new(barX, m*2 + col, barSize*(memForTextures/memTotal), col, Color.Accent, self.m_Tabs[1])
	barX = barX + barSize*(memForTextures/memTotal)
	DxRectangle:new(barX, m*2 + col, barSize*(memForFonts/memTotal), col, Color.Green, self.m_Tabs[1])
	barX = barX + barSize*(memForFonts/memTotal)
	DxRectangle:new(barX, m*2 + col, barSize*(memForRTs/memTotal), col, Color.Orange, self.m_Tabs[1])
	barX = barX + barSize*(memForRTs/memTotal)
	--legend
	DxRectangle:new(m, m*3 + col*2, col, col, Color.Accent, self.m_Tabs[1])
	GUILabel:new(m*2 + col, m*3 + col*2, self.m_Width-m*2, col, "Texturen", self.m_Tabs[1])
	DxRectangle:new(m*6+col*5, m*3 + col*2, col, col, Color.Green, self.m_Tabs[1])
	GUILabel:new(m*7 + col*6, m*3 + col*2, self.m_Width-m*2, col, "Fonts", self.m_Tabs[1])
	DxRectangle:new(m*10+col*9, m*3 + col*2, col, col, Color.Orange, self.m_Tabs[1])
	GUILabel:new(m*11 + col*10, m*3 + col*2, self.m_Width-m*2, col, "RenderTargets", self.m_Tabs[1])
	
	GUIRectangle:new(m, m*4 + col*3, self.m_Width-m*2, 2, Color.Accent, self.m_Tabs[1])
	GUILabel:new(m, m*4 + col*3, self.m_Width-m*2, col, ("%s / %sMB belegt"):format(memTotal-memFree, memTotal), self.m_Tabs[1])
	GUILabel:new(m, m*4 + col*3, self.m_Width-m*2, col, dxStats.VideoCardName, self.m_Tabs[1]):setAlignX("right")
end

function PerformanceStatsGUI:destructor()
	GUIForm.destructor(self)
end

]]