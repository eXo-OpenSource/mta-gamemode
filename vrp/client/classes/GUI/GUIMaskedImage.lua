-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIImage.lua
-- *  PURPOSE:     GUI image class
-- *
-- ****************************************************************************
GUIMaskedImage = inherit(GUIImage)

function GUIMaskedImage:constructor(posX, posY, width, height, path, maskPath, parent)
	GUIImage.constructor(self, posX, posY, width, height, path, parent)

	self.m_Image = DxTexture(path)
	self.m_Mask = DxTexture(maskPath)
	self.m_Shader = DxShader("files/shader/mask.fx")
	if not self.m_Shader then
		self.m_Active = false
		error("Error @ GUIMaskedImage:constructor, shader failed to create!")
	end

	self.m_Shader:setValue("InputTexture", self.m_Image)
	self.m_Shader:setValue("MaskTexture", self.m_Mask)
end

function GUIMaskedImage:destructor()
	if isElement(self.m_Shader) then
		destroyElement(self.m_Shader)
	end

	if isElement(self.m_Image) then
		destroyElement(self.m_Image)
	end

	if isElement(self.m_Mask) then
		destroyElement(self.m_Mask)
	end
end

function GUIMaskedImage:drawThis()
	dxSetBlendMode("modulate_add")
	if GUI_DEBUG then
		dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
	end
	if self.m_Image then
		dxDrawImage(math.floor(self.m_AbsoluteX), math.floor(self.m_AbsoluteY), self.m_Width, self.m_Height, self.m_Shader, self.m_Rotation or 0, self.m_RotationCenterOffsetX or 0, self.m_RotationCenterOffsetY or 0, self:getColor() or 0)
	end
	dxSetBlendMode("blend")
end

function GUIMaskedImage:setImage(path)
	assert(type(path) == "string", "Bad argument @ GUIMaskedImage.setImage")

	if isElement(self.m_Image) then
		destroyElement(self.m_Image)
	end

	self.m_Image = DxTexture(path)
	self.m_Shader:setValue("InputTexture", self.m_Image)
	self:anyChange()

	return self
end

function GUIMaskedImage:setMask(path)
	assert(type(path) == "string", "Bad argument @ GUIMaskedImage.setMask")

	if isElement(self.m_Mask) then
		destroyElement(self.m_Mask)
	end

	self.m_Mask = DxTexture(path)
	self.m_Shader:setValue("MaskTexture", self.m_Mask)
	self:anyChange()
	
	return self
end