
MostWanted = inherit(GUIForm3D)
inherit(Singleton, MostWanted)

function MostWanted:constructor()
	GUIForm3D.constructor(self, Vector3(1540.925, -1661.2, 15.85), Vector3(0, 0, 90), Vector2(4.2, 2.1), Vector2(1200,600), 10)
end

function MostWanted:onStreamIn(surface)
	self.m_WantedPlayer = {}
	self.m_WantedPlayerCount = 0
	self.m_Row = 0
	self.m_Column = 0
	self.m_Url = self:generateUrl()
	GUIWebView:new(0, 0, 1200, 600, self.m_Url, true, surface)
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

addEventHandler( "onClientRender", root,
    function()
        if isCursorShowing() then
            local screenx, screeny, worldx, worldy, worldz = getCursorPosition()
            local px, py, pz = getCameraMatrix()
            local hit, x, y, z, elementHit = processLineOfSight ( px, py, pz, worldx, worldy, worldz )

            if hit then
                dxDrawText( "Cursor at " .. x .. " " .. y .. " " ..  z, 200, 200 )
                if elementHit then
                    dxDrawText( "Hit element " .. getElementType(elementHit), 200, 220 )
                end
            end
        end
    end
)
