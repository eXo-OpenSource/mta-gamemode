-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMaskedRendertarget.lua
-- *  PURPOSE:     GUI masked rendertarget class
-- *
-- ****************************************************************************
GUIMaskedRendertarget = inherit(GUIElementMask)

function GUIMaskedRendertarget:constructor(posX, posY, width, height, rendertarget, maskPath, parent)
	self.m_MaskTexture = DxTexture(maskPath)
	GUIElementMask.constructor(self, posX, posY, width, height, rendertarget, self.m_MaskTexture, parent)
end

function GUIMaskedRendertarget:destructor()
	GUIElementMask.destructor(self)

	if isElement(self.m_MaskTexture) then
		self.m_MaskTexture:destroy()
	end
end
