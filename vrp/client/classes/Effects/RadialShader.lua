-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/RadialShader.lua
-- *  PURPOSE:     Login shader class
-- *
-- ****************************************************************************
RadialShader = inherit(Singleton)

function RadialShader:constructor()
	self.m_Enabled = false
	self.m_Update = bind(self.update, self)
end

function RadialShader:destructor()
	self:setEnabled(false)
end

function RadialShader:setEnabled(enabled)
	-- Don't do anything if the enabled state is already set
	if self.m_Enabled == enabled then
		return
	end

	if not enabled then
		removeEventHandler("onClientHUDRender", root, self.m_Update)

		if self.m_RadialShader then
			destroyElement(self.m_RadialShader)
		end
		if self.m_ScreenSource then
			destroyElement(self.m_ScreenSource)
		end
	else
		self.m_RadialShader = dxCreateShader("files/shader/radialFog.fx")
		self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

		addEventHandler("onClientHUDRender", root, self.m_Update)
	end

	self.m_Enabled = enabled
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
