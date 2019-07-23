-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/InviteGUI.lua
-- *  PURPOSE:    	InviteGUI GUI class
-- *
-- ****************************************************************************
InviteGUI = inherit(GUIForm)

function InviteGUI:constructor(callback,filter)
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.2/2, screenHeight/2 - screenHeight*0.5/2, screenWidth*0.2, screenHeight*0.5)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Spieler einladen", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.1, _"Bitte wähle einen Spieler aus!", self.m_Window):setFont(VRPFont(self.m_Height*0.05))
	self.m_PlayerSearch = GUIEdit:new(self.m_Width*0.01, self.m_Height*0.14, self.m_Width*0.98, self.m_Height*0.07, self.m_Window)
	self.m_PlayerSearch.onChange = function () self:searchPlayer() end
	self.m_PlayersGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.22, self.m_Width*0.98, self.m_Height*0.65, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Name", 1)
	self.m_InviteButton = GUIButton:new(self.m_Width*0.01, self.m_Height*0.9, self.m_Width*0.98, self.m_Height*0.1, _"Hinzufügen", self.m_Window):setBackgroundColor(Color.Green)

	self.m_InviteButton.onLeftClick = bind(self.InviteButton_Click, self)

	self.m_Filter = filter

	self.m_Callback = callback
	self:refreshOnlinePlayers()
end

function InviteGUI:refreshOnlinePlayers()
	self.m_PlayersGrid:clear()
	if self.m_Filter == "group" then
		for k, player in ipairs(getElementsByType("player")) do
			if not player:getGroupType() then
				if #self.m_PlayerSearch:getText() < 3 or string.find(string.lower(player:getName()), string.lower(self.m_PlayerSearch:getText())) then
					self.m_PlayersGrid:addItem(getPlayerName(player))
				end
			end
		end
	elseif self.m_Filter == "faction" then
		for k, player in ipairs(getElementsByType("player")) do
			if player:getFactionId() == 0 then
				if #self.m_PlayerSearch:getText() < 3 or string.find(string.lower(player:getName()), string.lower(self.m_PlayerSearch:getText())) then
					self.m_PlayersGrid:addItem(getPlayerName(player))
				end
			end
		end
	elseif self.m_Filter == "company" then
		for k, player in ipairs(getElementsByType("player")) do
			if player:getCompanyId() == 0 then
				if #self.m_PlayerSearch:getText() < 3 or string.find(string.lower(player:getName()), string.lower(self.m_PlayerSearch:getText())) then
					self.m_PlayersGrid:addItem(getPlayerName(player))
				end
			end
		end
	else
		for k, player in ipairs(getElementsByType("player")) do
			if #self.m_PlayerSearch:getText() < 3 or string.find(string.lower(player:getName()), string.lower(self.m_PlayerSearch:getText())) then
				self.m_PlayersGrid:addItem(getPlayerName(player))
			end
		end
	end
end

function InviteGUI:searchPlayer()
	self:refreshOnlinePlayers()
end

function InviteGUI:InviteButton_Click()
	local selectedItem = self.m_PlayersGrid:getSelectedItem()
	if selectedItem then
		local player = getPlayerFromName(selectedItem:getColumnText(1))
		if player then
			self.m_Callback(player)
			delete(self)
		else
			ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online!")
		end
	end
end
