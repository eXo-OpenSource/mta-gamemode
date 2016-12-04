-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/DebugGUI.lua
-- *  PURPOSE:     Performance statistics GUI class
-- *
-- ****************************************************************************
DebugGUI = inherit(GUIForm)
inherit(Singleton, DebugGUI)

DebugGUI.Level = {
	[0] = {["Type"] = "Custom", ["Label"] = "[C]", ["Color"] = tocolor(0, 125, 255)},
	[1] = {["Type"] = "Error", ["Label"] = "[E]", ["Color"] = tocolor(255, 0, 0)},
	[2] = {["Type"] = "Warning", ["Label"] = "[W]", ["Color"] = tocolor(255, 165, 0)},
	[3] = {["Type"] = "Info", ["Label"] = "[I]", ["Color"] = tocolor(0, 255, 0)}
}

function DebugGUI:constructor()
	GUIForm.constructor(self, 500, screenHeight*0.3, 350, screenHeight*0.6, true, true)

	self.m_Fields = {}

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Debug-Console", true, true, self)

	self.m_TabPanel = GUITabPanel:new(0, 32, self.m_Width, self.m_Height-32, self.m_Window)
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)

	---------------------------------------------------------------------

	self.m_TabDebug = self.m_TabPanel:addTab(_"Debug")
	self.m_DebugCheckBoxes = {}
	self.m_DebugCheckBoxes["Server"] = GUICheckbox:new(self.m_Width*0.0+10, 5, self.m_Width*0.5, self.m_Height*0.03, "Server", self.m_TabDebug):setFontSize(1.5)
	self.m_DebugCheckBoxes["Client"] = GUICheckbox:new(self.m_Width*0.5+10, 5, self.m_Width*0.5, self.m_Height*0.03, "Client", self.m_TabDebug):setFontSize(1.5)
	self.m_DebugCheckBoxes[0] = GUICheckbox:new(self.m_Width*0.00+10, 5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[0]["Type"], self.m_TabDebug):setFontSize(1):setColor(DebugGUI.Level[0]["Color"])
	self.m_DebugCheckBoxes[1] = GUICheckbox:new(self.m_Width*0.25+10, 5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[1]["Type"], self.m_TabDebug):setFontSize(1):setColor(DebugGUI.Level[1]["Color"])
	self.m_DebugCheckBoxes[2] = GUICheckbox:new(self.m_Width*0.50+10, 5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[2]["Type"], self.m_TabDebug):setFontSize(1):setColor(DebugGUI.Level[2]["Color"])
	self.m_DebugCheckBoxes[3] = GUICheckbox:new(self.m_Width*0.75+10, 5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[3]["Type"], self.m_TabDebug):setFontSize(1):setColor(DebugGUI.Level[3]["Color"])
	self.m_DebugGrid = GUIGridList:new(0, self.m_Height*0.095, self.m_Width, self.m_Height*0.6, self.m_TabDebug)
	self.m_DebugGrid:setFont(VRPFont(20))
	self.m_DebugGrid:setItemHeight(20)
	self.m_DebugGrid:addColumn(_"S/C", 0.075)
	self.m_DebugGrid:addColumn(_"Typ", 0.075)
	self.m_DebugGrid:addColumn(_"Message", 0.85)
	self.m_DebugLabels = {}
	self.m_DebugLabels["Type"] = GUILabel:new(5, self.m_Height*0.71, self.m_Width, self.m_Height*0.045, "", self.m_TabDebug)
	self.m_DebugLabels["File"] = GUILabel:new(5, self.m_Height*0.755, self.m_Width, self.m_Height*0.035, "", self.m_TabDebug)
	self.m_DebugLabels["Msge"] = GUILabel:new(5, self.m_Height*0.79, self.m_Width, self.m_Height*0.035, "", self.m_TabDebug)

	self.m_DebugCheckBoxes["Server"]:setChecked(true)
	self.m_DebugCheckBoxes["Client"]:setChecked(true)
	self.m_DebugCheckBoxes[1]:setChecked(true)
	self.m_DebugCheckBoxes[2]:setChecked(true)

	for index, box in pairs(self.m_DebugCheckBoxes) do
		box.onChange = function() self:refreshDebugGrid() end
	end

	---------------------------------------------------------------------
	self.m_TabPerformance = self.m_TabPanel:addTab(_"Performance")

	self:addField("FreeVideoMemory", self.m_TabPerformance, function() return ("%sMB"):format(dxGetStatus().VideoMemoryFreeForMTA) end)
	self:addField("VideoMemoryUsedByRenderTargets", self.m_TabPerformance, function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByRenderTargets) end)
	self:addField("VideoMemoryUsedByTextures", self.m_TabPerformance, function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByTextures) end)
	self:addField("VideoMemoryUsedByFonts", self.m_TabPerformance, function() return ("%sMB"):format(dxGetStatus().VideoMemoryUsedByFonts) end)

	self.m_PerformanceRefreshTimer = false
	self:refresh()

	addEventHandler("onClientDebugMessage", root, bind(self.onClientDebug, self))
	self.m_DebugLogTable = {}

end

function DebugGUI:refresh()
	for k, v in ipairs(self.m_Fields) do
		v.label:setText(v.func())
	end
end

function DebugGUI:TabPanel_TabChanged(tabId)
	if isTimer(self.m_PerformanceRefreshTimer) then killTimer(self.m_PerformanceRefreshTimer) end
	self.m_PerformanceRefreshTimer = false
	if tabId == self.m_TabDebug.TabIndex then
		self:refreshDebugGrid()
	elseif tabId == self.m_TabPerformance.TabIndex then
		self.m_PerformanceRefreshTimer = setTimer(bind(self.refresh, self), 500, 0)
	end
end

local lastDebug = {}
lastDebug["Server"] = {["Id"] = 0, ["Message"] = "", ["File"] = ""}
lastDebug["Client"] = {["Id"] = 0, ["Message"] = "", ["File"] = ""}

function DebugGUI:onClientDebug(message, level, file, line)
	self:addDebug("Client", message, level, file, line)
end

function DebugGUI:onServerDebug(message, level, file, line)
	self:addDebug("Server", message, level, file, line)
end

function DebugGUI:addDebug(type, message, level, file, line)
	id = #self.m_DebugLogTable+1
	file = file..":"..line
	local last = lastDebug[type]
	if last.Message == message and last.File == file then
		self.m_DebugLogTable[last.Id].x =  self.m_DebugLogTable[last.Id].x + 1
	else
		self.m_DebugLogTable[id] = {["Type"] = type, ["Level"] = level, ["Message"] = message, ["File"] = file, ["x"] = 1}
		lastDebug[type]["Id"] = id
		lastDebug[type]["Message"] = message
		lastDebug[type]["File"] = file
	end
	self:refreshDebugGrid()
end

function DebugGUI:refreshDebugGrid()
	self.m_DebugGrid:clear()
	local table = table.reverse(self.m_DebugLogTable)
	for id, data in ipairs(table) do
		if self.m_DebugCheckBoxes[data.Level]:isChecked() and self.m_DebugCheckBoxes[data.Type]:isChecked() then
			self:addLine(id, data.Type, data.Level, data.Message, data.File, data.x)
		end
	end
end

function DebugGUI:addLine(id, type, level, message, file, x)
	local item, table
	message = x > 1 and x.."x "..message or message
	item = self.m_DebugGrid:addItem(string.sub(type, 1, 1), DebugGUI.Level[level].Label, message)
	item:setFont(VRPFont(20))
	item:setColumnColor(1, DebugGUI.Level[level].Color)
	item:setColumnColor(2, DebugGUI.Level[level].Color)
	item.Id = id
	item.onLeftClick = function(item)
		table = self.m_DebugLogTable[id]
		self.m_DebugLabels["Type"]:setText("Type: "..table.Type.." - "..DebugGUI.Level[table.Level].Type)
		self.m_DebugLabels["Type"]:setColor(DebugGUI.Level[table.Level].Color)
		self.m_DebugLabels["File"]:setText("File: "..table.File)
		self.m_DebugLabels["Msge"]:setText("Message: "..table.Message)

	end
end

function DebugGUI:addField(name, parent, getFunc)
	self.m_Fields[#self.m_Fields + 1] = {func = getFunc}

	GUILabel:new(self.m_Width*0.02, #self.m_Fields*self.m_Height*0.05, self.m_Width*0.65, self.m_Height*0.045, name..":", parent)
	self.m_Fields[#self.m_Fields].label = GUILabel:new(self.m_Width*0.65, #self.m_Fields*self.m_Height*0.05, self.m_Width*0.32, self.m_Height*0.045, "", parent):setAlignX("right")
end

function DebugGUI:onHide()
	if isTimer(self.m_PerformanceRefreshTimer) then killTimer(self.m_PerformanceRefreshTimer) end
	self.m_PerformanceRefreshTimer = false
end

addEventHandler("onClientResourceStart", resourceRoot,
	function()
		DebugGUI:new():setVisible(false)
		bindKey(core:get("KeyBindings", "KeyToggleDebugGUI", "F10"), "down",
			function()
				DebugGUI:getSingleton():setVisible(not DebugGUI:getSingleton():isVisible())
			end
		)
	end
)

addEvent("receiveServerDebug", true)
addEventHandler("receiveServerDebug", root,
	function(message, level, file, line)
		DebugGUI:getSingleton():onServerDebug(message, level, file, line)
	end
)
