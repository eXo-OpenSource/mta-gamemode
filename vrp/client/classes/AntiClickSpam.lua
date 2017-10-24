
-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/AntiClickSpam.lua
-- *  PURPOSE:     Anti Click Spam prevent server performance
-- *
-- ****************************************************************************
AntiClickSpam = inherit(Singleton)

function AntiClickSpam:constructor()
	self.m_Warn = 6
	self.m_Block = 8
	self.m_Counter = 0
	self.m_Enabled = true
	addEventHandler("onClientClick",root, bind(self.onClick, self))

	addRemoteEvents{"clickSpamSetEnabled"}
	addEventHandler("clickSpamSetEnabled",root, bind(self.setEnabled, self))

	setTimer(bind(self.reset, self), 1000, 0)
end

function AntiClickSpam:onClick(button, state)
	if state == "down" and self.m_Enabled then
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

	local f = function()
		showCursor(false)
	end
	addEventHandler("onClientRender", root, f)
	local timer = setTimer(function()
		removeEventHandler("onClientRender", root, f)
	end, 10000, 1)

end

function AntiClickSpam:reset()
	self.m_Counter = 0
end

function AntiClickSpam:setEnabled(state)
	self.m_Enabled = state
end

