TextureReplace = inherit(Object)

function TextureReplace:constructor(textureName, path, isRenderTarget, width, height, targetElement)
	if not isRenderTarget then
		self.m_Texture = dxCreateTexture(path)
	else
		self.m_Texture = dxCreateRenderTarget(width, height, true)

		if path then
			dxSetRenderTarget(texture)
			dxDrawImage(0, 0, width, height, path)
			dxSetRenderTarget(nil)
		end
	end

	self.m_Shader = dxCreateShader("files/shader/texreplace.fx")
	if not self.m_Shader then
		error("Loading the shader failed")
	end

	engineApplyShaderToWorldTexture(self.m_Shader, textureName)
	if not targetElement then
		dxSetShaderValue(self.m_Shader, "gTexture", self.m_Texture)
	else
		dxSetShaderValue(self.m_Shader, "gTexture", self.m_Texture, targetElement)
	end
end

function TextureReplace:destructor()
	destroyElement(self.m_Texture)
	destroyElement(self.m_Shader)
end

function TextureReplace:getTexture()
	return self.m_Texture
end

function TextureReplace:getShader()
	return self.m_Shader
end
