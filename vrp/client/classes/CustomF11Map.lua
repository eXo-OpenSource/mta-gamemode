-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/CustomF11Map.lua
-- *  PURPOSE:     Custom f11 map class
-- *
-- ****************************************************************************
CustomF11Map = inherit(Singleton)

function CustomF11Map:constructor()
	self.m_RenderFunc = bind(self.draw, self)
	self.m_Visible = false
	self.m_Enabled = false
	
	bindKey("f11", "down",
		function()
			if not self.m_Enabled then
				return
			end
		
			self.m_Visible = not self.m_Visible
			
			if self.m_Visible then
				addEventHandler("onClientRender", root, self.m_RenderFunc)
			else
				removeEventHandler("onClientRender", root, self.m_RenderFunc)
			end
		end
	)
end

function CustomF11Map:destructor()
	self:disable()
end

function CustomF11Map:enable()
	toggleControl("radar", false)
	forcePlayerMap(false)
	self.m_Enabled = true
end

function CustomF11Map:disable()
	toggleControl("radar", true)
	
	self.m_Enabled = false
	self.m_Visible = false
	removeEventHandler("onClientRender", root, self.m_RenderFunc)
end

function CustomF11Map:draw()
	local height = screenHeight
	local mapPosX, mapPosY = screenWidth/2-height/2, 0

	-- Draw map
	dxDrawImage(mapPosX, mapPosY, height, height, "files/images/Radar_Monochrome/Radar.jpg")
	
	-- Draw local player blip
	local rotX, rotY, rotZ = getElementRotation(localPlayer)
	local posX, posY = getElementPosition(localPlayer)
	local mapX, mapY = CustomF11Map.worldToMapPosition(posX, posY)
	dxDrawImage(mapPosX + mapX - 8, mapPosY + mapY - 8, 16, 16, "files/images/Radar_Monochrome/Blips/LocalPlayer.png", -rotZ)
	
	-- Draw blips
    for i, v in ipairs(Blip.Blips) do
        local mapX, mapY = CustomF11Map.worldToMapPosition(v.m_WorldX, v.m_WorldY)
        dxDrawImage(mapPosX + mapX - 8, mapPosY + mapY - 8, 16, 16, v.m_ImagePath, 0)
    end
end

function CustomF11Map.worldToMapPosition(worldX, worldY)
	local height = screenHeight
	local mapX = worldX / ( 6000/height) + height/2
	local mapY = worldY / (-6000/height) + height/2
	return mapX, mapY
end
