-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Effects/ZoomBlurShaderShader.lua
-- *  PURPOSE:     ZoomBlurShader shader class 
-- *
-- ****************************************************************************
ZoomBlurShader = inherit(Object)

function ZoomBlurShader:constructor()
	self.m_ZoomBlurShader = dxCreateShader("files/shader/zoomBlur.fx")
	self.m_ScreenSource = dxCreateScreenSource(screenWidth, screenHeight)

	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end

function ZoomBlurShader:update()
	if self.m_ZoomBlurShader and self.m_ScreenSource then
		self.m_ScreenSource:update()

		self.m_ZoomBlurShader:setValue("ScreenTexture", self.m_ScreenSource)
		
		self.m_Ready = true
		dxDrawImage(0, 0, screenWidth, screenHeight, self.m_ZoomBlurShader)
	end
end

function ZoomBlurShader:setBlurOption( c, b) 
	if self.m_ZoomBlurShader and self.m_ScreenSource then
		if self.m_Ready then
			self.m_ZoomBlurShader:setValue("Center", c)
			self.m_ZoomBlurShader:setValue("BlurAmount", b)
		end
	end
end

function ZoomBlurShader:destructor()
	if self.m_ZoomBlurShader then
		destroyElement(self.m_ZoomBlurShader)
	end
	if self.m_ScreenSource then
		destroyElement(self.m_ScreenSource)
	end
	removeEventHandler("onClientPreRender", root, self.m_Update)
	self.m_Update = nil
end

function ZoomBlurShader:setValue(iValue)
	self.m_ZoomBlurShader:setValue("BlurAmount", iValue)
end