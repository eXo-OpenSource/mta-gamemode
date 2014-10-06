HUDUI = inherit(Singleton)

function HUDUI:constructor()
	self.m_IsVisible = false
	self.m_Font = dxCreateFont("files/fonts/Gasalt.ttf", 40, false)
	self.m_MunitionProgress = 0
	self.m_TestKarma = 50
	
	setTimer(function() self.m_TestKarma = math.random(-100,100) end,5000,0)
	
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

function HUDUI:draw(deltaTime)	
	if self.m_IsVisible then
		dxDrawRectangle(screenWidth-0.195*screenWidth,0.0425*screenHeight,0.195*screenWidth,0.092*screenHeight,tocolor(0,0,0,150))
		dxDrawText ("$",screenWidth-0.169*screenWidth,0.0625*screenHeight,0.195*screenWidth,0.092*screenHeight,Color.White,1,self.m_Font)
		dxDrawText (getPlayerMoney(localPlayer),screenWidth-0.143*screenWidth,0.0625*screenHeight,0.195*screenWidth,0.092*screenHeight,Color.White,1,self.m_Font)
		
		local munitionWindowActive = true
		
		if NO_MUNITION_ITEMS[getPedWeapon(localPlayer)] then
			munitionWindowActive = false
		end
		
		if munitionWindowActive and self.m_MunitionProgress < 1 then
			self.m_MunitionProgress = self.m_MunitionProgress + 0.01
		elseif not munitionWindowActive and self.m_MunitionProgress > 0 then
			self.m_MunitionProgress = self.m_MunitionProgress - 0.01
		end
		
		-- Weapon-Window
		local addX = math.floor(interpolateBetween(0,0,0,0.156*screenWidth,0,0,self.m_MunitionProgress,"OutElastic"))
		dxDrawRectangle(screenWidth-(0.25*screenWidth+addX),0.0465*screenHeight,0.05*screenWidth,0.09*screenHeight,tocolor(0,0,0,150))
		-- images became changed later
		if munitionWindowActive then
			dxDrawImage(screenWidth-(0.25*screenWidth+addX)+(0.05*screenWidth/2)-(0.033*screenWidth/2),0.0465*screenHeight+(0.09*screenHeight/2)-(0.059*screenHeight/2),0.033*screenWidth,0.059*screenHeight,"files/images/Weapons/gun.png")
		else
			dxDrawImage(screenWidth-(0.25*screenWidth+addX)+(0.05*screenWidth/2)-(0.033*screenWidth/2),0.0465*screenHeight+(0.09*screenHeight/2)-(0.059*screenHeight/2),0.033*screenWidth,0.059*screenHeight,"files/images/Weapons/hand.png")
		end
		
		-- Munition-Window
		local addY = interpolateBetween(0,0,0,0.134259*screenHeight,0,0,self.m_MunitionProgress,"Linear")
		dxDrawRectangle(screenWidth-0.351*screenWidth,-0.09*screenHeight+addY,0.153*screenWidth,0.09*screenHeight,tocolor(0,0,0,150))
		local inClip = getPedAmmoInClip(localPlayer)
		local totalAmmo = getPedTotalAmmo(localPlayer)
		local sMunition = ("%d - %d"):format(inClip,totalAmmo-inClip)
		dxDrawText(sMunition,screenWidth-0.276*screenWidth-(dxGetTextWidth(sMunition,1,self.m_Font)/2),-85+addY,0.153*screenWidth,0.09*screenHeight,Color.White,1,self.m_Font)
		
		-- Karmabar
		
		--dxDrawImage(screenWidth-480,170,480,35,"files/images/Bar.png")
		--dxDrawImage(screenWidth-0.25*screenWidth,0.157*screenHeight,0.25*screenWidth,0.03*screenHeight,"files/images/Bar_hover.png")
		dxDrawRectangle(screenWidth-0.25*screenWidth,0.157*screenHeight,0.25*screenWidth,0.03*screenHeight,tocolor(0,0,0,150))
		if self.m_TestKarma >= 0 then
			dxDrawRectangle(screenWidth-0.25*screenWidth,0.157*screenHeight,(0.25*screenWidth)*self.m_TestKarma/100,0.03*screenHeight,tocolor(0,125,0,100))
		else
			dxDrawRectangle(screenWidth-0.25*screenWidth,0.157*screenHeight,(0.25*screenWidth)*-self.m_TestKarma/100,0.03*screenHeight,tocolor(125,0,0,100))
		end
		
		-- Wantedlevel
	
		dxDrawRectangle(screenWidth-0.05*screenWidth,0.20*screenHeight,0.05*screenWidth,0.09*screenHeight,tocolor(0,0,0,150))
		dxDrawImage    (screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-(0.025*screenWidth/2),0.199*screenHeight+(0.09*screenHeight/2)-36,0.025*screenWidth,0.044*screenHeight,"files/images/wanted.png")
		dxDrawText     (getPlayerWantedLevel(localPlayer),screenWidth-0.05*screenWidth+(0.05*screenWidth/2)-6,0.21*screenHeight+(0.09*screenHeight/2),0,0,Color.White,0.5,self.m_Font)
	end
end