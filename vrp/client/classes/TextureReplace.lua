TextureReplace = inherit(Object)
TextureReplace.ServerElements = {}

function TextureReplace:constructor(textureName, path, isRenderTarget, width, height, targetElement)
	if not texturePath or #texturePath <= 5 then
		error(("Texturepath is blow 6 chars [traceback: %s]"):format(debug.traceback()))
	end

	self.m_TextureName = textureName
	self.m_TexturePath = path
	self.m_IsRenderTarget = isRenderTarget
	self.m_Width = width
	self.m_Height = height
	self.m_Element = targetElement

	if not self.m_Element then
		self:loadShader()
	else
		if isElementStreamedIn(self.m_Element) then
			self:loadShader()
		end
	end

	if self.m_Element then
		self.m_OnElementDestory = bind(delete, self)
		self.m_OnElementStreamOut = bind(self.onElementStreamOut, self)
		self.m_OnElementStreamIn = bind(self.onElementStreamIn, self)
		addEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestory)
		addEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
		addEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
	end
end

function TextureReplace:destructor()
	if self.m_Texture and isElement(self.m_Texture) then
		destroyElement(self.m_Texture)
	end
	if self.m_Shader and isElement(self.m_Shader) then
		destroyElement(self.m_Shader)
	end
end

function TextureReplace:onElementStreamIn()
	outputConsole(("Element %s streamed in, creating texture..."):format(tostring(self.m_Element)))
	if not self:loadShader() then
		outputConsole(("Loading the texture of element %s failed!"):format(tostring(self.m_Element)))
	end
end

function TextureReplace:onElementStreamOut()
	outputConsole(("Element %s streamed out, destroying texture..."):format(tostring(self.m_Element)))
	if not self:unloadShader() then
		outputConsole(("Unloading the texture of element %s failed!"):format(tostring(self.m_Element)))
	end
end

function TextureReplace:getTexture()
	return self.m_Texture
end

function TextureReplace:getShader()
	return self.m_Shader
end

function TextureReplace:loadShader()
	if self.m_Shader and isElement(self.m_Shader) then return false end
	if self.m_Texture and isElement(self.m_Shader) then return false end

	local membefore = dxGetStatus().VideoMemoryUsedByTextures
	if not self.m_IsRenderTarget then
		self.m_Texture = dxCreateTexture(self.m_TexturePath)
	else
		self.m_Texture = dxCreateRenderTarget(self.m_Width, self.m_Height, true)

		if self.m_TexturePath then
			dxSetRenderTarget(self.m_Texture)
				dxDrawImage(0, 0, width, height, path)
			dxSetRenderTarget(nil)
		end
	end

	if (dxGetStatus().VideoMemoryUsedByTextures - membefore) > 100 then
		delete(self)
		error(("Texture memory usage above 100mb! Data:[ Path: %s, textureName: %s, isRenderTarget: %s, width: %s, height: %s, targetElement: %s]"):format(tostring(self.m_TexturePath), tostring(self.m_TextureName), tostring(self.m_IsRenderTarget), tostring(self.m_Width), tostring(self.m_Height), tostring(self.m_Element)))
	end

	self.m_Shader = dxCreateShader("files/shader/texreplace.fx")
	if not self.m_Shader then
		outputDebugString("Loading the shader failed")
		return false
	end

	if not self.m_Texture then
		outputDebugString("Loading the texture failed! ("..self.m_TexturePath..")")
		return false
	end

	dxSetShaderValue(self.m_Shader, "gTexture", self.m_Texture)
	if self.m_Element then
		return engineApplyShaderToWorldTexture(self.m_Shader, self.m_TextureName, self.m_Element)
	else
		return engineApplyShaderToWorldTexture(self.m_Shader, self.m_TextureName)
	end
end

function TextureReplace:unloadShader()
	if not self.m_Shader or not isElement(self.m_Shader) then return false end
	if not self.m_Texture or not isElement(self.m_Texture) then return false end

	local a = destroyElement(self.m_Texture)
	local b = destroyElement(self.m_Shader)

	return a and b
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
