-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/WorldItemOverviewGUI.lua
-- *  PURPOSE:     overview of world items of a specified owner
-- *
-- ****************************************************************************


WorldItemOverviewGUI = inherit(GUIForm)
inherit(Singleton, WorldItemOverviewGUI)
addRemoteEvents{"recieveWorldItemListOfOwner"}
WorldItemOverviewGUI.Action = {
	Mark = "Mark",
	Collect = "Collect",
	Delete = "Delete"
}

function WorldItemOverviewGUI:constructor(sOwnerName, tblObjects, id, type)
	--main
	self.m_OwnerId = id
	self.m_OwnerType = type
	self.m_Width = 640
	self.m_Height = 410
	self.m_Refreshing = false
	self.m_FilterApplied = false
	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Objektübersicht - %s", sOwnerName), true, true, self)
   
	--object list
	self.m_PlacedObjectsLabel = GUILabel:new(5, 30, self.m_Width, 30, "", self) --will be set on list loading
	self.m_ObjectList = GUIGridList:new(5, 65, self.m_Width - 10, 200, self)
		:addColumn(_"Name", 0.2)
		:addColumn(_"Position", 0.3)
		:addColumn(_"Ersteller", 0.2)
		:addColumn(_"Erstellzeit", 0.3)
	self.m_ObjectList.onLeftClick = bind(WorldItemOverviewGUI.Event_OnListItemClick, self)

	self.m_ListRefreshButton = GUIButton:new(self.m_Width-35, 65, 30, 30, " "..FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15)):setFontSize(1)
	self.m_ListRefreshButton:setBackgroundColor(Color.LightBlue)
	self.m_ListRefreshButton.onLeftClick = function()
		self.m_Refreshing = true
		self.m_FilterApplied = false
		self.m_ListRefreshButton:setEnabled(false)
		triggerServerEvent("requestWorldItemListOfOwner", localPlayer, self.m_OwnerId, self.m_OwnerType)
	end
	self:loadObjectsInList(tblObjects)
	
	--filter
	GUILabel:new(5, 270, self.m_Width, 30, _"Filter", self) 
	self.m_FilterEditName       = GUIEdit:new(5, 305, 120, 30, self):setFontSize(1)
	self.m_FilterEditPosition   = GUIEdit:new(130, 305, 190, 30, self):setFontSize(1)
	self.m_FilterEditPlacer     = GUIEdit:new(325, 305, 120, 30, self):setFontSize(1)
	self.m_FilterEditTime       = GUIEdit:new(450, 305, 150, 30, self):setFontSize(1)
	self.m_FilterApplyButton    = GUIButton:new(self.m_Width-35, 305, 30, 30, " "..FontAwesomeSymbols.Check, self):setFont(FontAwesome(15)):setFontSize(1)
	self.m_FilterApplyButton:setBackgroundColor(Color.LightBlue)
	self.m_FilterApplyButton.onLeftClick = bind(WorldItemOverviewGUI.applyFilter, self)
	
	--options
	GUILabel:new(5, 340, self.m_Width, 30, _"Optionen", self)
	self.m_Changer = GUIChanger:new(5, 375, 250, 30, self)
	self.m_Changer:addItem("Filter (gesamte Liste)")
	self.m_Changer:addItem("Auswahl in Liste")
	self.m_MapMarkBtn = VRPButton:new(260, 375, 165, 30, _"auf Karte markieren", true, self)
	self.m_MapMarkBtn.onLeftClick = bind(WorldItemOverviewGUI.Event_OnActionButtonClick, self, WorldItemOverviewGUI.Action.Mark)
	self.m_CollectBtn = VRPButton:new(430, 375, 100, 30, _"Aufheben", true, self)
	self.m_CollectBtn.onLeftClick = bind(WorldItemOverviewGUI.Event_OnActionButtonClick, self, WorldItemOverviewGUI.Action.Collect)
	self.m_DeleteBtn = VRPButton:new(535, 375, 100, 30, _"Löschen", true, self):setBarColor(Color.Red)
	self.m_DeleteBtn.onLeftClick = bind(WorldItemOverviewGUI.Event_OnActionButtonClick, self, WorldItemOverviewGUI.Action.Delete)
end

function WorldItemOverviewGUI:destructor()
	self:updateDebugArrow(true)
	GUIForm.destructor(self)
end

function WorldItemOverviewGUI:loadObjectsInList(tblObjects)
	self.m_ListRefreshButton:setEnabled(true)
	self.m_Refreshing = false
	self.m_ObjectList:clear()
	self.m_FullObjectList = {}
	self.m_FilteredObjectList = {}
	local i = 1
	for modelid, objects in pairs(tblObjects) do
		for object in pairs(tblObjects[modelid]) do
			self.m_ObjectList:addItem(
				object:getData("Name"), 
				getZoneName(object:getPosition()), 
				object:getData("Placer"), 
				getOpticalTimestamp(object:getData("PlacedTimestamp"))
			).m_Id = i
			table.insert(self.m_FullObjectList, {
				Object      = object,
				Name        = object:getData("Name"),
				Zone        = getZoneName(object:getPosition()),
				Placer      = object:getData("Placer"),
				Timestamp   = getOpticalTimestamp(object:getData("PlacedTimestamp"))
			})
			i = i + 1
		end
	end
	self.m_ListSize = i - 1
	self.m_PlacedObjectsLabel:setText(_("platzierte Objekte (%d)", self.m_ListSize))
	self.m_FilteredObjectList = self.m_FullObjectList
	if self.m_FilterApplied then
		self:applyFilter()
	end
end

function WorldItemOverviewGUI:Event_OnListItemClick()
	nextframe(function()
		self.m_SelectedListItem = self.m_ObjectList:getSelectedItem()
		if self.m_SelectedListItem and not isElement(self.m_FilteredObjectList[self.m_SelectedListItem.m_Id].Object) then
			WarningBox:new(_"Dieses Objekt existiert nicht mehr!")
		end
		self:updateDebugArrow()
	end)
end

function WorldItemOverviewGUI:applyFilter()
	local nameFilter        = self.m_FilterEditName:getDrawnText():lower()
	local positionFilter    = self.m_FilterEditPosition:getDrawnText():lower()
	local placerFilter      = self.m_FilterEditPlacer:getDrawnText():lower()
	local timeFilter        = self.m_FilterEditTime:getDrawnText():lower()
	self.m_ObjectList:clear()
	self.m_FilteredObjectList = {}
	local i = 1
	for _, v in ipairs(self.m_FullObjectList) do
		local insert =  v.Name:lower():find(nameFilter) 
						and v.Zone:lower():find(positionFilter) 
						and v.Placer:lower():find(placerFilter) 
						and v.Timestamp:lower():find(timeFilter)
		if insert then
			self.m_ObjectList:addItem(
				v.Name, 
				v.Zone, 
				v.Placer, 
				v.Timestamp
			).m_Id = i
			table.insert(self.m_FilteredObjectList, v)
			i = i + 1
		end
	end
	self.m_FilterApplied = true
	self.m_ListSize = i - 1
	self.m_PlacedObjectsLabel:setText(_("platzierte Objekte (%d)", self.m_ListSize))
end

function WorldItemOverviewGUI:updateDebugArrow(forceDestroy)
	if self.m_SelectedListItem and not forceDestroy then
		local obj = self.m_FilteredObjectList[self.m_SelectedListItem.m_Id].Object
		if isElement(obj) then
			local _, _, _, _, _, maxZ = getElementBoundingBox(obj)
			if not self.m_DebugArrow then
				self.m_DebugArrow = createMarker(obj.position.x, obj.position.y, obj.position.z + maxZ + 2, "arrow", 1, 200, 100, 0, 100)
			else
				self.m_DebugArrow:setPosition(obj.position.x, obj.position.y, obj.position.z + maxZ + 2)
			end
		else
			self:updateDebugArrow(true)
		end
	else
		if self.m_DebugArrow then
			self.m_DebugArrow:destroy()
			self.m_DebugArrow = nil
		end
	end
end

function WorldItemOverviewGUI:getObjectsInList()
	local newList = {}
	for i, v in pairs(self.m_FilteredObjectList) do
		table.insert(newList, v.Object)
	end
	return newList
end

function WorldItemOverviewGUI:Event_OnActionButtonClick(action)
	local __, type = self.m_Changer:getIndex()
	if type == 1 then -- list
		outputDebug(action.." list")
		if action == WorldItemOverviewGUI.Action.Collect then
			QuestionBox:new(_("möchtest du wirklich %d Objekte aufheben? (dazu benötigst du den entsprechenden Platz im Inventar)", self.m_ListSize), 
			function()
				triggerServerEvent("worldItemMassCollect", root, self:getObjectsInList(), true, self.m_OwnerId, self.m_OwnerType)
			end)
		elseif action == WorldItemOverviewGUI.Action.Delete then
			QuestionBox:new(_("möchtest du wirklich %d Objekte permanent löschen? (dazu benötigst du den entsprechenden Platz im Inventar)", self.m_ListSize), 
			function()
				triggerServerEvent("worldItemMassDelete", root, self:getObjectsInList(), true, self.m_OwnerId, self.m_OwnerType)
			end)
		end
	elseif type == 2 then -- selection
		outputDebug(action.." selection")
		if self.m_SelectedListItem then
			if action == WorldItemOverviewGUI.Action.Collect then
				triggerServerEvent("worldItemCollect", self.m_FilteredObjectList[self.m_SelectedListItem.m_Id].Object, true, self.m_OwnerId, self.m_OwnerType)
				self:updateDebugArrow(true)
			elseif action == WorldItemOverviewGUI.Action.Delete then
				triggerServerEvent("worldItemDelete", self.m_FilteredObjectList[self.m_SelectedListItem.m_Id].Object, true, self.m_OwnerId, self.m_OwnerType)
				self:updateDebugArrow(true)
			end
		else
			ErrorBox:new(_"Bitte wähle ein Objekt aus der Liste aus oder ändere deine Auswahl links.")
		end
	end
end

addEventHandler("recieveWorldItemListOfOwner", root, function(sOwnerName, tblObjects, id, type)
	if WorldItemOverviewGUI:isInstantiated() then
		if id == WorldItemOverviewGUI:getSingleton().m_OwnerId then
			WorldItemOverviewGUI:getSingleton():loadObjectsInList(tblObjects)
		else
			ErrorBox:new(_"Bitte schließe erst das alte Objektübersichts-Fenster!")
		end
	else
	 WorldItemOverviewGUI:new(sOwnerName, tblObjects, id, type)
	end
end)

addCommandHandler("foverview", function(cmd)
	triggerServerEvent("requestWorldItemListOfOwner", localPlayer, localPlayer:getFaction():getId(), "faction")
end)
addCommandHandler("poverview", function(cmd)
	triggerServerEvent("requestWorldItemListOfOwner", localPlayer, localPlayer:getPrivateSync("Id"), "player")
end)