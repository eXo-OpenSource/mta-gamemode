EasterEggArcade.Game = inherit(Singleton)	

local GAME_LEVELS = 
{
	{"I", "Strobe", 50, tocolor(255, 255, 0, 255)},
	{"II", "Pyccmex", 100, tocolor(255, 255, 0, 255)},
	{"III", "Fresher", 200,  tocolor(0, 255, 255, 255)},
	{"IV", "Larry", (9*6),  tocolor(255, 255, 255, 255), true},
	{"V", "Tony Chao", 300,  tocolor(255, 0, 100, 255)},
	{"VI", "Master SDM", 500,  tocolor(255, 0, 0, 255)},
	{"VII", "Finale Form Str0", 140,  tocolor(255, 255, 255, 255), true},
}

function EasterEggArcade.Game:constructor()
	self.m_Level = 1
end

function EasterEggArcade.Game:setLevel(level) 
	self.m_Level = level
end

function EasterEggArcade.Game:restart() 
	if self.m_Logic then 
		delete(self.m_Logic)
	end
	self.m_Logic = EasterEggArcade.GameLogic:new(GAME_LEVELS[self.m_Level][1], GAME_LEVELS[self.m_Level][2], GAME_LEVELS[self.m_Level][3], GAME_LEVELS[self.m_Level][4], GAME_LEVELS[self.m_Level][5])
end

function EasterEggArcade.Game:stop()
	if self.m_Logic then 
		if self.m_Logic:isGameWon() then 
			self.m_Level = self.m_Level + 1
			if self.m_Level <= #GAME_LEVELS then
				self.m_Logic:delete()
				self.m_Logic = EasterEggArcade.GameLogic:new(GAME_LEVELS[self.m_Level][1], GAME_LEVELS[self.m_Level][2], GAME_LEVELS[self.m_Level][3], GAME_LEVELS[self.m_Level][4], GAME_LEVELS[self.m_Level][5])
			else 
				self.m_Logic:delete()
				self.m_Logic = EasterEggArcade.GameLogic:new(GAME_LEVELS[1][1], GAME_LEVELS[1][2], GAME_LEVELS[1][3], GAME_LEVELS[1][4], GAME_LEVELS[1][5], true)
			end
		else 
			self.m_Logic:delete()
		end
	end
end

function EasterEggArcade.Game:getGameLogic()
	return self.m_Logic
end
