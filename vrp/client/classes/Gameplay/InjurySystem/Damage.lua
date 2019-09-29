-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Minigames/InjurySystem/Damage.lua
-- *  PURPOSE:     Damage
-- *
-- ****************************************************************************
Damage = inherit(Singleton)

function Damage:constructor() 
	self.m_Data = {}
	addRemoteEvents{"Damage:startTreatment", "Damage:cancelTreatment", "Damage:finishTreatment"}
	addEventHandler("Damage:startTreatment", localPlayer, bind(self.Event_startTreatment, self))
	addEventHandler("Damage:cancelTreatment", localPlayer, bind(self.Event_cancelTreatment, self))
	addEventHandler("Damage:finishTreatment", localPlayer, bind(self.Event_finishTreatment, self))
end

function Damage:destructor() 

end

function Damage:Event_startTreatment(time, isHealer)	
	self.m_InTreatment = true
	self.m_Input = guiGetInputEnabled()
	if self.m_Countdown then 
		self.m_Countdown:delete()
		self.m_Countdown = nil
	end
	if self.m_CancelGUI then 
		delete(self.m_CancelGUI:getSingleton())
		self.m_CancelGUI = nil
	end
	if self.m_CancelTimer and isTimer(self.m_CancelTimer) then 
		killTimer(self.m_CancelTimer)
		self.m_CancelTimer = nil
	end
	if InjuryGUI:isInstantiated() then 
		delete(InjuryGUI:getSingleton())
	end
	guiSetInputEnabled(true)
	showCursor(true)
	self.m_Countdown = ShortCountdown:new(time, "Behandlung", "files/images/Other/Treatment.png")
	self.m_CancelGUI = InjuryTreatmentGUI:new(self.m_Countdown.m_AbsoluteX+self.m_Countdown.m_Width, self.m_Countdown.m_AbsoluteY, isHealer)
	self.m_CancelTimer = setTimer(function() if self.m_CancelGUI then delete(self.m_CancelGUI:getSingleton()) end end, time*1000, 1)

end

function Damage:Event_finishTreatment()
	self.m_InTreatment = false
	if not self.m_Input then
		guiSetInputEnabled(false)
	end
	showCursor(false)
	if self.m_Countdown then 
		self.m_Countdown:delete()
		self.m_Countdown = nil
	end
	if self.m_CancelGUI then 
		delete(self.m_CancelGUI:getSingleton())
		self.m_CancelGUI = nil
	end
	if self.m_CancelTimer and isTimer(self.m_CancelTimer) then 
		killTimer(self.m_CancelTimer)
		self.m_CancelTimer = nil
	end
end

function Damage:Event_cancelTreatment() 			
	self.m_InTreatment = false
	if not self.m_Input then
		guiSetInputEnabled(false)
	end
	showCursor(false)
	if self.m_Countdown then 
		self.m_Countdown:delete()
		self.m_Countdown = nil
	end
	if self.m_CancelGUI then 
		delete(self.m_CancelGUI:getSingleton())
		self.m_CancelGUI = nil
	end
	if self.m_CancelTimer and isTimer(self.m_CancelTimer) then 
		killTimer(self.m_CancelTimer)
		self.m_CancelTimer = nil
	end
end

function Damage:isInTreatment() return self.m_InTreatment end