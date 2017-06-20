HTTPTextureReplacer = inherit(TextureReplacer)
HTTPTextureReplacer.BasePath = "http://picupload.pewx.de/textures/"
HTTPTextureReplacer.ClientPath = "files/images/Textures/remote/%s"
HTTPTextureReplacer.Queue = Stack:new()
HTTPTextureReplacer.Locked = false

-- normal methods
function HTTPTextureReplacer:constructor(element, fileName, textureName, options)
	TextureReplacer.constructor(self, element, textureName, options)

	self.m_FileName = fileName
	self.m_PixelFileName = ("%s.pixels"):format(self.m_FileName)

	if isElementStreamedIn(self.m_Element) then
		self:load()
	end
end

function HTTPTextureReplacer:destructor()
	TextureReplacer.destructor(self)
end

function HTTPTextureReplacer:load()
	if not fileExists(HTTPTextureReplacer.ClientPath:format(self.m_PixelFileName)) then
		self:addToQeue()
		return TextureReplacer.Status.DELAYED
	else
		self.m_Texture = TextureReplacer.getCached(HTTPTextureReplacer.ClientPath:format(self.m_FileName))
		return self:attach()
	end
end

function HTTPTextureReplacer:unload()
	local a = TextureReplacer.removeCached(HTTPTextureReplacer.ClientPath:format(self.m_FileName))
	local b = self:detach()
	return ((a and b) and TextureReplacer.Status.SUCCESS) or TextureReplacer.Status.FAILURE
end

-- downlaoder
function HTTPTextureReplacer:downloadTexture()
	Async.create(
		function()
			local dgi = HTTPMinimalDownloadGUI:new()
			local provider = HTTPProvider:new(HTTPTextureReplacer.BasePath, dgi)
			if provider:startCustom(self.m_FileName, HTTPTextureReplacer.ClientPath:sub(0, -3), false, true) then
				delete(dgi)

				self:load()
			else
				setTimer(function() delete(dgi) end, 10000, 1)
				self:unload()
			end

			-- process next download (if exists)
			self:processNext()
			--nextframe(self.processNext, self)
		end
	)()
end

function HTTPTextureReplacer:processNext()
	if HTTPTextureReplacer.Queue:empty() then
		HTTPTextureReplacer.Locked = false
	else
		HTTPTextureReplacer.Queue:pop():downloadTexture()
	end
end

function HTTPTextureReplacer:addToQeue()
	HTTPTextureReplacer.Queue:push(self)
	if not HTTPTextureReplacer.Locked then
		HTTPTextureReplacer.Locked = true
		self:processNext()
	end
end
