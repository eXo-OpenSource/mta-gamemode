CachedTexture = inherit(Object)

function CachedTexture:constructor(path)
	self.m_Texture = DxTexture(TextureCache.getPixels(path))
	self.m_Instances = {}
	self.m_CreationTime = getTickCount()
end

function CachedTexture:destructor()
	if self.m_Texture then
		self.m_Texture:destroy()
	end
end

function CachedTexture:getTexture()
	return self.m_Texture
end

function CachedTexture:increment(instance)
	table.insert(self.m_Instances, instance)
end

function CachedTexture:decrement(instance)
	local idx = table.find(self.m_Instances, instance)
	if idx then
		table.remove(self.m_Instances, idx)
	end
end

function CachedTexture:getUsage()
	return #self.m_Instances
end

function CachedTexture:canCollected()
	return self:getUsage() == 0
end
