-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/BreakingNews.lua
-- *  PURPOSE:     Breaking News class
-- *
-- ****************************************************************************
BreakingNews = inherit(GUIForm)
inherit(Singleton, BreakingNews)

function BreakingNews:constructor(text)
	GUIForm.constructor(self, 0, 0, screenWidth*0.6, 50, false, true)
	GUIImage:new(0, 0, self.m_Width-24, self.m_Height, "files/images/Other/BreakingNewsBG.png", self):setAlpha(220)
	GUIImage:new(self.m_Width-24, 0, 24, self.m_Height, "files/images/Other/BreakingNewsEnd.png", self):setAlpha(220)
	GUIImage:new(5, self.m_Height/2 - 40/2, 71, 40, "files/images/Other/BreakingNews.png", self)
	self.m_Label = GUILabel:new(85, 0, self.m_Width-85, self.m_Height, text, self):setAlignY("center"):setFont(VRPFont(32)):setFontSize(1)
	self:setVisible(false)
	self:FadeIn()
end

function BreakingNews:FadeIn()
	GUIForm.fadeIn(self, 750)
	setTimer(bind(self.fadeOut, self), 10000, 1)
end

function BreakingNews:FadeOut()
	GUIForm.fadeOut(self, 750)
	setTimer(function() delete(self) end, 750, 1)
end

addEvent("breakingNews", true)
addEventHandler("breakingNews", root, function(...)
	if BreakingNews:isInstantiated() then delete(BreakingNews:getSingleton()) end
	BreakingNews:new(...)
end)
