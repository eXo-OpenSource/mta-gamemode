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

	GUIForm.constructor(self, screenWidth/2-300, screenHeight/2-200, 600, 400, false, true)
	self.m_TabPanel = GUITabPanel:new(0, 0, self.m_Width, self.m_Height, self)
	self.m_CloseButton = GUILabel:new(self.m_Width-28, 0, 28, 28, "[x]", self):setFont(VRPFont(35))
	--self.m_CloseButton.onHover = function () self.m_CloseButton:setColor(Color.LightRed) end
	--self.m_CloseButton.onUnhover = function () self.m_CloseButton:setColor(Color.White) end
	self.m_CloseButton.onLeftClick = function() self:delete() end

	self.m_BackButton = GUILabel:new(self.m_Width-58, 0, 30, 28, "[←]", self):setFont(VRPFont(35))
	--self.m_BackButton.onHover = function () self.m_BackButton:setColor(Color.LightBlue) end
	--self.m_BackButton.onUnhover = function () self.m_BackButton:setColor(Color.White) end
	self.m_BackButton.onLeftClick = function() self:close() SelfGUI:getSingleton():show() Cursor:show() end

	local tabAllgemein = self.m_TabPanel:addTab(_"Allgemein")
	GUILabel:new(10, 10, 150, 30, _"Adminansage:", tabAllgemein):setColor(Color.White)
	self.m_AdminAnnounceText = GUIEdit:new(150, 10, 330, 30,tabAllgemein)
	self.m_AnnounceButton = GUIButton:new(490, 10, 100, 30, _"senden",  tabAllgemein)
	self.m_AnnounceButton.onLeftClick = bind(self.AnnounceButton_Click, self)

	local tabSpieler = self.m_TabPanel:addTab(_"Spieler")
	self.m_PlayersGrid = GUIGridList:new(10, 10, 200, 380, tabSpieler)
	self.m_PlayersGrid:addColumn(_"Spieler", 1)

	self.m_PlayerNameLabel = GUILabel:new(220, 10, 180, 20, _"Spieler: -", tabSpieler)
	self.m_PlayerTimeLabel = GUILabel:new(220, 35, 180, 20, _"Spielstunden: -", tabSpieler)
	self.m_PlayerJobLabel = GUILabel:new(220, 60, 180, 20, _"Job: -", tabSpieler)
	self.m_PlayerFactionLabel = GUILabel:new(410, 10, 180, 20, _"Fraktion: -", tabSpieler)
	self.m_PlayerCompanyLabel = GUILabel:new(410, 35, 180, 20, _"Unternehmen: -", tabSpieler)
	self.m_PlayerGroupLabel = GUILabel:new(410, 60, 180, 20, _"Gang/Firma: -", tabSpieler)

	self.m_adminButton = {}
	self:addAdminButton("goto", "hin porten", 220, 170, 180, 30, Color.Green, tabSpieler)
	self:addAdminButton("gethere", "her porten", 410, 170, 180, 30, Color.Green, tabSpieler)
	self:addAdminButton("kick", "kicken", 220, 210, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("prison", "ins Prison", 220, 250, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("warn", "Warn geben", 220, 290, 180, 30, Color.Orange, tabSpieler)
	self:addAdminButton("timeban", "Timeban", 410, 210, 180, 30, Color.Red, tabSpieler)
	self:addAdminButton("permaban", "Permaban", 410, 250, 180, 30, Color.Red, tabSpieler)
	self:addAdminButton("setFaction", "in Fraktion setzen", 220, 330, 180, 30, Color.Blue, tabSpieler)
	self:addAdminButton("setCompany", "in Unternehmen setzen", 410, 330, 180, 30, Color.Blue, tabSpieler)

	local tabTicket = self.m_TabPanel:addTab(_"Tickets")
	self.m_WebView = GUIWebView:new(0, 0, self.m_Width, self.m_Height, "http://exo-reallife.de/ingame/ticketSystem/admin.php?player="..getPlayerName(getLocalPlayer()).."&sessionID="..self:generateSessionId(), true, tabTicket)


	for key, playeritem in ipairs(getElementsByType("player")) do
		local item = self.m_PlayersGrid:addItem(playeritem:getName())
		item.player = playeritem
		item.onLeftClick = function()
			self:onSelectPlayer(playeritem)
		end
	end
end

function AdminGUI:addAdminButton(func, text, x, y, width, height, color, parent)
	self.m_adminButton[func] = GUIButton:new(x, y, width, height, _(text),  parent):setFontSize(1):setBackgroundColor(color)
	self.m_adminButton[func].func = func
	self.m_adminButton[func].onLeftClick = function () self:onButtonClick(func) end
	self.m_adminButton[func]:setEnabled(false)
end

function AdminGUI:onSelectPlayer(player)
	self.m_PlayerNameLabel:setText(_("Spieler: %s", player:getName()))
	local hours, minutes = math.floor(localPlayer:getPlayTime()/60), (localPlayer:getPlayTime() - math.floor(localPlayer:getPlayTime()/60)*60)
	self.m_PlayerTimeLabel:setText(_("Spielzeit: %s:%s h", hours, minutes))
	self.m_PlayerFactionLabel:setText(_("Fraktion: %s", player:getShortFactionName()))
	self.m_PlayerCompanyLabel:setText(_("Unternehmen: %s", player:getShortCompanyName()))
	self.m_PlayerGroupLabel:setText(_("Gang/Firma: %s", player:getGroupName()))
	self.m_PlayerJobLabel:setText(_("Job: %s", player:getJobName()))


	self:refreshButtons()
end

function AdminGUI:refreshButtons()
	for index, btn in pairs(self.m_adminButton) do
		if localPlayer:getRank() < ADMIN_RANK_PERMISSION[btn.func] then
			btn:setEnabled(false)
		else
			btn:setEnabled(true)
		end
	end
end

function AdminGUI:onButtonClick(func)
	if self.m_PlayersGrid:getSelectedItem() then
		local selectedPlayer = self.m_PlayersGrid:getSelectedItem().player
		if func == "gethere" or func == "goto" then
			triggerServerEvent("adminTriggerFunction", root, func, selectedPlayer)
		elseif func == "kick" then
			InputBox:new(_("Spieler %s kicken", selectedPlayer:getName()), _("Aus welchem Grund möchtest du den Spieler %s vom Server kicken?", selectedPlayer:getName()), function (reason) triggerServerEvent("adminTriggerFunction", root, func, selectedPlayer, reason) end)
		elseif func == "setCompany" then
			local companyTable = {[0] = "Kein Unternehmen", [1] = "Fahrschule", [2] = "Mech & Tow", [3] = "San News", [4] = "Public Transport"}
			ChangerBox:new(_"Unternehmen setzten", _"Bitte wähle das gewünschte Unternehmen aus:",companyTable, function (companyId) triggerServerEvent("adminSetPlayerCompany", root, selectedPlayer,companyId) end)
		elseif func == "setFaction" then
			local factionTable = {[0] = "Keine Fraktion", [1] = "SAPD", [2] = "FBI", [3] = "SA Army", [4] = "Rescue Team", [5] = "Cosa Nostra", [6] = "Yakuza"}
			ChangerBox:new(_"Fraktion setzten", _"Bitte wähle die gewünschte Fraktion aus:",factionTable, function (factionId) triggerServerEvent("adminSetPlayerFaction", root, selectedPlayer,factionId) end)
		else
			outputDebug("Under Developement", 255, 0 ,0)
		end
	end
	self:delete()
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


function AdminGUI:generateSessionId()
	return md5(localPlayer:getName()..localPlayer:getSerial()) -- ToDo: generate serverside with lastlogin timestamp for more security
end


addEventHandler("showAdminMenu", root,
	function(...)
		AdminGUI:new()
	end
)
