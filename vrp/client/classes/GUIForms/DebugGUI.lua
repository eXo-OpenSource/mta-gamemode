-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/DebugGUI.lua
-- *  PURPOSE:     Performance statistics GUI class
-- *
-- ****************************************************************************
DebugGUI = inherit(GUIForm)
inherit(Singleton, DebugGUI)

addEvent("receiveServerDebug", true)


DebugGUI.Colors = {["Server"] = tocolor(255, 204, 0), ["Client"] = tocolor(50, 200, 255)}

DebugGUI.Level = {
	[0] = {["Type"] = "Custom", ["Label"] = "[C]", ["Color"] = tocolor(0, 125, 255)},
	[1] = {["Type"] = "Error", ["Label"] = "[E]", ["Color"] = tocolor(255, 0, 0)},
	[2] = {["Type"] = "Warning", ["Label"] = "[W]", ["Color"] = tocolor(255, 165, 0)},
	[3] = {["Type"] = "Info", ["Label"] = "[I]", ["Color"] = tocolor(0, 255, 0)}
}

function DebugGUI:constructor()
	GUIForm.constructor(self, 5, screenHeight*0.2, 350, screenHeight*0.62, true, true)

	self.m_Fields = {}

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Debug-Console", true, false, self)

	self.m_DebugCheckBoxes = {}
	self.m_DebugCheckBoxes["Server"] = GUICheckbox:new(self.m_Width*0.0+10, 30+5, self.m_Width*0.5, self.m_Height*0.03, "Server", self.m_Window):setFontSize(1.5):setColor(DebugGUI.Colors["Server"])
	self.m_DebugCheckBoxes["Client"] = GUICheckbox:new(self.m_Width*0.5+10, 30+5, self.m_Width*0.5, self.m_Height*0.03, "Client", self.m_Window):setFontSize(1.5):setColor(DebugGUI.Colors["Client"])
	self.m_DebugCheckBoxes[0] = GUICheckbox:new(self.m_Width*0.00+10, 30+5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[0]["Type"], self.m_Window):setFontSize(1):setColor(DebugGUI.Level[0]["Color"])
	self.m_DebugCheckBoxes[1] = GUICheckbox:new(self.m_Width*0.25+10, 30+5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[1]["Type"], self.m_Window):setFontSize(1):setColor(DebugGUI.Level[1]["Color"])
	self.m_DebugCheckBoxes[2] = GUICheckbox:new(self.m_Width*0.50+10, 30+5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[2]["Type"], self.m_Window):setFontSize(1):setColor(DebugGUI.Level[2]["Color"])
	self.m_DebugCheckBoxes[3] = GUICheckbox:new(self.m_Width*0.75+10, 30+5+self.m_Height*0.04, self.m_Width*0.25, self.m_Height*0.025, DebugGUI.Level[3]["Type"], self.m_Window):setFontSize(1):setColor(DebugGUI.Level[3]["Color"])
	self.m_DebugGrid = GUIGridList:new(0, 30+self.m_Height*0.095, self.m_Width, self.m_Height*0.7, self.m_Window)
	self.m_DebugGrid:setFont(VRPFont(20))
	self.m_DebugGrid:setItemHeight(20)
	self.m_DebugGrid:addColumn(_"S/C", 0.075)
	self.m_DebugGrid:addColumn(_"Typ", 0.075)
	self.m_DebugGrid:addColumn(_"Message", 0.85)
	self.m_DebugLabels = {}
	self.m_DebugLabels["Type"] = GUILabel:new(5, 30+self.m_Height*0.81, self.m_Width, self.m_Height*0.045, "", self.m_Window)
	self.m_DebugLabels["File"] = GUILabel:new(5, 30+self.m_Height*0.855, self.m_Width, self.m_Height*0.035, "", self.m_Window)
	self.m_DebugLabels["Msge"] = GUILabel:new(5, 30+self.m_Height*0.89, self.m_Width, self.m_Height*0.035, "", self.m_Window)

	self.m_ClearButton = GUIButton:new(self.m_Width-35, 30+self.m_Height*0.81, 30, 30, FontAwesomeSymbols.Trash, self.m_Window):setFont(FontAwesome(15)):setBackgroundColor(Color.Red)
	self.m_ClearButton.onLeftClick = function ()
		self.m_DebugLogTable = {}
		self:refreshDebugGrid()
	end


	for index, box in pairs(self.m_DebugCheckBoxes) do
		box:setChecked(true)
		box.onChange = function() self:refreshDebugGrid() end
	end

	addEventHandler("onClientDebugMessage", root, bind(self.onClientDebug, self))
	self.m_DebugLogTable = {}

end

local lastDebug = {}
lastDebug["Server"] = {["Id"] = 0, ["Message"] = "", ["File"] = ""}
lastDebug["Client"] = {["Id"] = 0, ["Message"] = "", ["File"] = ""}

function DebugGUI:onShow()
	showCursor(true)
	self:refreshDebugGrid()
end

function DebugGUI:onHide()
	showCursor(false)
end

function DebugGUI:onClientDebug(message, level, file, line)
	self:addDebug("Client", message, level, file, line)
end

function DebugGUI:onServerDebug(message, level, file, line)
	self:addDebug("Server", message, level, file, line)
end

function DebugGUI:addDebug(type, message, level, file, line)
	id = #self.m_DebugLogTable+1
	line = line or ""
	file = file or ""
	file = file..":"..line
	local last = lastDebug[type]
	if last.Message == message and last.File == file then
		self.m_DebugLogTable[last.Id].x =  self.m_DebugLogTable[last.Id].x + 1
	else
		self.m_DebugLogTable[id] = {["Id"] = id, ["Type"] = type, ["Level"] = level, ["Message"] = message, ["File"] = file, ["x"] = 1}
		lastDebug[type]["Id"] = id
		lastDebug[type]["Message"] = message
		lastDebug[type]["File"] = file
	end
	if self:isVisible() then
		self:refreshDebugGrid()
	end
end

function DebugGUI:refreshDebugGrid()
	self.m_DebugGrid:clear()
	local table = table.reverse(self.m_DebugLogTable)
	for id, data in ipairs(table) do
		if self.m_DebugCheckBoxes[data.Level]:isChecked() and self.m_DebugCheckBoxes[data.Type]:isChecked() then
			self:addLine(data.Id, data.Type, data.Level, data.Message, data.File, data.x)
		end
	end
end

function DebugGUI:addLine(id, type, level, message, file, x)
	local item, table
	message = x > 1 and x.."x "..message or message
	item = self.m_DebugGrid:addItem(string.sub(type, 1, 1), DebugGUI.Level[level].Label, message)
	item:setFont(VRPFont(20))
	item:setColumnColor(1, DebugGUI.Colors[type])
	item:setColumnColor(2, DebugGUI.Level[level].Color)
	item.Id = id
	item.onLeftClick = function(item)
		if self.m_CopyButton then delete(self.m_CopyButton) end
		table = self.m_DebugLogTable[id]
		self.m_DebugLabels["Type"]:setText("Type: "..table.Type.." - "..DebugGUI.Level[table.Level].Type)
		self.m_DebugLabels["Type"]:setColor(DebugGUI.Level[table.Level].Color)
		self.m_DebugLabels["File"]:setText("File: "..table.File)
		self.m_DebugLabels["Msge"]:setText("Message: "..table.Message)
		self.m_CopyButton = GUIButton:new(self.m_Width-70, 30+self.m_Height*0.81, 30, 30, FontAwesomeSymbols.Copy, self.m_Window):setFont(FontAwesome(15))
		self.m_CopyButton.onLeftClick = function ()
			local string = self.m_DebugLabels["Type"]:getText().."\r\n"..self.m_DebugLabels["File"]:getText().."\r\n"..self.m_DebugLabels["Msge"]:getText()
			setClipboard(string)
			InfoBox:new(_"Die Debug Nachricht ist nun in deiner Zwischenablage!")
		end
	end
end

function DebugGUI:addField(name, parent, getFunc)
	self.m_Fields[#self.m_Fields + 1] = {func = getFunc}

	GUILabel:new(self.m_Width*0.02, #self.m_Fields*self.m_Height*0.05, self.m_Width*0.65, self.m_Height*0.045, name..":", parent)
	self.m_Fields[#self.m_Fields].label = GUILabel:new(self.m_Width*0.65, #self.m_Fields*self.m_Height*0.05, self.m_Width*0.32, self.m_Height*0.045, "", parent):setAlignX("right")
end

function DebugGUI.initalize()
	DebugGUI:new()
	DebugGUI:getSingleton():close()

	bindKey(core:get("KeyBindings", "KeyToggleDebugGUI", "F9"), "down",
		function()
			DebugGUI:getSingleton():setVisible(not DebugGUI:getSingleton():isVisible())
		end
	)

	addEventHandler("receiveServerDebug", root,
		function(message, level, file, line)
			DebugGUI:getSingleton():onServerDebug(message, level, file, line)
		end
	)
end
