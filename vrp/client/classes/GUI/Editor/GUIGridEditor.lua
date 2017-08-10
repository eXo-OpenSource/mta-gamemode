-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/Editor/GUIGridEditor.lua
-- *  PURPOSE:     InGame GUI Editor for grid UIs 
-- *
-- ****************************************************************************

GUIGridEditor = inherit(Singleton)

GUIGridEditor.ms_ValidGUIClassData = {
    {
        displayName = "Rechteck",
        class       = GUIForm,
        varName     = "form",
        rootAble    = true, -- can this element be a gui root element (e.g. window)
    },
    {
        displayName = "Fenster",
        class       = GUIWindow,
        varName     = "window",
        rootAble    = true, 
        defaultArgs = {"Fenster", true, true},
    },
    {
        displayName = "Tab-Menü",
        class       = GUITabPanel,
        varName     = "tabPanel",
        rootAble    = true, 
        defaultArgs = {"Fenster", true, true},
    },
}

GUIGridEditor.ms_ValidGUIClasses = {}       -- [displayName] = class
GUIGridEditor.ms_ValidGUIForms = {}         -- [displayName] = class (can be used as gui root)
GUIGridEditor.ms_DefaultElementArgs = {}    -- [class] = {var1, var2, var3, ....}
GUIGridEditor.CLASS_TO_NAME = {}            -- [class] = varName

for i, v in pairs(GUIGridEditor.ms_ValidGUIClassData) do -- fill specific tables with data from above
    GUIGridEditor.ms_ValidGUIClasses[v.displayName] = v.class
    GUIGridEditor.ms_DefaultElementArgs[v.class] = v.defaultArgs or {}
    GUIGridEditor.CLASS_TO_NAME[v.class] = v.varName
    if v.rootAble then
        GUIGridEditor.ms_ValidGUIForms[v.displayName] = v.class
    end
end


function GUIGridEditor:constructor()
    self.m_UniqueCounter = 0
    self.m_MouseMenuWrapper = GUIEditorMouseMenuWrapper:getSingleton()
end

function GUIGridEditor:destructor()

end

function GUIGridEditor:isEditable(guiEle)
    return guiEle.m_Editable
end

function GUIGridEditor:registerEditable(class, guiEle)
    guiEle.m_Editable   = true
    guiEle.m_SuperClass = class
    guiEle.m_Name       = GUIGridEditor.CLASS_TO_NAME[class]..self.m_UniqueCounter
   
    self.m_UniqueCounter = self.m_UniqueCounter + 1
end

function GUIGridEditor:createRootGUIElement(class, posX, posY)
    if not self.m_PreviewElement then
        outputDebug(posX, posY)
        self.m_PreviewElement = GUIEditorPreview:new(posX, posY, 300, 300) -- create a form as the root of the editor
        if class ~= GUIForm then
            local guiEle = self.m_PreviewElement:setRootElement(class, 0, 0, 300, 300, unpack(GUIGridEditor.ms_DefaultElementArgs[class] or {})) -- add a window or tab menu
            self:registerEditable(class, guiEle)
        end
    else
        ErrorBox:new(_"Du kannst nur ein Fenster zugleich bearbeiten!")
    end
end

addCommandHandler("guiedit", function()
    GUIGridEditor:getSingleton()
end)