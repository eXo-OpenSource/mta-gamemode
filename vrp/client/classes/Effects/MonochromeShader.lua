-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/MonochromeShaderShader.lua
-- *  PURPOSE:     MonochromeShader shader class 
-- *
-- ****************************************************************************
MonochromeShader = inherit(Object)

function MonochromeShader:constructor()
	self.m_MonochromeShader = dxCreateShader("files/shader/monochrome.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end

function MonochromeShader:update()
	if self.m_MonochromeShader and self.m_ScreenSource then
		self.m_ScreenSource:update()

		self.m_MonochromeShader:setValue("ScreenTexture", self.m_ScreenSource)
		
		self.m_Ready = true
		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_MonochromeShader)
	end
end

function MonochromeShader:setBlurColor(c) 
	if self.m_MonochromeShader and self.m_ScreenSource then
		if self.m_Ready then
			self.m_MonochromeShader:setValue("filterColor", c)
		end
	end
end

function MonochromeShader:destructor()
	if self.m_MonochromeShader then
		destroyElement(self.m_MonochromeShader)
	end
	if self.m_ScreenSource then
		destroyElement(self.m_ScreenSource)
	end
	removeEventHandler("onClientPreRender", root, self.m_Update)
	self.m_Update = nil
end
