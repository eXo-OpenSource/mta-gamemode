-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/GroupPropertyGUI.lua
-- *  PURPOSE:     GroupProperty GUI class
-- *
-- ****************************************************************************
GroupPropertyGUI = inherit(GUIForm)
inherit(Singleton, GroupPropertyGUI)

addRemoteEvents{"setPropGUIActive","sendGroupKeyList","updateGroupDoorState","forceGroupPropertyClose"}
function GroupPropertyGUI:constructor( tObj )
	self.m_PropertyTable = tObj
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.4/2, screenHeight/2 - screenHeight*0.5/2, screenWidth*0.4, screenHeight*0.5, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Immobilienpanel", true, false, self)
	self.m_TabPanel = GUITabPanel:new(0, self.m_Height*0.1, self.m_Width, self.m_Height*0.8, self.m_Window)
	local tabManage = self.m_TabPanel:addTab(_("Verwaltung"))
	self.m_TabManage = tabManage
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.05, self.m_Width*0.99, self.m_Height*0.14, _"Verwaltung", tabManage):setFontSize(1)
	GUIRectangle:new(self.m_Width*0.01, self.m_Height*0.19, self.m_Width*0.98, self.m_Height*0.01, tocolor(200,200,200,255),tabManage)
	self.m_LockButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.3, self.m_Width*0.35, self.m_Height*0.08, _"Auf-/Abschließen", tabManage):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_KeyImage = GUIImage:new(self.m_Width*0.09-(self.m_Height*0.1), self.m_Height*0.3, self.m_Height*0.1, self.m_Height*0.1,"files/images/Other/KeyIcon.png", self.m_TabManage)
	self.m_LockButton.onLeftClick = function() triggerServerEvent("switchGroupDoorState",localPlayer) end
	self:setGroupDoorState( tObj.m_Open )
	self.m_DepotButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.43, self.m_Width*0.35, self.m_Height*0.08, _"Depot", tabManage):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_DepotBtnFunc = function() self:openDepot() end
	self.m_DepotButton.onLeftClick = self.m_DepotBtnFunc

	self.m_MessageButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.56, self.m_Width*0.35, self.m_Height*0.08, _"Eingangsnachricht", tabManage):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_MessageFunc = function() self:newMessageWindow() end
	self.m_MessageButton.onLeftClick = self.m_MessageFunc
	self.m_MessageButton:setVisible(false) -- nicht fertig
	self.m_SellButton = GUIButton:new(self.m_Width*0.1, self.m_Height*0.69, self.m_Width*0.35, self.m_Height*0.08, _"Verkaufen", tabManage):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_SellButton.onLeftClick = bind(GroupPropertyGUI.OnSellClick,self)

	local x,y,z = getElementPosition( tObj.m_Pickup)
	GUIRectangle:new(self.m_Width*0.59, self.m_Height*0.29, self.m_Width*0.37, self.m_Height*0.49, tocolor(179,89,0,255),self.m_TabManage)
	self.m_Map = GUIMiniMap:new(self.m_Width*0.6, self.m_Height*0.3, self.m_Width*0.35, self.m_Height*0.47, self.m_TabManage)
	self.m_Map:setMapPosition(x, y)
	self.m_Map:addBlip("Marker.png", x, y)

	local tabAccess = self.m_TabPanel:addTab(_("Berechtigung"))
	self.m_TabAccess = tabAccess

	GUILabel:new(self.m_Width*0.01, self.m_Height*0.05, self.m_Width*0.99, self.m_Height*0.14, _"Schlüssel-Berechtigung", tabAccess):setFont(VRPFont(self.m_Height*0.14))
	GUIRectangle:new(self.m_Width*0.01, self.m_Height*0.2, self.m_Width*0.98, self.m_Height*0.01, tocolor(200,200,200,255),tabAccess)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.25, self.m_Width*0.45, self.m_Height*0.1, _"Name des Spielers:", tabAccess)
	self.m_PlayerEdit = GUIEdit:new(self.m_Width*0.45, self.m_Height*0.25, self.m_Width*0.5, self.m_Height*0.08, tabAccess)
	self.m_KeyAddButton = GUIButton:new(self.m_Width*0.65, self.m_Height*0.37, self.m_Width*0.3, self.m_Height*0.08, _"Vergeben", tabAccess):setBackgroundColor(Color.Green):setFontSize(1)
	self.m_KeyRemoveButton = GUIButton:new(self.m_Width*0.65, self.m_Height*0.47, self.m_Width*0.3, self.m_Height*0.08, _"Abnehmen", tabAccess):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_KeyRemoveAllButton = GUIButton:new(self.m_Width*0.65, self.m_Height*0.57, self.m_Width*0.3, self.m_Height*0.08, _"Alle Abnehmen", tabAccess):setBackgroundColor(Color.Red):setFontSize(1)
	self.m_KeyRefreshButton = GUIButton:new(self.m_Width*0.65, self.m_Height*0.67, self.m_Width*0.3, self.m_Height*0.08, _"Aktualisieren", tabAccess):setBackgroundColor(Color.Orange):setFontSize(1)
	self.m_KeyAddButton.onLeftClick = function() triggerServerEvent("KeyChangeAction",localPlayer, self.m_PlayerEdit:getDrawnText(),"add") end
	self.m_KeyRemoveButton.onLeftClick = function() triggerServerEvent("KeyChangeAction", localPlayer, self.m_PlayerEdit:getDrawnText(),"remove") end
	self.m_KeyRemoveAllButton.onLeftClick = function() triggerServerEvent("KeyChangeAction", localPlayer, false, "all") end
	self.m_KeyRefreshButton.onLeftClick = function() self:triggerRefresh()  end
	self.m_KeyGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.37, self.m_Width*0.62, self.m_Height*0.38, tabAccess)
	self.m_KeyGrid:addColumn(_"Spieler mit Schlüssel", 1)


	local tabInfo = self.m_TabPanel:addTab(_("Information"))
	self.m_TabInfo = tabInfo
	GUILabel:new(self.m_Width*0, self.m_Height*0.1, self.m_Width, self.m_Height*0.10, string.upper(self.m_PropertyTable.m_Name), tabInfo):setFont(VRPFont(self.m_Height*0.12)):setAlignX("center")
	GUIRectangle:new(self.m_Width*0.1, self.m_Height*0.23, self.m_Width*0.8, self.m_Height*0.01, tocolor(255,255,255,255),tabInfo)
	GUILabel:new(self.m_Width*0.1, self.m_Height*0.24, self.m_Width*0.65, self.m_Height*0.10, "Kaufpreis: "..self.m_PropertyTable.m_Price.."$", tabInfo):setFont(VRPFont(self.m_Height*0.08))
	GUILabel:new(self.m_Width*0.1, self.m_Height*0.36, self.m_Width*0.65, self.m_Height*0.10, "Verkaufpreis (System): "..math.floor(self.m_PropertyTable.m_Price*0.66).."$", tabInfo):setFont(VRPFont(self.m_Height*0.08))
	GUILabel:new(self.m_Width*0.1, self.m_Height*0.48, self.m_Width*0.65, self.m_Height*0.10, "Lage: "..getZoneName(tObj.m_CamMatrix[1],tObj.m_CamMatrix[2],tObj.m_CamMatrix[3]), tabInfo):setFont(VRPFont(self.m_Height*0.08))

	addEventHandler("sendGroupKeyList", root, function(tList, tChangeList)
		self:refreshGrid(tList,tChangeList)
	end)

	addEventHandler("updateGroupDoorState", root, function(iState)
		self:setGroupDoorState(iState)
	end)

end

function GroupPropertyGUI:openDepot( )
	triggerServerEvent("requestPropertyItemDepot", localPlayer)
end

function GroupPropertyGUI:OnSellClick()
	QuestionBox:new(
		_"Bist du dir sicher, dass du diese Immobilie verkaufen möchtest?",
		function() 	triggerServerEvent("GroupPropertySell",localPlayer) end
	)
end

function GroupPropertyGUI:newMessageWindow()
	if self.m_MessageWindow then
		self.m_MessageWindow:delete()
	end
	self.m_MessageWindow = GroupPropertyMessageGUI:new( self )
end

function GroupPropertyGUI:forceClose()
	delete(self)
end

function GroupPropertyGUI:triggerRefresh()
	triggerServerEvent("requestRefresh",localPlayer)
end

function GroupPropertyGUI:refreshGrid(t1, t2)
	self.m_KeyGrid:clear()
	for k, v in ipairs(t1) do
		self.m_KeyGrid:addItem(v.NameOfOwner)
	end
	for k, v in ipairs(t2) do
		if v[1] == "add" then
			self.m_KeyGrid:addItem(v[4])
		end
	end
end

function GroupPropertyGUI:setGroupDoorState( b )
	self.m_Open = b
	if b == 0 then
		self.m_KeyImage:setVisible(true)
	else
		self.m_KeyImage:setVisible(false)
	end
end



function GroupPropertyGUI:setMessage( text )
	if #text < 20 and #text > 1 then
		triggerServerEvent("updatePropertyText",localPlayer, text)
	end
end

addEventHandler("forceGroupPropertyClose",localPlayer,function()
	GroupPropertyGUI.disable()
end)

function GroupPropertyGUI.disable()
	if GroupPropertyGUI:isInstantiated() then
		delete(GroupPropertyGUI:getSingleton())
	end
	unbindKey("f6","up", GroupPropertyGUI.toggle)
end

function GroupPropertyGUI.toggle(key, state, pickup)
	if GroupPropertyGUI:isInstantiated() then
		delete(GroupPropertyGUI:getSingleton())
	else
		GroupPropertyGUI:new(pickup)
	end
end

addEventHandler("setPropGUIActive",localPlayer,function(pickup)
	bindKey("f6","up", GroupPropertyGUI.toggle, pickup)
	ShortMessage:new(_"Drücke F6 für das Immobilien-Panel!")
end
)
