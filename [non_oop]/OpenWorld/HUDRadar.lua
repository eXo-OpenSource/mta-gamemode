HUDRadar = {}
self = {}

Color = {
	Black = tocolor(0, 0, 0, 255);
	Red = tocolor(255, 0, 0, 255)
}

function HUDRadar.constructor()
	--TransferManager:getSingleton():requestFilesAsOnce({"files/images/HUD/Radar.png"}, bind(HUDHunger.load, self))
	
	showPlayerHudComponent("radar", false)
	
	self.m_Width, self.m_Height = 394, 224
	self.m_Zoom = 1
	self.m_ImageWidth, self.m_ImageHeight = 6000, 6000 --1536, 1536
	HUDRadar.load()
end
addCommandHandler("testrad", HUDRadar.constructor)

function HUDRadar.load()
	addEventHandler("onClientRender", root, HUDRadar.drawThis)
end

function HUDRadar.drawThis()
	local screenWidth, screenHeight = guiGetScreenSize()
	-- Draw the rectangle (the border)
	dxDrawRectangle(20, screenHeight-250, 400, 230, Color.Black)
	
	-- Draw the map (map size: 1536px*1536px)
	local _, _, rotation = getElementRotation(localPlayer)
	local posX, posY, posZ = getElementPosition(localPlayer)
	local mapX = posX / (6000 /self.m_ImageWidth)  + self.m_ImageWidth/2  - self.m_Width/self.m_Zoom/2
	local mapY = posY / (-6000/self.m_ImageHeight) + self.m_ImageHeight/2 - self.m_Height/self.m_Zoom/2
	
	dxDrawImageSection(23, screenHeight-247, self.m_Width, self.m_Height, mapX, mapY, self.m_Width/self.m_Zoom, self.m_Height/self.m_Zoom, "Radar.jpg")
	
	-- Draw the player blip
	dxDrawImage(20+self.m_Width/2-16, screenHeight-247+self.m_Height/2-16, 32, 32, "left.png", -rotation)
	--dxDrawRectangle(20+self.m_Width/2, screenHeight-247+self.m_Height/2, 5, 5, Color.Red)
end

addCommandHandler("zoom",
	function(cmd, zoom)
		zoom = tonumber(zoom)
		if zoom then
			self.m_Zoom = zoom
		end
	end
)