TextureCache = {} -- Static class
TextureCache.Map = {}

-- Cache methods
function TextureCache.getCached(path, instance)
	if not TextureCache.Map[path] then
		TextureCache.Map[path] = CachedTexture:new(path)
	end

	local cachedTexture = TextureCache.Map[path]
	cachedTexture:increment(instance)
	return cachedTexture:getTexture()
end

function TextureCache.removeCached(path, instance)
	if TextureCache.Map[path] then
		local cachedTexture = TextureCache.Map[path]
		cachedTexture:decrement(instance)
		if cachedTexture:canCollected() then
			delete(cachedTexture)
			TextureCache.Map[path] = nil
		end

		return true
	end

	return false
end

function TextureCache.getPixels(path)
	local pixels = path
	if fileExists(path) then
		local file = fileOpen(path)
		if file then
			pixels = fileRead(file, fileGetSize(file))
			fileClose(file)
		end
	end

	return pixels
end
