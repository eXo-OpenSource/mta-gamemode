HUDUI = inherit(Singleton)

function HUDUI:constructor()
	self.m_IsVisible = false
	self.m_Font = dxCreateFont("files/fonts/Gasalt.ttf", 40, false)
	self.m_MunitionProgress = 0
	
	showPlayerHudComponent("all",false)
	showPlayerHudComponent("crosshair",true)
	
	self.m_RenderHandler = bind(self.draw,self)
	
	addEventHandler("onClientRender",root,self.m_RenderHandler)
end

function HUDUI:show()
	self.m_IsVisible = true
end

function HUDUI:hide()
	self.m_IsVisible = false
end

function HUDUI:draw()	
	if self.m_IsVisible then
		dxDrawRectangle(screenWidth-375,50,375,100,tocolor(0,0,0,150))
		dxDrawText ("$",screenWidth-325,65,375,100,Color.White,1,self.m_Font)
		dxDrawText (getPlayerMoney(localPlayer),screenWidth-275,65,375,100,Color.White,1,self.m_Font)
		
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
		local addX = interpolateBetween(0,0,0,300,0,0,self.m_MunitionProgress,"Linear")
		dxDrawRectangle(screenWidth-(480+addX),50,100,100,tocolor(0,0,0,150))
		-- images became changed later
		if munitionWindowActive then
			dxDrawImage(screenWidth-(480+addX),50,100,100,"files/images/Weapons/gun.png")
		else
			dxDrawImage(screenWidth-(480+addX),50,100,100,"files/images/Weapons/hand.png")
		end
		
		-- Munition-Window
		local addY = interpolateBetween(0,0,0,150,0,0,self.m_MunitionProgress,"Linear")
		dxDrawRectangle(screenWidth-675,-100+addY,295,100,tocolor(0,0,0,150))
		local inClip = getPedAmmoInClip(localPlayer)
		local totalAmmo = getPedTotalAmmo(localPlayer)
		local sMunition = ("%d - %d"):format(inClip,totalAmmo-inClip)
		dxDrawText(sMunition,screenWidth-530-(dxGetTextWidth(sMunition,1,self.m_Font)/2),-85+addY,295,100,Color.White,1,self.m_Font)
		
		-- Wantedlevel
		
		-- ...
		
	end
end