-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/GUIMaskedRendertarget.lua
-- *  PURPOSE:     GUI masked rendertarget class
-- *
-- ****************************************************************************
GUIMaskedRendertarget = inherit(GUIElementMask)

function GUIMaskedRendertarget:constructor(posX, posY, width, height, rendertarget, maskPath, parent)
	GUIElementMask.constructor(self, posX, posY, width, height, rendertarget, DxTexture(maskPath), parent)
end