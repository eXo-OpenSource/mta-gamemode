-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditor/MapEditorMapSettingsGUI.lua
-- *  PURPOSE:     Map Editor Map Settings GUI class
-- *
-- ****************************************************************************

MapEditorMapSettingsGUI = inherit(GUIForm)
inherit(Singleton, MapEditorMapSettingsGUI)

function MapEditorMapSettingsGUI:constructor(id, mapInfos)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12)
	self.m_Height = grid("y", 6)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Map Editor: Map Einstellungen", true, true, self)
	
	self.m_NameLabel = GUIGridLabel:new(1, 1, 4, 1, "Name:", self.m_Window)
	self.m_ActiveLabel = GUIGridLabel:new(1, 2, 4, 1, "Aktiv:", self.m_Window)
	self.m_SaveObjectsLabel = GUIGridLabel:new(1, 3, 4, 1, "Speichert Objekte:", self.m_Window)
	self.m_DeactivatableLabel = GUIGridLabel:new(1, 4, 4, 1, "(De-) aktivierbar:", self.m_Window)
	
	self.m_NameEdit = GUIGridEdit:new(5, 1, 7, 1, self.m_Window)
	self.m_ActiveSwitch = GUIGridSwitch:new(5, 2, 3, 1, self.m_Window)
	self.m_SaveObjectsSwitch = GUIGridSwitch:new(5, 3, 3, 1, self.m_Window)
	self.m_DeactivatableSwitch = GUIGridSwitch:new(5, 4, 3, 1, self.m_Window)
	
	self.m_SaveButton = GUIGridButton:new(4, 5, 4, 1, "Speichern", self.m_Window)
    self.m_DiscardButton = GUIGridButton:new(8, 5, 4, 1, "Abbrechen", self.m_Window)

    self.m_SaveButton.onLeftClick = function()
        local name = self.m_MapInfos[1] ~= self.m_NameEdit:getText() and self.m_NameEdit:getText() or false
        local activate = self.m_ActiveSwitch:getState()
        local saveObjects = self.m_SaveObjectsSwitch:getState()
        local deactivatable = self.m_DeactivatableSwitch:getState()
        local settings = {id, name, activate, saveObjects, deactivatable}
        triggerServerEvent("MapEditor:changeSettings", localPlayer, settings)
        delete(self)
    end

    self.m_DiscardButton.onLeftClick = function()
        delete(self)
    end
    
    self:fillInfos(mapInfos)
end

function MapEditorMapSettingsGUI:fillInfos(mapInfos)
    self.m_MapInfos = mapInfos
    self.m_NameEdit:setText(mapInfos[1])
    self.m_ActiveSwitch:setState(toboolean(mapInfos[3]))
	self.m_SaveObjectsSwitch:setState(toboolean(mapInfos[4]))
    self.m_DeactivatableSwitch:setState(toboolean(mapInfos[5]))
    if localPlayer:getRank() ~= RANK.Developer then
        self.m_SaveObjectsSwitch:setEnabled(false)
        self.m_DeactivatableSwitch:setEnabled(false)
    end
end

function MapEditorMapSettingsGUI:destructor()
	GUIForm.destructor(self)
end
