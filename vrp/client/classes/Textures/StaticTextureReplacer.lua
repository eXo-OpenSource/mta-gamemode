StaticFileTextureReplacer = inherit(FileTextureReplacer)

function StaticFileTextureReplacer:constructor(fileName, textureName, options)
	FileTextureReplacer.constructor(self, nil, fileName, textureName, options)
	self:load()
end

function StaticFileTextureReplacer:destructor()
	self:unload()
	FileTextureReplacer.destructor(self)
end



StaticRenderTargetTextureReplacer = inherit(FileTextureReplacer)

function StaticRenderTargetTextureReplacer:constructor(fileName, textureName, options)
	RenderTargetTextureReplacer.constructor(self, nil, fileName, textureName, options)
	self:load()
end

function StaticRenderTargetTextureReplacer:destructor()
	self:unload()
	RenderTargetTextureReplacer.destructor(self)
end
