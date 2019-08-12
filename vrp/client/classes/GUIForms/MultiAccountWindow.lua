-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/MultiAccountWindow.lua
-- *  PURPOSE:     MultiAccountWindow class
-- *
-- ****************************************************************************
MultiAccountWindow = inherit(GUIForm)
inherit(Singleton, MultiAccountWindow)
addRemoteEvents{"adminSendMultiAccountsToClient", "adminRemoveMultiAccountFromList"}

function MultiAccountWindow:constructor()
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 17)
	self.m_Height = grid("y", 13)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Multi-Accounts", true, true, self)
    self.m_GridList = GUIGridGridList:new(1, 1, 7, 11, self.m_Window)
    self.m_GridList:addColumn("ID", 0.1)
	self.m_GridList:addColumn("Name", 0.4)
    self.m_GridList:addColumn("Multi-Account", 0.5)
    self.m_GridList:setSortable{"Name", "Multi-Account"}
	self.m_DeleteButton = GUIGridButton:new(1, 12, 7, 1, "Löschen", self.m_Window):setBackgroundColor(Color.Red)
	
	self.m_IdLabel = GUIGridLabel:new(8, 1, 9, 1, "Multi-Account ID: ", self.m_Window):setHeader()
	self.m_NameLabel = GUIGridLabel:new(8, 2, 9, 1, "Name: ", self.m_Window)
	self.m_MultiNameLabel = GUIGridLabel:new(8, 3, 9, 1, "Multi-Account: ", self.m_Window)
	self.m_SerialLabel = GUIGridLabel:new(8, 4, 9, 1, "Serial: ", self.m_Window)
	self.m_AllowCreateLabel = GUIGridLabel:new(8, 5, 9, 1, "Kann Multi-Account erstellen: ", self.m_Window)
	self.m_AdminLabel = GUIGridLabel:new(8, 6, 9, 1, "Admin: ", self.m_Window)
	
    self.m_NewLabel = GUIGridLabel:new(8, 7, 8, 1, "Neuen Multi-Account erstellen", self.m_Window):setHeader()
    self.m_NewSerialEdit = GUIGridEdit:new(8, 8, 9, 1, self.m_Window):setCaption("Serial")
	self.m_NewNameEdit = GUIGridEdit:new(8, 9, 9, 1, self.m_Window):setCaption("Name")
	self.m_NewMultiNameEdit = GUIGridEdit:new(8, 10, 9, 1, self.m_Window):setCaption("Multi-Account Name (mehrere mit , trennen)")
	self.m_AllowCreateSwitch = GUIGridSwitch:new(14, 11, 3, 1, self.m_Window)
	self.m_NewAllowCreateLabel = GUIGridLabel:new(8, 11, 6, 1, "Kann neuen Account erstellen:", self.m_Window)
    self.m_NewCreateButton = GUIGridButton:new(8, 12, 9, 1, "Multi-Account eintragen", self.m_Window):setBackgroundColor(Color.Green)
    
    self.m_EventBind = bind(self.fillGridList, self)
    addEventHandler("adminSendMultiAccountsToClient", root, self.m_EventBind)
    self.m_RemoveBind = bind(self.removeFromGridList, self)
    addEventHandler("adminRemoveMultiAccountFromList", root, self.m_RemoveBind)

    self.m_DeleteButton.onLeftClick = function()
        if self.m_GridList:getSelectedItem() then
            local id = self.m_GridList:getSelectedItem():getColumnText(1)
            QuestionBox:new(_("Möchtest du den Multi-Account mit der ID %s löschen?", id),
                function()
                    triggerServerEvent("adminDelteMultiAccount", localPlayer, id)
                end
            )
        end
    end
    self.m_NewCreateButton.onLeftClick = function()
        local serial = self.m_NewSerialEdit:getText()
        local name = self.m_NewNameEdit:getText()
        local multiAccountName = self.m_NewMultiNameEdit:getText()
        local allowCreate = self.m_AllowCreateSwitch:getState()
        if serial then
            QuestionBox:new(_("Möchtest du einen Multi-Account mit der Serial %s erstellen?", serial),
                function()
                    triggerServerEvent("adminCreateMultiAccount", localPlayer, serial, name, multiAccountName, allowCreate)
                end
            )
        else
            ErrorBox:new("Bitte trage eine Serial ein!")
        end
    end

    triggerServerEvent("adminRequestMultiAccounts", localPlayer)
end

function MultiAccountWindow:destructor()
    removeEventHandler("adminSendMultiAccountsToClient", root, self.m_EventBind)
    removeEventHandler("adminRemoveMultiAccountFromList", root, self.m_RemoveBind)
	GUIForm.destructor(self)
end

function MultiAccountWindow:fillGridList(multiAccountTable)
    for key, multiAccount in pairs(multiAccountTable) do
        local multiAccounts = ""
        if #multiAccount.linkedTo > 2 then
            multiAccounts = tostring(string.short(multiAccount.linkedTo[2], 9).." +"..#multiAccount.linkedTo-2)
        else
            multiAccounts = tostring(multiAccount.linkedTo[2] and string.short(multiAccount.linkedTo[2], 12) or "-")
        end

        local item = self.m_GridList:addItem(tostring(key), string.short(tostring(multiAccount.linkedTo[1] or "-"), 12), multiAccounts)
        item.onLeftClick = function()
            self.m_IdLabel:setText(_("Multi-Account ID: %s", key))
            self.m_NameLabel:setText(_("Name: %s", multiAccount.linkedTo[1] or "-"))
            local text = "-"
            for key, name in pairs(multiAccount.linkedTo) do
                if key == 1 then
                    text = ""
                elseif key == 2 then
                    text = name
                else
                    text = text..", "..name
                end
            end
            self.m_MultiNameLabel:setText(_("Multi-Account(s): %s", text))
            self.m_SerialLabel:setText(_("Serial: %s", multiAccount.serial))
            self.m_AllowCreateLabel:setText(_("Kann Multi-Account erstellen: %s", multiAccount.allowCreate > 0 and "Ja" or "Nein"))
            self.m_AdminLabel:setText(_("Admin: %s", multiAccount.admin))
        end
    end
end

function MultiAccountWindow:removeFromGridList(id)
    for key, item in pairs(self.m_GridList:getItems()) do
        if item:getColumnText(1) == id then
            self.m_GridList:removeItem(key)
        end
    end
end
