TextureReplace = inherit(Object)
TextureReplace.ServerElements = {}
TextureReplace.Cache = {}
TextureReplace.Map = {}
TextureReplace.TextureEncryptionKey = hash("sha256", "TextureReplace:TEXTURE_KEY:exoIsBest")

function TextureReplace:constructor(textureName, path, isRenderTarget, width, height, targetElement)
	if not path or #path <= 5 then
		outputConsole("Texturepath is blow 6 chars traceback in Console")
		traceback()
	end
	if not textureName or #textureName <= 5 then
		outputConsole("TextureName is blow 6 chars traceback in Console")
		traceback()
	end
	self.m_Width = width
	self.m_Height = height
	self.m_TextureName = textureName
	self.m_TexturePath = path
	self.m_IsRenderTarget = isRenderTarget
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

	TextureReplace.Map[#TextureReplace.Map+1] = self
end

function TextureReplace:destructor()
	if self.m_Texture and isElement(self.m_Texture) then
		if self.m_IsRenderTarget then
			destroyElement(self.m_Texture)
		else
			TextureReplace.unloadCache(self.m_TexturePath, self.m_IsRawPixels, self.m_URLPath)
		end
	end
	if self.m_Shader and isElement(self.m_Shader) then
		destroyElement(self.m_Shader)
	end

	-- Remove events
	if self.m_Element and isElement(self.m_Element) then -- does the element still exist?
		removeEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestory)
		removeEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
		removeEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
	end
end

function TextureReplace:onElementStreamIn()
	--outputConsole(("Element %s streamed in, creating texture..."):format(tostring(self.m_Element)))
	if not self:loadShader() then
		outputConsole(("Loading the texture of element %s failed!"):format(tostring(self.m_Element)))
	end
end

function TextureReplace:onElementStreamOut()
	--outputConsole(("Element %s streamed out, destroying texture..."):format(tostring(self.m_Element)))
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
		self.m_Texture = TextureReplace.getCachedTexture(self.m_TexturePath, self)
	else
		self.m_Texture = dxCreateRenderTarget(self.m_Width, self.m_Height, true)
		if self.m_TexturePath then
			dxSetRenderTarget(self.m_Texture)
				dxDrawImage(0, 0, width, height, path)
			dxSetRenderTarget(nil)
		end
	end

	if (dxGetStatus().VideoMemoryUsedByTextures - membefore) > 10 then
		delete(self)
		error(("Texture memory usage above 10mb! Data: [Path: %s, textureName: %s, isRenderTarget: %s, width: %s, height: %s, targetElement: %s]"):format(tostring(self.m_TexturePath), tostring(self.m_TextureName), tostring(self.m_IsRenderTarget), tostring(self.m_Width), tostring(self.m_Height), tostring(self.m_Element)))
	end

	self.m_Shader = dxCreateShader("files/shader/texreplace.fx")
	if not self.m_Shader then
		outputDebugString("Loading the shader failed")
		return false
	end

	if not self.m_Texture then
		outputDebugString("Loading the texture failed! ("..self.m_TexturePath..")")
		self.m_Shader:destroy()

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
	local a = TextureReplace.unloadCache(self.m_TexturePath)
	local b = destroyElement(self.m_Shader)
	return a and b
end

function TextureReplace.getCachedTexture(path, instance)
	if path:find("files/images/Textures/Custom/") then
		path = path..".texture"
	end
	local index = md5(path):sub(1, 8)
	if bIsRawPixels then
		index = url
	end
	if not TextureReplace.Cache[index] then
		if not fileExists(path) then
			if #path:sub(30, #path-8) > 5 then
				outputChatBox(("#FF0000Some texture are getting downloaded and may not get displayed correctly! (%s)"):format(path), 255, 255, 255, true)
				--							 remove .texture extension
				TextureReplace.downloadTexture(path:sub(30, #path-8),
					function(success)
						if success then
							local membefore = dxGetStatus().VideoMemoryUsedByTextures
							TextureReplace.Cache[index] = {memusage = 0; path = path; counter = 0; texture = dxCreateTexture(path); bRemoteUrl = url}

							instance:loadShader()
						end
					end
				)

				return false
			else
				if DEBUG then
					outputConsole("Texturepath is blow 6 chars traceback in Console")
					traceback()
				end
			end
		end

		local membefore = dxGetStatus().VideoMemoryUsedByTextures
		TextureReplace.Cache[index] = {memusage = 0; path = path; counter = 0; texture = dxCreateTexture(path); bRemoteUrl = url}
		TextureReplace.Cache[index].memusage = (dxGetStatus().VideoMemoryUsedByTextures - membefore)
	end

	TextureReplace.Cache[index].counter = TextureReplace.Cache[index].counter + 1
	--outputConsole("incremented texture counter of "..path.." to "..TextureReplace.Cache[path].counter)
	return TextureReplace.Cache[index].texture
end

function TextureReplace.unloadCache(path)
	if path:find("files/images/Textures/Custom/") then
		path = path..".texture"
	end
	local index = md5(path):sub(1, 8)
	if not TextureReplace.Cache[index] then return false end
	TextureReplace.Cache[index].counter = TextureReplace.Cache[index].counter - 1
	--outputConsole("decremented texture counter of "..path.." to "..TextureReplace.Cache[path].counter)

	if TextureReplace.Cache[index].counter == 0 then
		--outputConsole("destroying texture "..path)
		local result = destroyElement(TextureReplace.Cache[index].texture)
		TextureReplace.Cache[index] = nil
		return result
	end

	return true
end

function TextureReplace.downloadTexture(path, callback)
	Async.create(
		function()
			local dgi = HTTPDownloadGUI:getSingleton()
			local provider = HTTPProvider:new(TEXTURE_HTTP_URL, dgi)
			if provider:startCustom(path, "files/images/Textures/Custom/"--[[, TextureReplace.TextureEncryptionKey]]) then -- did the download succeed
				delete(dgi)
				if callback then callback(true) end
			else
				if callback then callback(false) end
			end
		end
	)()
end

function TextureReplace.getTexture(path)
	if path:sub(-8, #path) ~= ".texture" then -- is not encrypted
		return path
	else -- is encrypted
		local file = fileOpen(path)
		local data = file:read(file:getSize())
		file:close()

		return teaDecode(data, TextureReplace.TextureEncryptionKey)
	end
end

-- Events
addEvent("changeElementTexture", true)
addEventHandler("changeElementTexture", root,
	function(vehicles)
		for i, vehData in pairs(vehicles) do
			if not TextureReplace.ServerElements[vehData.vehicle] then
				TextureReplace.ServerElements[vehData.vehicle] = {}
			end

			if TextureReplace.ServerElements[vehData.vehicle][vehData.textureName] then
				delete(TextureReplace.ServerElements[vehData.vehicle][vehData.textureName])
			end
			TextureReplace.ServerElements[vehData.vehicle][vehData.textureName] = TextureReplace:new(vehData.textureName, vehData.texturePath, false, 0, 0, vehData.vehicle, vehData.isFetchRemote, vehData.sUrl)
		end
	end
)

addEvent("removeElementTexture", true)
addEventHandler("removeElementTexture", root,
	function(textureName)
		if TextureReplace.ServerElements[source] and TextureReplace.ServerElements[source][textureName] then
			delete(TextureReplace.ServerElements[source][textureName])
			TextureReplace.ServerElements[source][textureName] = nil
		end

		if table.size(TextureReplace.ServerElements[source]) <= 0 then
			TextureReplace.ServerElements[source] = nil
		end
	end
)

function TextureReplace.deleteFromElement(element)
	for index, texture in pairs(TextureReplace.Map) do
		if texture and texture.m_Element == element then
			delete(TextureReplace.Map[index])
			TextureReplace.Map[index] = nil
		end
	end
end
