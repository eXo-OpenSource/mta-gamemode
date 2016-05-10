DeathGUI = inherit(GUIForm)
inherit(Singleton, DeathGUI)


function DeathGUI:constructor(time)
	GUIForm.constructor(self, screenWidth-400, 0, 450, 200, false)
	GUILabel:new(0, 0, self.m_Width-10, 80, _"eXo-Krankenhaus", self):setAlignX("right"):setColor(Color.LightBlue)
	self.m_Seconds = time/1000
	self.m_Timer = setTimer(bind(self.decreaseSeconds, self), time, 0)
	self.m_CountdownLabel = GUILabel:new(0, 80, self.m_Width-10, 50, _("%d Sekunden", self.m_Seconds), self):setAlignX("right")
	HUDUI:getSingleton():hide()
end

function DeathGUI:destructor()
	HUDUI:getSingleton():show()
	GUIForm.destructor(self)
end

function DeathGUI:decreaseSeconds()
	self.m_Seconds = self.m_Seconds-1
	self.m_CountdownLabel:setText(_("%d Sekunden", self.m_Seconds))
	if self.m_Seconds <= 0 then
		self.m_Timer:destroy()
		delete(self)
	end
end
