-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/PolicePanel.lua
-- *  PURPOSE:     PolicePanel form class
-- *
-- ****************************************************************************

PolicePanel = inherit(GUIForm)
inherit(Singleton, PolicePanel)

local ElementLocateBlip, ElementLocateTimer, GPSEnabled
local GPSUpdateStep = 0

addRemoteEvents{"receiveJailPlayers", "receiveBugs"}

function PolicePanel:constructor()
	GUIWindow.updateGrid(true)			-- initialise the grid function to use a window
	self.m_Width = grid("x", 16) 	-- width of the window
	self.m_Height = grid("y", 11) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Polizeicomputer", true, false, self)
	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel({"Spieler", "Knast", "Wanzen", "Wantedregeln"}) 
	self.m_TabPanel:updateGrid() 
	self.m_TabPanel.onTabChanged = bind(self.TabPanel_TabChanged, self)

	--
	-- Allgemein
	--
	
	self.m_PlayersGrid = GUIGridGridList:new(1, 1, 9, 9, self.m_Tabs[1])
	self.m_PlayersGrid:addColumn(_"W", 0.05)
	self.m_PlayersGrid:addColumn(_"Name", 0.4)
	self.m_PlayersGrid:addColumn(_"Fraktion", 0.2)
	self.m_PlayersGrid:addColumn(_"Firma/Gang", 0.3)

	GUIGridLabel:new(10, 1, 6, 1, _"Spielerinformationen", self.m_Tabs[1]):setHeader("sub")	
	self.m_InfoTextLabel =	GUIGridLabel:new(10, 2, 4, 6, _"", self.m_Tabs[1]):setAlign("left", "top")		
	self.m_InfoDataLabel =	GUIGridLabel:new(12, 2, 4, 6, _"", self.m_Tabs[1]):setAlign("right", "top")		

	self.m_RefreshBtn = GUIGridIconButton:new(9, 10, FontAwesomeSymbols.Refresh, self.m_Tabs[1])
	self.m_RefreshBtn.onLeftClick = function() self:loadPlayers() end

	self.m_WantedFilter = GUIGridCheckbox:new(1, 10, 1, 1, _"W", self.m_Tabs[1])
	self.m_WantedFilter.onChange = function() self:loadPlayers() end
	self.m_FactionFilter = GUIGridCheckbox:new(2, 10, 1, 1, _"F", self.m_Tabs[1])
	self.m_FactionFilter.onChange = function() self:loadPlayers() end
	self.m_GangFilter = GUIGridCheckbox:new(3, 10, 1, 1, _"G", self.m_Tabs[1])
	self.m_GangFilter.onChange = function() self:loadPlayers() end

	self.m_PlayerSearch = GUIGridEdit:new(4, 10, 5, 1, self.m_Tabs[1])
	self.m_PlayerSearch.onChange = function () self:loadPlayers() end
	
	self.m_LocatePlayerBtn = GUIGridButton:new(10, 8, 4, 1, ElementLocateBlip and _"Orten beenden" or _"Orten", self.m_Tabs[1]) 
	self.m_LocatePlayerBtn.onLeftClick = function()
		if ElementLocateBlip then 
			if self:stopLocating() then
				self.m_LocatePlayerBtn:setText(_"Orten")
			end
		else
			if self:locatePlayer() then
				self.m_LocatePlayerBtn:setText(_"Orten beenden")
			end
		end
	end
	
	self.m_GPS = GUIGridCheckbox:new(14, 8, 2, 1, _"Navi", self.m_Tabs[1])
	self.m_GPS:setChecked(GPSEnabled)
	self.m_GPS.onChange = function() GPSEnabled = self.m_GPS:isChecked() end
	
	self.m_AddWantedsBtn = GUIGridButton:new(10, 9, 4, 1, _"Wanteds geben", self.m_Tabs[1]) 
	self.m_AddWantedsBtn.onLeftClick = function() self:giveWanteds() end
	
	self.m_DeleteWantedsBtn = GUIGridButton:new(14, 9, 2, 1, _"Löschen", self.m_Tabs[1]):setBackgroundColor(Color.Red)
	self.m_DeleteWantedsBtn.onLeftClick = function() QuestionBox:new(
		_("Möchtest du wirklich alle Wanteds von %s löschen?", self.m_SelectedPlayer:getName()),
		function() triggerServerEvent("factionStateClearWanteds", localPlayer, self.m_SelectedPlayer) end)
	end
	
	
	self.m_AddSTVOBtn = GUIGridButton:new(10, 10, 4, 1, _"STVO-Punkte geben", self.m_Tabs[1]) 
	self.m_AddSTVOBtn.onLeftClick = function() self:giveSTVO("give") end
	
	self.m_SetSTVOBtn = GUIGridButton:new(14, 10, 2, 1, _"Setzen", self.m_Tabs[1]) 
	self.m_SetSTVOBtn.onLeftClick = function() self:giveSTVO("set") end
	
	self.m_PlayerFuncElements = {
		self.m_LocatePlayerBtn, self.m_GPS, self.m_AddWantedsBtn, self.m_DeleteWantedsBtn, self.m_AddSTVOBtn, self.m_SetSTVOBtn
	}
	--
	-- Knast 
	--

	self.m_JailPlayersGrid = GUIGridGridList:new(1, 1, 15, 9, self.m_Tabs[2])
	self.m_JailPlayersGrid:addColumn(_"Spieler", 0.3)
	self.m_JailPlayersGrid:addColumn(_"Zeit", 0.2)
	self.m_JailPlayersGrid:addColumn(_"Fraktion", 0.2)
	self.m_JailPlayersGrid:addColumn(_"Gang", 0.2)
	
	self.m_JailRefreshBtn = GUIGridIconButton:new(15, 1, FontAwesomeSymbols.Refresh, self.m_Tabs[2])
	self.m_JailRefreshBtn.onLeftClick = function()
		triggerServerEvent("factionStateLoadJailPlayers", root)
	end

	self.m_FreePlayerBtn = GUIGridButton:new(1, 10, 4, 1, _"Freilassen", self.m_Tabs[2]):setBackgroundColor(Color.Green):setBarEnabled(false) 
	self.m_FreePlayerBtn.onLeftClick = function()
		if self.m_JailSelectedPlayer and isElement(self.m_JailSelectedPlayer) then
			QuestionBox:new(
				_("Möchtest du %s wirklich aus dem Knast befreien?", self.m_JailSelectedPlayer:getName()),
				function()
					triggerServerEvent("factionStateFreePlayer", localPlayer, self.m_JailSelectedPlayer)
				end
			)
		else
			ErrorBox:new(_"Der Spieler ist nicht mehr online!")
		end
	end
	self:loadPlayers()
	
	--
	-- Wanzen 
	--
	
	self.m_BugsGrid = GUIGridGridList:new(1, 1, 11, 5, self.m_Tabs[3])
	self.m_BugsGrid:addColumn(_"ID", 0.1)
	self.m_BugsGrid:addColumn(_"Status", 0.45)
	self.m_BugsGrid:addColumn(_"Ziel", 0.2)
	
	self.m_BugRefresh = GUIGridIconButton:new(11, 1, FontAwesomeSymbols.Refresh, self.m_Tabs[3])
	self.m_BugRefresh.onLeftClick = function()
		triggerServerEvent("factionStateLoadBugs", root)
	end

	self.m_BugLocate = GUIGridButton:new(12, 1, 4, 1, ElementLocateBlip and _"Orten beenden" or _"Orten", self.m_Tabs[3]) 
	self.m_BugLocate.onLeftClick = function()
		if ElementLocateBlip then 
			if self:stopLocating() then
				self.m_BugLocate:setText(_"Orten")
			end
		else
			if self:bugAction("locate") then
				self.m_BugLocate:setText(_"Orten beenden")
			end
		end
	end
	
	self.m_BugClearLog = GUIGridButton:new(12, 2, 4, 1, _"Log löschen", self.m_Tabs[3]):setBackgroundColor(Color.Orange)
	self.m_BugClearLog:setEnabled(false)
	self.m_BugClearLog.onLeftClick = function() self:bugAction("clearLog") end
	
	self.m_BugDisable = GUIGridButton:new(12, 3, 4, 1, _"Deaktivieren", self.m_Tabs[3]):setBackgroundColor(Color.Red)
	self.m_BugDisable:setEnabled(false)
	self.m_BugDisable.onLeftClick = function() self:bugAction("disable") end

	self.m_BugLogGrid = GUIGridGridList:new(1, 6, 15, 5, self.m_Tabs[3])
	self.m_BugLogGrid:setItemHeight(20)
	self.m_BugLogGrid:setFont(VRPFont(20))
	self.m_BugLogGrid:addColumn(_"Log", 1)
	
	--
	-- Wantedregeln
	--
	
	self.m_WantedRules = GUIGridWebView:new(1, 1, 15, 10, INGAME_WEB_PATH .. "/ingame/other/wanteds.php", true, self.m_Tabs[4])
	self.m_WantedRules:setRenderingEnabled(false) --only render the browser if the player is on its tab

	addEventHandler("receiveJailPlayers", root, bind(self.receiveJailPlayers, self))
	addEventHandler("receiveBugs", root, bind(self.receiveBugs, self))

	self:bind("F5", function(self)
		if isCursorShowing() then
			self:loadPlayers()
		end
	end)
end

addCommandHandler("pp", function()
	PolicePanel:new()
end)

function PolicePanel:TabPanel_TabChanged(tabId)
	self.m_WantedRules:setRenderingEnabled(false) --only render the browser if the player is on its tab
	if tabId == 2 then
		triggerServerEvent("factionStateLoadJailPlayers", root)
	elseif tabId == 3 then
		triggerServerEvent("factionStateLoadBugs", root)
	elseif tabId == 4 then
		self.m_WantedRules:setRenderingEnabled(true)
	end
end

function PolicePanel:loadPlayers()
	self.m_PlayersGrid:clear()
	for i, v in pairs(self.m_PlayerFuncElements) do
		v:setEnabled(false)
	end
	self.m_InfoTextLabel:setText("")		
	self.m_InfoDataLabel:setText("")	
	
	self.m_Players = {}

	for i,v in pairs(getElementsByType("player")) do
		local skip = false
		--skip inactive players
		if v:isAFK() then skip = true end
		if v:getData("inAdminPrison") then skip = true end
		--filters
		if self.m_WantedFilter:isChecked() and v:getWanteds() == 0 then skip = true end
		if self.m_FactionFilter:isChecked() and (not v:getFaction() or not v:getFaction():isEvilFaction()) then skip = true end
		if self.m_GangFilter:isChecked() and v:getGroupType() ~= "Gang" then skip = true end
		if #self.m_PlayerSearch:getText() <= 3 or string.find(string.lower(v:getName()), string.lower(self.m_PlayerSearch:getText())) then
			if not skip then
				self.m_Players[v] = v:getWanteds()
			end
		end
	end

	if self.m_Players then
		table.sort(self.m_Players, function(a, b) return a < b end)
		
		for player in pairs(self.m_Players) do
			if isElement(player) then
				local item = self.m_PlayersGrid:addItem(
					player:getWanteds(), 
					player:getName(), 
					player:getFaction() and player:getFaction():getShortName() or "-",
					player:getGroupName() or "-"
				)
				item.player = player
				item.onLeftClick = function()
					self:onSelectPlayer(player)
				end

				if player:getPublicSync("Phone") == true then
					if player:getInterior() == 0 and player:getDimension() == 0 then
						item:setColumnColor(1, tocolor(200, 255, 200))
					else
						item:setColumnColor(1, tocolor(255, 220, 200))
					end
				else
					item:setColumnColor(1, tocolor(255, 200, 200))
				end

				if player:getFaction() then
					local color = player:getFaction():getColor()
					item:setColumnColor(3, tocolor(color.r, color.g, color.b))
				end

				if player:getFaction() then
					local color = player:getFaction():getColor()
					item:setColumnColor(3, tocolor(color.r, color.g, color.b))
				end
		
				if player:getGroupType() then
					if player:getGroupType() == "Gang" then
						item:setColumnColor(4, Color.Red)
					elseif player:getGroupType() == "Firma" then
						item:setColumnColor(4, Color.Accent)
					end
				end
			end
			
		end
	end
end

function PolicePanel:receiveJailPlayers(playerTable)
	self.m_JailPlayersGrid:clear()
	for player, jailtime in pairs(playerTable) do
		local item = self.m_JailPlayersGrid:addItem(player:getName(), jailtime)
		item.player = player
		item.onLeftClick = function()
			self:onSelectJailPlayer(player)
		end
	end
end


function PolicePanel:receiveBugs(bugTable)
	self.m_BugsGrid:clear()
	self.m_BugData = bugTable


	for id, bugData in ipairs(bugTable) do
		local owner, state, element = "-", "nicht in Benutzung"
		if bugData["element"] and isElement(bugData["element"]) then
			
			element = bugData["element"]

			if element:getType() == "vehicle" then
				owner = element:getData("OwnerName") or "Unbekannt"
				state = "angebracht an Fahrzeug"
			elseif element:getType() == "player" then
				owner = element:getName() or "Unbekannt"
				state = "angebracht an Spieler"
			end
		end

		local item = self.m_BugsGrid:addItem(id, state, owner)

		if id == self.m_CurrentSelectedBugId  then
			item:onInternalLeftClick()
			self:onSelectBug(id)
		end

		item.onLeftClick = function()
			triggerServerEvent("factionStateLoadBugs", root)
			self:onSelectBug(id)
		end
	end
end

function PolicePanel:onSelectBug(id)
	self.m_CurrentSelectedBugId = id
	if self.m_BugData and self.m_BugData[id] and self.m_BugData[id]["element"] and isElement(self.m_BugData[id]["element"]) then

		self.m_BugLogGrid:clear()
		for index, msg in pairs(self.m_BugData[id]["log"]) do
			item = self.m_BugLogGrid:addItem(msg)
			item:setFont(VRPFont(20))
			item.onLeftClick = function()
				ShortMessage:new(msg)
			end
		end
		if localPlayer:getFaction() and localPlayer:getFaction():getId() == 2 then
			self.m_BugDisable:setEnabled(true)
			self.m_BugClearLog:setEnabled(true)
		end
		self.m_BugLocate:setEnabled(true)
		self.m_BugRefresh:setEnabled(true)

	else
		self.m_BugLogGrid:clear()
		self.m_BugDisable:setEnabled(false)
		self.m_BugClearLog:setEnabled(false)
		self.m_BugLocate:setEnabled(false)
		self.m_BugRefresh:setEnabled(false)
	end

end

function PolicePanel:bugAction(func)
	if self.m_CurrentSelectedBugId and self.m_CurrentSelectedBugId > 0 then
		local id = self.m_CurrentSelectedBugId

		if self.m_BugData and self.m_BugData[id] and self.m_BugData[id]["active"] and self.m_BugData[id]["active"] == true then
			if func == "locate" then
				if self.m_BugData[id]["element"] and isElement(self.m_BugData[id]["element"]) then
					self:locateElement(self.m_BugData[id]["element"], "bug")
					return true
				else
					ErrorBox:new(_"Die Wanze wurde nicht gefunden!")
				end
			else
				triggerServerEvent("factionStateBugAction", localPlayer, func, id)
				return true
			end
		else
			ErrorBox:new("Diese Wanze ist nicht aktiviert!")
		end
	else
		ErrorBox:new("Keine Wanze ausgewählt!")
	end
end

function PolicePanel:onSelectPlayer(player)
	self.m_InfoTextLabel:setText(_"STVO\n Auto\n Motorrad\n LKW\n Pilot")		
	self.m_InfoDataLabel:setText(("\n%s\n%s\n%s\n%s"):format(player:getSTVO("Driving"), player:getSTVO("Bike"), player:getSTVO("Truck"), player:getSTVO("Pilot")))	
	self.m_SelectedPlayer = player
	for i, v in pairs(self.m_PlayerFuncElements) do
		v:setEnabled(true)
	end
end

function PolicePanel:onSelectJailPlayer(player)
	self.m_JailSelectedPlayer = player
end

function PolicePanel:locatePlayer()
	local item = self.m_PlayersGrid:getSelectedItem()
	if not item then ErrorBox:new(_"Du musst einen Spieler auswählen!") return end
	local player = item.player
	if isElement(player) then
		if player:isAFK() then ErrorBox:new(_"Der Spieler ist AFK!") return false end
		if player:getData("inAdminPrison") then ErrorBox:new(_"Der Spieler sitzt gerade eine administrative Strafe ab!") return false end

		if player:getPublicSync("Phone") == true then
			self:locateElement(player, "phone")
			return true
		else
			ErrorBox:new(_"Der Spieler konnte nicht geortet werden!\n Sein Handy ist ausgeschaltet!")
		end
	else
		ErrorBox:new(_"Spieler nicht mehr online!")
	end
end

function PolicePanel:locateElement(element, locationOf)
	local elementText = element:getType() == "player" and _"Der Spieler" or _"Die Wanze"

	if (getElementDimension(element) == 0 and getElementInterior(element) == 0) or element:getData("inSewer") then
		self:stopLocating()

		local pos = element:getPosition()
		ElementLocateBlip = Blip:new("Marker.png", pos.x, pos.y, 9999)
		ElementLocateBlip:attachTo(element)
		ElementLocateBlip:setColor(BLIP_COLOR_CONSTANTS.Red)
		ElementLocateBlip:setDisplayText(elementText)
		localPlayer.m_LocatingElement = element
		InfoBox:new(_("%s wurde geortet! Folge dem Blip auf der Karte!", elementText))
		GPSUpdateStep = 10
		ElementLocateTimer = setTimer(function(locationOf)
			if localPlayer.m_LocatingElement and isElement(localPlayer.m_LocatingElement) then
				if not localPlayer:getPublicSync("Faction:Duty") then
					self:stopLocating()
				end

				local int = getElementInterior(localPlayer.m_LocatingElement)
				local dim = getElementDimension(localPlayer.m_LocatingElement)
				if int > 0 or dim > 0 then
					ErrorBox:new(_("%s ist in einem Gebäude!", elementText))
					self:stopLocating()
				end
				if locationOf == "bug" then
					if not element:getData("Wanze") == true then
						ErrorBox:new(_"Ortung beendet: Die Wanze ist nicht mehr verfügbar!")
						self:stopLocating()
					end
				elseif locationOf == "phone" then
					if not element:getPublicSync("Phone") == true then
						ErrorBox:new(_"Ortung beendet: Der Spieler hat sein Handy ausgeschaltet!")
						self:stopLocating()
					end
				end

				self:updateGPS()
			else
				self:stopLocating()
			end
		end, 1000, 0, locationOf)
	else
		ErrorBox:new(_"Der Spieler konnte nicht geortet werden!\n Er ist in einem Gebäude!")
	end
end

function PolicePanel:updateGPS()
	if GPSEnabled then
		if GPSUpdateStep == 10 then
			if ElementLocateBlip and ElementLocateBlip.getPosition then
				local x, y, z = ElementLocateBlip:getPosition()
				GPS:getSingleton():startNavigationTo(Vector3(x, y, z), false, true)
			end
			GPSUpdateStep = 0
		end
		GPSUpdateStep = GPSUpdateStep + 1
	end
end

function PolicePanel:stopLocating()
	if ElementLocateBlip then delete(ElementLocateBlip) ElementLocateBlip = nil end
	if isTimer(ElementLocateTimer) then killTimer(ElementLocateTimer) end
	localPlayer.m_LocatingElement = false
	GPS:getSingleton():stopNavigation()
	return true
end

function PolicePanel:giveWanteds()
	local item = self.m_PlayersGrid:getSelectedItem()
	if item then
		local player = item.player
		GiveWantedBox:new(player, 1, MAX_WANTED_LEVEL, "Wanteds geben", function(player, amount, reason) triggerServerEvent("factionStateGiveWanteds", localPlayer, player, amount, reason) end)
	else
		ErrorBox:new(_"Kein Spieler ausgewählt!")
	end
end

function PolicePanel:giveSTVO(action)
	local item = self.m_PlayersGrid:getSelectedItem()
	if item then
		local player = item.player
		if action == "give" then
			GiveSTVOBox:new(player, 1, 6, "STVO-Punkte geben", function(player, category, amount, reason) triggerServerEvent("factionStateGiveSTVO", localPlayer, player, category, amount, reason) end)
		elseif action == "set" then
			GiveSTVOBox:new(player, 0, 20, "STVO-Punkte setzen", function(player, category, amount, reason) triggerServerEvent("factionStateSetSTVO", localPlayer, player, category, amount, reason) end)
		end
	else
		ErrorBox:new(_"Kein Spieler ausgewählt!")
	end
end

GiveWantedBox = inherit(GUIForm)

function GiveWantedBox:constructor(player, min, max, title, callback)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 8)
	self.m_Height = grid("y", 4)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("%s %s", player:getName(), title), true, true, self)

	GUIGridLabel:new(1, 1, 3, 1, _"Anzahl", self.m_Window)
	self.m_Changer = GUIGridChanger:new(4, 1, 4, 1, self.m_Window)
	for i = min, max do
		self.m_Changer:addItem(tostring(i))
	end

	GUIGridLabel:new(1, 2, 3, 1, _"Grund", self.m_Window)
	self.m_ReasonBox = GUIGridEdit:new(4, 2, 4, 1, self.m_Window)
	self.m_SubmitButton = GUIGridButton:new(1, 3, 7, 1, _"Bestätigen", self.m_Window):setBarEnabled(false)
	self.m_SubmitButton.onLeftClick =
	function()
		callback(player, self.m_Changer:getIndex(), self.m_ReasonBox:getText())
		delete(self)
	end
end

GiveSTVOBox = inherit(GUIForm)

function GiveSTVOBox:constructor(player, min, max, title, callback)
	GUIWindow.updateGrid()
	self.m_Width = grid("x", 10)
	self.m_Height = grid("y", 5)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height,  _("%s %s", player:getName(), title), true, true, self)

	GUIGridLabel:new(1, 1, 3, 1, _"Kategorie", self.m_Window)
	self.m_STVOCategories = GUIGridChanger:new(4, 1, 6, 1, self.m_Window)
	self.m_STVOCategories:addItem(_"Auto")
	self.m_STVOCategories:addItem(_"Motorrad")
	self.m_STVOCategories:addItem(_"Lastkraftwagen")
	self.m_STVOCategories:addItem(_"Pilot")

	GUIGridLabel:new(1, 2, 3, 1, _"Anzahl", self.m_Window)
	self.m_Changer = GUIGridChanger:new(4, 2, 6, 1, self.m_Window)
	for i = min, max do
		self.m_Changer:addItem(tostring(i))
	end

	GUIGridLabel:new(1, 3, 3, 1, _"Grund", self.m_Window)
	self.m_ReasonBox = GUIGridEdit:new(4, 3, 6, 1, self.m_Window)
	self.m_SubmitButton = GUIGridButton:new(1, 4, 9, 1, _"Bestätigen", self.m_Window):setBarEnabled(false)
	self.m_SubmitButton.onLeftClick =
	function()
		local categoryName, categoryIndex = self.m_STVOCategories:getIndex()
		local category

		if categoryIndex == 1 then
			category = "Driving"
		elseif categoryIndex == 2 then
			category = "Bike"
		elseif categoryIndex == 3 then
			category = "Truck"
		elseif categoryIndex == 4 then
			category = "Pilot"
		end

		callback(player, category, self.m_Changer:getIndex(), self.m_ReasonBox:getText())
		delete(self)
	end
end