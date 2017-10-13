HTTPTextureReplacer = inherit(TextureReplacer)
HTTPTextureReplacer.BasePath = "http://picupload.pewx.de/textures/"
HTTPTextureReplacer.ClientPath = "files/images/Textures/remote/%s"
HTTPTextureReplacer.Queue = Queue:new()

-- normal methods
function HTTPTextureReplacer:constructor(element, fileName, textureName, options)
	assert(fileName and fileName:len() > 0 and fileName:find(HTTPTextureReplacer.BasePath), "Bad Argument @ HTTPTextureReplacer:constructor #2")
	TextureReplacer.constructor(self, element, textureName, options)

	self.m_FileName = fileName:gsub(HTTPTextureReplacer.BasePath, "")
	self.m_PixelFileName = ("%s.pixels"):format(self.m_FileName)
end

function HTTPTextureReplacer:destructor()
	TextureReplacer.destructor(self)
end

function HTTPTextureReplacer:load()
	if not fileExists(HTTPTextureReplacer.ClientPath:format(self.m_PixelFileName)) then
		self:addToQueue()
		return TextureReplacer.Status.DELAYED
	else
		self.m_Texture = TextureCache.getCached(HTTPTextureReplacer.ClientPath:format(self.m_PixelFileName), self)
		return self:attach()
	end
end

function HTTPTextureReplacer:unload()
	local a = TextureCache.removeCached(HTTPTextureReplacer.ClientPath:format(self.m_PixelFileName), self)
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
	if not HTTPTextureReplacer.Queue:empty() then
		HTTPTextureReplacer.Queue:pop():downloadTexture()
	end
end

function HTTPTextureReplacer:addToQueue()
	HTTPTextureReplacer.Queue:push(self)

	self:processNext()
end
