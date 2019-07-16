-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMaskedImage.lua
-- *  PURPOSE:     GUI masked image class
-- *
-- ****************************************************************************
GUIMaskedImage = inherit(GUIElementMask)

function GUIMaskedImage:constructor(posX, posY, width, height, path, maskPath, parent)
	GUIElementMask.constructor(self, posX, posY, width, height, DxTexture(path), DxTexture(maskPath), parent)
end
