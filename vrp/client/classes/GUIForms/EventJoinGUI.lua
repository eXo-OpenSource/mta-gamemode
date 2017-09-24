-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/EventJoinGUI.lua
-- *  PURPOSE:     Event GUI
-- *
-- ****************************************************************************
EventJoinGUI = inherit(GUIForm)
inherit(Singleton, EventJoinGUI)

function EventJoinGUI:constructor(eventId)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.35/2, screenHeight/2 - screenHeight*0.45/2, screenWidth*0.35, screenHeight*0.45)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Event beitreten", true, true, self)
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.98, self.m_Height*0.08, _"Typ: ", self.m_Window)
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.08, _"Beschreibung:", self.m_Window)
	self.m_DescriptionLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.3, self.m_Width*0.98, self.m_Height*0.08, _"Das Straßenrennen ist ein cooles Event.\nDeine Aufgabe ist es an ein Ziel zu fahren!\n\nViel Glück!", self.m_Window)

	self.m_ButtonJoin = GUIButton:new(self.m_Width*0.05, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Beitreten", self.m_Window):setBackgroundColor(Color.Green):setBarEnabled(true)
	self.m_ButtonCancel = GUIButton:new(self.m_Width*0.55, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Abbrechen", self.m_Window):setBackgroundColor(Color.Red):setBarEnabled(true)

	self.m_ButtonCancel.onLeftClick = function() delete(self) end
	self.m_ButtonJoin.onLeftClick = (
		function()
			triggerServerEvent("eventJoin", root, eventId)
			delete(self)
		end
	)
end

function EventJoinGUI:setInfo(name, description)
	self.m_TypeLabel:setText(_"Typ: "..name)
	self.m_DescriptionLabel:setText(description)
end

addEvent("eventGUI", true)
addEventHandler("eventGUI", root,
	function(eventId, name, description)
		EventJoinGUI:new(eventId):setInfo(name, description)
	end
)
