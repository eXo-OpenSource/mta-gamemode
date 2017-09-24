-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/DxRectangle.lua
-- *  PURPOSE:     Dx resctangle to provide animation dummies without mouse interaction
-- *
-- ****************************************************************************
DxRectangle = inherit(DxElement)
inherit(GUIColorable, DxRectangle)

function DxRectangle:constructor(posX, posY, width, height, color, parent, isRelative)
	DxElement.constructor(self, posX, posY, width, height, parent, isRelative)
	GUIColorable.constructor(self, color or Color.White)    
end


function DxRectangle:drawThis()
    dxSetBlendMode("modulate_add")
    
    if GUI_DEBUG then
        dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, tocolor(math.random(0, 255), math.random(0, 255), math.random(0, 255), 150))
    end

    dxDrawRectangle(self.m_AbsoluteX, self.m_AbsoluteY, self.m_Width, self.m_Height, self.m_Color)
    
    dxSetBlendMode("blend")
end
