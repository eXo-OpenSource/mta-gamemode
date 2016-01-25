-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/AdminGUI.lua
-- *  PURPOSE:     Admin GUI class
-- *
-- ****************************************************************************

AdminGUI = inherit(GUIForm)
inherit(Singleton, AdminGUI)

addRemoteEvents{"showAdminMenu"}
function AdminGUI:constructor() 
	
	GUIForm.constructor(self, screenWidth/2-screenWidth*0.5/2, screenHeight/2-screenHeight*0.5/2, screenWidth*0.5, screenHeight*0.5)
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() self:close() end
	
	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	GUILabel:new(self.m_Width*0.02, self.m_Height*0.2, self.m_Width*0.25, self.m_Height*0.07, _"Adminansage:", tabAllgemein):setColor(Color.White)
	self.m_AdminAnnounceText = GUIEdit:new(self.m_Width*0.02, self.m_Height*0.29, self.m_Width*0.6, self.m_Height*0.09,tabAllgemein)
	self.m_AnnounceButton = GUIButton:new(self.m_Width*0.68, self.m_Height*0.29, self.m_Width*0.2, self.m_Height*0.09, _"senden",  tabAllgemein)
	self.m_AnnounceButton.onLeftClick = bind(self.AnnounceButton_Click, self)
	
	local tabSpieler = self.m_TabPanel:addTab(_"Spieler")
	self.m_PlayersGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.9, tabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 1)
	self.m_setFactionButton = GUIButton:new(self.m_Width*0.40, self.m_Height*0.05, self.m_Width*0.3, self.m_Height*0.075, _"in Fraktion setzten",  tabSpieler)
	
	for key, playeritem in ipairs(getElementsByType("player")) do
		local item = self.m_PlayersGrid:addItem(playeritem:getName())
		item.player = playeritem
	end
	
	self.m_setFactionButton.onLeftClick = function() 
		local factionTable = {[1] = "SAPD", [2] = "FBI", [3] = "SA Army", [4] = "Rescue Team", [5] = "Cosa Nostra"}
		if self.m_PlayersGrid:getSelectedItem() then
			local selectedPlayer = self.m_PlayersGrid:getSelectedItem().player
			ChangerBox:new(_"Fraktion setzten", _"Bitte wähle die gewünschte Fraktion aus:",factionTable, function (factionId) triggerServerEvent("adminSetPlayerFaction", root, selectedPlayer,factionId) end) 
		end
	end
end

function AdminGUI:AnnounceButton_Click()
	local announceString = self.m_AdminAnnounceText:getText()
	if announceString ~= "" and #announceString > 0 then 
		--triggerServerEvent("adminAnnounce", root, announceString)
		self:AnnounceText( announceString )
		self.m_AdminAnnounceText:setText(" ")
	else
		ErrorBox:new(_"Bitte geben einen gültigen Wert ein!")
	end
end

function AdminGUI:AnnounceText( message )
	if self.m_MoveText == nil then
		self.m_MoveText = GUIMovetext:new(0, 0, screenWidth, screenHeight*0.05,message,"",1,(screenWidth*0.1)*-1, self,"files/images/GUI/megafone.png",true)
	end
end

addEventHandler("showAdminMenu", root,
		function(...)
			AdminGUI:new()
			AdminGUI:show()
		end
	)