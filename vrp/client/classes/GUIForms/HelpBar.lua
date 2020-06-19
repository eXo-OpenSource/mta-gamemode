-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HelpBar.lua
-- *  PURPOSE:     Help bar (slider) class
-- *
-- ****************************************************************************
HelpBar = inherit(GUIForm)
inherit(Singleton, HelpBar)
addRemoteEvents{"setHelpBarLexiconPage", "resetHelpBar"}

function HelpBar:constructor()
	GUIForm.constructor(self, screenWidth-screenWidth*0.028/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4, screenWidth*0.03/ASPECT_RATIO_MULTIPLIER, screenHeight*0.1, false, true)

	self.m_Enabled = core:get("HUD", "showHelpBar", true)

	self.m_Icon = GUIImage:new(0, 0, self.m_Width, self.m_Height, "files/images/GUI/HelpIcon.png", self)
	self.m_Icon.onLeftClick = bind(self.HelpIcon_Click, self)
	self.m_Icon.onHover = function ()
		if self.m_BlinkTimer and isTimer(self.m_BlinkTimer) then
			killTimer(self.m_BlinkTimer)
		end

		self.m_Icon:setColor(Color.Yellow)
	end
	self.m_Icon.onUnhover = function () self.m_Icon:setColor(Color.White) end

	self.m_Visible = false
end

function HelpBar:toggle()
	self.m_Enabled = core:get("HUD", "showHelpBar", true)
	if self.m_Enabled and self.m_LexiconUrl then
		self:fadeIn()
	else
		self:fadeOut()
	end
end

function HelpBar:fadeIn()
	if not self.m_Enabled then return false end
	self.m_Visible = true
	self.m_Icon:setPosition(self.m_Width, 0)
	Animation.Move:new(self.m_Icon, 500, 0, 0)

	self.m_Icon.onUnhover()
end

function HelpBar:fadeOut()
	self.m_Icon:setPosition(0, 0)
	Animation.Move:new(self.m_Icon, 500, self.m_Width, 0)

	setTimer(function ()
		if self.m_Enabled then
			self.m_Visible = false
		end
	end, 500, 1)
end

function HelpBar:setLexiconPage(url)
	self.m_LexiconUrl = url
	if self.m_Visible and not url then
		self:fadeOut()
	elseif not self.m_Visible and url then
		if not self.m_Enabled then return false end
		self:fadeIn()
	end
end

function HelpBar:HelpIcon_Click()
	if not self.m_LexiconUrl then ErrorBox:new(_"Der Hilfetext ist nicht verfügbar.") return end
	HelpGUI:getSingleton():openLexiconPage(self.m_LexiconUrl)
end


-- Events
function HelpBar.Event_SetManualText(lexiconPage)
	HelpBar:getSingleton():setLexiconPage(lexiconPage)
end
addEventHandler("setHelpBarLexiconPage", root, HelpBar.Event_SetManualText)

function HelpBar.Event_ResetManualText()
	HelpBar:getSingleton():setLexiconPage(nil)
end
addEventHandler("resetHelpBar", root, HelpBar.Event_ResetManualText)
