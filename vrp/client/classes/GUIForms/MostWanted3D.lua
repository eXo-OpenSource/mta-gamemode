
MostWanted = inherit(GUIForm3D)
inherit(Singleton, MostWanted)

function MostWanted:constructor()
	GUIForm3D.constructor(self, Vector3(1540.925, -1661.18, 15.9), Vector3(0, 0, 90), Vector2(3.73, 4.4), Vector2(900,1200), 50)
end

function MostWanted:onStreamIn(surface)
	self.m_WantedPlayer = {}
	self.m_WantedPlayerCount = 0
	self.m_Row = 0
	self.m_Column = 0
	self.m_Url = self:generateUrl()
	GUIWebView:new(0, 0, 900, 1200, self.m_Url, true, surface)
end

function MostWanted:generateUrl()
	local url = "http://exo-reallife.de/ingame/other/mostWanted.php?size=1"
	local i = 1
	for index, player in pairs(getElementsByType("player")) do
		if i < 8 then
			if player:getWantedLevel() >= 4 then
				url = url..("&name[%d]=%s&wanteds[%d]=%d&skin[%d]=%d"):format(i, player:getName(), i, player:getWantedLevel(), i, player:getModel())
				i = i+1
			end
		end
	end
	return url
end
