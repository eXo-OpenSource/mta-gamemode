GUIElementMask = inherit(GUIElement)
inherit(GUIColorable, GUIElementMask)
inherit(GUIRotatable, GUIElementMask)

function GUIElementMask:constructor(posX, posY, width, height, texture, maskTextrue, parent)
	self.m_Texture = texture
	self.m_Mask = maskTextrue
	self.m_Shader = DxShader("files/shader/mask.fx")
	if not self.m_Shader then
		error("Error @ GUIElementMaskedImage:constructor, shader failed to create!")
	end

	self.m_Shader:setValue("InputTexture", self.m_Texture)
	self.m_Shader:setValue("MaskTexture", self.m_Mask)

	GUIElement.constructor(self, posX, posY, width, height, parent)
	GUIColorable.constructor(self)
	GUIRotatable.constructor(self)
end

function GUIElementMask:destructor()
	if isElement(self.m_Shader) then
		self.m_Shader:destroy()
	end

	GUIElement.destructor(self)
end

function GUIElementMask:drawThis()
	dxSetBlendMode("modulate_add")
	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end
	if self.m_Shader then
		dxDrawImage(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_Shader, self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0, self.m_RotationCenterOffsetY or 0, self:getColor() or 0)
	end
	dxSetBlendMode("blend")
end

function GUIElementMask:setTexture(path)
	assert(type(path) == "string", "Bad argument @ GUIElementMask.setImage")

	if isElement(self.m_Texture) then
		destroyElement(self.m_Texture)
	end

	self.m_Texture = DxTexture(path)
	self.m_Shader:setValue("InputTexture", self.m_Texture)
	self:anyChange()

	return self
end

function GUIElementMask:setMask(path)
	assert(type(path) == "string", "Bad argument @ GUIElementMask.setMask")

	if isElement(self.m_Mask) then
		destroyElement(self.m_Mask)
	end

	self.m_Mask = DxTexture(path)
	self.m_Shader:setValue("MaskTexture", self.m_Mask)
	self:anyChange()

	return self
end
