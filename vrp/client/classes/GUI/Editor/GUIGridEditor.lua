-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/Editor/GUIGridEditor.lua
-- *  PURPOSE:     InGame GUI Editor for grid UIs 
-- *
-- ****************************************************************************

GUIGridEditor = inherit(Singleton)

function GUIGridEditor:constructor()
    self.m_Editor = CodeEditorGUI:getSingleton()
end

function GUIGridEditor:destructor()

end

addCommandHandler("guiedit", function()
    GUIGridEditor:getSingleton()
end)