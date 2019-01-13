-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ShortMessageLogGUI.lua
-- *  PURPOSE:     ShortMessageLogGUI
-- *
-- ****************************************************************************
ShortMessageLogGUI = inherit(GUIForm)
inherit(Singleton, ShortMessageLogGUI)

ShortMessageLogGUI.m_Log = {}
function ShortMessageLogGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"ShortMessage-Log", true, true, self)
	self.m_Window:addBackButton(function () SelfGUI:getSingleton():show() end)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.96, self.m_Height*0.07, _"Log von letzten Shortmessages (Doppelklick zum kopieren)", self.m_Window)
	self.m_LogGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.96, self.m_Height*0.5, self.m_Window)
	self.m_LogGrid:addColumn(_"Nachricht", 1)
	self.m_LogGrid:setFont(VRPFont(20))
	self.m_LogGrid:setItemHeight(24)
	self.m_Title = GUILabel:new(self.m_Width*0.02, self.m_Height*0.7, self.m_Width*0.96, self.m_Height*0.07, "", self.m_Window)
	self.m_Text = GUILabel:new(self.m_Width*0.02, self.m_Height*0.77, self.m_Width*0.96, self.m_Height*0.05, "", self.m_Window)
	self.m_Clear = GUIButton:new(self.m_Width*0.68, self.m_Height*0.91, self.m_Width*0.3, self.m_Height*0.07, _"Leeren", self.m_Window):setBackgroundColor(Color.Orange)
	self.m_Clear.onLeftClick = bind(self.clear, self)

	self:setVisible(false)
end

function ShortMessageLogGUI:clear()
	ShortMessageLogGUI.m_Log = {}
	self.m_LogGrid:clear()
end

function ShortMessageLogGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function ShortMessageLogGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	if self.m_LogGrid then
		self.m_LogGrid:clear()
		local item, string
		for key, data in ripairs(ShortMessageLogGUI.m_Log) do
			item = self.m_LogGrid:addItem(data.text)
			item:setFont(VRPFont(20))
			item.onLeftClick = function()
				self.m_Title:setText(("%s %s"):format(getOpticalTimestamp(data.timestamp, true), data.title))
				self.m_Text:setText(data.text)
			end

			item.onLeftDoubleClick = function ()
				setClipboard(("%s \r\n %s \r\n %s"):format(getOpticalTimestamp(data.timestamp, true), data.title, data.text));
				outputChatBox("[ShortMessage] Log-Zeile wurde in Zwischenablage kopiert!", 200,200,0);
			end
		end
	end
end

function ShortMessageLogGUI.insertLog(title, text, color)
	local id = #ShortMessageLogGUI.m_Log+1
	ShortMessageLogGUI.m_Log[id] ={
		["title"] = title or "",
		["text"] = text:gsub("\n", "") or "",
		["color"] = type(color) == "table" and color or Color.White,
		["timestamp"] = getRealTime().timestamp
	}
end
