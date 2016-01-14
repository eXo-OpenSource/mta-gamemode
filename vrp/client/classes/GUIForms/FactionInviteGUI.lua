-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/FactionInviteGUI.lua
-- *  PURPOSE:     Faction creation GUI class
-- *
-- ****************************************************************************
FactionInviteGUI = inherit(GUIForm)

function FactionInviteGUI:constructor()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.2/2, screenHeight/2 - screenHeight*0.5/2, screenWidth*0.2, screenHeight*0.5)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Spieler einladen", true, true, self)
	GUILabel:new(self.m_Width*0.01, self.m_Height*0.08, self.m_Width*0.96, self.m_Height*0.1, _"Bitte wähle einen Spieler aus!", self.m_Window):setFont(VRPFont(self.m_Height*0.05))
	self.m_PlayersGrid = GUIGridList:new(self.m_Width*0.01, self.m_Height*0.14, self.m_Width*0.98, self.m_Height*0.75, self.m_Window)
	self.m_PlayersGrid:addColumn(_"Name", 1)
	self.m_InviteButton = GUIButton:new(self.m_Width*0.01, self.m_Height*0.9, self.m_Width*0.98, self.m_Height*0.1, _"Hinzufügen", self.m_Window):setBackgroundColor(Color.Green)
	
	self.m_InviteButton.onLeftClick = bind(self.InviteButton_Click, self)
	
	for k, player in ipairs(getElementsByType("player")) do
		self.m_PlayersGrid:addItem(getPlayerName(player))
	end
end

function FactionInviteGUI:InviteButton_Click()
	local selectedItem = self.m_PlayersGrid:getSelectedItem()
	if selectedItem then
		local player = getPlayerFromName(selectedItem:getColumnText(1))
		if player then
			triggerServerEvent("factionAddPlayer", root, player)
			delete(self)
		else
			ErrorBox:new(_"Dieser Spieler ist nicht (mehr) online!")
		end
	end
end
