WareHUD = inherit(Object)

local fuseTexture
local bombWidth, bombHeight = screenWidth*0.07, screenWidth*0.07
local bombStartX, bombStartY = screenWidth*0.3 - (bombWidth/2), screenHeight*0.8

function WareHUD:constructor() 
	fuseTexture = dxCreateTexture(WareHUD:makePath("fuse.png"))
	dxSetTextureEdge(fuseTexture, "border", tocolor(0,0,0,0))
	self.m_FuseWidth, self.m_FuseHeight = dxGetMaterialSize(fuseTexture)
	self.m_RenderFunc = bind(self.Event_OnRender, self)
	addEventHandler("onClientRender", root, self.m_RenderFunc)
end

function WareHUD:displayRoundTime( roundTime )
	self.m_StartTime = getTickCount() 
	self.m_RoundDuration = roundTime
	self.m_RenderRoundTimer = true
end

function WareHUD:stopRoundTime() 
	self.m_RenderRoundTimer = false
end

function WareHUD:Event_OnRender() 
	if self.m_RenderRoundTimer then 
		self:render_bomb()
	end
end

function WareHUD:render_bomb() 
	local now = getTickCount() 
	local elapsed = now - self.m_StartTime 
	local prog = elapsed/self.m_RoundDuration
	local prog2 = elapsed/(self.m_RoundDuration*0.5)
	local interProg = elapsed/self.m_RoundDuration 
	local scale = interpolateBetween(1.1, 0, 0, 1.4, 0, 0, interProg*15, "SineCurve")
	if prog < 0 then prog = 0 end
	local timeLeft = self.m_RoundDuration - elapsed
	timeLeft = secondsToClock(timeLeft)
	dxDrawText(timeLeft, bombStartX, bombStartY+bombHeight*1.1, bombStartX + bombWidth, (bombStartY + bombHeight*1.1)+2, tocolor(0, 0, 0, 255), 1*scale, "default-bold", "center")
	dxDrawText(timeLeft, bombStartX, bombStartY+bombHeight*1.1, bombStartX + bombWidth, (bombStartY + bombHeight*1.1), tocolor(200, 200*(1-prog), 0, 255), 1*scale, "default-bold", "center")
	dxDrawImage(bombStartX, bombStartY, bombWidth, bombHeight, self:makePath("bomb.png"))
	dxDrawImageSection(bombStartX+bombWidth+screenWidth*0.3, bombStartY+bombHeight*0.5-screenHeight*0.025, -1*screenWidth*0.3, math.floor(screenHeight*0.05), (self.m_FuseWidth*prog)*-1, 0, self.m_FuseWidth, self.m_FuseHeight, fuseTexture)
	dxDrawImage((bombStartX+bombWidth + (screenWidth*0.3*(1-prog))) - ((screenWidth*0.015*scale - screenWidth*0.015)*0.5), bombStartY-((bombHeight*scale - bombHeight)*0.5), screenWidth*0.015*scale, bombHeight*scale, self:makePath("fire.png") , 0, 0, 0, tocolor(255, 255, 255*prog, 255))
end

function WareHUD:destructor()
	removeEventHandler("onClientRender", root, self.m_RenderFunc)
end

function WareHUD:makePath( file )
	return "files/images/Textures/Ware/"..file
end

function secondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00"
  else
    secs = string.format("%02.f", math.floor(seconds/1000));
	tenth = string.format("%02.f", math.floor((seconds - (secs*1000))/10));
    return secs..":"..tenth
  end
end