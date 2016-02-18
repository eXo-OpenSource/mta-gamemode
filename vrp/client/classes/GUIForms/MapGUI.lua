-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/MapGUI.lua
-- *  PURPOSE:     Teleportation map GUI
-- *
-- ****************************************************************************
MapGUI = inherit(GUIForm)
inherit(Singleton, MapGUI)

function MapGUI:constructor(func)
	local size = screenHeight*0.7
	GUIForm.constructor(self, screenWidth/2-size/2, screenHeight/2-size/2, size, size+screenHeight*0.03)
	self.m_Callback = func

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Karte", true, true, self)
	self.m_Map = GUIImage:new(self.m_Width*0.02, self.m_Height*0.06, self.m_Width*0.96, self.m_Width*0.96, "files/images/Radar_GTA/Radar.jpg", self.m_Window)

	self.m_Map.onLeftDoubleClick = bind(self.Map_DoubleClick, self)
end

function MapGUI:Map_DoubleClick(element, absX, absY)
	local mapX, mapY = absX - self.m_Map.m_PosX - self.m_PosX, absY - self.m_Map.m_PosY - self.m_PosY
	local mapWidth, mapHeight = self.m_Map:getSize()

	-- Convert map to world position
	local worldX = mapX * (6000 / mapWidth) - 3000
	local worldY = -(mapY * (6000 / mapHeight) - 3000)
	local hit, hitX, hitY, worldZ = processLineOfSight(worldX, worldY, 3000, worldX, worldY, -3000)
	if self.m_Callback then
		self.m_Callback(worldX, worldY, worldZ or 20)
	end
	delete(self)
end
