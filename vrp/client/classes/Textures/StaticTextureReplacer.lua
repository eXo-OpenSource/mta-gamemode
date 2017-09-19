StaticTextureReplacer = inherit(FileTextureReplacer)

function StaticTextureReplacer:constructor(fileName, textureName, options)
	FileTextureReplacer.constructor(self, nil, fileName, textureName, options)
	self:load()
end

function StaticTextureReplacer:destructor()
	self:unload()
	FileTextureReplacer.destructor(self)
end
