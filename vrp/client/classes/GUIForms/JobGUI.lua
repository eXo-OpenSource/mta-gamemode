-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/JobGUI.lua
-- *  PURPOSE:     Job GUI class
-- *
-- ****************************************************************************
JobGUI = inherit(GUIForm)
inherit(Singleton, JobGUI)

function JobGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "JobGUI", false, false, self)
	self.m_Header = GUIImage:new(30, 30, 540, 135, "files/images/Jobs/HeaderTrashman.png", self)
	self.m_InfoLabel = GUILabel:new(30, 180, 540, 200, LOREM_IPSUM, self)
	self.m_InfoLabel:setFont(VRPFont(20))

	self.m_AcceptButton = GUIButton:new(50, 400, 210, 35, _"Akzeptieren", self)
	self.m_AcceptButton:setBackgroundColor(Color.Green):setFont(VRPFont(28)):setFontSize(1)
	self.m_AcceptButton.onLeftClick = bind(self.AcceptButton_Click, self)
	self.m_DeclineButton = GUIButton:new(340, 400, 210, 35, _"Ablehnen / Kündigen", self)
	self.m_DeclineButton:setBackgroundColor(Color.Red):setFont(VRPFont(28)):setFontSize(1)
	self.m_DeclineButton.onLeftClick = bind(self.DeclineButton_Click, self)
	self.m_InfoButton = GUIButton:new(300-(35/2), 400, 35, 35, _"i", self)
	self.m_InfoButton:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1.5)
	self.m_InfoButton.onLeftClick = bind(self.InfoButton_Click, self)
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

function JobGUI:setDeclineCallback(func)
	self.m_DeclineCallback = func
end


function JobGUI:setInfoCallback(func)
	self.m_InfoCallback = func
end

function JobGUI:AcceptButton_Click()
	if self.m_AcceptCallback then
		self.m_AcceptCallback()
	end
	self:close()
end

function JobGUI:DeclineButton_Click()
	if self.m_DeclineCallback then
		self.m_DeclineCallback()
	end
	self:close()
end

function JobGUI:InfoButton_Click()
	if self.m_InfoCallback then
		self.m_InfoCallback()
	end
	self:close()
end
