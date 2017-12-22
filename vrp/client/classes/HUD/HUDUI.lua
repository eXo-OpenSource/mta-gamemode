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
	self.m_UIMode = core:get("HUD", "UIStyle", UIStyle.Chart)
	self.m_Enabled = core:get("HUD", "showUI", true)
	self.m_RedDot = core:get("HUD", "reddot", false)
	self.m_Scale = core:get("HUD", "hudScale", 1)
	self.m_DefaultHealhArmor = core:get("HUD", "defaultHealthArmor", true)
	local design = tonumber(core:getConfig():get("HUD", "RadarDesign"))
	local enabled = core:get("HUD", "showRadar")
	self.m_MunitionProgress = 0
	self.m_ChartAnims = {}

	if self.m_UIMode == UIStyle.Default and self.m_Enabled then
		setPlayerHudComponentVisible("all", true)
		setPlayerHudComponentVisible("wanted", false)
		HUDRadar:getSingleton():updateRadarType(core:get("HUD", "GWRadar", false))
	else
		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
		HUDRadar:getSingleton():updateRadarType(core:get("HUD", "GWRadar", false))
	end

	self.m_RenderHandler = bind(self.draw,self)

	addEventHandler("onClientRender",root,self.m_RenderHandler, false, "high")
end

function HUDUI:getLocalTarget()
	return localPlayer:getPrivateSync("isSpecting") or localPlayer
end

function HUDUI:show()
	self.m_IsVisible = true
end

function HUDUI:hide()
	self.m_IsVisible = false
end

function HUDUI:refreshHandler()
	removeEventHandler("onClientRender",root,self.m_RenderHandler)
	addEventHandler("onClientRender",root,self.m_RenderHandler, false, "high")
end

function HUDUI:draw()
	if not self.m_Enabled then return end
	if not self.m_IsVisible then return end
	if DEBUG then ExecTimeRecorder:getSingleton():startRecording("UI/HUD_general") end
	if self.m_UIMode == UIStyle.Default then
		self:drawDefault()
	elseif self.m_UIMode == UIStyle.vRoleplay then
		self:drawVRP()
		if self.m_DefaultHealhArmor == true then
			self:drawVRPHealthArmor()
			self:drawKarmaBar(0.0325*screenHeight, 1.2)
		else
			self:drawKarmaBar(0.0425*screenHeight, 1.6)
		end
	elseif self.m_UIMode == UIStyle.eXo then
		self:drawExo()
	elseif self.m_UIMode == UIStyle.Chart then
		self:drawChart()
	end

	if self.m_RedDot == true then
		self:drawRedDot()
	end

	if localPlayer:getPublicSync("AFK") == true then
		self:drawAFK()
	end
	if DEBUG then ExecTimeRecorder:getSingleton():endRecording("UI/HUD_general", 1, 1) end
end

function HUDUI:setUIMode(uiMode)
	local design = tonumber(core:getConfig():get("HUD", "RadarDesign"))
	local enabled = core:get("HUD", "showRadar")
	if uiMode == UIStyle.Default then
		setPlayerHudComponentVisible("all", true)
		setPlayerHudComponentVisible("wanted", false)
		HUDRadar:getSingleton():updateRadarType(core:get("HUD", "GWRadar", false))
	elseif self.m_UIMode == UIStyle.Default then
		setPlayerHudComponentVisible("all", false)
		setPlayerHudComponentVisible("crosshair", true)
		HUDRadar:getSingleton():updateRadarType(core:get("HUD", "GWRadar", false))
	end
	self.m_ChartAnims = {} -- unload chart ui animations
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
			HUDRadar:getSingleton():updateRadarType(core:get("HUD", "GWRadar", false))
		else
			setPlayerHudComponentVisible("all", true)
			HUDRadar:getSingleton():updateRadarType(core:get("HUD", "GWRadar", false))
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

function HUDUI:drawDefault()
	dxSetAspectRatioAdjustmentEnabled(true)
	if self:getLocalTarget():getWanteds() > 0 then
		local width = math.floor(screenWidth / 5.8)
		local height = math.floor(screenHeight / 25)
		local x = math.floor(screenWidth * 0.78)
		local y = math.floor(screenHeight * 0.22 )
		dxDrawText(("%s Wanteds"):format(self:getLocalTarget():getWanteds()), x, y, x + width, y + height, Color.White, 1.3, "pricedown", "center", "center")
	end
end

function HUDUI:drawLevelRect()
	local f = math.floor

	-- Background
	dxDrawRectangle(screenWidth - screenWidth*0.195, 0, screenWidth*0.2, screenHeight*0.035, tocolor(0, 0, 0, 120))
	dxDrawRectangle(screenWidth - screenWidth*0.195, 0, screenWidth*0.2, 5, Color.LightBlue)

	-- Joblevel
	dxDrawImage(f(screenWidth*0.81), f(screenHeight*0.0095), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/JobLevel.png")
	dxDrawText(self:getLocalTarget():getJobLevel(), screenWidth*0.83, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")

	-- Weaponlevel
	dxDrawImage(f(screenWidth*0.855), f(screenHeight*0.0105), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/WeaponLevel.png")
	dxDrawText(self:getLocalTarget():getWeaponLevel(), screenWidth*0.875, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")

	-- Vehiclelevel
	dxDrawImage(f(screenWidth*0.905), f(screenHeight*0.0105), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/VehicleLevel.png")
	dxDrawText(self:getLocalTarget():getVehicleLevel(), screenWidth*0.925, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")

	-- Skinlevel
	dxDrawImage(f(screenWidth*0.955), f(screenHeight*0.0105), f(screenWidth*0.016 / ASPECT_RATIO_MULTIPLIER), f(screenHeight*0.02), "files/images/HUD/SkinLevel.png")
	dxDrawText(self:getLocalTarget():getSkinLevel(), screenWidth*0.975, screenHeight*0.007, nil, nil, Color.White, 1.5, "arial")
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

function HUDUI:drawVRP()
	local f = math.floor
	dxDrawRectangle(screenWidth-0.195*screenWidth, 0.04*screenHeight, 0.195*screenWidth, 0.092*screenHeight,tocolor(0,0,0,150))
	dxDrawText("$"..convertNumber(self:getLocalTarget():getMoney()), screenWidth-0.14*screenWidth, 0.04*screenHeight, screenWidth-screenWidth*0.007, 0.04*screenHeight+0.092*screenHeight, Color.White, 1, self.m_Font, "right", "center")

	local munitionWindowActive = true

	if NO_MUNITION_ITEMS[getPedWeapon(self:getLocalTarget())] then
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

	local weaponIconPath = WeaponIcons[self:getLocalTarget():getWeapon()]
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
	local inClip = getPedAmmoInClip(self:getLocalTarget())
	local totalAmmo = getPedTotalAmmo(self:getLocalTarget())
	local sMunition = ("%d - %d"):format(inClip,totalAmmo-inClip)
	dxDrawText(sMunition,screenWidth-0.276*screenWidth-(dxGetTextWidth(sMunition,1,self.m_Font)/2), -85+addY+screenHeight*0.015, 0.153*screenWidth,0.092*screenHeight,Color.White,1,self.m_Font)


	-- Wantedlevel
	dxDrawRectangle(screenWidth-0.05*screenWidth,0.14*screenHeight,0.05*screenWidth,0.105*screenHeight,tocolor(0,0,0,150))
	dxDrawImage    (screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-(0.025*screenWidth/2), 0.155*screenHeight+(0.09*screenHeight/2)-36, 0.025*screenWidth,0.044*screenHeight, "files/images/HUD/wanted.png", 0, 0, 0, self:getLocalTarget():getWanteds() > 0 and Color.Yellow or Color.White)
	dxDrawText     (self:getLocalTarget():getWanteds(),screenWidth-0.05*screenWidth,0.16*screenHeight+(0.09*screenHeight/2),screenWidth-0.05*screenWidth+0.05*screenWidth,0,Color.White,0.5,self.m_Font, "center")

	self:drawTimeRect()
	self:drawLevelRect()
end

function HUDUI:drawKarmaBar(height, fontSize)
	local left, top = screenWidth-0.25*screenWidth, 0.14*screenHeight
	local width = 0.195*screenWidth

	local karma = math.floor(self:getLocalTarget():getKarma()) or 0

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
		dxDrawText("Karma: "..math.round(karma), left, top, left+width/2-1, top+height, Color.White, fontSize, "default-bold", "center", "center")
	end
end

function HUDUI:drawVRPHealthArmor()
	local health = self:getLocalTarget():getHealth()
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

	local armor = self:getLocalTarget():getArmor()
	dxDrawRectangle(left, top, width, height, tocolor(0, 0, 0, 150))
	dxDrawRectangle(left, top, width*armor/100, height, tocolor(0, 0, 128))

	local armor = "Schutzweste: "..math.floor(armor).." %"
	dxDrawText(armor, left , top, left+width, top+height, Color.White, 1.2, "default-bold", "center", "center")
end

function HUDUI:getZone()
	local pos = self:getLocalTarget():getPosition()
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
	local lebensanzeige = getElementHealth(self:getLocalTarget())
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
	dxDrawText (convertNumber(self:getLocalTarget():getMoney()),screenWidth-width*0.7-r_os,width*0.265,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default-bold" ) --Money
	dxDrawText (time,screenWidth-width*0.22-r_os,width*0.265,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default" ) -- Clock
	dxDrawText (self:getZone(),screenWidth-width*0.7-r_os,width*0.372,width,height, tocolor ( 255, 255, 255, 255 ), 1.02*width*0.0039, "default" ) -- ORT
	--dxDrawText (getSpielzeit(),screenWidth-width*0.55-r_os,width*0.765,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default" ) --
	--dxDrawText (getLevel(),screenWidth-width*0.15-r_os,width*0.765,width,height, tocolor ( 255, 255, 255, 255 ), 1.2*width*0.0039, "default" ) --

	local b_x = 100
	local bar_x = hudStartX+ (((97/imageWidth))*width)
	local bar_width = width * (201/imageWidth)
	local bar_height = height*(12/imageHeight)

	b_x = self:getLocalTarget():getArmor()/100
	dxDrawImageSection(bar_x, height*(155/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/blue_b.png',0,0,0,tocolor(255,255,255,200)) -- erster Balken

	b_x = self:getLocalTarget():getHealth()/100
	if b_x > (15*0.01) then
		dxDrawImageSection(bar_x ,height*(186/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/red_b.png',0,0,0,tocolor(255,255,255,200))
	elseif b_x <= (15*0.01) and ( getTickCount() % 1000 > 500 ) then
		dxDrawImageSection(bar_x ,height*(186/imageHeight),bar_width*b_x,bar_height,scroll_,0,207*b_x,15,'files/images/HUD/exo/red_b.png',0,0,0,tocolor(255,255,255,200)) -- zweiter Balken
	end

	local karma = self:getLocalTarget():getKarma()
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

	dxDrawText ("SCHUTZWESTE: "..math.floor(getPedArmor(self:getLocalTarget())).."%",screenWidth-width*0.5-r_os,width*0.475,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","center" ) --Money
	dxDrawText ("LEBEN: "..lebensanzeige.."%",screenWidth-width*0.5-r_os,width*0.57,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","center" ) --Money
	dxDrawText ("KARMA: "..math.round(self:getLocalTarget():getKarma()),screenWidth-width*0.5-r_os,width*0.675,screenWidth-10,height, tocolor ( r,g,b,a ), 0.8*width*0.0039, "sans","center" ) --Money

	dxDrawImage(screenWidth-width*0.3-r_os,0,width*0.24,width*0.24, WeaponIcons[self:getLocalTarget():getWeapon()])
	local tAmmo = getPedTotalAmmo( self:getLocalTarget() )
	local iClip = getPedAmmoInClip( self:getLocalTarget() )
	local weaponSlot = getPedWeaponSlot(self:getLocalTarget())
	if weaponSlot >= 2 then
		dxDrawText ( iClip.."-"..tAmmo-iClip,hudStartX+width*0.5, height*0.125,width*0.5, height*0.28, tocolor ( 255,255,255,255 ), 1.1*width*0.0039, "sans","left","top" ) --Money
	end
	dxDrawText(math.floor(self:getLocalTarget():getPlayTime()/60).." Std.",hudStartX+width*0.5, height*0.77,width*0.5, height*0.08, tocolor ( 255,255,255,255 ), 0.9*width*0.0039, "sans","left","top" ) --Money

	dxDrawText(self:getLocalTarget():getWanteds() or 0,hudStartX+width*0.89, height*0.77,width*0.5, height*0.08, tocolor ( 255,255,255,255 ), 0.9*width*0.0039, "sans","left","top" ) --Money


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

	if isElementInWater(self:getLocalTarget()) then
		dxDrawRectangle ((screenWidth-width)*1.05,sx*0.318,sx*0.4,sx*0.02, tocolor ( 50,200,255,125 ))
		dxDrawText ("Sauerstoff: "..math.floor((getPedOxygenLevel(localPlayer)*100)/2500).."%",sx*0.9-r_os,sx*0.32,screenWidth*0.99,sx, tocolor ( 255,255,255,255 ), 1.2*width*0.0039, "default","right")
	end
end

function HUDUI:getSkinBrowserSave(skinid, w, h) -- get the correct skin texture and manage the underlying browser
	if not self.m_SkinBrowser then
		self.m_SkinBrowser = createBrowser(w, h, false, true)
		self.m_SkinID = skinid
		self.m_BrowserW = w
		self.m_BrowserH = h
		addEventHandler("onClientBrowserCreated", self.m_SkinBrowser, function()
			self.m_SkinBrowser:loadURL("https://exo-reallife.de/ingame/skinPreview/skinPreviewChartUI.php?skin="..skinid)
		end)
	end
	if skinid ~= self.m_SkinID then
		self.m_SkinBrowser:loadURL("https://exo-reallife.de/ingame/skinPreview/skinPreviewChartUI.php?skin="..skinid)
		self.m_SkinID = skinid
	end
	if w ~= self.m_BrowserW or h ~= self.m_BrowserH then
		resizeBrowser (self.m_SkinBrowser, w, h)
		self.m_BrowserW = w
		self.m_BrowserH = h
	end
	return self.m_SkinBrowser
end

function HUDUI:drawChart()
	local scale = self.m_Scale*1.2
	local height = 30*scale
	local margin = core:get("HUD", "chartMargin", true) and 5*scale or 0 --used in UI setting
	local margin_save = 5*scale --used internally for images and to separate col1 from col2
	local w_height = height*2 + margin
	local border = height
	local col1_w = 240*scale -- bars
	local col2_w = height*2 --level etc
	local col1_x = screenWidth - border - col2_w - margin_save - col1_w
	local col2_x = screenWidth - border - col2_w
	local col1_i = 0
	local col2_i = 0
	local font = VRPFont(height)
	local fontAwesome = FontAwesome(height*0.7)

	local function getProgress(identifier, fadeOut, justGet)
		if not justGet and not self.m_ChartAnims[identifier] then self.m_ChartAnims[identifier] = {0, getTickCount(), false} end
		if justGet then return self.m_ChartAnims and self.m_ChartAnims[identifier] and self.m_ChartAnims[identifier][1] or 0 end -- little hack to get the progress without updating it

		local d = self.m_ChartAnims[identifier]
		local prog = d[1]

		if fadeOut ~= d[3] then d[2] = getTickCount() d[3] = fadeOut end -- reset Animation if fade status changes
		if not fadeOut and d[1] < 1 then prog = (getTickCount() - d[2])/200 end
		if fadeOut and d[1] > 0 then prog = 1 - (getTickCount() - d[2])/200 end

		prog = math.clamp(0, prog, 1)
		d[1] = prog

		return getEasingValue(prog, "OutQuad")
	end

	local function dxDrawTextInCenter(text, x, y, w, h, icon, prog)
		if not prog then prog = 0 end
		dxDrawText(text, x + w/2, y + h/2, nil, nil, Color.changeAlphaRate(Color.White, prog), 1, icon and fontAwesome or font, "center", "center")
	end

	local function drawCol(col, progress, color, text, icon, iconBgColor, identifier, fadeOut)
		local prog = identifier and getProgress(identifier, fadeOut) or 0
		if fadeOut and prog == 0 then return true end --don't draw if it isn't visible anyways
		local x, w, i = col1_x, col1_w, col1_i
		if col == 2 then x, w, i = col2_x, col2_w, col2_i end
		local base_y =  border + (height + margin)*i - margin * (1 - prog)
		local isIcon = icon and icon:len() == 1

		--change colors based on setting
		if core:get("HUD", "chartColorBlue", false) then
			color = color ~= Color.Clear and Color.LightBlue or color
			iconBgColor = iconBgColor ~= Color.Clear and Color.DarkLightBlue or iconBgColor
		end

		dxDrawRectangle(x, base_y, w, height, tocolor(0, 0, 0, 150*prog)) --bg
		dxDrawRectangle(x + (isIcon and height or 0), base_y, (w - (isIcon and height or 0))/100*progress, height, Color.changeAlphaRate(color, prog)) --progress
		dxDrawTextInCenter(text, x + (isIcon and height or 0), base_y, w - (isIcon and height or 0), height, false, prog) --label

		if isIcon then
			if iconBgColor then
				dxDrawRectangle(x, base_y, height, height, Color.changeAlphaRate(iconBgColor, prog)) --iconbg
			end
			dxDrawTextInCenter(icon, x, base_y, height, height, true, prog) --icon
		end

		if col == 1 then
			col1_i = col1_i + prog
		elseif col == 2 then
			col2_i = col2_i + prog
		end
	end

	local health, armor, karma = self:getLocalTarget():getHealth(), self:getLocalTarget():getArmor(), math.round(self:getLocalTarget():getKarma())
	local oxygen = math.percent(getPedOxygenLevel(self:getLocalTarget()), 1000)
	local dsc = core:get("HUD", "chartLabels", true)
	local healthColor = Color.HUD_Red
	if health <= 20 then --quick and dirty flash animation
		healthColor = Color.changeAlphaRate(healthColor, getProgress("health-color", getTickCount()%1000 > 500))
	end
	local oxygenColor = Color.HUD_Blue
	if oxygen <= 50 then
		oxygenColor = Color.changeAlphaRate(oxygenColor, getProgress("health-color", getTickCount()%1000 > 500))
	end

	drawCol(1, health, healthColor, dsc and math.ceil(health).."% Leben" or math.ceil(health), FontAwesomeSymbols.Heart, Color.HUD_Red_D, "health", health == 0)
	drawCol(1, armor, Color.HUD_Grey, dsc and math.ceil(armor).."% Schutzweste" or math.ceil(armor), FontAwesomeSymbols.Shield, Color.HUD_Grey_D, "armor", armor == 0)
	drawCol(1, oxygen, oxygenColor, dsc and math.ceil(oxygen).."% Atemluft" or math.ceil(oxygen), FontAwesomeSymbols.Comment, Color.HUD_Blue_D, "oxygen", oxygen == 100)
	drawCol(1, math.percent(math.abs(karma), 150), Color.HUD_Cyan, dsc and karma.." Karma" or karma, FontAwesomeSymbols.Circle_O_Notch, Color.HUD_Cyan_D, "karma")
	drawCol(1, 0, Color.Clear, toMoneyString(self:getLocalTarget():getMoney()), FontAwesomeSymbols.Money, Color.HUD_Green_D, "money")
	drawCol(1, 0, Color.Clear, dsc and self:getLocalTarget():getPoints().." Punkte" or self:getLocalTarget():getPoints(), FontAwesomeSymbols.Points, Color.HUD_Lime_D, "points", not core:get("HUD", "chartPointLevelVisible", true))
	drawCol(1, 0, Color.Clear, getZoneName(self:getLocalTarget().position), FontAwesomeSymbols.Waypoint, Color.HUD_Brown_D, "zone", self:getLocalTarget():getInterior() ~= 0 or not core:get("HUD", "chartZoneVisible", true))

	drawCol(2, 0, Color.Clear, ("%02d:%02d"):format(getRealTime().hour, getRealTime().minute), false, Color.Clear, "clock")
	if core:get("HUD", "chartSkinVisible", false) or getProgress("skin", true, true) > 0 then
		local prog = getProgress("skin", not core:get("HUD", "chartSkinVisible", false))

		dxDrawRectangle(col2_x, border + (height + margin)*col2_i - margin * (1 - prog), col2_w, w_height, tocolor(0, 0, 0, 150*prog)) --skin
		dxDrawImage(col2_x, border + (height + margin)*col2_i - margin * (1 - prog), col2_w, w_height, self:getSkinBrowserSave(localPlayer:getModel(), col2_w + margin_save*2, w_height), 0, 0, 0, tocolor(255, 255, 255, 255*prog))

		col2_i = col2_i + prog * 2
	end
	drawCol(2, 0, Color.Clear, ("%d-%d"):format(getPlayerPing(self:getLocalTarget()), getNetworkStats().packetlossLastSecond), false, Color.Clear, "net", not DEBUG_NET)
	drawCol(2, 0, Color.Clear, ("%dh"):format(math.floor(self:getLocalTarget():getPlayTime()/60)), false, Color.Clear, "playtime", not core:get("HUD", "chartPlaytimeVisible", false))
	drawCol(2, 0, Color.Clear, self:getLocalTarget():getWanteds(), FontAwesomeSymbols.Star, Color.HUD_Orange_D, "wanted", self:getLocalTarget():getWanteds() == 0)
	drawCol(2, 0, Color.Clear, self:getLocalTarget():getVehicleLevel(), FontAwesomeSymbols.Car, Color.Clear, "veh-level", not core:get("HUD", "chartPointLevelVisible", true))
	drawCol(2, 0, Color.Clear, self:getLocalTarget():getSkinLevel(), FontAwesomeSymbols.Player, Color.Clear, "skin-level", not core:get("HUD", "chartPointLevelVisible", true))
	drawCol(2, 0, Color.Clear, self:getLocalTarget():getWeaponLevel(), FontAwesomeSymbols.Bullseye, Color.Clear, "weapon-level", not core:get("HUD", "chartPointLevelVisible", true))
	drawCol(2, 0, Color.Clear, self:getLocalTarget():getJobLevel(), FontAwesomeSymbols.Suitcase, Color.Clear, "job-level", not core:get("HUD", "chartPointLevelVisible", true))
	drawCol(2, 0, Color.Clear, self:getLocalTarget():getFishingLevel(), FontAwesomeSymbols.Anchor, Color.Clear, "fishing-level", not core:get("HUD", "chartPointLevelVisible", true))
	drawCol(2, 0, Color.Clear, math.min(60, self:getLocalTarget().FPS.frames + 1), FontAwesomeSymbols.Desktop, Color.Clear, "fps", not core:get("HUD", "chartFPSVisible", true))

	--weapons
	local weaponIconPath = WeaponIcons[self:getLocalTarget():getWeapon()]
	if weaponIconPath and (self:getLocalTarget():getWeapon() ~= 0 or getProgress("weapon", true, true) > 0) then
		local prog = getProgress("weapon", self:getLocalTarget():getWeapon() == 0)
		local base_y = border + (height + margin)*col1_i - margin * (1 - prog)

		local ammo = ("%d - %d"):format(getPedAmmoInClip(self:getLocalTarget()),getPedTotalAmmo(self:getLocalTarget()) - getPedAmmoInClip(self:getLocalTarget()))
		local showAmmo = ammo ~= "0 - 1" -- do not show ammo for melee weapons

		dxDrawRectangle(col1_x, base_y, col1_w, w_height, tocolor(0, 0, 0, 150*prog)) --bg
		dxDrawImage(col1_x + margin_save, base_y + margin_save, w_height - margin_save*2, w_height - margin_save*2, weaponIconPath, 0, 0, 0, tocolor(255, 255, 255, 255*prog))
		dxDrawTextInCenter(WEAPON_NAMES[self:getLocalTarget():getWeapon()], col1_x + w_height, base_y, col1_w - w_height, showAmmo and w_height/2 or w_height, false, prog)
		if showAmmo then
			dxDrawTextInCenter(ammo, col1_x + w_height, base_y + w_height/2, col1_w - w_height, w_height/2, false, prog)
		end
	end
end

function HUDUI:drawRedDot()
	local reddotSlots = {2, 3, 4, 5, 6, 7}
	if reddotSlots[getPedWeaponSlot(self:getLocalTarget())] then
		if getPedControlState(self:getLocalTarget(), "aim_weapon" ) then
			local x1, y1, z1 = getPedWeaponMuzzlePosition(self:getLocalTarget())
			local x2, y2, z2 = getPedTargetEnd(self:getLocalTarget())
			local x3, y3, z3 = getPedTargetCollision(self:getLocalTarget())
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
