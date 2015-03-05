DeathmatchGUI = inherit(GUIForm)

function DeathmatchGUI:constructor ()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.35/2, screenHeight/2 - screenHeight*0.45/2, screenWidth*0.35, screenHeight*0.45)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch beitreten", true, true, self)
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.98, self.m_Height*0.08, _"Verfügbare Matches:", self.m_Window)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.96, self.m_Height*0.53, self.m_Window)
	self.m_Grid:addColumn(_"DM-Host", 0.35)
	self.m_Grid:addColumn(_"DM-Typ", 0.35)
	self.m_Grid:addColumn(_"DM-Status", 0.35)

	self.m_HostButton = VRPButton:new(self.m_Width*0.05, self.m_Height*0.73, self.m_Width*0.9, self.m_Height*0.1, _"Deathmatch hosten", true, self.m_Window):setBarColor(Color.LightBlue)
	self.m_ButtonJoin = VRPButton:new(self.m_Width*0.05, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Beitreten", true, self.m_Window):setBarColor(Color.Green)
	self.m_ButtonCancel = VRPButton:new(self.m_Width*0.55, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Abbrechen", true, self.m_Window):setBarColor(Color.Red)

	self.m_ButtonCancel.onLeftClick = (
		function()
			DeathmatchEvent:getSingleton():closeGUIForm()
		end
	)
	self.m_ButtonJoin.onLeftClick = (
		function()
			local item = self.m_Grid:getSelectedItem()
			if not item then
				WarningBox:new(_"Bitte wähle ein Match aus!")
				return
			end

			if item.status == DeathmatchEvent.Status[1] then -- waiting
				if item.passworded then
					local instance = DeathmatchEvent:getSingleton()
					local onPasswordRight = function (instance, item)
						instance:addPlayertoMatch(item.id)
						instance:closeGUIForm()
						instance:openGUIForm(3)
					end
					PasswordBox:new(item.password, bind(onPasswordRight, instance, item), nil)
				else
					local instance = DeathmatchEvent:getSingleton()
					instance:addPlayertoMatch(item.id)
					instance:closeGUIForm()
					instance:openGUIForm(3)
				end
			else
				if item.status == DeathmatchEvent.Status[2] then -- starting
					WarningBox:new(_"Dieses Match startet bereits!")
				elseif item.status == DeathmatchEvent.Status[3] then -- active
					WarningBox:new(_"Dieses Match läuft bereits!")
				end

				return
			end
		end
	)
	self.m_HostButton.onLeftClick = (
		function()
			local instance = DeathmatchEvent:getSingleton()
			instance:closeGUIForm()
			instance:openGUIForm(2)
		end
	)

	self:updateData()
end

function DeathmatchGUI:updateData ()
	self.m_Grid:clear()

	local instance = DeathmatchEvent:getSingleton()
	for i, v in ipairs(instance.m_Matches) do
		local item = self.m_Grid:addItem(("%s (%s/%s)"):format(getPlayerName(v.players[1]), #v.players, v.type*2), instance.Types[v.type][2].." ("..(v.passworded and _"Privat" or _"Öffentlich")..")", instance.Status[v.status][2])
		item.status = instance.Status[v.status]
		item.id = v.id
		item.passworded = v.passworded
		item.password = v.password
		item.onLeftDoubleClick = function () self.m_ButtonJoin.onLeftClick()  end
	end
end
function DeathmatchGUI:update (...) return self:updateData(...) end


-- ########################################
HostDeathmatchGUI = inherit(GUIForm)

function HostDeathmatchGUI:constructor ()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.35/2, screenHeight/2 - screenHeight*0.45/2, screenWidth*0.35, screenHeight*0.45)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch hosten", true, true, self)
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.98, self.m_Height*0.08, _"Deathmatch-Typ:", self.m_Window)
	self.m_TypeChange = GUIChanger:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.48, self.m_Height*0.085, self.m_Window)
	self.m_TypeChange:addItem(("1 vs. 1 (2 %s)"):format(_"Spieler"))
	self.m_TypeChange:addItem(("2 vs. 2 (4 %s)"):format(_"Spieler"))
	self.m_TypeChange:addItem(("3 vs. 3 (6 %s)"):format(_"Spieler"))

	--[[
	self.m_ModeLabel = GUILabel:new(self.m_Width*0.5, self.m_Height*0.1, self.m_Width*0.98, self.m_Height*0.08, _"Lobby-Typ:", self.m_Window)
	self.m_ModeChange = GUIChanger:new(self.m_Width*0.5, self.m_Height*0.18, self.m_Width*0.48, self.m_Height*0.085, self.m_Window)
	self.m_ModeChange:addItem(_"Öffentlich")
	self.m_ModeChange:addItem(_"Privat")
	--]]

	self.m_PasswordLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.1, self.m_Width*0.48, self.m_Height*0.08, _"Lobby-Passwort:", self.m_Window)
	self.m_PasswordEdit = GUIEdit:new(self.m_Width*0.51, self.m_Height*0.18, self.m_Width*0.48, self.m_Height*0.085, self.m_Window):setCaption(_"Passwort")
	self.m_PasswordEdit:setMasked("*")

	self.m_MapLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.32, self.m_Width*0.48, self.m_Height*0.08, _"Map auswählen:", self.m_Window)
	self.m_MapGrid = GUIGridList:new(self.m_Width*0.51, self.m_Height*0.40, self.m_Width*0.48, self.m_Height*0.42, self.m_Window)
	self.m_MapGrid:addColumn("Mapname", 0.35)
	for i, v in ipairs(DeathmatchEvent.data["Maps"]) do
		local item = self.m_MapGrid:addItem(v[1])
		item.id = i
	end

	self.m_WeaponLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.32, self.m_Width*0.48, self.m_Height*0.08, _"Waffe auswählen:", self.m_Window)
	self.m_WeaponGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.40, self.m_Width*0.48, self.m_Height*0.42, self.m_Window)
	self.m_WeaponGrid:addColumn(_"Waffe", 0.35)
	for i, v in ipairs(DeathmatchEvent.data["Weapons"]) do
		local item = self.m_WeaponGrid:addItem(v[1])
		item.id = i
	end

	self.m_ButtonHost = VRPButton:new(self.m_Width*0.05, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Hosten", true, self.m_Window):setBarColor(Color.Green)
	self.m_ButtonCancel = VRPButton:new(self.m_Width*0.55, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Abbrechen", true, self.m_Window):setBarColor(Color.Red)

	self.m_ButtonCancel.onLeftClick = (
		function()
			local instance = DeathmatchEvent:getSingleton()
			instance:closeGUIForm()
			instance:openGUIForm(1)
		end
	)
	self.m_ButtonHost.onLeftClick = (
		function()
			local weapon = self.m_WeaponGrid:getSelectedItem().id
			local map = self.m_MapGrid:getSelectedItem().id
			local name, type = self.m_TypeChange:getIndex()
			local password = (self.m_PasswordEdit:getText() ~= "" and md5(self.m_PasswordEdit:getText())) or false;
			local passworded = (password and true) or false

			if (weapon ~= nil and map ~= nil) then
				local instance = DeathmatchEvent:getSingleton()
				instance:closeGUIForm()
				instance:Event_createMatch(type, weapon, map, {passworded, password})

				ShortMessage:new(_"Das Match wird erstellt... Bitte warten!")
			else
				WarningBox:new(_"Bitte wähle eine Map und eine Waffe aus!")
			end
		end
	)
end


-- ########################################
LobbyDeathmatchGUI = inherit(GUIForm)

function LobbyDeathmatchGUI:constructor ()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.35/2, screenHeight/2 - screenHeight*0.45/2, screenWidth*0.35, screenHeight*0.45)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch Lobby", true, true, self)
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.48, self.m_Height*0.08, _"Spieler in der Lobby:", self.m_Window)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.48, self.m_Height*0.6, self.m_Window)
	self.m_Grid:addColumn(_"Spielername", 0.35)

	GUILabel:new(self.m_Width*0.51, self.m_Height*0.1, self.m_Width*0.49, self.m_Height*0.08, _"Lobby Einstellungen:", self.m_Window)
	self.m_HostLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.18, self.m_Width*0.49, self.m_Height*0.08, _"Host:", self.m_Window)
	self.m_MapLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.26, self.m_Width*0.49, self.m_Height*0.08, _"Map:", self.m_Window)
	self.m_WeaponLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.34, self.m_Width*0.49, self.m_Height*0.08, _"Waffe:", self.m_Window)
	self.m_PlayerLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.42, self.m_Width*0.49, self.m_Height*0.08, _"Spieler:", self.m_Window)
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.5, self.m_Width*0.49, self.m_Height*0.08, _"DM-Typ:", self.m_Window)
	self.m_StatusLabel = GUILabel:new(self.m_Width*0.51, self.m_Height*0.58, self.m_Width*0.49, self.m_Height*0.08, _"Status:", self.m_Window)

	self.m_KickButton = VRPButton:new(self.m_Width*0.51, self.m_Height*0.685, self.m_Width*0.42, self.m_Height*0.09, _"Spieler herrauswerfen", true, self.m_Window):setBarColor(Color.Green)
	self.m_StartButton = VRPButton:new(self.m_Width*0.05, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Start", true, self.m_Window):setBarColor(Color.Green)
	self.m_ButtonCancel = VRPButton:new(self.m_Width*0.55, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Abbrechen", true, self.m_Window):setBarColor(Color.Red)
	self.m_KickButton:setEnabled(false)
	self.m_StartButton:setEnabled(false)

	self.m_KickButton.onLeftClick = (
		function()

		end
	)
	self.m_StartButton.onLeftClick = (
		function()
			triggerServerEvent("Deathmatch.setMatchStatus", root, localPlayer:getMatchID(), 2)
		end
	)
	self.m_ButtonCancel.onLeftClick = (
		function()
			local instance = DeathmatchEvent:getSingleton()
			local removeFunc = function ()
				instance:removePlayerfromMatch(localPlayer:getMatchID())
				instance:closeGUIForm()
				instance:openGUIForm(1)
			end

			if instance:getMatchData(localPlayer:getMatchID())["host"] == localPlayer then
				QuestionBox:new(_"Willst du das Match wirklich verlassen? (Das Match wird dadurch gelöscht!)", removeFunc)
			else
				QuestionBox:new(_"Willst du das Match wirklich verlassen?", removeFunc)
			end
		end
	)

	self:updateData()
end

function LobbyDeathmatchGUI:updateData ()
	local matchData = DeathmatchEvent:getSingleton():getMatchData(localPlayer:getMatchID())
	local isHost = (matchData["host"] == localPlayer)

	self.m_Grid:clear()
	for i, v in ipairs(matchData["players"]) do
		local name = getPlayerName(v)
		if matchData["host"] == v then
			name = name.." (".._("Host")..")"
		end

		local item = self.m_Grid:addItem(name)
		item.player = v
		item.onLeftDoubleClick = function () return self.m_KickButton.onLeftClick(item.player) end
	end

	-- Update Labels
	self.m_HostLabel:setText(_("Host: %s", getPlayerName(matchData["host"])))
	self.m_MapLabel:setText(_("Map: %s", DeathmatchEvent.data.Maps[matchData["map"]][1]))
	self.m_WeaponLabel:setText(_("Waffe: %s", DeathmatchEvent.data.Weapons[matchData["weapon"]][1]))
	self.m_PlayerLabel:setText(_("Spieler: %s", #matchData["players"].."/"..matchData["type"]*2))
	self.m_TypeLabel:setText(_("DM-Typ: %s", DeathmatchEvent.Types[matchData["type"]][2]))
	self.m_StatusLabel:setText(_("Status: %s", DeathmatchEvent.Status[matchData["status"]][2]))

	-- Update Buttons
	self.m_KickButton:setEnabled(isHost)
	self.m_StartButton:setEnabled(isHost)
end
function LobbyDeathmatchGUI:update (...) return self:updateData(...) end
