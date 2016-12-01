-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/LoginShader.lua
-- *  PURPOSE:     Login shader class 
-- *
-- ****************************************************************************
LoginShader = inherit(Object)

function LoginShader:constructor()
	self.m_LoginShader = dxCreateShader("files/shader/loginShader.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end

function LoginShader:startFade()
	self.m_Animation:reset()
end

function LoginShader:update()
	if self.m_LoginShader and self.m_ScreenSource then
		self.m_ScreenSource:update()

		self.m_LoginShader:setValue("ScreenTexture", self.m_ScreenSource)

		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_LoginShader)

	end
end

function LoginShader:destructor()
	self.m_LoginShader:destroy()
	self.m_ScreenSource:destroy()
	removeEventHandler("onClientPreRender", root, self.m_Update)
end
