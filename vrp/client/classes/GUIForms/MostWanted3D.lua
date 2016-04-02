
MostWanted = inherit(GUIForm3D)
inherit(Singleton, MostWanted)

local DRAWN_WANTEDS = {4, 5, 6}

function MostWanted:constructor()
	GUIForm3D.constructor(self, Vector3(1540.925, -1661.18, 15.24), Vector3(0, 0, 90), Vector2(3.73, 5), Vector2(900,1200), 50)
end

function MostWanted:onStreamIn(surface)
	self.m_Surface = self:getSurface()
	self.m_WantedPlayer = {}
	self.m_WantedPlayerCount = 0
	self.m_Row = 0
	self.m_Column = 0
	self:refresh()
end

function MostWanted:refresh()
	for index, player in pairs(getElementsByType("player")) do
	--	if DRAWN_WANTEDS[player:getWantedLevel()] then
		if player:getWantedLevel() > 0 then
			self:outputWantedPlayer(player)
		end
	end
end

function MostWanted:outputWantedPlayer(player)
	if self.m_WantedPlayerCount < 8 then
		self.m_WantedPlayer[player] = GUIWebView:new(10+self.m_Column*210, 10+self.m_Row*270, 200, 260, "http://exo-reallife.de/ingame/other/mostWanted.php?name="..player:getName().."&wanteds="..player:getWantedLevel().."&skin="..player:getModel(), true, self.m_Surface)
		self.m_WantedPlayerCount = self.m_WantedPlayerCount + 1

		if self.m_WantedPlayerCount == 4 or self.m_WantedPlayerCount == 8 then
			self.m_Row = 0
			self.m_Column = self.m_Column+1
		else
			self.m_Row = self.m_Row+1
		end
	end
end
