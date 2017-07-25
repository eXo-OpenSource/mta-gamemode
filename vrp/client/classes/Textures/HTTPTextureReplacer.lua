HTTPTextureReplacer = inherit(TextureReplacer)
HTTPTextureReplacer.BasePath = "http://picupload.pewx.de/textures/"
HTTPTextureReplacer.ClientPath = "files/images/Textures/remote/%s"
HTTPTextureReplacer.Queue = Queue:new()

-- normal methods
function HTTPTextureReplacer:constructor(element, fileName, textureName, options)
	TextureReplacer.constructor(self, element, textureName, options)

	self.m_FileName = fileName:find(HTTPTextureReplacer.BasePath) and fileName:gsub(HTTPTextureReplacer.BasePath, "") or fileName
	outputChatBox("HTTP: "..self.m_FileName)
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
		self.m_Texture = TextureReplacer.getCached(HTTPTextureReplacer.ClientPath:format(self.m_PixelFileName))
		return self:attach()
	end
end

function HTTPTextureReplacer:unload()
	local a = TextureReplacer.removeCached(HTTPTextureReplacer.ClientPath:format(self.m_PixelFileName))
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
			nextframe(self.processNext, self)
		end
	)()
end

function HTTPTextureReplacer:processNext()
	if HTTPTextureReplacer.Queue:empty() then
		HTTPTextureReplacer.Queue:unlock()
	else
		HTTPTextureReplacer.Queue:pop_back(1):downloadTexture()
	end
end

function HTTPTextureReplacer:addToQeue()
	HTTPTextureReplacer.Queue:push_back(self)
	if not HTTPTextureReplacer.Queue:locked() then
		HTTPTextureReplacer.Queue:lock()
		self:processNext()
	end
end
