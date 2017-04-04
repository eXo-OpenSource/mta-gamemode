-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/FadeOutShader.lua
-- *  PURPOSE:     Fade out shader class (originally created by Sam@ake)
-- *
-- ****************************************************************************
FadeOutShader = inherit(Object)

function FadeOutShader:constructor(time)
	self.m_FadeOutShader = dxCreateShader("files/shader/fadeOut.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)
	self.m_Animation = AnimateOutInBack:new(time or 5000)

	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end

function FadeOutShader:startFade()
	self.m_Animation:reset()
end

function FadeOutShader:update()
	if self.m_FadeOutShader and self.m_ScreenSource then
		self.m_ScreenSource:update()

		self.m_FadeOutShader:setValue("screenSource", self.m_ScreenSource)
		self.m_FadeOutShader:setValue("screenSize", {screenWidth, screenHeight})
		self.m_FadeOutShader:setValue("fadeProcess", self.m_Animation:getFactor())

		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_FadeOutShader)

		-- Destroy the shader when animation has ended
		if self.m_Animation:getFactor() >= 0.99 then
			delete(self)
		end
	end
end

function FadeOutShader:destructor()
	self.m_FadeOutShader:destroy()
	self.m_ScreenSource:destroy()
	delete(self.m_Animation)

	removeEventHandler("onClientPreRender", root, self.m_Update)
end
