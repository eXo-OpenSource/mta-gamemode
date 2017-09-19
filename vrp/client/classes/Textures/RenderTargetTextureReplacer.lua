RenderTargetTextureReplacer = inherit(TextureReplacer)

function RenderTargetTextureReplacer:constructor(element, rendertarget, textureName, options)
	assert(fileName and fileName:len() > 0, "Bad Argument @ FileTextureReplacer:constructor #2")
	TextureReplacer.constructor(self, element, textureName, options)

	self.m_Texture = rendertarget
end

function RenderTargetTextureReplacer:destructor()
	TextureReplacer.destructor(self)
end

function RenderTargetTextureReplacer:load()
	return self:attach()
end

function RenderTargetTextureReplacer:unload()
	return self:detach()
end
