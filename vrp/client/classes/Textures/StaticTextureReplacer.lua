StaticFileTextureReplacer = inherit(FileTextureReplacer)
StaticRenderTargetTextureReplacer = inherit(RenderTargetTextureReplacer)

function StaticFileTextureReplacer:constructor(fileName, textureName, options)
	FileTextureReplacer.constructor(self, nil, fileName, textureName, options)
	self:load()
end

function StaticFileTextureReplacer:destructor()
	self:unload()
	FileTextureReplacer.destructor(self)
end

function StaticRenderTargetTextureReplacer:constructor(rendertarget, textureName, options)
	RenderTargetTextureReplacer.constructor(self, nil, rendertarget, textureName, options)
	self:load()
end

function StaticRenderTargetTextureReplacer:destructor()
	self:unload()
	RenderTargetTextureReplacer.destructor(self)
end
