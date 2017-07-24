TextureReplace = inherit(Object)
TextureReplace.ServerElements = {}
TextureReplace.Cache = {}
TextureReplace.Map = {}

TextureReplace.Working = false
TextureReplace.Pending = {}

TextureReplace.Modes = {
	[1] = "onStream",
	[2] = "permanent",
	[3] = "noTexture"
}

function TextureReplace.initalize()
	TextureReplace.CurrentMode = core:get("Other", "TextureMode", 1)
	TextureReplace.setMode(TextureReplace.CurrentMode)
end

function TextureReplace.setMode(mode)
	if TextureReplace.Modes[mode] then
		TextureReplace.CurrentMode = mode
		for index, textureObject in pairs(TextureReplace.Map) do
			if TextureReplace.Modes[mode] == TextureReplace.Modes[1] then
				if textureObject.m_Element and isElement(textureObject.m_Element) and textureObject.m_Element:isStreamedIn() then
					textureObject:loadShader()
				else
					textureObject:unloadShader()
				end
			elseif TextureReplace.Modes[mode] == TextureReplace.Modes[2] then
				textureObject:loadShader()
			elseif TextureReplace.Modes[mode] == TextureReplace.Modes[3] then
				if textureObject.m_Optional then
					textureObject:unloadShader()
				end
			end
		end
		if TextureReplace.Modes[mode] == TextureReplace.Modes[3] then
		end
	else
		outputDebugString("Invalid TextureReplace Mode "..mode)
	end
end

function TextureReplace:constructor(textureName, path, isRenderTarget, width, height, targetElement, optional, onRequest)
	if not path or #path <= 5 then
		outputConsole("Texturepath "..path.." is blow 6 chars traceback in Console")
		traceback()
	end
	if not textureName or #textureName <= 5 then
		outputConsole("TextureName "..textureName.." is blow 6 chars traceback in Console")
		traceback()
	end
	self.m_Width = width
	self.m_Height = height
	self.m_TextureName = textureName
	self.m_TexturePath = path
	self.m_IsRenderTarget = isRenderTarget
	self.m_Element = targetElement
	self.m_Optional = optional
	self.m_OnRequest = onRequest
	if TextureReplace.Modes[TextureReplace.CurrentMode] ~= TextureReplace.Modes[3] or not optional then
		if not self.m_Element then
			self:loadShader()
		else
			if (TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[1] and isElementStreamedIn(self.m_Element)) or TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[2] then
				self:loadShader()
			end
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
			TextureReplace.unloadCache(self.m_TexturePath)
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
	if TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[3] and self.m_Optional then
		return
	end

	if TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[1] or (TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[3] and not self.m_Optional ) or  (TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[2] and not self.m_OnRequest ) then
		TextureReplace.Pending[source] = self
		if not TextureReplace.Working then
			TextureReplace.loadingQueue()
		end
	end
end

function TextureReplace:onElementStreamOut()
	--outputConsole(("Element %s streamed out, destroying texture..."):format(tostring(self.m_Element)))
	if (TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[3] and self.m_Optional) or TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[2] then
		return
	end

	TextureReplace.Pending[source] = nil
	if not self:unloadShader() then
		outputDebugString(("Unloading the texture of %s failed!"):format(inspect(self.m_Element)))
	end
end

function TextureReplace:getTexture()
	return self.m_Texture
end

function TextureReplace:getShader()
	return self.m_Shader
end

function TextureReplace:loadShader()
	if TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[3] and self.m_Optional then
		return
	end
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
	else
		if type(self.m_Texture) ~= "userdata" or not isElement(self.m_Texture) then
			outputDebugString("Loading the texture failed! ("..self.m_TexturePath..")")
			self.m_Shader:destroy()
			return false
		else
			if isElement(self.m_Texture) then
				if not getElementType(self.m_Texture) == "texture" then
					outputDebugString("Loading the texture failed! ("..self.m_TexturePath..")")
					self.m_Shader:destroy()
					return false
				end
			end
		end
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
	local a = TextureReplace.unloadCache(self.m_TexturePath, self.m_Optional)
	local b = destroyElement(self.m_Shader)
	--outputDebug(inspect(self.m_Element).." cache unloaded: "..inspect(a).." shader destroyed: "..inspect(b))
	return a and b
end

function TextureReplace.getCachedTexture(path, instance)
	if path:find("files/images/Textures/Custom/") then
		path = path..".texture"
	end
	local index = md5(path):sub(1, 8)
	if not TextureReplace.Cache[index] then
		if not fileExists(path) then
			if #path:sub(30, #path-8) > 5 then
				--outputChatBox(("#FF0000Some texture are getting downloaded and may not get displayed correctly! (%s)"):format(path), 255, 255, 255, true)
				--							 remove .texture extension
				TextureReplace.downloadTexture(path:sub(30, #path-8),
					function(success)
						if success then
							local membefore = dxGetStatus().VideoMemoryUsedByTextures
							local pathExisting = TextureReplace.getRawTexture(path)
							if pathExisting then
								local dxTex = dxCreateTexture(pathExisting, "dxt1",true, "clamp", "2d", 1)
								TextureReplace.Cache[index] = {memusage = 0; path = path; counter = 0; texture = dxTex;}
								instance:loadShader()
							end
						end
					end
				)

				return false
			else
				if DEBUG then
					outputConsole("Texturepath "..path.." is blow 6 chars traceback in Console")
					traceback()
				end
			end
		end

		local membefore = dxGetStatus().VideoMemoryUsedByTextures
		local createFromPath = TextureReplace.getRawTexture(path)
		if createFromPath then
			local dxTexture = dxCreateTexture(createFromPath, "dxt1",true, "clamp", "2d", 1)
			TextureReplace.Cache[index] = {memusage = 0; path = path; counter = 0; texture = dxTexture;}
			TextureReplace.Cache[index].memusage = (dxGetStatus().VideoMemoryUsedByTextures - membefore)
		else
			outputDebugString("Could not locate file: "..path.."!")
			return false
		end
	end

	TextureReplace.Cache[index].counter = TextureReplace.Cache[index].counter + 1
	--outputConsole("incremented texture counter of "..path.." to "..TextureReplace.Cache[path].counter)
	return TextureReplace.Cache[index].texture
end

function TextureReplace.unloadCache(path, optional)
	if path:find("files/images/Textures/Custom/") then
		path = path..".texture"
	end
	local index = md5(path):sub(1, 8)
	if not TextureReplace.Cache[index] then return false end
	TextureReplace.Cache[index].counter = TextureReplace.Cache[index].counter - 1
	--outputConsole("decremented texture counter of "..path.." to "..TextureReplace.Cache[path].counter)

	if TextureReplace.Cache[index].counter <= 0 then
		--outputConsole("destroying texture "..path)
		if not optional then
			local result = destroyElement(TextureReplace.Cache[index].texture)
			TextureReplace.Cache[index] = nil
			return result
		else
			return true
		end
	end

	return true
end

function TextureReplace.downloadTexture(path, callback)
	Async.create(
		function()
			local dgi = HTTPMinimalDownloadGUI:new()
			local provider = HTTPProvider:new(TEXTURE_HTTP_URL, dgi)
			if provider:startCustom(path, "files/images/Textures/Custom/", true) then -- did the download succeed
				delete(dgi)
				if callback then callback(true) end
			else
				setTimer(function() delete(dgi) end, 10000, 1)
				if callback then callback(false) end
			end
		end
	)()
end

function TextureReplace.getRawTexture(path)
	if path:sub(-8, #path) ~= ".texture" then -- is not encrypted
		return path
	else -- is encrypted
		local file = fileOpen(path)
		if file then
			local data = file:read(file:getSize())
			file:close()

			return base64Decode(data)
		else
			return false
		end
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
			--outputDebug("new texture for "..inspect(vehData.vehicle).." optional: "..inspect(vehData.optional))
			if string.find(vehData.texturePath, "http") then
				TextureReplace.ServerElements[vehData.vehicle][vehData.textureName] = HTTPTextureReplacer:new(vehData.vehicle, vehData.texturePath, vehData.textureName)
			else
				TextureReplace.ServerElements[vehData.vehicle][vehData.textureName] = FileTextureReplacer:new(vehData.vehicle, vehData.texturePath, vehData.textureName)
			end
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

function TextureReplace.loadingQueue()
	--[[
	if TextureReplace.Modes[TextureReplace.CurrentMode] == TextureReplace.Modes[3] then
		TextureReplace.Pending = {}
		TextureReplace.Working = false
		return
	end
	--]]
	TextureReplace.Working = true
	for veh, obj in pairs(TextureReplace.Pending) do
		if not obj:loadShader() then
			outputDebugString(("Loading the texture of element %s failed!"):format(tostring(obj.m_Element)))
		end
		TextureReplace.Pending[veh] = nil
		setTimer(TextureReplace.loadingQueue, 50, 1)
		return
	end
	TextureReplace.Working = false
end
