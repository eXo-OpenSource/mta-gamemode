-- ****************************************************************************
-- *
-- *  PROJECT:     GTA:SA Online
-- *  FILE:        client/classes/GUIForms/JobGUI.lua
-- *  PURPOSE:     Job GUI class
-- *
-- ****************************************************************************
JobGUI = inherit(Singleton)
inherit(GUIForm, JobGUI)

function JobGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "JobGUI", false, false, self)
	self.m_Header = GUIImage:new(30, 30, 540, 135, "files/images/Jobs/HeaderTrashman.png", self)
	self.m_InfoLabel = GUILabel:new(30, 180, 540, 200, LOREM_IPSUM, 1.2, self)
	
	self.m_AcceptButton = GUIButton:new(50, 400, 210, 35, "Accept", self)
	self.m_AcceptButton:setBackgroundColor(Color.Green)
	self.m_AcceptButton.onLeftClick = bind(self.AcceptButton_Click, self)
	self.m_DeclineButton = GUIButton:new(340, 400, 210, 35, "Decline", self)
	self.m_DeclineButton:setBackgroundColor(Color.Red)
	self.m_DeclineButton.onLeftClick = bind(self.DeclineButton_Click, self)
end

function JobGUI:setDescription(text)
	self.m_InfoLabel:setText(text)
end

function JobGUI:setHeaderImage(imgPath)
	self.m_Header:setImage(imgPath)
end

function JobGUI:setAcceptCallback(func)
	self.m_AcceptCallback = func
end

function JobGUI:AcceptButton_Click()
	if self.m_AcceptCallback then
		self.m_AcceptCallback()
	end
	self:close()
end

function JobGUI:DeclineButton_Click()
	self:close()
end
