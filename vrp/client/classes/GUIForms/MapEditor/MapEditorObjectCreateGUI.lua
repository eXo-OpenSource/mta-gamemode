-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditor/MapEditorObjectCreateGUI.lua
-- *  PURPOSE:     Map Editor Object Create GUI class
-- *
-- ****************************************************************************

MapEditorObjectCreateGUI = inherit(GUIForm)
inherit(Singleton, MapEditorObjectCreateGUI)
local blockedCategories = {
    ["Gebäude"] = true,
    ["Interior Objekte"] = true,
    ["Landmassen"] = true,
    ["Verschiedenes"] = true,
    ["Natur"] = true,
    ["Strukturen"] = true,
    ["Transport"] = true
}

function MapEditorObjectCreateGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 27)

	GUIForm.constructor(self, 0, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"MapEditor: erstelle Objekt", true, true, self)
    
    self.m_ComboBox = GUIGridCombobox:new(1, 1, 11, 1, "Kategorie Auswahl", self.m_Window)
    
	self.m_GridList = GUIGridGridList:new(1, 2, 11, 24, self.m_Window)
	self.m_GridList:addColumn("ID", 0.2)
	self.m_GridList:addColumn("Name", 0.8)
	
	self.m_CreateButton = GUIGridButton:new(1, 26, 5, 1, "Erstellen", self.m_Window):setBackgroundColor(Color.Green)
    self.m_AbortButton = GUIGridButton:new(7, 26, 5, 1, "Abbrechen", self.m_Window):setBackgroundColor(Color.Red)

    self.m_ComboBox.onLeftClick = function()
        self.m_GridList:clear()
        self.m_GridList:setVisible(false)
    end

    self.m_ComboBox.onSelectItem = function()
        if not blockedCategories[self.m_ComboBox:getSelectedItem():getColumnText(1)] then
            self.m_GridList:setVisible(true)
            if self.m_ComboBox:getSelectedItem().m_UpperCategory then
                self:fillGridList(self.m_ComboBox:getSelectedItem().m_UpperCategory, self.m_ComboBox:getSelectedItem():getColumnText(1))
            else
                self:fillGridList(self.m_ComboBox:getSelectedItem():getColumnText(1))
            end
        end
    end

    self.m_CreateButton.onLeftClick = function()
        ObjectPlacer:new(tonumber(self.m_GridList:getSelectedItem():getColumnText(1)), MapEditor:getSingleton().m_ObjectPlacedBind, false)
        MapEditor:getSingleton():setPlacingMode(true, tonumber(self.m_GridList:getSelectedItem():getColumnText(1)))
        delete(self)
    end

    self.m_AbortButton.onLeftClick = function()
        delete(self)
    end
    
    self:fillComboBox()
    showChat(false)
    HUDRadar:getSingleton():hide()
end

function MapEditorObjectCreateGUI:destructor()
    GUIForm.destructor(self)
    showChat(true)
    HUDRadar:getSingleton():show()
    if self.m_TempObject and isElement(self.m_TempObject) then self.m_TempObject:destroy() end
    if self.m_Marker and isElement(self.m_Marker) then self.m_Marker:destroy() end
    delete(CenteredFreecam:getSingleton())
end

function MapEditorObjectCreateGUI:fillComboBox()
    local objects = xmlLoadFile("files/data/objects.xml")
    local nodes = xmlNodeGetChildren(objects)
    self.m_ObjectTable = {}
    for key, node in pairs(nodes) do
        for k, category in pairs(xmlNodeGetAttributes(node)) do
            self.m_ComboBox:addItem(category)
            for k, subnode in pairs(xmlNodeGetChildren(node)) do
                if not xmlNodeGetAttribute(subnode, "model") then
                    for k, subcategory in pairs(xmlNodeGetAttributes(subnode)) do 
                        self.m_ComboBox:addItem(("    %s"):format(subcategory)).m_UpperCategory = category
                    end
                end
            end
        end
    end
end

function MapEditorObjectCreateGUI:fillGridList(searchCategory, searchSubCategory)
    local objects = xmlLoadFile("files/data/objects.xml")
    for key, node in pairs(xmlNodeGetChildren(objects)) do
        if xmlNodeGetAttribute(node, "name") == searchCategory then
            for k, subnode in pairs(xmlNodeGetChildren(node)) do
                if not searchSubCategory then
                    local model = xmlNodeGetAttribute(subnode, "model")
                    local name = xmlNodeGetAttribute(subnode, "name")
                    local item = self.m_GridList:addItem(model, name)
                    item.onLeftClick = function()
                        self:createTempObject(model)
                    end
                else
                    if "    "..xmlNodeGetAttribute(subnode, "name") == searchSubCategory then
                        for sk, subsubnode in pairs(xmlNodeGetChildren(subnode)) do
                            local model = xmlNodeGetAttribute(subsubnode, "model")
                            local name = xmlNodeGetAttribute(subsubnode, "name")
                            local item = self.m_GridList:addItem(model, name)
                            item.onLeftClick = function()
                                self:createTempObject(model)
                            end
                        end
                    end
                end
            end
        end
    end
    xmlUnloadFile(objects)
end

function MapEditorObjectCreateGUI:createTempObject(model)
    if self.m_TempObject and isElement(self.m_TempObject) then self.m_TempObject:destroy() end
    if self.m_Marker and isElement(self.m_Marker) then self.m_Marker:destroy() end

    self.m_TempObject = createObject(model, localPlayer:getPosition() + Vector3(localPlayer.matrix.forward.x*1.25, localPlayer.matrix.forward.y*1.25, 0.25))
    self.m_TempObject:setCollisionsEnabled(false)
    self.m_TempObject:setScale(5 / self.m_TempObject:getRadius())
    
    self.m_Marker = createMarker(self.m_TempObject:getPosition() + Vector3(0,0,1), "arrow", 0.1, 255, 255, 0)
    self.m_Marker:attach(self.m_TempObject, 0, 0, 0.25)

    CenteredFreecam:new(localPlayer, 50, true, true)
end