-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/SniperShaderShader.lua
-- *  PURPOSE:     SniperShader shader class 
-- *
-- ****************************************************************************
SniperShader = inherit(Object)

function SniperShader:constructor( dur)
	self.m_SniperShader = dxCreateShader("files/shader/zoomBlur.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

	self.m_Update = bind(self.update, self)
	self.m_StartTick = getTickCount()
	self.m_EndTick = self.m_StartTick + dur
	local ran = math.random(1,2)
	if ran == 1 then
		self.m_RandomStart = -0.5
	else 
		self.m_RandomStart = 1.5
	end
	addEventHandler("onClientHUDRender", root, self.m_Update)
end

function SniperShader:update()
	if self.m_SniperShader and self.m_ScreenSource then
		local now = getTickCount()
		local elap = now - self.m_StartTick
		local dur = self.m_EndTick - self.m_StartTick
		local prog = elap/dur
		local blur, center, sizefactor = interpolateBetween(0.4,self.m_RandomStart,0.95,0,0.5,1.3,prog,"OutBack")
		local rot = interpolateBetween(-10,0,0,0,10,0,prog*1.1,"CosineCurve")
		self.m_ScreenSource:update()

		self.m_SniperShader:setValue("ScreenTexture", self.m_ScreenSource)
		self.m_SniperShader:setValue("BlurAmount", blur)
		self.m_SniperShader:setValue("Center", center)
		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_SniperShader,rot)
	end
end

function SniperShader:destructor()
	if self.m_SniperShader then
		destroyElement(self.m_SniperShader)
	end
	if self.m_ScreenSource then
		destroyElement(self.m_ScreenSource)
	end
	removeEventHandler("onClientHUDRender", root, self.m_Update)
	self.m_Update = nil
end

function SniperShader:setValue(iValue)
	self.m_SniperShader:setValue("BlurAmount", iValue)
end