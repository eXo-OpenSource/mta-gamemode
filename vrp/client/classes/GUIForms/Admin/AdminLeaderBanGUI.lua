-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/Admin/AdminLeaderBanGUI.lua
-- *  PURPOSE:     AdminLeaderBanGUI class
-- *
-- ****************************************************************************
AdminLeaderBanGUI = inherit(GUIForm)
inherit(Singleton, AdminLeaderBanGUI)
addRemoteEvents{"adminSendLeaderBansToClient", "adminRemoveLeaderBanFromList"}

function AdminLeaderBanGUI:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 17)
	self.m_Height = grid("y", 14)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Leadersperren", true, true, self)
    self.m_GridList = GUIGridGridList:new(1, 1, 7, 12, self.m_Window)
    self.m_GridList:addColumn("ID", 0.2)
	self.m_GridList:addColumn("Name", 0.8)
    self.m_GridList:setSortable{"ID", "Name"}
	self.m_DeleteButton = GUIGridButton:new(1, 13, 7, 1, "Löschen", self.m_Window):setBackgroundColor(Color.Red)
	
    self.m_ReasonHeaderLabel = GUIGridLabel:new(8, 1, 9, 1, "Begründung:", self.m_Window):setHeader()
    self.m_ReasonLabel = GUIGridLabel:new(8, 3, 9, 1, "", self.m_Window):setMultiline(true)
	self.m_CreatedAtLabel = GUIGridLabel:new(8, 5, 9, 1, "Vergeben am: ", self.m_Window)
	self.m_ValidUntilLabel = GUIGridLabel:new(8, 6, 9, 1, "Sperre bis: ", self.m_Window)
	self.m_AdminLabel = GUIGridLabel:new(8, 7, 9, 1, "Admin(s): ", self.m_Window)
	
    self.m_NewLabel = GUIGridLabel:new(8, 8, 8, 1, "Neue Leadersperre eintragen", self.m_Window):setHeader()
    self.m_NewNameEdit = GUIGridEdit:new(8, 9, 9, 1, self.m_Window):setCaption("Name")
	self.m_NewReasonEdit = GUIGridEdit:new(8, 10, 9, 1, self.m_Window):setCaption("Begründung")
	self.m_NewValidUntilEdit = GUIGridEdit:new(8, 11, 9, 1, self.m_Window):setCaption("Gültig bis (timestamp eintragen)"):setNumeric(true, true)
    self.m_NewAdminNamesEdit = GUIGridEdit:new(8, 12, 9, 1, self.m_Window):setCaption("Admin (mehrere mit , trennen)")
    self.m_NewCreateButton = GUIGridButton:new(8, 13, 9, 1, "Leadersperre eintragen", self.m_Window):setBackgroundColor(Color.Green)
    
    self.m_EventBind = bind(self.fillGridList, self)
    addEventHandler("adminSendLeaderBansToClient", root, self.m_EventBind)
    self.m_RemoveBind = bind(self.removeFromGridList, self)
    addEventHandler("adminRemoveLeaderBanFromList", root, self.m_RemoveBind)

    self.m_DeleteButton.onLeftClick = function()
        if self.m_GridList:getSelectedItem() then
            local id = self.m_GridList:getSelectedItem():getColumnText(1)
            local name = self.m_GridList:getSelectedItem():getColumnText(2)
            InputBox:new("Leadersperre aufheben", "Aus welchem Grund möchtest du die Sperre aufheben?", 
                function(text)
                    triggerServerEvent("adminEditLeaderBans", localPlayer, "remove", name, text)
                end
            )
        end
    end
    self.m_NewCreateButton.onLeftClick = function()
        local name = self.m_NewNameEdit:getText()
        local reason = self.m_NewReasonEdit:getText()
        local validUntil = self.m_NewValidUntilEdit:getText()
        local admins = self.m_NewAdminNamesEdit:getText()
        if name and validUntil and tonumber(validUntil) then
            QuestionBox:new(_("Möchtest du dem Spieler %s eine Leadersperre geben?", name),
                function()
                    triggerServerEvent("adminEditLeaderBans", localPlayer, "add", name, reason, tonumber(validUntil), admins)
                end
            )
        else
            ErrorBox:new("Bitte gib einen Namen und einen Timestamp an.")
        end
    end

    triggerServerEvent("adminRequestLeaderBans", localPlayer)
end

function AdminLeaderBanGUI:destructor()
    removeEventHandler("adminSendLeaderBansToClient", root, self.m_EventBind)
    removeEventHandler("adminRemoveMultiAccountFromList", root, self.m_RemoveBind)
	GUIForm.destructor(self)
end

function AdminLeaderBanGUI:fillGridList(leaderBanTable, nameTable)
    self.m_GridList:clear()
    for id, data in pairs(leaderBanTable) do
        local item = self.m_GridList:addItem(tostring(id), nameTable[id]["playerName"])
        item.id = id
        item.onLeftClick = function()
            self.m_ReasonLabel:setText(_("%s", data["reason"]))
            self.m_CreatedAtLabel:setText(_("Vergeben am: %s", getOpticalTimestamp(data["createdAt"])))
            self.m_ValidUntilLabel:setText(_("Sperre bis: %s", data["validUntil"] == 0 and "unbefristet" or getOpticalTimestamp(data["validUntil"])))
            local text = "-"
            for key, name in pairs(nameTable[id]["adminNames"]) do
                if key == 1 then
                    text = name
                else
                    text = text..", "..name
                end
            end
            self.m_AdminLabel:setText(_("Admin: %s",text))
        end
    end
end

function AdminLeaderBanGUI:removeFromGridList(id)
    for key, item in pairs(self.m_GridList:getItems()) do
        if item:getColumnText(1) == id then
            self.m_GridList:removeItem(key)
        end
    end
end
