-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/HistoryPlayer.lua
-- *  PURPOSE:     History Player Class
-- *
-- ****************************************************************************
HistoryUninviteGUI = inherit(GUIForm)

function HistoryUninviteGUI:constructor(callBack)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.22/2, screenWidth*0.4, screenHeight*0.22)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Spieler rauswerfen", true, true, self)
	-- GUILabel:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.5, text, self.m_Window):setFont(VRPFont(self.m_Height*0.17))
	self.m_ReasonInternalyLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.14, self.m_Width*0.96, self.m_Height*0.09, _"Interner Grund für den Rauswurf", self.m_Window):setFont(VRPFont(self.m_Height*0.14))
	self.m_ReasonInternaly = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.27, self.m_Width*0.96, self.m_Height*0.14, self.m_Window):setMaxLength(128)

	self.m_ReasonExternalyLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.40, self.m_Width*0.96, self.m_Height*0.09, _"Öffentlicher Grund für den Rauswurf", self.m_Window):setFont(VRPFont(self.m_Height*0.14))
	self.m_ReasonExternaly = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.54, self.m_Width*0.96, self.m_Height*0.14, self.m_Window):setMaxLength(128)

	self.m_YesButton = GUIButton:new(self.m_Width*0.13, self.m_Height*0.75, self.m_Width*0.29, self.m_Height*0.18, _"Rauswerfen", self.m_Window):setBackgroundColor(Color.Red)
	self.m_NoButton = GUIButton:new(self.m_Width*0.58, self.m_Height*0.75, self.m_Width*0.29, self.m_Height*0.18, _"Abbrechen", self.m_Window)--:setBackgroundColor(Color.Red)

	self.m_YesButton.onLeftClick = function()
		if self.m_ReasonExternaly.m_Text == "" then
			ErrorBox:new(_"Öffentlicher Grund für den Rauswurf muss ausgefüllt werden!")
			return
		end
        
        if callBack then
            callBack(self.m_ReasonInternaly.m_Text, self.m_ReasonExternaly.m_Text)
        end
		delete(self)
	end

	self.m_NoButton.onLeftClick = function() delete(self) end
end
