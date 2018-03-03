TextureReplacer = inherit(Object)
TextureReplacer.Map = {
	SERVER_ELEMENTS = {},
	SHARED_ELEMENTS = {},
	STATIC_ELEMENTS = {}
}
TextureReplacer.Status = {
	SUCCESS = 1,
	FAILURE = 2,
	DELAYED = 3,
	DENIED = 4
}
TextureReplacer.Backlog = {}
TextureReplacer.Queue = Queue:new()
TextureReplacer.Queue.clear = function(self)
	Queue.clear(self)
	self.m_CurrentLoaded = 0
	self.m_Count = 0
end

-- abstract methods
TextureReplacer.load   = pure_virtual
TextureReplacer.unload = pure_virtual

-- normal methods
function TextureReplacer:constructor(element, textureName, options)
	assert(textureName and textureName:len() > 0, "Bad Argument @ TextureReplacer:constructor #2")

	self.m_Element     = element
	self.m_TextureName = textureName
	self.m_LoadingMode = core:get("Other", "TextureMode", TEXTURE_LOADING_MODE.DEFAULT)
	self.m_Active      = true

	self.m_OnElementDestroy   = bind(delete, self)
	self.m_OnElementStreamIn  = bind(self.onStreamIn, self)
	self.m_OnElementStreamOut = bind(self.onStreamOut, self)

	if self.m_Element then
		assert(isElement(element), "Bad Argument @ TextureReplacer:constructor #1")
		addEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestroy, false)
		if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
			addEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
			addEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
			if isElementStreamedIn(self.m_Element) then
				self:onStreamIn()
			end
		elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.PERMANENT then
			table.insert(TextureReplacer.Backlog, self)
		elseif self.m_LoadingMode == TEXTURE_LOADING_MODE.NONE then
			self.m_Active = false
		end
	end

	-- Save instance to map
	TextureReplacer.addRef(self)
end

function TextureReplacer:destructor()
	-- Unload texture
	self:unload()

	-- Remove Map ref
	TextureReplacer.removeRef(self)

	-- Remove events
	if self.m_Element and isElement(self.m_Element) then -- does the element still exist?
		removeEventHandler("onClientElementDestroy", self.m_Element, self.m_OnElementDestroy)
		if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
			removeEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
			removeEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
		end
	end
end

function TextureReplacer:onStreamIn()
	if not self.m_Active then return false end
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		self:addToLoadingQeue()
	end
end

function TextureReplacer:onStreamOut()
	if not self.m_Active then return false end
	if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
		self:unload()
	end
end

function TextureReplacer:attach()
	if not self.m_Active then return TextureReplacer.Status.DENIED end
	if not self.m_Texture or not isElement(self.m_Texture) then return TextureReplacer.Status.FAILURE end
	if self.m_Shader then return TextureReplacer.Status.FAILURE end

	self.m_Shader = DxShader("files/shader/texreplace.fx", 0, 0, false, "all")
	if not self.m_Shader then
		self.m_Active = false
		error(("Error @ TextureReplacer:attach, shader failed to create! [Element: %s]"):format(inspect(self.m_Element or "STATIC")))
	end

	self.m_Shader:setValue("gTexture", self.m_Texture)
	if self.m_Element then
		return self.m_Shader:applyToWorldTexture(self.m_TextureName, self.m_Element) and TextureReplacer.Status.SUCCESS or TextureReplacer.Status.FAILURE
	else
		return self.m_Shader:applyToWorldTexture(self.m_TextureName) and TextureReplacer.Status.SUCCESS or TextureReplacer.Status.FAILURE
	end
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

	if self.m_Element then
		if self.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
			removeEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
			removeEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
		end

		if loadingMode == TEXTURE_LOADING_MODE.STREAM then
			addEventHandler("onClientElementStreamOut", self.m_Element, self.m_OnElementStreamOut)
			addEventHandler("onClientElementStreamIn", self.m_Element, self.m_OnElementStreamIn)
			if isElementStreamedIn(self.m_Element) then
				self:onStreamIn()
			end
		elseif loadingMode == TEXTURE_LOADING_MODE.PERMANENT then
			self:addToLoadingQeue()
		elseif loadingMode == TEXTURE_LOADING_MODE.NONE then
			self.m_Active = false
		end
	end
	self.m_LoadingMode = loadingMode
end

function TextureReplacer.addRef(instance)
	if instance.m_Element then
		if not TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element] then
			TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element] = {}
		end
		TextureReplacer.Map.SHARED_ELEMENTS[instance.m_Element][instance.m_TextureName] = instance
	else
		TextureReplacer.Map.STATIC_ELEMENTS[instance.m_TextureName] = instance
	end
end

function TextureReplacer.removeRef(instance)
	if instance.m_Element then
		for i, tab in pairs(TextureReplacer.Map.SHARED_ELEMENTS) do
			for j, inst in pairs(tab) do
				if instance == inst then
					TextureReplacer.Map.SHARED_ELEMENTS[i][j] = nil
				end
			end
		end
	else
		for i, tab in pairs(TextureReplacer.Map.STATIC_ELEMENTS) do
			if instance == inst then
				TextureReplacer.Map.STATIC_ELEMENTS[i][j] = nil
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
	if instanceof(self, FileTextureReplacer) and not core:get("Other", "FileTexturesEnabled", true) then
		self:unload()
		return false
	end
	if instanceof(self, HTTPTextureReplacer) and not core:get("Other", "HTTPTexturesEnabled", true) then
		self:unload()
		return false
	end

	if TextureReplacer.Queue:empty() then
		TextureReplacer.Queue:push(self)
		TextureReplacer.Queue.m_Count = (TextureReplacer.Queue.m_Count or 0) + 1

		TextureReplacer.Queue.m_CurrentLoaded = 0
		TinyInfoLabel:getSingleton():setText(_"Achtung: 0 / 1 Custom Textur(en) werden geladen")

		local thread = Thread:new(TextureReplacer.loadTextures, 75)
		nextframe(function() thread:start() end)
	else
		TextureReplacer.Queue:push(self)
		TextureReplacer.Queue.m_Count = (TextureReplacer.Queue.m_Count or 0) + 1
	end
end

function TextureReplacer.loadTextures()
	while (not TextureReplacer.Queue:empty()) do
		local instance = TextureReplacer.Queue:pop()
		if instance.m_Element then
			local status = instance:load()
			if stauts == TextureReplacer.Status.FAILURE or status == TextureReplacer.Status.DENIED then
				ErrorBox:new(_("Folgende Custom-Textur konnte nicht geladen werden: {%s, %s}", instance.m_FileName, inspect(instance.m_Element)))
			end

			TextureReplacer.Queue.m_CurrentLoaded = TextureReplacer.Queue.m_CurrentLoaded + 1
			TinyInfoLabel:getSingleton():setText(_("Achtung: %s / %s Custom Textur(en) werden geladen", TextureReplacer.Queue.m_CurrentLoaded, TextureReplacer.Queue.m_Count))

			Thread.pause()
		end
	end

	TextureReplacer.Queue.m_CurrentLoaded = 0
	TextureReplacer.Queue.m_Count = 0
	TinyInfoLabel:getSingleton():clearText()
end

--// Static Helper
function TextureReplacer.changeLoadingMode(loadingMode)
	-- clear queue to cancel current loading requests
	TextureReplacer.Queue:clear()

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

function TextureReplacer.forceReload()
	-- clear queue to cancel current loading requests
	TextureReplacer.Queue:clear()

	for textureName, tab in pairs(TextureReplacer.Map.SHARED_ELEMENTS) do
		for i, instance in pairs(tab) do
			if instanceof(instance, TextureReplacer, false) then
				if instance.m_Element then
					instance:unload()
					if instance.m_LoadingMode == TEXTURE_LOADING_MODE.STREAM then
						if isElementStreamedIn(instance.m_Element) then
							instance:onStreamIn()
						end
					elseif instance.m_LoadingMode == TEXTURE_LOADING_MODE.PERMANENT then
						instance:addToLoadingQeue()
					end
				end
			end
		end
	end
end

function TextureReplacer.loadBacklog()
	for i, instance in pairs(TextureReplacer.Backlog) do
		instance:addToLoadingQeue()
	end
	TextureReplacer.Backlog = {}
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

		-- force loading of new textures (in permanent mode)
		TextureReplacer.loadBacklog()
	end
)

addEvent("removeElementTexture", true)
addEventHandler("removeElementTexture", root,
	function(textureName)
		if TextureReplacer.Map.SERVER_ELEMENTS[source] and TextureReplacer.Map.SERVER_ELEMENTS[source][textureName] then
			delete(TextureReplacer.Map.SERVER_ELEMENTS[source][textureName])
			TextureReplacer.Map.SERVER_ELEMENTS[source][textureName] = nil

			if table.size(TextureReplacer.Map.SERVER_ELEMENTS[source]) <= 0 then
				TextureReplacer.Map.SERVER_ELEMENTS[source] = nil
			end
		end
	end
)
