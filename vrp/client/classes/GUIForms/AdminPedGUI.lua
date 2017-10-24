-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminPedGUI.lua
-- *  PURPOSE:     Admin Ped GUI class
-- *
-- ****************************************************************************

AdminPedGUI = inherit(GUIForm)
inherit(Singleton, AdminPedGUI)

addRemoteEvents{"adminPedReceiveData"}

function AdminPedGUI:constructor(money)
	GUIForm.constructor(self, screenWidth/2-400, screenHeight/2-540/2, 800, 540)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, "Admin-Ped Menü", true, true, self)
	self.m_Window:addBackButton(function () delete(self) AdminGUI:getSingleton():show() end)

	self.m_PedGrid = GUIGridList:new(10, 50, self.m_Width-20, 300, self.m_Window)
	self.m_PedGrid:addColumn(_"ID", 0.05)
	self.m_PedGrid:addColumn(_"Name", 0.2)
	self.m_PedGrid:addColumn(_"Zone", 0.2)
	self.m_PedGrid:addColumn(_"Rollen", 0.3)
	self.m_PedGrid:addColumn(_"Aktuell", 0.1)
	self.m_PedGrid:addColumn(_"gespawnt", 0.15)


	self.m_SpawnPed = GUIButton:new(10, 360, 200, 30, "ausgewählen Ped spawnen",  self):setFontSize(1):setBackgroundColor(Color.Green)
	self.m_SpawnPed.onLeftClick = function()
		if not self.m_SelectedPedId then
			ErrorBox:new(_"Kein Ped ausgewählt!")
		end
		triggerServerEvent("adminPedSpawn", localPlayer, self.m_SelectedPedId)
	end
	self.m_SpawnPed:setVisible(false)
	self.m_DeletePosition = GUIButton:new(10, 395, 200, 30, "ausgewählen Ped Position löschen",  self):setFontSize(1):setBackgroundColor(Color.Red)
	self.m_DeletePosition:setVisible(false)
	self.m_DeletePosition.onLeftClick = function()
		if not self.m_SelectedPedId then
			ErrorBox:new(_"Kein Ped ausgewählt!")
		end
		triggerServerEvent("adminPedDelete", localPlayer, self.m_SelectedPedId)
	end

	self.m_CreatePed = GUIButton:new(10, 500, 180, 30, "neuen Ped plazieren",  self):setFontSize(1):setBackgroundColor(Color.LightBlue)
	self.m_CreatePed.onLeftClick = function() delete(self) triggerServerEvent("adminCreatePed", localPlayer) end

	self.m_RolesGrid = GUIGridList:new(390, 360, 180, 170, self.m_Window)
	self.m_RolesGrid:addColumn(_"verfügbare Rollen", 1)

	self.m_AddRoleButton = GUIButton:new(575, 405, 30, 30, FontAwesomeSymbols.Double_Right, self):setFont(FontAwesome(20)):setBackgroundColor(Color.LightBlue):setFontSize(1)
	self.m_AddRoleButton:setEnabled(false)
	self.m_AddRoleButton.onLeftClick = bind(self.addRole, self)

	self.m_RemRoleButton = GUIButton:new(575, 445, 30, 30, FontAwesomeSymbols.Double_Left, self):setFont(FontAwesome(20)):setBackgroundColor(Color.LightBlue):setFontSize(1)
	self.m_RemRoleButton:setEnabled(false)
	self.m_RemRoleButton.onLeftClick = bind(self.remRole, self)

	self.m_PedRolesGrid = GUIGridList:new(610, 360, 180, 170, self.m_Window)
	self.m_PedRolesGrid:addColumn(_"gesetzte Rollen", 1)

	addEventHandler("adminPedReceiveData", root, bind(self.onReceiveData, self))
end

function AdminPedGUI:onShow()
	SelfGUI:getSingleton():addWindow(self)
	triggerServerEvent("adminPedRequestData", localPlayer)
end

function AdminPedGUI:onHide()
	SelfGUI:getSingleton():removeWindow(self)
end

function AdminPedGUI:addRole()
	if not self.m_SelectedPedId then
		ErrorBox:new(_"Kein Ped ausgewählt!")
	end
	if self.m_RolesGrid:getSelectedItem() and self.m_RolesGrid:getSelectedItem().id then
		triggerServerEvent("adminPedChangeRole", localPlayer, self.m_SelectedPedId, "add", self.m_RolesGrid:getSelectedItem().id)
	else
		ErrorBox:new(_"Ungültige Rolle ausgewählt!")
	end
end

function AdminPedGUI:remRole()
	if not self.m_SelectedPedId then
		ErrorBox:new(_"Kein Ped ausgewählt!")
	end
	if self.m_PedRolesGrid:getSelectedItem() and self.m_PedRolesGrid:getSelectedItem().id then
		triggerServerEvent("adminPedChangeRole", localPlayer, self.m_SelectedPedId, "rem", self.m_PedRolesGrid:getSelectedItem().id)
	else
		ErrorBox:new(_"Ungültige Rolle ausgewählt!")
	end
end

function AdminPedGUI:onReceiveData(peds, roles, roleNames)

	self.m_PedData = peds
	self.m_Roles = roles
	self.m_RoleNames = roleNames
	local item, pedRoleNames

	self.m_PedGrid:clear()
	for id, pedData in pairs(peds) do
		pedRoleNames = {}
		for index, roleId in pairs(pedData["Roles"]) do
			table.insert(pedRoleNames, self.m_RoleNames[roleId])
		end
		item = self.m_PedGrid:addItem(id, pedData["Name"], getZoneName(normaliseVector(pedData["Pos"])), table.concat(pedRoleNames, ", "), pedData["CurrentRole"], pedData["Spawned"] and "Ja" or "Nein")
		item.id = id
		item.onLeftClick = function()
			self:onSelectPed(id)
		end
	end

	self.m_RolesGrid:clear()
	for roleName, roleId in pairs(roles) do
		item = self.m_RolesGrid:addItem(roleName)
		item.id = roleId
		item.onLeftClick = function()
			self.m_AddRoleButton:setEnabled(true)
		end
	end

	if self.m_SelectedPedId then
		self:onSelectPed(self.m_SelectedPedId)
	end
end

function AdminPedGUI:onSelectPed(id)
	local data = self.m_PedData[id]
	self.m_PedRolesGrid:clear()

	if not data then
		self.m_SelectedPedId = nil
		self.m_SpawnPed:setVisible(false)
		self.m_DeletePosition:setVisible(false)
		return
	end

	self.m_SelectedPedId = id
	self.m_SpawnPed:setVisible(true)
	self.m_DeletePosition:setVisible(true)
	if data["Spawned"] then
		self.m_SpawnPed:setText("ausgewählen Ped despawnen")
		self.m_SpawnPed:setBackgroundColor(Color.Red)
	else
		self.m_SpawnPed:setText("ausgewählen Ped spawnen")
		self.m_SpawnPed:setBackgroundColor(Color.Green)
	end

	for index, roleId in pairs(data["Roles"]) do
		item = self.m_PedRolesGrid:addItem(self.m_RoleNames[roleId])
		item.id = roleId
		item.onLeftClick = function()
			self.m_RemRoleButton:setEnabled(true)
		end
	end

end
