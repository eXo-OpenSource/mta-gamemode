-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditor/MapEditorMainGUI.lua
-- *  PURPOSE:     Map Editor Main GUI class
-- *
-- ****************************************************************************

MapEditorMainGUI = inherit(GUIForm)
inherit(Singleton, MapEditorMainGUI)

function MapEditorMainGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 13)
	self.m_Height = grid("y", 4)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight-self.m_Height-25, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"MapEditor", true, true, self)
	self.m_CreateObjectButton = GUIGridButton:new(1, 1, 4, 3, "Objekt erstellen", self.m_Window)
	self.m_DeleteWorldObjectButton = GUIGridButton:new(5, 1, 4, 3, "Standard Map Objekte löschen", self.m_Window)
    self.m_ChangeMapButton = GUIGridButton:new(9, 1, 4, 3, "Map Auswahl", self.m_Window)
    
    self.m_CreateObjectButton.onLeftClick = function()
        MapEditorObjectCreateGUI:new()
    end
    self.m_DeleteWorldObjectButton.onLeftClick = function() 
        -- initialize
    end
    self.m_ChangeMapButton.onLeftClick = function()
        MapEditorMapGUI:new()
    end
end

function MapEditorMainGUI:destructor()
    GUIForm.destructor(self)
    delete(MapEditorObjectCreateGUI:getSingleton())

end