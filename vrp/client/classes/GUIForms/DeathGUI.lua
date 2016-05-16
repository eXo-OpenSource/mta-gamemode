DeathGUI = inherit(GUIForm)
inherit(Singleton, DeathGUI)


function DeathGUI:constructor(time)
	GUIForm.constructor(self, screenWidth-500, screenHeight-10, 450, 200, false)
	GUIRectangle:new(0,0, self.m_Width, self.m_Height, tocolor(0,0,0,125), self)
	GUILabel:new(0, 0, self.m_Width-10, 80, _"eXo-Krankenhaus", self):setAlignX("right"):setColor(Color.LightBlue)
	self.m_Seconds = time/1000
	self.m_Timer = setTimer(bind(self.decreaseSeconds, self), 1000, 0)
	self.m_CountdownLabel = GUILabel:new(0, 80, self.m_Width-10, 50, _("%d Sekunden", self.m_Seconds), self):setAlignX("right")
	HUDUI:getSingleton():hide()
end

function DeathGUI:destructor()
	killTimer(self.m_Timer)
	HUDUI:getSingleton():show()
	GUIForm.destructor(self)
end

function DeathGUI:decreaseSeconds()
	self.m_Seconds = self.m_Seconds-1
	self.m_CountdownLabel:setText(_("%d Sekunden", self.m_Seconds))
	if self.m_Seconds <= 0 then
		delete(self)
	end
end
