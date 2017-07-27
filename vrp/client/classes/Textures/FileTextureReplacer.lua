FileTextureReplacer = inherit(TextureReplacer)
FileTextureReplacer.ClientPath = "files/images/Textures/%s"

-- normal methods
function FileTextureReplacer:constructor(element, fileName, textureName, options)
	TextureReplacer.constructor(self, element, textureName, options)

	self.m_FileName = fileName:find("files/images/Textures/") and fileName:gsub("files/images/Textures/", "") or fileName

	if isElementStreamedIn(self.m_Element) then
		self:load()
	end
end

function FileTextureReplacer:destructor()
	TextureReplacer.destructor(self)
end

function FileTextureReplacer:load()
	self.m_Texture = TextureReplacer.getCached(FileTextureReplacer.ClientPath:format(self.m_FileName))
	return self:attach()
end

function FileTextureReplacer:unload()
	local a = TextureReplacer.removeCached(FileTextureReplacer.ClientPath:format(self.m_FileName))
	local b = self:detach()
	return ((a and b) and TextureReplacer.Status.SUCCESS) or TextureReplacer.Status.FAILURE
end
