-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditor/MapEditorEditingPlayersGUI.lua
-- *  PURPOSE:     Map Editor Editing Players GUI class
-- *
-- ****************************************************************************

MapEditorEditingPlayersGUI = inherit(GUIForm)
inherit(Singleton, MapEditorEditingPlayersGUI)
addRemoteEvents{"MapEditorEditingPlayersGUI:sendInfosToClient"}

function MapEditorEditingPlayersGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 10)
	self.m_Height = grid("y", 12)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Map Editor: bearbeitende Spieler", true, true, self)
    self.m_GridList = GUIGridGridList:new(1, 1, 9, 10, self.m_Window)
    self.m_GridList:addColumn("ID", 0.25)
    self.m_GridList:addColumn("Name", 0.75)
    self.m_EndButton = GUIGridButton:new(1, 11, 9, 1, "Map Editor schließen", self.m_Window)

    self.m_Window:addBackButton(
        function()
            MapEditorMapGUI:getSingleton():show()
            delete(self)
        end
    )

    self.m_EndButton.onLeftClick = function()
        if self.m_GridList:getSelectedItem() then
            if getPlayerFromName(self.m_GridList:getSelectedItem():getColumnText(2)) then
                triggerServerEvent("MapEditor:forceCloseEditor", localPlayer, self.m_GridList:getSelectedItem():getColumnText(2))
            end
        end
    end

    self.m_FillBind = bind(self.fillGridList, self)
    addEventHandler("MapEditorEditingPlayersGUI:sendInfosToClient", root, self.m_FillBind)
    triggerServerEvent("MapEditor:requestEditingPlayers", localPlayer)
end

function MapEditorEditingPlayersGUI:destructor()
    GUIForm.destructor(self)
    if MapEditorMapGUI:isInstantiated() then
        MapEditorMapGUI:getSingleton():show()
    end
    removeEventHandler("MapEditorEditingPlayersGUI:sendInfosToClient", root, self.m_FillBind)
end

function MapEditorEditingPlayersGUI:fillGridList(maps, players)
    for mapId, map in pairs(maps) do
        self.m_GridList:addItemNoClick(mapId, map[1])
        for index, playerTable in pairs(players) do
            if playerTable[2] == mapId then
                item = self.m_GridList:addItem("", playerTable[1])
            end
        end
    end
end