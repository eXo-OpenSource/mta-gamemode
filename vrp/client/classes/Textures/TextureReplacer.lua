TextureReplacer = inherit(Object)
TextureReplacer.Map = {
	SERVER = {},
	SHARED = {},
	TEXTURE_CACHE = {}
}
TextureReplacer.Status = {
	SUCCESS = 1,
	FAILURE = 2,
	DELAYED = 3
}

-- abstract methods
TextureReplacer.load   = pure_virtual
TextureReplacer.unload = pure_virtual

-- normal methods
function TextureReplacer:constructor(element, textureName, options)
	assert(isElement(element), "Bad Argument @ TextureReplacer:constructor #1")

	self.m_Id          = #TextureReplacer.Map.SHARED + 1
	self.m_Element     = element
	self.m_TextureName = textureName
	self.m_LoadingMode = core:get("Other", "TextureMode", 1)
	self.m_Active      = true

	self.m_OnElementDestory   = bind(delete, self)
	self.m_OnElementStreamOut = bind(self.onStramIn, self)
	self.m_OnElementStreamIn  = bind(self.onStramOut, self)
	TextureReplacer.Map.SHARED[self.m_Id] = self

	addEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestory)
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		addEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
		addEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
	elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.PERMANENT then
		self:load()
	elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.NONE then
		self.m_Active = false
	end
end

function TextureReplacer:destructor()
	self:unload()

	-- Remove events
	if self.m_Element and isElement(self.m_Element) then -- does the element still exist?
		removeEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestory)
		if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
			removeEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
			removeEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
		end
	end
end

function TextureReplacer:onStramIn()
	if not self.m_Active then return false end
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		self:load()
	end
end

function TextureReplacer:onStramOut()
	if not self.m_Active then return false end
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		self:unload()
	end
end

function TextureReplacer:attach()
	if not self.m_Active then return TextureReplacer.Status.FAILURE end
	if not self.m_Texture then return TextureReplacer.Status.FAILURE end
	if self.m_Shader then return TextureReplacer.Status.FAILURE end

	self.m_Shader = DxShader("files/shader/texreplace.fx")
	if not self.m_Shader then
		self.m_Active = false
		error(("Error @ TextureReplacer:attach, shader failed to create! [Id: %d, Element: %s]"):format(self.m_Id, inspect(self.m_Element)))
	end

	self.m_Shader:setValue("gTexture", self.m_Texture)
	local status = self.m_Shader:applyToWorldTexture(self.m_TextureName, self.m_Element)
	return status and TextureReplacer.Status.SUCCESS or TextureReplacer.Status.FAILURE
end

function TextureReplacer:detach()
	if not self.m_Shader or not isElement(self.m_Shader) then return TextureReplacer.Status.FAILURE end

	self.m_Shader:destroy()
	if self.m_Shader then self.m_Shader = nil end
	if self.m_Texture then self.m_Texture = nil end
	return TextureReplacer.Status.SUCCESS
end

-- Cache methods
function TextureReplacer.getCached(path)
	if not TextureReplacer.Map.TEXTURE_CACHE[path] then
		local pixels = TextureReplacer.getPixels(path) or path -- if we dont have a pixels file use normal load
		TextureReplacer.Map.TEXTURE_CACHE[path] = {
			texture = DxTexture(pixels),
			counter = 0,
			tick    = getTickCount(),
		}
	end

	TextureReplacer.Map.TEXTURE_CACHE[path].counter = TextureReplacer.Map.TEXTURE_CACHE[path].counter + 1
	return TextureReplacer.Map.TEXTURE_CACHE[path].texture
end

function TextureReplacer.removeCached(path)
	if TextureReplacer.Map.TEXTURE_CACHE[path] then
		TextureReplacer.Map.TEXTURE_CACHE[path].counter = TextureReplacer.Map.TEXTURE_CACHE[path].counter - 1
		if TextureReplacer.Map.TEXTURE_CACHE[path].counter <= 0 then
			TextureReplacer.Map.TEXTURE_CACHE[path].texture:destroy()
			TextureReplacer.Map.TEXTURE_CACHE[path] = nil
		end

		return true
	end

	return false
end

function TextureReplacer.getPixels(path)
	local filePath = ("%s.pixels"):format(path)
	local pixels = false
	if fileExists(filePath) then
		local file = fileOpen(filePath)
		if file then
			pixels = fileRead(file, fileGetSize(file))
			fileClose(file)
		end
	end

	return pixels
end
