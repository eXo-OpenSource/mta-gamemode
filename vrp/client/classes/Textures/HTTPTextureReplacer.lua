HTTPTextureReplacer = inherit(TextureReplacer)
HTTPTextureReplacer.BasePath = "https://picupload.pewx.de/textures/"
HTTPTextureReplacer.ExternalPath = "http://i.imgur.com/"
HTTPTextureReplacer.ClientPath = "files/images/Textures/remote/%s"
HTTPTextureReplacer.Queue = Queue:new()

--[[
Async.create(function()
	DEBUG_VEHS_MM = {}
	for i,vehicle in pairs(getElementsByType("vehicle")) do
		if vehicle.getTunings and type(vehicle:getTunings()) == "table" and vehicle:getTunings().m_Tuning["Texture"] then
			for i,v in pairs(vehicle:getTunings().m_Tuning["Texture"]) do
				if v:find("http://picupload") then
					table.insert(DEBUG_VEHS_MM, vehicle)
					vehicle:getTunings().m_Tuning["Texture"][i] = v:gsub("http://picupload", "https://picupload")
				end
			end
		end
    end
    outputConsole("vehicles: "..(table.size(DEBUG_VEHS_MM)))
end)()]]

-- normal methods
function HTTPTextureReplacer:constructor(element, fileName, textureName, options, force)
	--do not use assert as it produces a "real" lua error and blocks any textures loading afterwards
	if not (fileName and fileName:len() > 0 and (fileName:find(HTTPTextureReplacer.BasePath) or fileName:find(HTTPTextureReplacer.ExternalPath))) then
		outputDebugString("Bad Argument @ HTTPTextureReplacer:constructor #2", 1)
		outputDebugString(fileName, 1)
	 	return
	end
	TextureReplacer.constructor(self, element, textureName, options, force)
	self.m_PathType = 1
	if fileName:find(HTTPTextureReplacer.ExternalPath) then self.m_PathType = 2 end
	if self.m_PathType == 2 then
		self.m_FileName = fileName:gsub(HTTPTextureReplacer.ExternalPath, "")
	else
		self.m_FileName = fileName:gsub(HTTPTextureReplacer.BasePath, "")
	end
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
	if not self.m_PixelFileName then return TextureReplacer.Status.FAILURE end
	local a = TextureCache.removeCached(HTTPTextureReplacer.ClientPath:format(self.m_PixelFileName), self)
	local b = self:detach()
	return ((a and b) and TextureReplacer.Status.SUCCESS) or TextureReplacer.Status.FAILURE
end

-- downlaoder
function HTTPTextureReplacer:downloadTexture()
	Async.create(
		function()
			local dgi = HTTPMinimalDownloadGUI:new()
			local provider
			if self.m_PathType == 1 then
				provider = HTTPProvider:new(HTTPTextureReplacer.BasePath, dgi)
			else
				provider = HTTPProvider:new(HTTPTextureReplacer.ExternalPath, dgi)
			end
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
