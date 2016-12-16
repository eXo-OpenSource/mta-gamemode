
-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AntiClickSpam.lua
-- *  PURPOSE:     Anti Click Spam prevent server performance
-- *
-- ****************************************************************************
AntiClickSpam = inherit(Singleton)

function AntiClickSpam:constructor()
	self.m_Warn = 4
	self.m_Block = 8
	self.m_Counter = 0
	addEventHandler("onClientClick",root, bind(self.onClick, self))

	setTimer(bind(self.reset, self), 1000, 0)
end

function AntiClickSpam:onClick(button, state)
	if state == "down" then
		self.m_Counter = self.m_Counter + 1
		self:checkSpam()
	end
end

function AntiClickSpam:checkSpam()
	if self.m_Counter >= self.m_Warn and self.m_Counter < self.m_Block then
		WarningBox:new("Achtung: Clickspam!")
	elseif self.m_Counter >= self.m_Block then
		ErrorBox:new("Achtung: Clickspam - Klicken wurde gesperrt!")
		self:block()
	end
end

function AntiClickSpam:block()
	showCursor(false)
	local timer = setTimer(function()
		showCursor(false)
	end, 50, 0)

	setTimer(function(timer)
		if isTimer(timer) then killTimer(timer) end
	end, 10000, 1, timer)
end

function AntiClickSpam:reset()
	self.m_Counter = 0
end
