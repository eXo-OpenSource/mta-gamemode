FileTextureReplacer = inherit(TextureReplacer)
FileTextureReplacer.ClientPath = "files/images/Textures/%s"

-- normal methods
function FileTextureReplacer:constructor(element, fileName, textureName, options)
	assert(fileName and fileName:len() > 0, "Bad Argument @ FileTextureReplacer:constructor #2")
	TextureReplacer.constructor(self, element, textureName, options)

	self.m_FileName = fileName:gsub("files/images/Textures/", "")

	if isElementStreamedIn(self.m_Element) then
		self:load()
	end
end

function FileTextureReplacer:destructor()
	TextureReplacer.destructor(self)
end

function FileTextureReplacer:load()
	if not self.m_FileName then return delete(self) end

	self.m_Texture = TextureReplacer.getCached(FileTextureReplacer.ClientPath:format(self.m_FileName))
	return self:attach()
end

function FileTextureReplacer:unload()
	if not self.m_FileName then return delete(self) end

	local a = TextureReplacer.removeCached(FileTextureReplacer.ClientPath:format(self.m_FileName))
	local b = self:detach()
	return ((a and b) and TextureReplacer.Status.SUCCESS) or TextureReplacer.Status.FAILURE
end
