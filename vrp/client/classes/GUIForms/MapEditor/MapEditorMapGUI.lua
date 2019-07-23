-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MapEditorMapGUI.lua
-- *  PURPOSE:     Map Editor Map GUI class
-- *
-- ****************************************************************************

MapEditorMapGUI = inherit(GUIForm)
inherit(Singleton, MapEditorMapGUI)
addRemoteEvents{"MapEditorMapGUI:sendInfos", "MapEditorMapGUI:sendObjectsToClient"}

function MapEditorMapGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 20)
	self.m_Height = grid("y", 13)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"MapEditor: Map Auswahl", true, true, self)
	
	self.m_GridList = GUIGridGridList:new(1, 1, 8, 11, self.m_Window)
	self.m_GridList:addColumn("ID", 0.1)
	self.m_GridList:addColumn("Name", 0.55)
	self.m_GridList:addColumn("Status", 0.35)
	
	self.m_EditMap = GUIGridButton:new(1, 12, 4, 1, "Bearbeiten", self.m_Window)
	self.m_MapStatus = GUIGridButton:new(5, 12, 4, 1, "Deaktivieren", self.m_Window)
	
	self.m_Headline = GUIGridLabel:new(9, 1, 11, 1, "Informationen zu Map #", self.m_Window):setHeader()
	
	self.m_NameLabel = GUIGridLabel:new(9, 2, 11, 1, "Name: -", self.m_Window)
	self.m_CreatorLabel = GUIGridLabel:new(9, 3, 11, 1, "Ersteller: -", self.m_Window)
	self.m_ObjectGrid = GUIGridGridList:new(9, 4, 11, 5, self.m_Window)
	
	self.m_ObjectGrid:addColumn("ID", 0.1)
	self.m_ObjectGrid:addColumn("Name", 0.55)
	self.m_ObjectGrid:addColumn("Ersteller", 0.35)
	
	self.m_ShowObject = GUIGridButton:new(9, 9, 5, 1, "Auf Karte anzeigen", self.m_Window)
	self.m_ShowAllObjects = GUIGridButton:new(15, 9, 5, 1, "Alle auf Karte anzeigen", self.m_Window)
	
	self.m_CreateNewLabel = GUIGridLabel:new(9, 11, 5, 1, "Neue Map anlegen", self.m_Window):setHeader()
	self.m_NewNameLabel = GUIGridEdit:new(9, 12, 6, 1, self.m_Window):setCaption("Name")
	self.m_CreateNewButton = GUIGridButton:new(15, 12, 5, 1, "Map anlegen", self.m_Window)
	
	self.m_ShowObject.onLeftClick = function()
		self:removeMarks()
		if self.m_ObjectGrid:getSelectedItem() then
			local object = self.m_ObjectTable[self.m_ObjectGrid:getSelectedItem():getColumnText(1)]
			self:markObject(object)
		end
	end

	self.m_EditMap.onLeftClick = function()
		if localPlayer:getRank() == RANK.Developer then
			InviteGUI:new(
				function(player)
					self:startMapEditing(player)
				end
			)
		elseif localPlayer:getRank() >= RANK.Supporter then
			self:startMapEditing(localPlayer)
		else
			ErrorBox:new("Du bist nicht berechtigt!")
		end
	end

	self.m_MapStatus.onLeftClick = function()
		if not self.m_GridList:getSelectedItem() then
			ErrorBox:new("Keine Map ausgewählt!")
			return
		end
		local id = tonumber(self.m_GridList:getSelectedItem():getColumnText(1))
		triggerServerEvent("MapEditor:setMapStatus", localPlayer, id)
	end

	self.m_ShowAllObjects.onLeftClick = function()
		self:removeMarks()
		for key, object in ipairs(self.m_ObjectTable) do
			self:markObject(object)
		end
	end

	self.m_CreateNewButton.onLeftClick = function()
		if #self.m_NewNameLabel:getText() < 5 then
			ErrorBox:new("Bitte gib der Map einen vernünftigen Namen!")
			return
		end
		triggerServerEvent("MapEditor:createNewMap", localPlayer, self.m_NewNameLabel:getText())
	end

	self.m_Blips = {}
    
    self.m_ReceiveBind = bind(self.receiveInfos, self)
	addEventHandler("MapEditorMapGUI:sendInfos", root, self.m_ReceiveBind)
	
	self.m_ObjectReceiveBind = bind(self.receiveObjectInfos, self)
	addEventHandler("MapEditorMapGUI:sendObjectsToClient", root, self.m_ObjectReceiveBind)

	triggerServerEvent("MapEditor:requestMapInfos", localPlayer)
end

function MapEditorMapGUI:destructor()
    GUIForm.destructor(self)
    removeEventHandler("MapEditorMapGUI:sendInfos", root, self.m_ReceiveBind)
end

function MapEditorMapGUI:receiveInfos(mapTable)
	self.m_GridList:clear()
    for key, infoTable in pairs(mapTable) do
		local item = self.m_GridList:addItem(key, infoTable[1], infoTable[3] == 1 and "aktiviert" or "deaktiviert")

		item.onLeftClick = function()
			self.m_ObjectGrid:clear()
			self.m_Headline:setText(("Informationen zu Map #%s"):format(key))
			self.m_NameLabel:setText(("Name: %s"):format(infoTable[1]))
			self.m_CreatorLabel:setText(("Ersteller: %s"):format(infoTable[2]))
			self.m_MapStatus:setText(infoTable[3] == 1 and "Deaktivieren" or "Aktivieren")
			triggerServerEvent("MapEditor:requestObjectInfos", localPlayer, key)
		end

	end
end

function MapEditorMapGUI:receiveObjectInfos(objectTable)
	self.m_ObjectTable = objectTable
	local objects = xmlLoadFile("files/data/objects.xml")
    
	for key, data in ipairs(objectTable) do
		local objectModel = data[1]:getModel()
		local objectName = "-none-"
		for key, node in pairs(xmlNodeGetChildren(objects)) do
			for k, subnode in pairs(xmlNodeGetChildren(node)) do
				if xmlNodeGetAttribute(subnode, "model") then
					if tonumber(xmlNodeGetAttribute(subnode, "model")) == objectModel then
						objectName = xmlNodeGetAttribute(subnode, "name")
					end
				else
					for sk, subsubnode in pairs(xmlNodeGetChildren(subnode)) do
						if tonumber(xmlNodeGetAttribute(subsubnode, "model")) == objectModel then
							objectName = xmlNodeGetAttribute(subsubnode, "name")
						end
					end
				end
			end
		end

		self.m_ObjectGrid:addItem(key, objectName, data[2])
	end

	xmlUnloadFile(objects)
end

function MapEditorMapGUI:markObject(object)
	self.m_Blips[#self.m_Blips+1] = Blip:new("Marker.png", object:getPosition().x, object:getPosition().y, 3000, {255, 255, 0}, {255, 255, 0})
end

function MapEditorMapGUI:removeMarks()
	for k, v in pairs(self.m_Blips) do 
		delete(v)
	end
	self.m_Blips = {}
end

function MapEditorMapGUI:startMapEditing(player)
	if not self.m_GridList:getSelectedItem() then
		ErrorBox:new("Keine Map ausgewählt!")
		return
	end
	local id = tonumber(self.m_GridList:getSelectedItem():getColumnText(1))
	triggerServerEvent("MapEditor:startMapEditing", localPlayer, player, id)
end