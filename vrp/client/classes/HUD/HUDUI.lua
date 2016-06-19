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
	self.m_UIMode = core:get("HUD", "UIStyle", UIStyle.vRoleplay)
	self.m_Enabled = core:get("HUD", "showUI", true)
	self.m_RedDot = core:get("HUD", "reddot", false)
	self.m_DefaultHealhArmor = core:get("HUD", "defaultHealthArmor", true)

	self.m_MunitionProgress = 0

	if self.m_UIMode == UIStyle.Default and self.m_Enabled then
		showPlayerHudComponent("all", true)
		showPlayerHudComponent("radar", false)
	else
		showPlayerHudComponent("all", false)
		showPlayerHudComponent("crosshair", true)
	end

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
	if not self.m_Enabled then return end
	if not self.m_IsVisible then return end

	if self.m_UIMode == UIStyle.vRoleplay then
		self:drawDefault()
		if self.m_DefaultHealhArmor == true then
			self:drawDefaultHealthArmor()
			self:drawKarmaBar(0.0325*screenHeight, 1.2)
		else
			self:drawKarmaBar(0.0425*screenHeight, 1.6)
		end
	elseif self.m_UIMode == UIStyle.eXo then
		self:drawExo()
	elseif self.m_UIMode == UIStyle.Default then
		return
	end

	if self.m_RedDot == true then
		self:drawRedDot()
	end

	if localPlayer:getPublicSync("AFK") == true then
		self:drawAFK()
	end
end

function HUDUI:setUIMode(uiMode)
	if uiMode == UIStyle.Default then
		showPlayerHudComponent("all", true)
		showPlayerHudComponent("radar", false)
	elseif self.m_UIMode == UIStyle.Default then
		showPlayerHudComponent("all", false)
		showPlayerHudComponent("crosshair", true)
	end

	self.m_UIMode = uiMode
end

function HUDUI:setEnabled(state)
	self.m_Enabled = state

	if self.m_UIMode == UIStyle.Default then
		if not state then
			showPlayerHudComponent("all", false)
			showPlayerHudComponent("crosshair", true)
		else
			showPlayerHudComponent("all", true)
			showPlayerHudComponent("radar", false)
		end
	end
end

function HUDUI:toggleReddot(state)
	self.m_RedDot = state
end

function HUDUI:toggleDefaultHealthArmor(state)
	self.m_DefaultHealhArmor = state
end

function HUDUI:isEnabled()
	return self.m_Enabled
end

function HUDUI:drawLevelRect()
	local f = math.floor

	-- Background
	dxDrawRectangle(screenWidth - screenWidth*0.195, 0, screenWidth*0.2, screenHeight*0.035, tocolor(0, 0, 0, 120))
	dxDrawRectangle(screenWidth - screenWidth*0.195, 0, screenWidth*0.2, 5, Color.LightBlue)

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

function HUDUI:drawDefault()
	local f = math.floor

	dxDrawRectangle(screenWidth-0.195*screenWidth,0.04*screenHeight,0.195*screenWidth,0.092*screenHeight,tocolor(0,0,0,150))
	dxDrawText("$"..localPlayer:getMoney(), screenWidth-0.14*screenWidth, 0.097*screenHeight/2, screenWidth-screenWidth*0.007, 0.097*screenHeight, Color.White, 1, self.m_Font, "right")

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
	dxDrawText(sMunition,screenWidth-0.276*screenWidth-(dxGetTextWidth(sMunition,1,self.m_Font)/2), -85+addY+screenHeight*0.015, 0.153*screenWidth,0.092*screenHeight,Color.White,1,self.m_Font)


	-- Wantedlevel
	dxDrawRectangle(screenWidth-0.05*screenWidth,0.14*screenHeight,0.05*screenWidth,0.105*screenHeight,tocolor(0,0,0,150))
	dxDrawImage    (screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-(0.025*screenWidth/2), 0.155*screenHeight+(0.09*screenHeight/2)-36, 0.025*screenWidth,0.044*screenHeight, "files/images/HUD/wanted.png", 0, 0, 0, getPlayerWantedLevel() > 0 and Color.Yellow or Color.White)
	dxDrawText     (getPlayerWantedLevel(),screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-5,0.16*screenHeight+(0.09*screenHeight/2),0,0,Color.White,0.5,self.m_Font)

	self:drawLevelRect()
end

function HUDUI:drawKarmaBar(height, fontSize)
	local left, top = screenWidth-0.25*screenWidth, 0.14*screenHeight
	local width = 0.195*screenWidth

	local karma = math.floor(localPlayer:getKarma()) or 0

	local barWidth = width*(math.abs(karma) <= 150 and math.abs(karma) or 150)/MAX_KARMA_LEVEL/2
	if karma == 0 then
		dxDrawRectangle(left, top, width/2-1, height, tocolor(0,0,0,150))
		dxDrawRectangle(left+width/2+1, top, width/2-1, height, tocolor(0,0,0,150))
		dxDrawText("Karma neutral", left, top, left+width, top+height, Color.White, fontSize, "default-bold", "center", "center")
	elseif karma > 0 then
		dxDrawRectangle(left, top, width/2-1, height, tocolor(0,0,0,150))
		dxDrawRectangle(left+width/2+1, top, width/2-1, height, tocolor(0,50,0,220))
		dxDrawRectangle(left+width/2+1, top, barWidth, height, tocolor(75,160,75,220))
		dxDrawText("Karma: +"..math.abs(karma), left+width/2+1, top, left+width, top+height, Color.White, fontSize, "default-bold", "center", "center")
	else
		dxDrawRectangle(left, top, width/2-1, height, tocolor(50,0,0,220))
		dxDrawRectangle(left+width/2+1, top, width/2-1, height, tocolor(0,0,0,150))
		dxDrawRectangle((left + width/2)-barWidth-1, top, barWidth, height, tocolor(160,75,75,220))
		dxDrawText("Karma: -"..math.abs(karma), left, top, left+width/2-1, top+height, Color.White, fontSize, "default-bold", "center", "center")
	end
end

function HUDUI:drawDefaultHealthArmor()
	local health = localPlayer:getHealth()
	--local color = tocolor(0,150,50) -- Todo find better solution
	local color = tocolor(255-(health+150)*(255/300), (health+150)*(255/300), -math.abs(health*(127/150))+127)
	local blink = false
	if health < 50 then
		--color = tocolor(255,128,50)
		if health < 25 then
			--color = tocolor(150,0,0)
			if health < 15 then blink = true end
		end
	end

	local left, top = screenWidth-0.25*screenWidth, 0.175*screenHeight
	local width, height = 0.195*screenWidth, 0.0325*screenHeight

	dxDrawRectangle(left, top, width, height,tocolor(0,0,0,150))
	if blink == true then
		if math.floor(getRealTime().timestamp/2) == getRealTime().timestamp/2 then
			dxDrawRectangle(left, top, width*health/100, height, color)
		end
	else
		dxDrawRectangle(left, top, width*health/100, height, color)
	end

	health = "Leben: "..math.floor(health).." %"
	dxDrawText(health, left , top, left+width, top+height, Color.White, 1.2, "default-bold", "center", "center")

	top =  0.21*screenHeight

	local armor = localPlayer:getArmor()
	dxDrawRectangle(left, top, width, height, tocolor(0, 0, 0, 150))
	dxDrawRectangle(left, top, width*armor/100, height, tocolor(0, 0, 128))

	local armor = "Schutzweste: "..math.floor(armor).." %"
	dxDrawText(armor, left , top, left+width, top+height, Color.White, 1.2, "default-bold", "center", "center")
end

function HUDUI:getZone()
	local pos = localPlayer:getPosition()
	local zone1 = getZoneName(pos)
	local zone2 = getZoneName(pos,true)
	local zone = ""
	if string.len(zone1) > 12 then
		zone = zone1
	else
		zone = zone1.." - "..zone2
	end
	if zone == "Unknown - Unknown" then zone = "Kein GPS-Signal" end
	return zone
end

function HUDUI:drawExo()
	sx_g = screenWidth
	local sx = screenWidth
	if sx_g > 1400 then sx_g = 1400 end

	local width = math.floor(sx_g*0.22)
	local height = math.floor(sx_g*0.22)
	local r_os = 1
	local hudStartX = math.floor(screenWidth-width-r_os)
	local lebensanzeige = getElementHealth(localPlayer)
	local progressBarSpeed = 24000

		if not start_count then start_count = getTickCount() end
		if not end_count then end_count = start_count + progressBarSpeed end


		local now = getTickCount()
		local elapsed = now - start_count
		local duration = end_count - start_count
		local prog = elapsed / duration
		local scroll_ = interpolateBetween(207,0,0,-207,0,0,prog,'Linear')

		dxDrawImage(hudStartX,1,math.floor(width),math.floor(height),'files/images/HUD/exo/bg.png')
		dxDrawText (localPlayer:getMoney(),screenWidth-width*0.7-r_os,width*0.265,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default-bold" ) --Money
		dxDrawText (getRealTime().hour..":"..getRealTime().minute,screenWidth-width*0.22-r_os,width*0.265,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default" ) -- Clock
		dxDrawText (self:getZone(),screenWidth-width*0.7-r_os,width*0.372,width,height, tocolor ( 255, 255, 255, 255 ), 1.02*width*0.0039, "default" ) -- ORT
		--dxDrawText (getSpielzeit(),screenWidth-width*0.55-r_os,width*0.765,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default" ) --
		--dxDrawText (getLevel(),screenWidth-width*0.15-r_os,width*0.765,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default" ) --

		local wanted = localPlayer:getWantedLevel()
		if wanted > 0 then dxDrawImage(screenWidth-width*0.146-r_os,width*0.86,width*0.1,height*0.1,"files/images/HUD/exo/wanted.png") end
		if wanted > 1 then dxDrawImage(screenWidth-width*0.256-r_os,width*0.86,width*0.1,height*0.1,"files/images/HUD/exo/wanted.png") end
		if wanted > 2 then dxDrawImage(screenWidth-width*0.36-r_os,width*0.86,width*0.1,height*0.1,"files/images/HUD/exo/wanted.png") end
		if wanted > 3 then dxDrawImage(screenWidth-width*0.47-r_os,width*0.86,width*0.1,height*0.1,"files/images/HUD/exo/wanted.png") end
		if wanted > 4 then dxDrawImage(screenWidth-width*0.58-r_os,width*0.86,width*0.1,height*0.1,"files/images/HUD/exo/wanted.png") end
		if wanted > 5 then dxDrawImage(screenWidth-width*0.69-r_os,width*0.86,width*0.1,height*0.1,"files/images/HUD/exo/wanted.png") end

		local b_x = 100

		b_x = localPlayer:getArmor()/100
		dxDrawImageSection(hudStartX+width*0.3162,height*0.478,sx*0.108*b_x,sx*0.0069,scroll_,0,207*b_x,15,'files/images/HUD/exo/blue_b.png',0,0,0,tocolor(255,255,255,200)) -- erster Balken

		b_x = localPlayer:getHealth()/100
		dxDrawImageSection(hudStartX+width*0.3162,height*0.576,sx*0.108*b_x,sx*0.0069,scroll_,0,207*b_x,15,'files/images/HUD/exo/red_b.png',0,0,0,tocolor(255,255,255,200)) -- zweiter Balken

		b_x = localPlayer:getKarma()/150
		dxDrawImageSection(hudStartX+width*0.3162,height*0.677,sx*0.108*b_x,sx*0.0069,scroll_,0,207*b_x,15,'files/images/HUD/exo/green_b.png',0,0,0,tocolor(255,255,255,200))

		if prog >= 1 then
			start_count = getTickCount()
			end_count = start_count + progressBarSpeed
		end
		local r,g,b,a = 0,0,0,200

		if lebensanzeige > 0 and lebensanzeige < 1 then lebensanzeige = 1 end
		lebensanzeige = math.floor(lebensanzeige)

		dxDrawText ("SCHUTZWESTE: "..math.floor(getPedArmor(localPlayer)).."%",screenWidth-width*0.5-r_os,width*0.475,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","right" ) --Money
		dxDrawText ("LEBEN: "..lebensanzeige.."%",screenWidth-width*0.5-r_os,width*0.58,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","right" ) --Money
		dxDrawText ("KARMA: "..math.floor(localPlayer:getKarma()).."%",screenWidth-width*0.5-r_os,width*0.675,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","right" ) --Money

		dxDrawImage(screenWidth-width*0.3-r_os,(sx*0),sx*0.04,sx*0.04, WeaponIcons[localPlayer:getWeapon()])
		
		dxDrawText ( math.floor(localPlayer:getPlayTime()/60).." Std.",hudStartX+width*0.5, height*0.77,width*0.5, height*0.08, tocolor ( 255,255,255,255 ), 0.9*width*0.0039, "sans","left","top" ) --Money

		dxDrawText ( math.floor(localPlayer:getLevel()),hudStartX+width*0.9, height*0.77,width*0.5, height*0.08, tocolor ( 255,255,255,255 ), 0.9*width*0.0039, "sans","left","top" ) --Money

		
		if getPedWeapon(localPlayer) > 9  then
				firestate = getHudFirestate()
				dxDrawText(getPedTotalAmmo ( localPlayer)-getPedAmmoInClip(localPlayer)..'-'..getPedAmmoInClip(localPlayer),screenWidth-width*0.57-r_os,width*0.14,width,height,tocolor(255,255,255,255),0.7,'pricedown')
				dxDrawText(firestate,screenWidth-width*0.57-r_os,width*0.07,width,height,tocolor(255,255,255,255),0.8*width*0.0039,'pricedown')

				local ammoTyp = getElementData ( localPlayer, "curAmmoTyp" )
				if not isElementInWater(localPlayer) and ammoTyp and ammoTyp > 0 and spezMuniWaffen[getPedWeapon(localPlayer)] then
					local ammo = specialAmmoName[ammoTyp]
					dxDrawRectangle ((screenWidth-width)*1.05,sx*0.218,sx*0.4,sx*0.02, tocolor ( 255,0,0,125 ))
					dxDrawText ("Spezialmunition: "..ammo.."",screenWidth-width*0.687-r_os,sx*0.22,screenWidth*0.99,sx, tocolor ( 255,255,255,255 ), 1.2*width*0.0039, "default","right")
				end
		end

		if isElementInWater(localPlayer) then
			dxDrawRectangle ((screenWidth-width)*1.05,sx*0.218,sx*0.4,sx*0.02, tocolor ( 50,200,255,125 ))
			dxDrawText ("Sauerstoff: "..math.floor((getPedOxygenLevel(localPlayer)*100)/2500).."%",sx*0.9-r_os,sx*0.22,screenWidth*0.99,sx, tocolor ( 255,255,255,255 ), 1.2*width*0.0039, "default","right")
		end
end

function HUDUI:drawRedDot()
	local reddotSlots = {2, 3, 4, 5, 6, 7}
	if reddotSlots[getPedWeaponSlot(localPlayer)] then
		if getPedControlState(localPlayer, "aim_weapon" ) then
			local x1, y1, z1 = getPedWeaponMuzzlePosition(localPlayer)
			local x2, y2, z2 = getPedTargetEnd(localPlayer)
			local x3, y3, z3 = getPedTargetCollision(localPlayer)
			if x3 then
				dxDrawLine3D(x1, y1, z1, x3, y3, z3, tocolor(200, 0, 0, 200), 2, false)
			else
				dxDrawLine3D(x1, y1, z1, x2, y2, z2, tocolor(200, 0, 0, 200), 2, false)
			end
		end
	end
end

function HUDUI:drawAFK()
	dxDrawText ("- AFK - ",0,0,screenWidth, 100,  Color.Orange, 5, "sans","center" )
end
