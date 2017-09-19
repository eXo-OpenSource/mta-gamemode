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
WareMath.Operators = 
{
	"+", 
	"-",
	"x", 
	":" -- todo remove division that return rational numbers
}
function WareMath:constructor( super )
	self.m_Super = super
	self.m_Int1 = math.random(1,30)
	self.m_Int2 = math.random(1,30)
	local randomOperator= math.random(1,3)
	local operatorString = WareMath.Operators[randomOperator]
	WareMath.modeDesc = ("Wieviel ist %d "..operatorString.." %d?"):format(self.m_Int1, self.m_Int2)
	if randomOperator == 1 then
		self.m_RightAnswer = self.m_Int1 + self.m_Int2
	elseif randomOperator == 2 then 
		self.m_RightAnswer = self.m_Int1 - self.m_Int2
	elseif randomOperator == 3 then 
		self.m_Int1 = math.random(1,14)
		self.m_Int2 = math.random(1,10)
		self.m_RightAnswer = self.m_Int1 * self.m_Int2
		WareMath.modeDesc = ("Wieviel ist %d "..operatorString.." %d?"):format(self.m_Int1, self.m_Int2)
	end
	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, true)
	end
	self.m_WrongPlayers = {}
	self.m_Winners = {}
end

function WareMath:onChat(player, text, type)
	if tonumber(text) == self.m_RightAnswer then
		if not self.m_WrongPlayers[player] then
			self.m_Super:addPlayerToWinners(player)
			self.m_Winners[player] = true
		end
	else
		if not self.m_Winners[player] then
			self.m_WrongPlayers[player] = true
			player:triggerEvent("onClientWareFail")
		end
	end
end

function WareMath:destructor()
	for key, p in ipairs(self.m_Super.m_Players) do
		showChat(p, false)
	end
end
