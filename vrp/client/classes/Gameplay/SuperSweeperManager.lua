-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Gameplay/SuperSweeperManager.lua
-- *  PURPOSE:     SuperSweeperManager
-- *
-- ****************************************************************************

SuperSweeperManager = inherit(Singleton)
SuperSweeperManager.CurrentGUI = false

addRemoteEvents{"superSweeperStartDeathScreen", "superSweeperSetZone"}

function SuperSweeperManager:constructor()
	self.m_DeathScreenActive = false
	self.m_RenderDeathScreen = bind(self.renderDeathScreen, self)
	self.m_EndDeathScreen = bind(self.endDeathScreen, self)
	self.m_RenderZone = bind(self.renderZone, self)
	self.m_RenderHealthBar = bind(self.renderHealthBar, self)

	self.m_KillerName = ""
	self.m_StartTime = 0

	self.m_ColShape = nil
	self.m_TextureReplacer = nil

	addEventHandler("superSweeperStartDeathScreen", root, bind(self.Event_onDeath, self))
	addEventHandler("superSweeperSetZone", root, bind(self.Event_setZone, self))
end

function SuperSweeperManager:destructor()
end

function SuperSweeperManager:renderZone()
	if self.m_ColShape then
		local position = self.m_ColShape.position
		local size = self.m_ColShape:getSize()

		for i = 1, 100 do
			-- North
			dxDrawLine3D(position.x, position.y + size.y, 10 * i, position.x + size.x, position.y + size.y, 10 * i, Color.Red, 10)

			-- South
			dxDrawLine3D(position.x, position.y, 10 * i, position.x + size.x, position.y, 10 * i, Color.Red, 10)

			-- East
			dxDrawLine3D(position.x + size.x, position.y + size.y, 10 * i, position.x + size.x, position.y, 10 * i, Color.Red, 10)

			-- West
			dxDrawLine3D(position.x, position.y + size.y, 10 * i, position.x, position.y, 10 * i, Color.Red, 10)
		end

	end
end

function SuperSweeperManager:renderHealthBar()
	if localPlayer.vehicle then
		local factorX, factorY = (1280 / screenWidth), (800 / screenHeight)

		dxDrawImage(screenWidth - 220 * factorX, 20 * factorY, 200 * factorX, 40 * factorY, "files/images/SuperSweeper/health_bar.png", 0 ,0, 0, tocolor(0, 0, 0, 255))
		local health = math.max(localPlayer.vehicle.health - 250, 0) / 750
		local p = -510 * (health ^ 2)
		local r, g = math.max(math.min(p + 255 * health + 255, 255), 0), math.max(math.min(p + 765 * health, 255), 0)
		dxDrawImageSection(screenWidth - 220 * factorX, 20 * factorY, 200 * factorX * health, 40 * factorY, 0, 0, 3821 * health, 600,"files/images/SuperSweeper/health_bar.png", 0, 0, 0, tocolor(r, g, 0, 255))

		dxDrawImage(screenWidth - 220 * factorX, (20 + 80) * factorY, 64 * factorX, 64 * factorY, "files/images/SuperSweeper/gps.png", 0, 0, 0, tocolor(0, 140, 255, 255))
	end
	-- 	dxDrawImage(sx-220*x12,20*y8,200*x12,300*y8,hud_rt)

	--[[
			dxDrawText(getElementData(lp,"Rocket") or "-",12,82,52,122,tocolor(0, 0, 0,255),2,"default-bold","left","center")
			dxDrawText(getElementData(lp,"Rocket") or "-",10,80,50,120,tocolor(0, 140, 255,255),2,"default-bold","left","center")
				dxDrawImage(50,80,40,40,"res/img/UI/Rocket.png",0,0,0,tocolor(0, 140, 255,255))

			dxDrawText(getElementData(lp,"Kills") or "-",52,82,192,122,tocolor(0, 0, 0,255),2,"default-bold","right","center")
			dxDrawText(getElementData(lp,"Kills") or "-",50,80,190,120,tocolor(0, 140, 255,255),2,"default-bold","right","center")
				dxDrawImage(110,80,40,40,"res/img/UI/Explo.png",0,0,0,tocolor(0, 140, 255,255))
	]]

	local cx, cy, cz, lx, ly, lz = getCameraMatrix()

	for k, player in ipairs(getElementsByType("player", true)) do
		if localPlayer.dimension == player.dimension and 
			localPlayer.interior == player.interior and 
			player.vehicle and 
			localPlayer ~= player then
			
			local position = player.position
			local distance = getDistanceBetweenPoints3D(position, Vector3(cx, cy, cz))

			if distance <= 60 then
				local sx, sy = getScreenFromWorldPosition(player.vehicle.position + Vector3(0, 0, 1.8))
				local alpha = 255 - (255 / 60 * distance)

				if isLineOfSightClear(position.x, position.y, position.z, lx, ly, lz, true, false, false) then
					if alpha <= 0 then
						alpha = 0
					end

					if sx and sy then
						dxDrawImage(sx - 100, sy - 20, 200, 40, "files/images/SuperSweeper/health_bar.png", 0 ,0 , 0, tocolor(0, 0, 0, alpha))
						local health = math.max(player.vehicle.health - 250, 0) / 750
						local p = -510 * (health ^ 2)
						local r, g = math.max(math.min(p + 255 * health + 255, 255), 0), math.max(math.min(p + 765 * health, 255), 0)
						dxDrawImageSection(sx - 100, sy - 20, 200 * health, 40, 0, 0, 3821 * health, 600, "files/images/SuperSweeper/health_bar.png", 0, 0, 0, tocolor(r, g, 0, alpha))
						
						dxDrawText(player.name, sx + 2, sy + 2 - 40, sx + 2, sy + 2 - 40, tocolor(0, 0, 0, alpha), 2, "default-bold", "center", "center")
						dxDrawText(player.name, sx, sy - 40, sx, sy - 40, tocolor(255, 255, 255, alpha), 2, "default-bold", "center", "center")
					end
				end
			end
		end
	end
end

function SuperSweeperManager:Event_setZone(colshape)
	self.m_ColShape = colshape

	if self.m_ColShape then
		HUDUI:getSingleton():hide()
		HUDSpeedo:getSingleton():hide()
		HUDRadar:getSingleton():hide()
		CustomF11Map:getSingleton():disable()
		Nametag:getSingleton():setDisabled(true)

		if self.m_TextureReplacer then
			delete(self.m_TextureReplacer)
		end
		
		self.m_TextureReplacer = StaticFileTextureReplacer:new("Other/trans.png", "shad_car")
		addEventHandler("onClientRender", root, self.m_RenderZone)
		addEventHandler("onClientRender", root, self.m_RenderHealthBar)
	else
		HUDUI:getSingleton():show()
		HUDSpeedo:getSingleton():show()
		HUDRadar:getSingleton():show()
		CustomF11Map:getSingleton():enable()
		Nametag:getSingleton():setDisabled(false)
		if self.m_TextureReplacer then
			delete(self.m_TextureReplacer)
		end
		removeEventHandler("onClientRender", root, self.m_RenderZone)
		removeEventHandler("onClientRender", root, self.m_RenderHealthBar)
	end
end

function SuperSweeperManager:Event_onDeath(killer)
	if not self.m_DeathScreenActive then
		self.m_DeathScreenActive = true
		setGameSpeed(0.3)
		playSound("files/audio/wasted.mp3")
		self.m_StartTime = getTickCount()
		
		if killer and killer.type and killer.type == "player" and killer ~= localPlayer then
			self.m_KillerName =  killer.name .. " pulverized you"
		elseif killer and (killer == "Zone" or killer == "Water") then
			self.m_KillerName = "Killed by the " .. (killer == "Zone" and "zone" or "water")
		else
			self.m_KillerName = "Suicide..."
		end

		addEventHandler("onClientRender", root, self.m_RenderDeathScreen)
		showChat(false)

		setTimer(self.m_EndDeathScreen, 9000, 1)
	end
end

function SuperSweeperManager:endDeathScreen()
	removeEventHandler("onClientRender", root, self.m_RenderDeathScreen)
	setGameSpeed(1)
	self.m_DeathScreenActive = false
	showChat(true)
end

function SuperSweeperManager:renderDeathScreen()
	local progress = (getTickCount() - self.m_StartTime) / 1000

	local lineAlpha = interpolateBetween(0, 0, 0, 150, 0, 0, progress, "Linear")
	local recAlpha = interpolateBetween(0, 0, 0, 255, 0, 0, progress, "OutQuad", 10000)

	dxDrawImage(0, 0, screenWidth, screenHeight, "files/images/Deathmatch/death_round.png", 0, 0, 0, tocolor(255,255,255,recAlpha))
	dxDrawImage(0, screenHeight*0.4, screenWidth, screenHeight*0.3, "files/images/Deathmatch/death_img.png", 0, 0, 0, tocolor(255, 255, 255, lineAlpha))

	dxDrawText(_"Wasted", screenWidth*0, screenHeight*0.4, screenWidth*1, screenHeight*0.7, tocolor(255,0,0,255), screenWidth/screenHeight*2, "pricedown", "center", "center")
	dxDrawText(self.m_KillerName, screenWidth*0, screenHeight*0.525, screenWidth*1, screenHeight*0.7, tocolor(255,255,255,255), screenWidth/screenHeight*1, "pricedown", "center", "center")
end
