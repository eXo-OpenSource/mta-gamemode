-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HelpBar.lua
-- *  PURPOSE:     Help bar (slider) class
-- *
-- ****************************************************************************
HelpBar = inherit(GUIForm)
inherit(Singleton, HelpBar)
addRemoteEvents{"setManualHelpBarText", "resetManualHelpBarText"}

function HelpBar:constructor()
	GUIForm.constructor(self, screenWidth*0.845, 0, screenWidth*0.16, screenHeight, false, true)

	self.m_Enabled = core:get("HUD", "showHelpBar", true)

	self.m_Icon = GUIImage:new(screenWidth-screenWidth*0.028/ASPECT_RATIO_MULTIPLIER, screenHeight*0.4, screenWidth*0.03/ASPECT_RATIO_MULTIPLIER, screenHeight*0.1, "files/images/GUI/HelpIcon.png")
	self.m_Icon.onLeftClick = bind(self.HelpIcon_Click, self)
	self.m_Icon.onHover = function ()
		if self.m_BlinkTimer and isTimer(self.m_BlinkTimer) then
			killTimer(self.m_BlinkTimer)
		end

		self.m_Icon:setColor(Color.Yellow)
	end
	self.m_Icon.onUnhover = function () self.m_Icon:setColor(Color.White) end

	self.m_Rectangle = GUIRectangle:new(self.m_Width, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200), self)
	self.m_TitleLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.01, self.m_Width*0.7, self.m_Height*0.1, _"Hilfe", self.m_Rectangle):setColor(Color.Accent)
	self.m_SubTitleLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.09, self.m_Width*0.9, self.m_Height*0.04, "Kein Text", self.m_Rectangle):setColor(Color.Accent)
	self.m_TextLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.15, self.m_Width*0.9, self.m_Height*0.8, "", self.m_Rectangle):setFont(VRPFont(self.m_Height*0.03))

	self.m_CloseButton = GUILabel:new(self.m_Width*0.75, self.m_Height*0.01, self.m_Width*0.25, self.m_Height*0.1, "⇛", self.m_Rectangle):setColor(Color.Accent)
	self.m_CloseButton.onLeftClick = function() self:fadeOut() end
	self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.Accent) end

	self.m_TutorialButton = GUILabel:new(self.m_Width*0.05, self.m_Height*0.80, self.m_Width, self.m_Height*0.05, _"Zeige Tutorial", self.m_Rectangle):setColor(Color.Accent)
	self.m_TutorialButton.onHover = function () self.m_TutorialButton:setColor(Color.White) end
	self.m_TutorialButton.onUnhover = function () self.m_TutorialButton:setColor(Color.Accent) end
	self.m_TutorialButton:setVisible(false)

	if localPlayer:isLoggedIn() then
		self.m_TicketButton = GUIButton:new(self.m_Width*0.05, self.m_Height*0.93, self.m_Width*0.9, self.m_Height*0.05, _"Ticket erstellen", self.m_Rectangle):setFontSize(1.2):setBackgroundColor(Color.Accent)
		self.m_TicketButton.onLeftClick = function() TicketGUI:getSingleton():open() end
	end

	self.m_Visible = false

	self.m_Icon:setVisible(self.m_Enabled)
end

function HelpBar:toggle()
	self.m_Enabled = core:get("HUD", "showHelpBar", true)
	self.m_Icon:setVisible(self.m_Enabled)
	if not self.m_Enabled then
		self:fadeOut()
	end
end

function HelpBar:fadeIn()
	self.m_Visible = true
	self.m_Rectangle:setPosition(self.m_Width, 0)
	Animation.Move:new(self.m_Rectangle, 500, 0, 0)

	self.m_Icon.onUnhover()
	self.m_Icon:setVisible(false)
end

function HelpBar:fadeOut()
	self.m_Rectangle:setPosition(0, 0)
	Animation.Move:new(self.m_Rectangle, 500, self.m_Width, 0)

	setTimer(function ()
		if self.m_Enabled then
			self.m_Icon:setVisible(true)
			self.m_Visible = false
		end
	end, 500, 1)
	if getCameraTarget(localPlayer) == localPlayer or getCameraTarget(localPlayer) == getPedOccupiedVehicle(localPlayer) then
		if localPlayer:isLoggedIn() and not localPlayer:isDead() then
			HUDUI:getSingleton():show()
			HUDUI:getSingleton():setEnabled(true)
		end
	end
end

function HelpBar:blink()
	local isFilled = true
	self.m_Icon:setColor(Color.Yellow)

	self.m_BlinkTimer = setTimer(
		function()
			isFilled = not isFilled

			if isFilled then
				self.m_Icon:setColor(Color.Yellow)
			else
				self.m_Icon:setColor(Color.White)
			end
		end, 400, 15
	)
end

function HelpBar:addText(title, text, blink, tutorial)
	localPlayer.m_oldHelp = {
		title = self.m_SubTitleLabel:getText();
		text = self.m_TextLabel:getText();
		tutorial = self.m_TutorialButton.onLeftClick
	}

	if isTimer(self.m_BlinkTimer) then
		killTimer(self.m_BlinkTimer)
		self.m_Icon:setColor(Color.White)
	end

	self.m_SubTitleLabel:setText(title)
	self.m_TextLabel:setText(text)

	if blink ~= false then
		self:blink()
	end

	if type(tutorial) == "function" then
		self.m_TutorialButton:setVisible(true)
		self.m_TutorialButton.onLeftClick = function ()
			self:fadeOut()
			QuestionBox:new(_"Willst du wirklich das Tutorial ansehen?", tutorial, bind(self.fadeIn, self))
		end
	else
		self.m_TutorialButton:setVisible(false)
		self.m_TutorialButton.onLeftClick = nil
	end
end

function HelpBar:addTempText(title, text, blink, tutorial, timeout, anim)
	self:addText(title, text, blink, tutorial)

	if anim then
		if not self.m_Visible then
			self:fadeIn()
		end
	end
	setTimer(
		function ()
			if anim then
				if self.m_Visible then
					self:fadeOut()
				end

				setTimer(
					function ()
						self:addText(localPlayer.m_oldHelp.title, localPlayer.m_oldHelp.text, false, localPlayer.m_oldHelp.tutorial)
					end, 550, 1
				)
			else
				self:addText(localPlayer.m_oldHelp.title, localPlayer.m_oldHelp.text, false, localPlayer.m_oldHelp.tutorial)
			end
		end, timeout or 10000, 1
	)
end

function HelpBar:HelpIcon_Click()
	HUDUI:getSingleton():hide()
	HUDUI:getSingleton():setEnabled(false)
	self:fadeIn()
end


-- Events
function HelpBar.Event_SetManualText(title, text, translate)
	local newTitle
	for i, v in ipairs(split(title, ".")) do
		if i == 1 then
			newTitle = _G[v]
		else
			newTitle = newTitle[v]
		end
	end
	local newText
	for i, v in ipairs(split(text, ".")) do
		if i == 1 then
			newText = _G[v]
		else
			newText = newText[v]
		end
	end
	HelpBar:getSingleton():addText(translate and _(newTitle) or newTitle, translate and _(newText) or newText)
end
addEventHandler("setManualHelpBarText", root, HelpBar.Event_SetManualText)

function HelpBar.Event_ResetManualText()
	HelpBar:getSingleton():addText(localPlayer.m_oldHelp.title or _(HelpTextTitles.General.Main), localPlayer.m_oldHelp.text or _(HelpTexts.General.Main), false, localPlayer.m_oldHelp.tutorial or false)
end
addEventHandler("resetManualHelpBarText", root, HelpBar.Event_ResetManualText)
