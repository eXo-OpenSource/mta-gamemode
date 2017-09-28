RenderTargetTextureReplacer = inherit(TextureReplacer)

function RenderTargetTextureReplacer:constructor(element, rendertarget, textureName, options)
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

function RenderTargetTextureReplacer:update()
	self.m_Shader:setValue("gTexture", self.m_Texture)
end
