-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/Editor/GUIEditorPreview.lua
-- *  PURPOSE:     InGame preview to show the result of GUIGridEditor
-- *
-- ****************************************************************************


GUIEditorPreview = inherit(GUIForm)

function GUIEditorPreview:constructor(posX, posY, width, height)
	GUIForm.constructor(self, posX, posY, width, height)
    self.m_Dummy = GUIRectangle:new(posX, posY, width, height, self)
    self.m_Dummy:setColor(Color.Primary)
end

function GUIEditorPreview:setRootElement(class, ...)
    if self.m_Dummy then 
        self.m_Dummy:delete()
        self.m_Dummy = nil
    end

    local args = {...} -- get the arguments specific to that element
    table.insert(args, self) -- add the parent as the last arg

    local element = class:new(unpack(args))
    return element
end