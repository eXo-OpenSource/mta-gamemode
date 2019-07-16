-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMaskedImage.lua
-- *  PURPOSE:     GUI masked image class
-- *
-- ****************************************************************************
GUIMaskedImage = inherit(GUIElementMask)

function GUIMaskedImage:constructor(posX, posY, width, height, path, maskPath, parent)
	self.m_MaskTexture = DxTexture(maskPath)
	self.m_ImageTexture = DxTexture(path)
	GUIElementMask.constructor(self, posX, posY, width, height, self.m_ImageTexture, self.m_MaskTexture, parent)
end

function GUIMaskedImage:destructor()
	GUIElementMask.destructor(self)

	if isElement(self.m_ImageTexture) then
		self.m_ImageTexture:destroy()
	end

	if isElement(self.m_MaskTexture) then
		self.m_MaskTexture:destroy()
	end
end
