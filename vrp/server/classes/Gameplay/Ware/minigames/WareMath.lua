-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareMath.lua
-- *  PURPOSE:     WareMath class
-- *
-- ****************************************************************************
WareMath = inherit(Object)
WareMath.modeDesc = "Wieviel ist x + x?"
WareMath.timeScale = 0.8

function WareMath:constructor( super )
	self.m_Super = super
	self.m_Int1 = math.random(1,30)
	self.m_Int2 = math.random(1,30)
	WareMath.modeDesc = ("Wieviel ist %d + %d?"):format(self.m_Int1, self.m_Int2)
	self.m_RightAnswer = self.m_Int1 + self.m_Int2
	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, true)
	end
end

function WareMath:onChat(player, text, type)
	if tonumber(text) == self.m_RightAnswer then
		self.m_Super:addPlayerToWinners(player)
	else
		player:sendError("Falsche Antwort!")
	end
end

function WareMath:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, false)
	end
end
