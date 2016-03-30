-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PolicePanel.lua
-- *  PURPOSE:     PolicePanel form class
-- *
-- ****************************************************************************

PolicePanel = inherit(GUIForm)
inherit(Singleton, PolicePanel)

local PlayerLocateBlip

function PolicePanel:constructor()
	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-230, 600, 460)

	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	self.m_CloseButton.onLeftClick = function() self:close() end
	self.m_TabSpieler = self.m_TabPanel:addTab(_"Spieler")

	self.m_PlayersGrid = GUIGridList:new(10, 10, 300, 400, self.m_TabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 0.5)
	self.m_PlayersGrid:addColumn(_"Fraktion", 0.3)

	self.m_PlayerNameLabel = GUILabel:new(320, 10, 180, 20, _"Spieler: -", self.m_TabSpieler)
	self.m_PlayerTimeLabel = GUILabel:new(320, 35, 180, 20, _"Spielstunden: -", self.m_TabSpieler)
	self.m_PlayerFactionLabel = GUILabel:new(320, 60, 180, 20, _"Fraktion: -", self.m_TabSpieler)
	self.m_PlayerCompanyLabel = GUILabel:new(320, 85, 180, 20, _"Unternehmen: -", self.m_TabSpieler)
	self.m_PlayerGroupLabel = GUILabel:new(320, 110, 180, 20, _"Gang/Firma: -", self.m_TabSpieler)
	self.m_PhoneStatus = GUILabel:new(320, 135, 180, 20, _"Handy: -", self.m_TabSpieler)

	self.m_LocatePlayerBtn = GUIButton:new(320, 280, 250, 30, "Spieler orten", self.m_TabSpieler)
	self.m_LocatePlayerBtn.onLeftClick = function() self:locatePlayer() end

	self:loadPlayers()
end

function PolicePanel:loadPlayers()
	self.m_PlayersGrid:clear()
	self.m_Players = {}
	for i=0, 6 do
		for Id, player in pairs(Element.getAllByType("player")) do
			if player:getWantedLevel() == i then
				if not self.m_Players[i] then self.m_Players[i] = {} end
				self.m_Players[i][player] = true
			end
		end
	end
	for i = 6, 0, -1 do
		if self.m_Players[i] then
			self.m_PlayersGrid:addItemNoClick(i.." Wanteds", "")
			for player, bool in pairs(self.m_Players[i]) do
				local item = self.m_PlayersGrid:addItem(player:getName(), player:getShortFactionName())
				item.player = player
				item.onLeftClick = function()
					self:onSelectPlayer(player)
				end
			end
		end
	end
end

function PolicePanel:onSelectPlayer(player)
	self.m_PlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	local hours, minutes = math.floor(player:getPlayTime()/60), (player:getPlayTime() - math.floor(player:getPlayTime()/60)*60)
	self.m_PlayerTimeLabel:setText(_("Spielzeit: %s:%s h", hours, minutes))
	self.m_PlayerFactionLabel:setText(_("Fraktion: %s", player:getShortFactionName()))
	self.m_PlayerCompanyLabel:setText(_("Unternehmen: %s", player:getShortCompanyName()))
	self.m_PlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	local phone = "Ausgeschaltet"
	if player:getPublicSync("Phone") == true then phone = "Eingeschaltet" end
	self.m_PhoneStatus:setText(_("Handy: %s", phone))
end

function PolicePanel:locatePlayer()
	local item = self.m_PlayersGrid:getSelectedItem()
	local player = item.player
	if isElement(player) then
		if player:getPublicSync("Phone") == true then
			if PlayerLocateBlip then delete(PlayerLocateBlip) end
			local pos = player:getPosition()
			PlayerLocateBlip = Blip:new("Locate.png", pos.x, pos.y)
			PlayerLocateBlip:attachTo(player)
			InfoBox:new(_"Spieler geortet! Folge dem Blip auf der Karte!")

		else
			ErrorBox:new(_"Der Spieler konnte nicht geortet werden!\n Sein Handy ist ausgeschaltet!")
		end
	else
		ErrorBox:new(_"Spieler nicht mehr online!")
	end
end
