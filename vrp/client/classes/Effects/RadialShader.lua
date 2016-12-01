-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/RadialShader.lua
-- *  PURPOSE:     Login shader class 
-- *
-- ****************************************************************************
RadialShader = inherit(Object)

function RadialShader:constructor()
	self.m_RadialShader = dxCreateShader("files/shader/radialFog.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

	self.m_Update = bind(self.update, self)
	removeEventHandler("onClientHUDRender", root, self.m_Update)
	addEventHandler("onClientHUDRender", root, self.m_Update)
end

function RadialShader:startFade()
	self.m_Animation:reset()
end

function RadialShader:update()
	if self.m_RadialShader and self.m_ScreenSource then
		self.m_ScreenSource:update()

		self.m_RadialShader:setValue("ScreenTexture", self.m_ScreenSource)

		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_RadialShader)

	end
end

function RadialShader:destructor()
	if self.m_RadialShader then
		self.m_RadialShader:destroy()
	end
	if self.m_ScreenSource then
		self.m_ScreenSource:destroy()
	end
	removeEventHandler("onClientHUDRender", root, self.m_Update)
end
