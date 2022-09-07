-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RankPermissionsGUI.lua
-- *  PURPOSE:     RankPermissionsGUI class
-- *
-- ****************************************************************************

RankPermissionsGUI = inherit(GUIForm)
inherit(Singleton, RankPermissionsGUI)

addRemoteEvents{"showRankPermissionsList"}
function RankPermissionsGUI:constructor(permissionsType, type)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 12) 
	self.m_Height = grid("y", 13)

	self.m_Changes = {}
	self.m_PermissionsType = permissionsType
	self.m_Type = type


	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Berechtigungen verwalten", true, true, self)
	
	self.m_PermissionsList = GUIGridGridList:new(1, 1, 9, 11, self.m_Window)
	self.m_PermissionsList:addColumn(_"Berechtigung", 1)
	
	self.m_SaveButton = GUIGridButton:new(1, 12, 11, 1, _"Speichern", self.m_Window)
	self.m_SaveButton.onLeftClick = bind(self.saveButton_Click, self)
	
	self.m_RankCheckBox = {}
	self.m_RankCheckBox[0] = GUIGridCheckbox:new(10, 3, 1, 1, _"Rang 0", self.m_Window):setEnabled(false)
	self.m_RankCheckBox[1] = GUIGridCheckbox:new(10, 4, 1, 1, _"Rang 1", self.m_Window):setEnabled(false)
	self.m_RankCheckBox[2] = GUIGridCheckbox:new(10, 5, 1, 1, _"Rang 2", self.m_Window):setEnabled(false)
	self.m_RankCheckBox[3] = GUIGridCheckbox:new(10, 6, 1, 1, _"Rang 3", self.m_Window):setEnabled(false)
	self.m_RankCheckBox[4] = GUIGridCheckbox:new(10, 7, 1, 1, _"Rang 4", self.m_Window):setEnabled(false)
	self.m_RankCheckBox[5] = GUIGridCheckbox:new(10, 8, 1, 1, _"Rang 5", self.m_Window):setEnabled(false)
	if type ~= "company" then 
		self.m_RankCheckBox[6] = GUIGridCheckbox:new(10, 9, 1, 1, _"Rang 6", self.m_Window):setEnabled(false)
	end
	
	for i, v in pairs(self.m_RankCheckBox) do
		v.onChange = function(state) self:onCheckBoxChange(i, state) end
	end

	addEventHandler("showRankPermissionsList", localPlayer, bind(self.updateList, self))

	triggerServerEvent("requestRankPermissionsList", localPlayer, permissionsType, type)
end

function RankPermissionsGUI:destructor()
	GUIForm.destructor(self)
end

function RankPermissionsGUI:updateList(rankTbl, type)
	self.m_RankPermissions = rankTbl
	self.m_Permissions = PermissionsManager:getSingleton():getPermissions(self.m_PermissionsType, type)

	self.m_PermissionsList:clear()
	for permission, permissionName in pairs(self.m_Permissions) do
		local item = self.m_PermissionsList:addItem(permissionName)
		item.name = permission
		item.onLeftClick = bind(self.setCheckBoxState, self, item.name)
	end
end

function RankPermissionsGUI:saveButton_Click()
	triggerServerEvent("changeRankPermissions", localPlayer, self.m_PermissionsType, self.m_Changes, self.m_Type)
	self.m_Changes = {}
end

function RankPermissionsGUI:setCheckBoxState(name, state)
	if name then
		local permInfo = self.m_PermissionsType == "permission" and PERMISSIONS_INFO or ACTION_PERMISSIONS_INFO
		for i, v in pairs(self.m_RankCheckBox) do
			v:setEnabled(tonumber(i) >= tonumber(permInfo[name][2][self.m_Type]))
			v:setChecked((self.m_Changes[i] and self.m_Changes[i][name]) or self.m_RankPermissions[tostring(i)][name])
		end
	end
end

function RankPermissionsGUI:onCheckBoxChange(rank, state)
	if self.m_PermissionsList:getSelectedItem() then
		if not self.m_Changes[rank] then
			self.m_Changes[rank] = {}
		end
		self.m_Changes[rank][self.m_PermissionsList:getSelectedItem().name] = state
	end
end