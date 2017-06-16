-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/QuestionBox.lua
-- *  PURPOSE:     Question box class
-- *
-- ****************************************************************************
QuestionBox = inherit(GUIForm)
inherit(Singleton, QuestionBox)

function QuestionBox:constructor(text, yesCallback, noCallback)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.18/2, screenWidth*0.4, screenHeight*0.18)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Frage", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.5, text, self.m_Window):setFont(VRPFont(self.m_Height*0.17))
	self.m_YesButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Ja", self.m_Window):setBackgroundColor(Color.Green)
	self.m_NoButton = GUIButton:new(self.m_Width*0.55, self.m_Height*0.7, self.m_Width*0.35, self.m_Height*0.2, _"Nein", self.m_Window):setBackgroundColor(Color.Red)

	self.m_YesButton.onLeftClick = function() if yesCallback then yesCallback() end delete(self) end
	self.m_NoButton.onLeftClick = function() if noCallback then noCallback() end delete(self) end
end

addEvent("questionBox", true)
addEventHandler("questionBox", root,
	function(id, text)
		QuestionBox:new(text,
			function()
				triggerServerEvent("questionBoxAccept", root, id)
			end,
			function()
				triggerServerEvent("questionBoxDiscard", root, id)
			end
		)
	end
)

addEvent("questionBoxClose", true)
addEventHandler("questionBoxClose", root,
	function()
		delete(QuestionBox:getSingleton())
	end)

