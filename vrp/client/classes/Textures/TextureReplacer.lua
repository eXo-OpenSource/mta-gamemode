TextureReplacer = inherit(Object)
TextureReplacer.Map = {
	SERVER_ELEMENTS = {},
	SHARED_ELEMENTS = {},
	TEXTURE_CACHE = {}
}
TextureReplacer.Status = {
	SUCCESS = 1,
	FAILURE = 2,
	DELAYED = 3,
	DENIED = 4
}
TextureReplacer.Backlog = {}
TextureReplacer.Queue = Queue:new()

-- abstract methods
TextureReplacer.load   = pure_virtual
TextureReplacer.unload = pure_virtual

-- normal methods
function TextureReplacer:constructor(element, textureName, options)
	assert(isElement(element), "Bad Argument @ TextureReplacer:constructor #1")
	assert(textureName and textureName:len() > 0, "Bad Argument @ TextureReplacer:constructor #2")

	self.m_Element     = element
	self.m_TextureName = textureName
	self.m_LoadingMode = core:get("Other", "TextureMode", 1)
	self.m_Active      = true

	self.m_OnElementDestory   = bind(delete, self)
	self.m_OnElementStreamIn  = bind(self.onStramIn, self)
	self.m_OnElementStreamOut = bind(self.onStramOut, self)

	addEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestory, false)
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		addEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
		addEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
		if isElementStreamedIn(self.m_Element) then
			self:onStramIn()
		end
	elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.PERMANENT then
		table.insert(TextureReplacer.Backlog, self)
	elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.NONE then
		self.m_Active = false
	end

	-- Save instance to map
	TextureReplacer.addRef(self)
end

function TextureReplacer:destructor()
	-- Remove Map ref
	TextureReplacer.removeRef(self)

	-- Unload texture
	self:unload()

	-- Remove events
	if isElement(self.m_Element) then -- does the element still exist?
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
		self:addToLoadingQeue()
	end
end

function TextureReplacer:onStramOut()
	if not self.m_Active then return false end
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		self:unload()
	end
end

function TextureReplacer:attach()
	if not self.m_Active then return TextureReplacer.Status.DENIED end
	if not self.m_Texture and not isElement(self.m_Texture) then return TextureReplacer.Status.FAILURE end
	if self.m_Shader then return TextureReplacer.Status.FAILURE end

	self.m_Shader = DxShader("files/shader/texreplace.fx")
	if not self.m_Shader then
		self.m_Active = false
		error(("Error @ TextureReplacer:attach, shader failed to create! [Element: %s]"):format(inspect(self.m_Element)))
	end

	self.m_Shader:setValue("gTexture", self.m_Texture)
	local status = self.m_Shader:applyToWorldTexture(self.m_TextureName, self.m_Element)

	-- process next texture
	if DEBUG then
		nextframe(TextureReplacer.loadNext)
	else
		setTimer(TextureReplacer.loadNext, 250, 1)
	end

	return status and TextureReplacer.Status.SUCCESS or TextureReplacer.Status.FAILURE
end

function TextureReplacer:detach()
	if not self.m_Active then return TextureReplacer.Status.DENIED end
	if not self.m_Shader or not isElement(self.m_Shader) then return TextureReplacer.Status.FAILURE end

	self.m_Shader:destroy()
	if self.m_Texture and isElement(self.m_Texture) then self.m_Texture:destroy() end
	if self.m_Shader then self.m_Shader = nil end
	if self.m_Texture then self.m_Texture = nil end
	return TextureReplacer.Status.SUCCESS
end

function TextureReplacer:setLoadingMode(loadingMode)
	if loadingMode == self.m_LoadingMode then return false end
	self.m_Active = true
	self:unload()

	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		removeEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
		removeEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
	end

	if loadingMode == TEXTURE_LOADING_MODE.STREAM then
		addEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
		addEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
		if isElementStreamedIn(self.m_Element) then
			self:onStramIn()
		end
	elseif loadingMode == TEXTURE_LOADING_MODE.PERMANENT then
		self:addToLoadingQeue()
	elseif loadingMode == TEXTURE_LOADING_MODE.NONE then
		self.m_Active = false
	end
	self.m_LoadingMode = loadingMode
end

-- Cache methods
function TextureReplacer.getCached(path)
	if not TextureReplacer.Map.TEXTURE_CACHE[path] then
		local pixels = path
		if path:find(".pixels") then
			pixels = TextureReplacer.getPixels(path) -- if we dont have a pixels file use normal load
		end
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
			local texture = TextureReplacer.Map.TEXTURE_CACHE[path].texture
			if texture and isElement(texture) then texture:destroy() end
			TextureReplacer.Map.TEXTURE_CACHE[path] = nil
		end

		return true
	end

	return false
end

-- // Helper
function TextureReplacer.getPixels(path)
	local pixels = false
	if fileExists(path) then
		local file = fileOpen(path)
		if file then
			pixels = fileRead(file, fileGetSize(file))
			fileClose(file)
		end
	end

	return pixels
end

function TextureReplacer.addRef(instance)
	if not TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element] then
		TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element] = {}
	end
	TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element][instance.m_TextureName] = instance
end

function TextureReplacer.removeRef(instance)
	--outputConsole(inspect(TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element][instance.m_TextureName]))

	--TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element][instance.m_TextureName] = nil
	for i, tab in pairs(TextureReplacer.Map.SHARED_ELEMENTS) do
		for j, inst in pairs(tab) do
			if instance == inst then
				TextureReplacer.Map.SHARED_ELEMENTS[i][j] = nil
			end
		end
	end
end

function TextureReplacer.deleteFromElement(element)
	if not TextureReplacer.Map.SHARED_ELEMENTS[element] then return false end
	for i, v in pairs(TextureReplacer.Map.SHARED_ELEMENTS[element]) do
		delete(v)
	end
	TextureReplacer.Map.SHARED_ELEMENTS[element] = nil
end

--// Queue
function TextureReplacer:addToLoadingQeue()
	TextureReplacer.Queue:push_back(self)
	TextureReplacer.Queue.m_Count = (TextureReplacer.Queue.m_Count or 0) + 1
	if not TextureReplacer.Queue:locked() then
		TextureReplacer.Queue:lock()

		TextureReplacer.Queue.m_CurrentLoaded = 0
		TextureReplacer.Queue.m_ShortMessage = ShortMessage:new(_("Achtung: Custom Texturen werden geladen, dies kann einen kleinen Lag verursachen!\nStatus: 0 / 1 Textur(en)"), nil, nil, math.huge)

		TextureReplacer.loadNext()
	end
end

function TextureReplacer.loadNext()
	if TextureReplacer.Queue:empty() then
		TextureReplacer.Queue:unlock()

		if TextureReplacer.Queue.m_ShortMessage then
			TextureReplacer.Queue.m_Count = 0
			delete(TextureReplacer.Queue.m_ShortMessage)
		end
	else
		TextureReplacer.Queue.m_CurrentLoaded = TextureReplacer.Queue.m_CurrentLoaded + 1
		TextureReplacer.Queue.m_ShortMessage.m_Text = _("Achtung: Custom Texturen werden geladen, dies kann einen kleinen Lag verursachen!\nStatus: %d / %d Textur(en)", TextureReplacer.Queue.m_CurrentLoaded, TextureReplacer.Queue.m_Count)
		TextureReplacer.Queue.m_ShortMessage:anyChange()

		local status = TextureReplacer.Queue:pop_back(1):load()
		if status == TextureReplacer.Status.FAILURE or status == TextureReplacer.Status.DENIED then
			TextureReplacer.loadNext()
		end
	end
end

--// Static Helper
function TextureReplacer.changeLoadingMode(loadingMode)
	for textureName, tab in pairs(TextureReplacer.Map.SHARED_ELEMENTS) do
		for i, instance in pairs(tab) do
			if instanceof(instance, TextureReplacer, false) then
				instance:setLoadingMode(loadingMode)
			else
				outputDebug("Found invalid SHARED_ELEMENT Instance! ("..tostring(textureName)..":"..tostring(i)..")")
			end
		end
	end
end

function TextureReplacer.loadBacklog()
	for i, instance in pairs(TextureReplacer.Backlog) do
		instance:addToLoadingQeue()
	end
end

-- Events
addEvent("changeElementTexture", true)
addEventHandler("changeElementTexture", root,
	function(vehicles)
		for i, vehData in pairs(vehicles) do
			if not TextureReplacer.Map.SERVER_ELEMENTS[vehData.vehicle] then
				TextureReplacer.Map.SERVER_ELEMENTS[vehData.vehicle] = {}
			end

			if TextureReplacer.Map.SERVER_ELEMENTS[vehData.vehicle][vehData.textureName] then
				delete(TextureReplacer.Map.SERVER_ELEMENTS[vehData.vehicle][vehData.textureName])
			end
			--outputDebug("new texture for "..inspect(vehData.vehicle).." optional: "..inspect(vehData.optional))
			if string.find(vehData.texturePath, "https://") or string.find(vehData.texturePath, "http://") then
				TextureReplacer.Map.SERVER_ELEMENTS[vehData.vehicle][vehData.textureName] = HTTPTextureReplacer:new(vehData.vehicle, vehData.texturePath, vehData.textureName)
			else
				TextureReplacer.Map.SERVER_ELEMENTS[vehData.vehicle][vehData.textureName] = FileTextureReplacer:new(vehData.vehicle, vehData.texturePath, vehData.textureName)
			end
		end
	end
)

addEvent("removeElementTexture", true)
addEventHandler("removeElementTexture", root,
	function(textureName)
		if TextureReplacer.Map.SERVER_ELEMENTS[source] and TextureReplacer.Map.SERVER_ELEMENTS[source][textureName] then
			delete(TextureReplacer.Map.SERVER_ELEMENTS[source][textureName])
			TextureReplacer.Map.SERVER_ELEMENTS[source][textureName] = nil
		end

		if table.size(TextureReplacer.Map.SERVER_ELEMENTS[source]) <= 0 then
			TextureReplacer.Map.SERVER_ELEMENTS[source] = nil
		end
	end
)
