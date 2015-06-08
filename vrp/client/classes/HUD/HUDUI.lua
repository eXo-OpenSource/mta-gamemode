-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/HUD/HUIUI.lua
-- *  PURPOSE:     HUD UI class
-- *
-- ****************************************************************************
HUDUI = inherit(Singleton)

function HUDUI:constructor()
	self.m_IsVisible = false
	self.m_Font = VRPFont(70)

	self.m_MunitionProgress = 0

	showPlayerHudComponent("all",false)
	showPlayerHudComponent("crosshair",true)

	self.m_RenderHandler = bind(self.draw,self)

	addEventHandler("onClientRender",root,self.m_RenderHandler, true, "high+999")
end

function HUDUI:show()
	self.m_IsVisible = true
end

function HUDUI:hide()
	self.m_IsVisible = false
end

function HUDUI:draw()
	if not self.m_IsVisible then
		return
	end
	local f = math.floor

	dxDrawRectangle(screenWidth-0.195*screenWidth,0.04*screenHeight,0.195*screenWidth,0.092*screenHeight,tocolor(0,0,0,150))
	dxDrawText("$"..localPlayer:getMoney(), screenWidth-0.14*screenWidth, 0.097*screenHeight/2, 0.195*screenWidth, 0.097*screenHeight, Color.White, 1, self.m_Font)

	local munitionWindowActive = true

	if NO_MUNITION_ITEMS[getPedWeapon(localPlayer)] then
		munitionWindowActive = false
	end

	-- TODO: Make frame independent
	if munitionWindowActive and self.m_MunitionProgress < 1 then
		self.m_MunitionProgress = self.m_MunitionProgress + 0.07
	elseif not munitionWindowActive and self.m_MunitionProgress > 0 then
		self.m_MunitionProgress = self.m_MunitionProgress - 0.07
	end

	-- Weapon-Window
	local addX = math.floor(interpolateBetween(0,0,0,0.156*screenWidth,0,0,self.m_MunitionProgress,"OutBack"))
	dxDrawRectangle(screenWidth-(0.25*screenWidth+addX),0.04*screenHeight,0.05*screenWidth,0.092*screenHeight,tocolor(0,0,0,150))

	local weaponIconPath = WeaponIcons[localPlayer:getWeapon()]
	if weaponIconPath then
		if munitionWindowActive then
			dxDrawImage(f(screenWidth-(0.25*screenWidth+addX)+(0.05*screenWidth/2)-(0.033*screenWidth/2)), f(0.0465*screenHeight+(0.09*screenHeight/2)-(0.059*screenHeight/2)), f(0.033*screenWidth), f(0.059*screenHeight), weaponIconPath)
		else
			dxDrawImage(f(screenWidth-(0.25*screenWidth+addX)+(0.05*screenWidth/2)-(0.033*screenWidth/2)), f(0.0465*screenHeight+(0.09*screenHeight/2)-(0.059*screenHeight/2)), f(0.033*screenWidth), f(0.059*screenHeight), weaponIconPath)
		end
	end

	-- Munition-Window
	local addY = interpolateBetween(0,0,0,0.14*screenHeight,0,0,self.m_MunitionProgress,"Linear")
	dxDrawRectangle(screenWidth-0.351*screenWidth,-0.1*screenHeight+addY,0.153*screenWidth,0.092*screenHeight,tocolor(0,0,0,150))
	local inClip = getPedAmmoInClip(localPlayer)
	local totalAmmo = getPedTotalAmmo(localPlayer)
	local sMunition = ("%d - %d"):format(inClip,totalAmmo-inClip)
	dxDrawText(sMunition,screenWidth-0.276*screenWidth-(dxGetTextWidth(sMunition,1,self.m_Font)/2),-85+addY,0.153*screenWidth,0.092*screenHeight,Color.White,1,self.m_Font)

	-- Karmabar
	local karma = localPlayer:getKarma() or 0
	dxDrawRectangle(screenWidth-0.25*screenWidth, 0.14*screenHeight, 0.195*screenWidth, 0.0425*screenHeight,karma >= 0 and tocolor(0,50,0,220) or tocolor(50,0,0,220))
	if karma >= 0 then
		dxDrawRectangle(screenWidth-0.25*screenWidth,0.14*screenHeight,(0.195*screenWidth)*karma/MAX_KARMA_LEVEL,0.0425*screenHeight,tocolor(75,160,75,220))
	else
		dxDrawRectangle(screenWidth-0.25*screenWidth,0.14*screenHeight,(0.195*screenWidth)*-karma/MAX_KARMA_LEVEL,0.0425*screenHeight,tocolor(160,75,75,220))
	end
	local karma = (karma >= 0 and "+" or "")..math.floor(karma)
	dxDrawText(karma,(screenWidth-0.25*screenWidth)+((0.195*screenWidth)/2-(dxGetTextWidth(karma, 0.5, self.m_Font)/2)),0.145*screenHeight,0,0,Color.White,0.5,self.m_Font)

	-- Wantedlevel
	dxDrawRectangle(screenWidth-0.05*screenWidth,0.14*screenHeight,0.05*screenWidth,0.09*screenHeight,tocolor(0,0,0,150))
	dxDrawImage    (screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-(0.025*screenWidth/2), 0.145*screenHeight+(0.09*screenHeight/2)-36, 0.025*screenWidth,0.044*screenHeight, "files/images/HUD/wanted.png", 0, 0, 0, getPlayerWantedLevel() > 0 and Color.Yellow or Color.White)
	dxDrawText     (getPlayerWantedLevel(),screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-5,0.148*screenHeight+(0.09*screenHeight/2),0,0,Color.White,0.5,self.m_Font)

	self:drawLevelRect()
end

function HUDUI:drawLevelRect()
	local f = math.floor

	-- Background
	dxDrawRectangle(screenWidth - screenWidth*0.195, 0, screenWidth*0.2, screenHeight*0.035, tocolor(0, 0, 0, 120))
	dxDrawRectangle(screenWidth - screenWidth*0.195, 0, screenWidth*0.2, 5, Color.DarkLightBlue)

	-- Joblevel
	dxDrawImage(f(screenWidth*0.81), f(screenHeight*0.0095), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/JobLevel.png")
	dxDrawText(localPlayer:getJobLevel(), screenWidth*0.83, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")

	-- Weaponlevel
	dxDrawImage(f(screenWidth*0.855), f(screenHeight*0.0105), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/WeaponLevel.png")
	dxDrawText(localPlayer:getWeaponLevel(), screenWidth*0.875, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")

	-- Vehiclelevel
	dxDrawImage(f(screenWidth*0.905), f(screenHeight*0.0105), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/VehicleLevel.png")
	dxDrawText(localPlayer:getVehicleLevel(), screenWidth*0.925, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")

	-- Skinlevel
	dxDrawImage(f(screenWidth*0.955), f(screenHeight*0.0105), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/SkinLevel.png")
	dxDrawText(localPlayer:getSkinLevel(), screenWidth*0.975, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")
end
