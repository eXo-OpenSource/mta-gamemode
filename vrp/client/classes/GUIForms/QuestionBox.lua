-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/QuestionBox.lua
-- *  PURPOSE:     Question box class
-- *
-- ****************************************************************************
QuestionBox = inherit(GUIForm)
inherit(Singleton, QuestionBox)

function QuestionBox:constructor(text, yesCallback, noCallback, rangeElement, range)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18, true, false, rangeElement, range)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Frage", true, false, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.55, text, self.m_Window):setFont(VRPFont(self.m_Height*0.17))
	self.m_YesButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.75, self.m_Width*0.35, self.m_Height*0.2, _"Ja", self.m_Window):setBackgroundColor(Color.Green)
	self.m_NoButton = GUIButton:new(self.m_Width*0.55, self.m_Height*0.75, self.m_Width*0.35, self.m_Height*0.2, _"Nein", self.m_Window):setBackgroundColor(Color.Red)

	self.m_YesCallBack = yesCallback
	self.m_NoCallBack = noCallback

	self.m_YesButton.onLeftClick = function() if self.m_YesCallBack then self.m_YesCallBack() end delete(self) end
	self.m_NoButton.onLeftClick = function() if self.m_NoCallBack then self.m_NoCallBack() end delete(self) end
end

function QuestionBox:destructor()
	GUIForm.destructor(self)
end

addEvent("questionBox", true)
addEventHandler("questionBox", root,
	function(id, text, rangeElement, range)
		QuestionBox:new(text,
			function()
				triggerServerEvent("questionBoxAccept", root, id)
			end,
			function()
				triggerServerEvent("questionBoxDiscard", root, id)
			end,
			rangeElement,
			range
		)
	end
)

addEvent("questionBoxClose", true)
addEventHandler("questionBoxClose", root,
	function()
		delete(QuestionBox:getSingleton())
	end
)
