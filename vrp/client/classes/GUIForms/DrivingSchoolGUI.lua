-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrivingSchoolGUI.lua
-- *  PURPOSE:     Driving school GUI
-- *
-- ****************************************************************************
DrivingSchoolGUI = inherit(GUIForm)
inherit(Singleton, DrivingSchoolGUI)

function DrivingSchoolGUI:constructor()
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.15, screenHeight*0.2, screenWidth*0.3, screenHeight*0.4)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fahrschule", true, true, self)
	
	GUILabel:new(self.m_Width*0.03, self.m_Height*0.1, self.m_Width*0.94, self.m_Height*0.75, _[[
		Herzlich Willkommen in der Flugschule!
		Hier kannst du einen Flugschein für Helikopter und Flugzeuge beantragen.
		Unmittelbar nach dem Bezahlen der Gebühr beginnt die Praxisprüfung, wo es deine Aufgabe ist, alle Marker erfolgreich abzufliegen.
		Solltest das Flugzeug durch dem Flug starke Beschädigungen aufweisen, erhälst du 80%% des Preises zurück.
		
		Derzeitiger Preis: 80.000$
		
		]], self.m_Window):setFont(VRPFont(self.m_Height*0.08))
		
	self.m_BuyButton = GUIButton:new(self.m_Width*0.2, self.m_Height*0.85, self.m_Width*0.6, self.m_Height*0.09, _"Kaufen", self.m_Window)
	self.m_BuyButton:setBackgroundColor(Color.Green)
	
	self.m_BuyButton.onLeftClick = function() triggerServerEvent("buyDriversLicense", root) delete(self) end
end
