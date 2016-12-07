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
	GUIForm.constructor(self, (screenWidth/2-screenWidth*0.4*0.5)/ASPECT_RATIO_MULTIPLIER, screenHeight*0.2, screenWidth*0.4/ASPECT_RATIO_MULTIPLIER, screenHeight*0.5)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"ShortMessage-Log", true, true, self)
	GUILabel:new(self.m_Width*0.05, self.m_Height*0.1, self.m_Width*0.9, self.m_Height*0.1, _"Log von letzten Shortmessages", self.m_Window)
	self.m_LogGrid = GUIGridList:new(self.m_Width*0.05, self.m_Height*0.2, self.m_Width*0.9, self.m_Height*0.6, self.m_Window)
	self.m_LogGrid:addColumn(_"Log-Zeilen", 1)
	self.m_Clear = GUIButton:new(self.m_Width*0.35, self.m_Height*0.88, self.m_Width*0.3, self.m_Height*0.08, _"Leeren", self.m_Window):setBackgroundColor(Color.Orange)
	self.m_Clear.onLeftClick = bind(self.clear, self)
	self:setVisible(false)
end

function ShortMessageLogGUI:clear()
	self.m_LogGrid:clear() 
	outputChatBox("[ShortMessage] Log wurde geleert!", 200,200,0);
end

function ShortMessageLogGUI:onShow()
	if self.m_LogGrid then 
		self.m_LogGrid:clear() 
		local item
		for key, str in ipairs( ShortMessageLogGUI.m_Log ) do 
			item = self.m_LogGrid:addItem(str)
			item.onLeftDoubleClick = function ()  setClipboard(str); outputChatBox("[ShortMessage] Log-Zeile wurde in Zwischenablage kopiert!", 200,200,0); end
		end
	end
end
