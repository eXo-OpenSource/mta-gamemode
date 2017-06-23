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
	self.m_Scale = core:get("HUD", "hudScale", 1)
	self.m_DefaultHealhArmor = core:get("HUD", "defaultHealthArmor", true)
	local design = tonumber(core:getConfig():get("HUD", "RadarDesign"))
	local enabled = core:get("HUD", "showRadar")
	self.m_MunitionProgress = 0

	if self.m_UIMode == UIStyle.Default and self.m_Enabled then
		setPlayerHudComponentVisible("all", true)
		--showPlayerHudComponent("radar", false)
		if design == 3 then
			setPlayerHudComponentVisible("radar",enabled)
		else setPlayerHudComponentVisible("radar",false)
		end
	else
		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
		if design == 3 then
			setPlayerHudComponentVisible("radar",enabled)
		else setPlayerHudComponentVisible("radar",false)
		end
	end

	self.m_RenderHandler = bind(self.draw,self)

	addEventHandler("onClientRender",root,self.m_RenderHandler)
end

function HUDUI:show()
	self.m_IsVisible = true
end

function HUDUI:hide()
	self.m_IsVisible = false
end

function HUDUI:refreshHandler()
	removeEventHandler("onClientRender",root,self.m_RenderHandler)
	addEventHandler("onClientRender",root,self.m_RenderHandler)
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
	elseif self.m_UIMode == UIStyle.Chart then
		self:drawChart()
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
	local design = tonumber(core:getConfig():get("HUD", "RadarDesign"))
	local enabled = core:get("HUD", "showRadar")
	if uiMode == UIStyle.Default then
		setPlayerHudComponentVisible("all", true)
		if design == 3 then
			setPlayerHudComponentVisible("radar",enabled)
		else setPlayerHudComponentVisible("radar",false)
		end
		--showPlayerHudComponent("radar", false)
	elseif self.m_UIMode == UIStyle.Default then
		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
		if design == 3 then
			setPlayerHudComponentVisible("radar",enabled)
		else setPlayerHudComponentVisible("radar",false)
		end
	end

	self.m_UIMode = uiMode
end

function HUDUI:setEnabled(state)
	self.m_Enabled = state
	local design = tonumber(core:getConfig():get("HUD", "RadarDesign"))
	local enabled = core:get("HUD", "showRadar")
	if self.m_UIMode == UIStyle.Default then
		if not state then
			setPlayerHudComponentVisible("all", false)
			setPlayerHudComponentVisible("crosshair", true)
			if design == 3 then
				setPlayerHudComponentVisible("radar",enabled)
			else setPlayerHudComponentVisible("radar",false)
			end
		else
			setPlayerHudComponentVisible("all", true)
			--showPlayerHudComponent("radar", false)
			if design == 3 then
				setPlayerHudComponentVisible("radar",enabled)
			else setPlayerHudComponentVisible("radar",false)
			end
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

function HUDUI:drawTimeRect()
	local f = math.floor

	local left = screenWidth-0.25*screenWidth
	-- Background
	dxDrawRectangle(left, 0, 0.05*screenWidth, screenHeight*0.035, tocolor(0, 0, 0, 120))
	dxDrawRectangle(left, 0, 0.05*screenWidth, 5, Color.LightBlue)

	local time =  string.format("%02d:%02d",getRealTime().hour,getRealTime().minute)
	dxDrawText(time, left, screenHeight*0.007, left+0.05*screenWidth, nil, Color.White, 1.5, "arial", "center")

end

function HUDUI:drawDefault()
	local f = math.floor
	dxDrawRectangle(screenWidth-0.195*screenWidth, 0.04*screenHeight, 0.195*screenWidth, 0.092*screenHeight,tocolor(0,0,0,150))
	dxDrawText("$"..convertNumber(localPlayer:getMoney()), screenWidth-0.14*screenWidth, 0.04*screenHeight, screenWidth-screenWidth*0.007, 0.04*screenHeight+0.092*screenHeight, Color.White, 1, self.m_Font, "right", "center")

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
	dxDrawRectangle(screenWidth-0.351*screenWidth,-0.1*screenHeight+addY,0.151*screenWidth,0.092*screenHeight,tocolor(0,0,0,150))
	local inClip = getPedAmmoInClip(localPlayer)
	local totalAmmo = getPedTotalAmmo(localPlayer)
	local sMunition = ("%d - %d"):format(inClip,totalAmmo-inClip)
	dxDrawText(sMunition,screenWidth-0.276*screenWidth-(dxGetTextWidth(sMunition,1,self.m_Font)/2), -85+addY+screenHeight*0.015, 0.153*screenWidth,0.092*screenHeight,Color.White,1,self.m_Font)


	-- Wantedlevel
	dxDrawRectangle(screenWidth-0.05*screenWidth,0.14*screenHeight,0.05*screenWidth,0.105*screenHeight,tocolor(0,0,0,150))
	dxDrawImage    (screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-(0.025*screenWidth/2), 0.155*screenHeight+(0.09*screenHeight/2)-36, 0.025*screenWidth,0.044*screenHeight, "files/images/HUD/wanted.png", 0, 0, 0, getPlayerWantedLevel() > 0 and Color.Yellow or Color.White)
	dxDrawText     (getPlayerWantedLevel(),screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-5,0.16*screenHeight+(0.09*screenHeight/2),0,0,Color.White,0.5,self.m_Font)

	self:drawTimeRect()
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
		dxDrawText("Karma: +"..math.round(karma), left+width/2+1, top, left+width, top+height, Color.White, fontSize, "default-bold", "center", "center")
	else
		dxDrawRectangle(left, top, width/2-1, height, tocolor(50,0,0,220))
		dxDrawRectangle(left+width/2+1, top, width/2-1, height, tocolor(0,0,0,150))
		dxDrawRectangle((left + width/2)-barWidth-1, top, barWidth, height, tocolor(160,75,75,220))
		dxDrawText("Karma: -"..math.round(karma), left, top, left+width/2-1, top+height, Color.White, fontSize, "default-bold", "center", "center")
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
	--if sx_g > 1400 then sx_g = 1400 end

	local width = math.floor(sx_g*0.22)*self.m_Scale
	local height = math.floor(sx_g*0.22)*self.m_Scale
	local r_os = 0
	local hudStartX = math.floor(screenWidth-width-r_os)
	local lebensanzeige = getElementHealth(localPlayer)
	local imageWidth = 303
	local imageHeight = 322
	local progressBarSpeed = 24000

	if not start_count then start_count = getTickCount() end
	if not end_count then end_count = start_count + progressBarSpeed end


	local now = getTickCount()
	local elapsed = now - start_count
	local duration = end_count - start_count
	local prog = elapsed / duration
	local scroll_ = interpolateBetween(207,0,0,-207,0,0,prog,'Linear')
	local time =  string.format("%02d:%02d",getRealTime().hour,getRealTime().minute)
	dxDrawImage(hudStartX,1,math.floor(width),math.floor(height),'files/images/HUD/exo/bg.png')
	dxDrawText (convertNumber(localPlayer:getMoney()),screenWidth-width*0.7-r_os,width*0.265,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default-bold" ) --Money
	dxDrawText (time,screenWidth-width*0.22-r_os,width*0.265,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default" ) -- Clock
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
	local bar_x = hudStartX+ (((97/imageWidth))*width)
	local bar_width = width * (201/imageWidth)
	local bar_height = height*(12/imageHeight)

	b_x = localPlayer:getArmor()/100
	dxDrawImageSection(bar_x, height*(155/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/blue_b.png',0,0,0,tocolor(255,255,255,200)) -- erster Balken

	b_x = localPlayer:getHealth()/100
	if b_x > (15*0.01) then
		dxDrawImageSection(bar_x ,height*(186/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/red_b.png',0,0,0,tocolor(255,255,255,200))
	elseif b_x <= (15*0.01) and ( getTickCount() % 1000 > 500 ) then
		dxDrawImageSection(bar_x ,height*(186/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/red_b.png',0,0,0,tocolor(255,255,255,200)) -- zweiter Balken
	end

	local karma = localPlayer:getKarma()
	b_x = math.abs(karma)/150
	if karma < 0 then
		dxDrawImageSection(bar_x ,height*(218/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/cyan_b.png',0,0,0,tocolor(255,255,255,200))
	elseif karma > 0 then
		dxDrawImageSection(bar_x ,height*(218/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/cyan_b.png',0,0,0,tocolor(255,255,255,200))
	end
	if prog >= 1 then
		start_count = getTickCount()
		end_count = start_count + progressBarSpeed
	end
	local r,g,b,a = 0,0,0,200

	if lebensanzeige > 0 and lebensanzeige < 1 then lebensanzeige = 1 end
	lebensanzeige = math.floor(lebensanzeige)

	dxDrawText ("SCHUTZWESTE: "..math.floor(getPedArmor(localPlayer)).."%",screenWidth-width*0.5-r_os,width*0.475,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","center" ) --Money
	dxDrawText ("LEBEN: "..lebensanzeige.."%",screenWidth-width*0.5-r_os,width*0.57,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","center" ) --Money
	dxDrawText ("KARMA: "..math.round(localPlayer:getKarma()),screenWidth-width*0.5-r_os,width*0.675,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","center" ) --Money

	dxDrawImage(screenWidth-width*0.3-r_os,0,width*0.24,width*0.24, WeaponIcons[localPlayer:getWeapon()])
	local tAmmo = getPedTotalAmmo( localPlayer )
	local iClip = getPedAmmoInClip( localPlayer )
	local weaponSlot = getPedWeaponSlot(localPlayer)
	if weaponSlot >= 2 then
		dxDrawText ( iClip.."-"..tAmmo-iClip,hudStartX+width*0.5, height*0.125,width*0.5, height*0.28, tocolor ( 255,255,255,255 ), 1.1*width*0.0039, "sans","left","top" ) --Money
	end
	dxDrawText ( math.floor(localPlayer:getPlayTime()/60).." Std.",hudStartX+width*0.5, height*0.77,width*0.5, height*0.08, tocolor ( 255,255,255,255 ), 0.9*width*0.0039, "sans","left","top" ) --Money

	dxDrawText ( math.floor(localPlayer:getLevel() or 0) or 0,hudStartX+width*0.9, height*0.77,width*0.5, height*0.08, tocolor ( 255,255,255,255 ), 0.9*width*0.0039, "sans","left","top" ) --Money


	--[[if getPedWeapon(localPlayer) > 9  then
			firestate = getHudFirestate()
			dxDrawText(getPedTotalAmmo ( localPlayer)-getPedAmmoInClip(localPlayer)..'-'..getPedAmmoInClip(localPlayer),screenWidth-width*0.57-r_os,width*0.14,width,height,tocolor(255,255,255,255),0.7,'pricedown')
			dxDrawText(firestate,screenWidth-width*0.57-r_os,width*0.07,width,height,tocolor(255,255,255,255),0.8*width*0.0039,'pricedown')

			local ammoTyp = getElementData ( localPlayer, "curAmmoTyp" )
			if not isElementInWater(localPlayer) and ammoTyp and ammoTyp > 0 and spezMuniWaffen[getPedWeapon(localPlayer)] then
				local ammo = specialAmmoName[ammoTyp]
				dxDrawRectangle ((screenWidth-width)*1.05,sx*0.218,sx*0.4,sx*0.02, tocolor ( 255,0,0,125 ))
				dxDrawText ("Spezialmunition: "..ammo.."",screenWidth-width*0.687-r_os,sx*0.22,screenWidth*0.99,sx, tocolor ( 255,255,255,255 ), 1.2*width*0.0039, "default","right")
			end
	end]]

	if isElementInWater(localPlayer) then
		dxDrawRectangle ((screenWidth-width)*1.05,sx*0.318,sx*0.4,sx*0.02, tocolor ( 50,200,255,125 ))
		dxDrawText ("Sauerstoff: "..math.floor((getPedOxygenLevel(localPlayer)*100)/2500).."%",sx*0.9-r_os,sx*0.32,screenWidth*0.99,sx, tocolor ( 255,255,255,255 ), 1.2*width*0.0039, "default","right")
	end
end

function HUDUI:drawChart()
	local scale = self.m_Scale*1.2
	local height = 30*scale
	local margin = 5*scale
	local w_height = height*2 + margin
	local border = margin*5
	local col1_w = 240*scale -- bars
	local col2_w = height*2 --level etc
	local col1_x = screenWidth - border - col2_w - margin - col1_w
	local col2_x = screenWidth - border - col2_w
	local col1_i = 0
	local col2_i = 0
	local font = VRPFont(height)
	local fontAwesome = FontAwesome(height*0.7)

	local function dxDrawTextInCenter(text, x, y, w, h, icon)
		--local text = tostring(text)
		dxDrawText(text, x + w/2, y + h/2, nil, nil, Color.White, 1, icon and fontAwesome or font, "center", "center")
	end
	
	local function drawCol(col, progress, color, text, icon, iconbgcolor)
		local x, w, i = col1_x, col1_w, col1_i
		if col == 2 then x, w, i = col2_x, col2_w, col2_i end
		dxDrawRectangle(x, border + (height + margin)*i, w, height, tocolor(0, 0, 0, 150)) --bg
		local isIcon = icon and icon:len() == 1
		dxDrawRectangle(x + (isIcon and height or 0), border + (height + margin)*i, (w - (isIcon and height or 0))/100*progress, height, color) --progress
		dxDrawTextInCenter(text, x + (isIcon and height or 0), border + (height + margin)*i, w - (isIcon and height or 0), height, false) --label
		if isIcon then
			if iconbgcolor then
				dxDrawRectangle(x, border + (height + margin)*i, height, height, iconbgcolor) --iconbg
			end
			dxDrawTextInCenter(icon, x, border + (height + margin)*i, height, height, true) --icon
		end
		if col == 1 then
			col1_i = col1_i + 1
		elseif col == 2 then
			col2_i = col2_i + 1
		end
	end

	local health, armor, karma = localPlayer:getHealth(), localPlayer:getArmor(), math.round(localPlayer:getKarma())
	local oxygen = math.percent(getPedOxygenLevel(localPlayer), 1000)
	if health > 0 then 
		drawCol(1, health, Color.HUD_Red, "Leben ("..math.round(health).."%)", FontAwesomeSymbols.Heart, Color.HUD_Red_D) 
	end
	if armor > 0 then 
		drawCol(1, armor, Color.HUD_Grey, "Schutzweste ("..math.round(armor).."%)", FontAwesomeSymbols.Shield, Color.HUD_Grey_D)
	end
	if localPlayer:isInWater() or oxygen < 100 then 
		drawCol(1, oxygen, Color.HUD_Blue, "Luft ("..math.round(oxygen).."%)", FontAwesomeSymbols.Comment, Color.HUD_Blue_D) 
	end
	drawCol(1, math.percent(math.abs(karma), 150), Color.HUD_Cyan, "Karma ("..karma..")", FontAwesomeSymbols.Circle_O_Notch, Color.HUD_Cyan_D)
	drawCol(1, 0, Color.Clear, toMoneyString(localPlayer:getMoney()), FontAwesomeSymbols.Money, Color.HUD_Green_D)
	drawCol(1, 0, Color.Clear, localPlayer:getPoints().." Punkte", FontAwesomeSymbols.Points, Color.HUD_Lime_D)

	if false then 
		dxDrawRectangle(col2_x, border, col2_w, w_height, tocolor(0, 0, 0, 150)) --skin
		col2_i = 2
	end
	drawCol(2, 0, Color.Clear, ("%02d:%02d"):format(getRealTime().hour, getRealTime().minute))
	if localPlayer:getWantedLevel() > 0 then drawCol(2, 0, Color.Clear, localPlayer:getWantedLevel(), FontAwesomeSymbols.Star, Color.HUD_Orange_D) end
	drawCol(2, 0, Color.Clear, localPlayer:getVehicleLevel(), FontAwesomeSymbols.Car)
	drawCol(2, 0, Color.Clear, localPlayer:getSkinLevel(), FontAwesomeSymbols.Player)
	drawCol(2, 0, Color.Clear, localPlayer:getWeaponLevel(), FontAwesomeSymbols.Bullseye)
	drawCol(2, 0, Color.Clear, localPlayer:getJobLevel(), FontAwesomeSymbols.Suitcase)
	drawCol(2, 0, Color.Clear, localPlayer:getFishingLevel(), FontAwesomeSymbols.Anchor)

	--weapons
	local weaponIconPath = WeaponIcons[localPlayer:getWeapon()]
	if weaponIconPath and localPlayer:getWeapon() ~= 0 then
		local base_y = border + (height + margin)*col1_i
		dxDrawRectangle(col1_x, base_y, col1_w, w_height, tocolor(0, 0, 0, 150)) --bg
		dxDrawImage(col1_x + margin, base_y + margin, w_height - margin*2, w_height - margin*2, weaponIconPath)
		dxDrawTextInCenter(WEAPON_NAMES[localPlayer:getWeapon()], col1_x + w_height, base_y, col1_w - w_height, w_height/2)
		local inClip = getPedAmmoInClip(localPlayer)
		local totalAmmo = getPedTotalAmmo(localPlayer)
		dxDrawTextInCenter(("%d - %d"):format(inClip,totalAmmo-inClip), col1_x + w_height, base_y + w_height/2, col1_w - w_height, w_height/2)
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

function HUDUI:setScale( scale )
	scale = scale*1.25
	local newScale = 0.5 + math.floor( ((1.5 * scale))*10)/10
	if self.m_Scale ~= newScale then
		self.m_Scale = newScale
		core:set("HUD", "hudScale", self.m_Scale)
	end
end
