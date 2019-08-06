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
	self.m_Width = grid("x", 7)
	self.m_Height = grid("y", 3)

    GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight-self.m_Height-25, self.m_Width, self.m_Height, false)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Map Editor", true, true, self)
    self.m_CreateObjectButton = GUIGridButton:new(1, 1, 3, 1, FontAwesomeSymbols.Plus, self.m_Window):setFont(FontAwesome(24)):setTooltip("Objekt erstellen", "top"):setBackgroundColor(Color.Green)
	self.m_DeleteWorldObjectButton = GUIGridButton:new(1, 2, 3, 1, FontAwesomeSymbols.Erase, self.m_Window):setFont(FontAwesome(24)):setTooltip("World-Object entfernen", "top"):setBackgroundColor(Color.Red)
    self.m_ChangeMapButton = GUIGridButton:new(4, 1, 3, 1, FontAwesomeSymbols.Edit, self.m_Window):setFont(FontAwesome(24)):setTooltip("Map ändern", "top"):setBackgroundColor(Color.Orange)
    self.m_HelpButton = GUIGridButton:new(4, 2, 3, 1, FontAwesomeSymbols.Question, self.m_Window):setFont(FontAwesome(24)):setTooltip("Hilfe", "top")
    
    self.m_CreateObjectButton.onLeftClick = function()
        MapEditorObjectCreateGUI:new()
    end

    self.m_DeleteWorldObjectButton.onLeftClick = function()
        if not MapEditor:getSingleton():getRemovingMode() then
            MapEditor:getSingleton():setRemovingMode(true)
        else
            MapEditor:getSingleton():setRemovingMode(false)
        end
    end

    self.m_ChangeMapButton.onLeftClick = function()
        MapEditorMapGUI:new()
    end

    self.m_HelpButton.onLeftClick = function()
        MapEditorHelpGUI:new()
    end
end

function MapEditorMainGUI:destructor()
    GUIForm.destructor(self)
    if not self.m_Closed then
        triggerServerEvent("MapEditor:forceCloseEditor", localPlayer)
    end
end

function MapEditorMainGUI:setClosed()
    self.m_Closed = true
end