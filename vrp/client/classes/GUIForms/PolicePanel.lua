-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PolicePanel.lua
-- *  PURPOSE:     Police panel GUI
-- *
-- ****************************************************************************
PolicePanel = inherit(GUIForm)
inherit(Singleton, PolicePanel)

addEvent("policePanelListRetrieve", true)

function PolicePanel:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)
	
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Polizeicomputer", true, true, self):setCloseOnClose(false)
	self.m_GridPlayers = GUIGridList:new(0.02 * self.m_Width, 0.1 * self.m_Height, 0.55 * self.m_Width, 0.86 * self.m_Height, self.m_Window)
	self.m_GridPlayers:addColumn(_"Name", 0.7)
	self.m_GridPlayers:addColumn(_"Wanteds", 0.3)
	self.m_Rect = GUIRectangle:new(0.6 * self.m_Width, 0.1 * self.m_Height, 0.38 * self.m_Width, 0.86 * self.m_Height, Color.DarkBlue, self.m_Window)
	local rectWidth, rectHeight = self.m_Rect:getSize()
	self.m_ButtonLocate = GUIButton:new(rectWidth * 0.05, rectHeight * 0.02, rectWidth * 0.9, rectHeight * 0.07, _"Orten", self.m_Rect):setBackgroundColor(Color.Green)

	self.m_ButtonLocate.onLeftClick = bind(PolicePanel.ButtonLocate_Click, self)
	
	addEventHandler("policePanelListRetrieve", root,
		function(list)
			self.m_GridPlayers:clear()
			
			for player, wantedlevel in pairs(list) do
				self.m_GridPlayers:addItem(getPlayerName(player), tostring(wantedlevel))
			end
		end
	)
end

function PolicePanel:onShow()
	triggerServerEvent("policePanelListRequest", root)
end

function PolicePanel:ButtonLocate_Click()
	local selectedItem = self.m_GridPlayers:getSelectedItem()
	if not selectedItem then
		ShortMessage:new(_"Bitte wähle einen Spieler aus!")
		return
	end
	
	local player = getPlayerFromName(selectedItem:getColumnText(1))
	if not player then return end
	
	if not player.policeLocationBlip then
		player.policeLocationBlip = createBlipAttachedTo(player, 23)
	else
		destroyElement(player.policeLocationBlip)
		player.policeLocationBlip = nil
	end
end
