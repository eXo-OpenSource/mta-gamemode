
MostWanted = inherit(GUIForm3D)
inherit(Singleton, MostWanted)

local DRAWN_WANTEDS = {4, 5, 6}

function MostWanted:constructor()
	GUIForm3D.constructor(self, Vector3(1540.925, -1661.18, 15.24), Vector3(0, 0, 90), Vector2(3.73, 5), Vector2(900,1200), 5)
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
	local count = self.m_WantedPlayerCount

	self.m_WantedPlayer[player] = {}
	self.m_WantedPlayer[player]["wanted"] = GUIImage:new(10+self.m_Column*175, 10+self.m_Row*175, 40, 30, "files/images/Nametag/w"..player:getWantedLevel()..".png", self.m_Surface)
	self.m_WantedPlayer[player]["name"] = GUILabel:new(45+self.m_Column*175, 10+self.m_Row*175, 150, 30,player:getName(), self.m_Surface)
	self.m_WantedPlayer[player]["skin"] = GUIWebView:new(30+self.m_Column*175, 10+self.m_Row*175, 170, 100, "http://exo-reallife.de/ingame/skinPreview/skinPreview.php?skin="..player:getModel(), true, self.m_Surface)

	self.m_WantedPlayerCount = count + 1

	if count == 4 or count == 9 then
		self.m_Row = 0
		self.m_Column = self.m_Column+1
	else
		self.m_Row = self.m_Row+1
	end
end
