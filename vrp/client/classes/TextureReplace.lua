TextureReplace = inherit(Object)
TextureReplace.ServerElements = {}

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
		outputDebugString("Loading the shader failed")
		return
	end

	if not self.m_Texture then
		outputDebugString("Loading the texture failed! "..textureName)
		return
	end

	dxSetShaderValue(self.m_Shader, "gTexture", self.m_Texture)
	if targetElement then
		engineApplyShaderToWorldTexture(self.m_Shader, textureName, targetElement)
		addEventHandler("onClientElementDestroy", targetElement, function () delete(self) end)
	else
		engineApplyShaderToWorldTexture(self.m_Shader, textureName)
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

-- Events
addEvent("changeElementTexture", true)
addEventHandler("changeElementTexture", root,
	function (element, ...)
		if type(element) == "table" then
			for i, shaderInfo in pairs(element) do
				if TextureReplace.ServerElements[shaderInfo.vehicle] then
					delete(TextureReplace.ServerElements[shaderInfo.vehicle])
				end
				TextureReplace.ServerElements[shaderInfo.vehicle] = TextureReplace:new(shaderInfo.textureName or shaderInfo.vehicle:getTextureName(), shaderInfo.texturePath, false, 256, 256, shaderInfo.vehicle)
			end
		else
			if TextureReplace.ServerElements[element] then
				delete(TextureReplace.ServerElements[element])
			end
			TextureReplace.ServerElements[element] = TextureReplace:new(..., element)
		end
	end
)

addEvent("removeElementTexture", true)
addEventHandler("removeElementTexture", root,
	function (element)
		if TextureReplace.ServerElements[element] then
			delete(TextureReplace.ServerElements[element])
		end
	end
)
