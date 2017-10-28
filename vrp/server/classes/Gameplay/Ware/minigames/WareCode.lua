-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Gameplay/Ware/minigames/WareCode.lua
-- *  PURPOSE:     WareCode class
-- *
-- ****************************************************************************
WareCode = inherit(Object)
WareCode.modeDesc = "Tippe folgendes: x"
WareCode.timeScale = 0.5

function WareCode:constructor( super )
	self.m_Super = super
	self.m_Amount = math.random(4, 10)
	self.m_RightAnswer = self:generate()
	self.m_Winners = {}
	self.m_WrongPlayers = {}
	WareCode.modeDesc = ("Tippe folgendes: %s"):format(self.m_RightAnswer)
end

function WareCode:onChat(player, text)
	if string.upper(text) == string.upper(self.m_RightAnswer) then
		if not self.m_WrongPlayers[player] then
			self.m_Super:addPlayerToWinners(player)
			self.m_Winners[player] = true
			outputChatBox("Richtig!", player, 0, 255, 0)
		end
	else
		if not self.m_Winners[player] then
			self.m_WrongPlayers[player] = true
			player:triggerEvent("onClientWareFail")
			outputChatBox("Falsch! (Richtig wäre: "..self.m_RightAnswer..")", player, 255, 0, 0)
		end
	end
	return
end

function WareCode:generate()
	local char = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","0","1","2","3","4","5","6","7","8","9"}
	local code = {}
	for i = 1, self.m_Amount do
		table.insert(code, string.upper(char[math.random(1, #char)]))
	end
	return table.concat(code)
end

function WareCode:destructor()

end
