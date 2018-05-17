EasterEggArcade.Game = inherit(Singleton)

function EasterEggArcade.Game:constructor()
	self.m_Logic = EasterEggArcade.GameLogic:new()
end

function EasterEggArcade.Game:restart() 
	if self.m_Logic then 
		delete(self.m_Logic)
	end
	self.m_Logic = EasterEggArcade.GameLogic:new()
end

function EasterEggArcade.Game:stop()
	if self.m_Logic then 
		self.m_Logic:delete()
	end
end

function EasterEggArcade.Game:getGameLogic()
	return self.m_Logic
end
