-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HelpBar.lua
-- *  PURPOSE:     Help bar (slider) class
-- *
-- ****************************************************************************
HelpBar = inherit(GUIForm)
inherit(Singleton, HelpBar)

function HelpBar:constructor()
	GUIForm.constructor(self, screenWidth*0.84, 0, screenWidth*0.16, screenHeight)

	self.m_Icon = GUIImage:new(screenWidth-screenWidth*0.028, screenHeight*0.4, screenWidth*0.03, screenHeight*0.1, "files/images/HelpIcon.png")
	self.m_Icon.onLeftClick = bind(self.HelpIcon_Click, self)

	self.m_Rectangle = GUIRectangle:new(self.m_Width, 0, self.m_Width, self.m_Height, tocolor(0, 0, 0, 200), self)
	self.m_TitleLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.01, self.m_Width*0.9, self.m_Height*0.1, _"Hilfe", self.m_Rectangle):setColor(Color.LightBlue)
	self.m_SubTitleLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.09, self.m_Width*0.9, self.m_Height*0.04, "Kein Text", self.m_Rectangle):setColor(Color.LightBlue)
	self.m_TextLabel = GUILabel:new(self.m_Width*0.05, self.m_Height*0.15, self.m_Width*0.9, self.m_Height*0.8, "", self.m_Rectangle):setFont(VRPFont(self.m_Height*0.03))

	self.m_CloseButton = GUILabel:new(self.m_Width*0.8, self.m_Height*0.005, self.m_Width*0.2, self.m_Height*0.1, "⇛", self.m_Rectangle):setColor(Color.LightBlue)
	self.m_CloseButton.onLeftClick = function() self:fadeOut() end
end

function HelpBar:fadeIn()
	self.m_Rectangle:setPosition(self.m_Width, 0)
	Animation.Move:new(self.m_Rectangle, 500, 0, 0)

	self.m_Icon:setAlpha(150)
end

function HelpBar:fadeOut()
	self.m_Rectangle:setPosition(0, 0)
	Animation.Move:new(self.m_Rectangle, 500, self.m_Width, 0)

	setTimer(function ()
		self.m_Icon:setAlpha(255)
	end, 500, 1)
end

function HelpBar:blink()
	local isFilled = true
	self.m_BlinkTimer = setTimer(
		function()
			isFilled = not isFilled

			if isFilled then
				self.m_Icon:setColor(Color.LightBlue)
			else
				self.m_Icon:setColor(Color.White)
			end
		end, 400, 15
	)
end

function HelpBar:addText(title, text, blink)
	self.m_SubTitleLabel:setText(title)
	self.m_TextLabel:setText(text)

	if blink ~= false then
		self:blink()
	end
end

function HelpBar:HelpIcon_Click()
	self:fadeIn()

	if self.m_BlinkTimer and isTimer(self.m_BlinkTimer) then
		killTimer(self.m_BlinkTimer)
		self.m_Icon:setColor(Color.White)
	end
end
