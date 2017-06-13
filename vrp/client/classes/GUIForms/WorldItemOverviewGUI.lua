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

function WorldItemOverviewGUI:constructor(sOwnerName, tblObjects, id, type)
    --main
    self.m_OwnerId = id
    self.m_OwnerType = type
    self.m_Width = 640
    self.m_Height = 415
    self.m_Refreshing = false
    self.m_FiltersApplied = false
    GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height)
    self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("Objektübersicht - %s", sOwnerName), true, true, self)
   
    --object list
    GUILabel:new(5, 30, self.m_Width, 30, _"platzierte Objekte", self)
    self.m_ObjectList = GUIGridList:new(5, 65, self.m_Width - 10, 200, self)
        :addColumn(_"Name", 0.2)
        :addColumn(_"Position", 0.3)
        :addColumn(_"Ersteller", 0.2)
        :addColumn(_"Erstellzeit", 0.3)

    self.m_ListRefreshButton = GUIButton:new(self.m_Width-35, 65, 30, 30, " "..FontAwesomeSymbols.Refresh, self):setFont(FontAwesome(15)):setFontSize(1)
    self.m_ListRefreshButton:setBackgroundColor(Color.LightBlue)
    self.m_ListRefreshButton.onLeftClick = function()
        self.m_Refreshing = true
        self.m_ListRefreshButton:setEnabled(false)
        triggerServerEvent("requestWorldItemListOfOwner", localPlayer, self.m_OwnerId, self.m_OwnerType)
    end
    self:loadObjectsInList(tblObjects)
    
    --filter
    GUILabel:new(5, 270, self.m_Width, 30, _"Filter", self) 
    GUIEdit:new(5, 305, 120, 30, self):setFontSize(1)
    GUIEdit:new(130, 305, 190, 30, self):setFontSize(1)
    GUIEdit:new(325, 305, 120, 30, self):setFontSize(1)
    GUIEdit:new(450, 305, 150, 30, self):setFontSize(1)
    self.m_FilterApplyButton = GUIButton:new(self.m_Width-35, 305, 30, 30, " "..FontAwesomeSymbols.Check, self):setFont(FontAwesome(15)):setFontSize(1)
    self.m_FilterApplyButton:setBackgroundColor(Color.LightBlue)
    
    --options
    GUILabel:new(5, 340, self.m_Width, 30, _"Optionen", self)
    self.m_Changer = GUIChanger:new(5, 375, 250, 30, self)
    self.m_Changer:addItem("Filter (gesamte Liste)")
    self.m_Changer:addItem("Auswahl in Liste")
    VRPButton:new(260, 375, 165, 30, _"auf Karte markieren", true, self)
    VRPButton:new(430, 375, 100, 30, _"Aufheben", true, self)
    VRPButton:new(535, 375, 100, 30, _"Löschen", true, self):setBarColor(Color.Red)

    --[[
        self.m_ShortMessageCTCInfo = GUILabel:new(self.m_Width*0.42, self.m_Height*0.325, self.m_Width*0.03, self.m_Height*0.04, "(?)", self.m_SettingBG)
		self.m_ShortMessageCTCInfo:setFont(VRPFont(25))
		self.m_ShortMessageCTCInfo:setFontSize(1)
		self.m_ShortMessageCTCInfo:setColor(Color.LightBlue)
		self.m_ShortMessageCTCInfo.onHover = function () self.m_ShortMessageCTCInfo:setColor(Color.White) end
		self.m_ShortMessageCTCInfo.onUnhover = function () self.m_ShortMessageCTCInfo:setColor(Color.LightBlue) end
		self.m_ShortMessageCTCInfo.onLeftClick = function ()
			ShortMessage:new(_(HelpTexts.Settings.ShortMessageCTC), _(HelpTextTitles.Settings.ShortMessageCTC), nil, 25000)
		end
    ]]
end

function WorldItemOverviewGUI:loadObjectsInList(tblObjects)
    self.m_ListRefreshButton:setEnabled(true)
    self.m_Refreshing = false
    self.m_ObjectList:clear()
    for modelid, objects in pairs(tblObjects) do
        for object in pairs(tblObjects[modelid]) do
            self.m_ObjectList:addItem(
                object:getData("Name"), getZoneName(object:getPosition()), object:getData("Placer"), getOpticalTimestamp(object:getData("PlacedTimestamp"))
            )
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