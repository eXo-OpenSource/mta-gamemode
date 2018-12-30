-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/ForumPermissionsGUI.lua
-- *  PURPOSE:     Forum Permissions GUI class
-- *
-- ****************************************************************************
ForumPermissionsGUI = inherit(GUIForm)
inherit(Singleton, ForumPermissionsGUI)

addRemoteEvents{"forumPermissionsReceive"}

function ForumPermissionsGUI:constructor(factionOrCompany, id)
	self.m_FactionOrCompanyId = id
	self.m_FactionOrCompany = factionOrCompany

	GUIWindow.updateGrid()
	self.m_Width = grid("x", 10)
	self.m_Height = grid("y", 13)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Foren-Gruppen", true, true, self)
	self.m_Window:deleteOnClose(true)

	self.m_Group = GUIGridChanger:new(1, 1, 9, 1, self.m_Window)

	self.m_Members = GUIGridGridList:new(1, 2, 9, 10, self.m_Window)
	self.m_Members:addColumn(_"Name", 1.0)

	self.m_SyncButton = GUIGridButton:new(3, 12, 5, 1, _"Synchronisieren", self.m_Window)
	self.m_SyncButton.onLeftClick = function()
		triggerServerEvent("forumPermissionsSync", localPlayer, self.m_FactionOrCompany, self.m_FactionOrCompanyId)
	end

	self.m_RefreshButton = GUIGridButton:new(1, 12, 1, 1, FontAwesomeSymbols.Refresh, self.m_Window):setBarEnabled(false):setFont(FontAwesome(15))
	self.m_RefreshButton.onLeftClick = function ()
		triggerServerEvent("forumPermissionsGet", localPlayer, self.m_FactionOrCompany, self.m_FactionOrCompanyId)
	end


	self.m_Group.onChange = function(item, index)
		if self.m_Data then
			for _, v in pairs(self.m_Data) do
				if v.name == item then
					self.m_Members:clear()
					for _, player in pairs(v.players) do
						self.m_Members:addItem(player.username)
					end
				end
			end
		end
	end

	self.m_ReceiveForumPermissionsEvent = bind(self.Event_ReceiveForumPermissions, self)
	addEventHandler("forumPermissionsReceive", root, self.m_ReceiveForumPermissionsEvent)

	triggerServerEvent("forumPermissionsGet", localPlayer, self.m_FactionOrCompany, self.m_FactionOrCompanyId)
end

function ForumPermissionsGUI:destructor()
	removeEventHandler("forumPermissionsReceive", root, self.m_ReceiveForumPermissionsEvent)
	GUIForm.destructor(self)
end

function ForumPermissionsGUI:Event_ReceiveForumPermissions(data)
	self.m_Data = data

	self.m_Group:clear()

	for _, group in pairs(data) do
		self.m_Group:addItem(group.name)
	end

	self.m_Group:setIndex(1)
end
