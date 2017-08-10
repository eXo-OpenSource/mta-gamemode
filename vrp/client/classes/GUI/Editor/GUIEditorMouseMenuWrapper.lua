-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUI/Editor/GUIGridEditor.lua
-- *  PURPOSE:     InGame GUI Editor for grid UIs 
-- *
-- ****************************************************************************

GUIEditorMouseMenuWrapper = inherit(Singleton)
GUIEditorMouseMenu = inherit(GUIMouseMenu)

function GUIEditorMouseMenuWrapper:constructor()
    self.m_ClickBind = bind(GUIEditorMouseMenuWrapper.onMouseClick, self)
    addEventHandler("onClientClick", root, self.m_ClickBind)
end

function GUIEditorMouseMenuWrapper:destructor()
    removeEventHandler("onClientClick", root, self.m_ClickBind)
end

function GUIEditorMouseMenuWrapper:onMouseClick(btn, state, mouseX, mouseY)
    local hElement = GUIElement.getHoveredElement()
    if btn == "left" and state == "up" then
        outputDebug(tostring(hElement), tostring(self.m_ActiveMouseMenu))
        if self.m_ActiveMouseMenu and hElement ~= self.m_ActiveMouseMenu then
            self.m_ActiveMouseMenu:delete()
            self.m_ActiveMouseMenu = nil
        end
        self.m_ActiveMouseMenu = GUIEditorMouseMenu:new(mouseX, mouseY)
        self.m_ActiveMouseMenu.m_CacheArea:bringToFront()
    end
end

function GUIEditorMouseMenu:constructor(posX, posY)
    GUIMouseMenu.constructor(self, posX, posY, 300, 300)

    local hElement = GUIElement.getHoveredElement()
    if hElement then -- create element-specific content
        if GUIGridEditor:getSingleton():isEditable(hElement) then
            outputDebug("clicked element", hElement.m_Name)
            self:createElementSpecificItems(hElement)
        end
    else -- create root context box
        self:createRootElements(posX, posY)
    end

    self:adjustWidth()

    GUIEditorMouseMenuWrapper:getSingleton().m_MouseMenuLoaded = true
end

function GUIEditorMouseMenu:destructor()
    GUIEditorMouseMenuWrapper:getSingleton().m_MouseMenuLoaded = false
    GUIMouseMenu.destructor(self)
end

function GUIEditorMouseMenu:createElementSpecificItems(ele)
    self:clearItems()
    self:addItem(ele.m_Name)
end

function GUIEditorMouseMenu:createRootElements(posX, posY)
    self:clearItems()
    for displayName, class in pairs(GUIGridEditor.ms_ValidGUIForms) do
        self:addItem(_(displayName),
        function()
            delete(self)
            GUIGridEditor:getSingleton():createRootGUIElement(class, posX, posY)
        end
        )--:setIcon(FontAwesomeSymbols.Cart_Plus)
    end
end

function GUIEditorMouseMenu:createElementSelection()
    self:clearItems()

end




