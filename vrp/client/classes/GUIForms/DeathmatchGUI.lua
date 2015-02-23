DeathmatchGUI = inherit(GUIForm)

function DeathmatchGUI:constructor ()
	GUIForm.constructor(self, screenWidth/2 - screenWidth*0.35/2, screenHeight/2 - screenHeight*0.45/2, screenWidth*0.35, screenHeight*0.45)

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Deathmatch beitreten", true, true, self)
	self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.98, self.m_Height*0.08, _"Verfügbare Matches:", self.m_Window)
	self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.96, self.m_Height*0.53, self.m_Window)
	self.m_Grid:addColumn(_"DM-Host", 0.35)
	self.m_Grid:addColumn(_"DM-Typ", 0.35)
	self.m_Grid:addColumn(_"DM-Status", 0.35)
    self:updateGrid()

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
                    ErrorBox:new("Passworded!")

                    local instance = DeathmatchEvent:getSingleton()
                    instance:closeGUIForm()
                    --instance:openGUIForm(4)
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
end

function DeathmatchGUI:updateGrid ()
    self.m_Grid:clear()

    local instance = DeathmatchEvent:getSingleton()
    for i, v in ipairs(instance.m_Matches) do
        local item = self.m_Grid:addItem(("%s (%s/%s)"):format(getPlayerName(v.players[1]), #v.players, v.type*2), instance.Types[v.type][2].." ("..(v.passworded and _"Privat" or _"Öffentlich")..")", instance.Status[v.status][2])
        item.status = instance.Status[v.status]
        item.id = v.id
        item.passworded = v.passworded
        item.onLeftDoubleClick = function () self.m_ButtonJoin.onLeftClick()  end
    end
end


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
        self.m_MapGrid:addItem(v[1])
    end

    self.m_WeaponLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.32, self.m_Width*0.48, self.m_Height*0.08, _"Waffe auswählen:", self.m_Window)
    self.m_WeaponGrid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.40, self.m_Width*0.48, self.m_Height*0.42, self.m_Window)
    self.m_WeaponGrid:addColumn(_"Waffe", 0.35)
    for i, v in ipairs(DeathmatchEvent.data["Weapons"]) do
        self.m_WeaponGrid:addItem(v[1])
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
            local weapon = self.m_WeaponGrid:getSelectedItem()
            local map = self.m_MapGrid:getSelectedItem()
            local name, type = self.m_TypeChange:getIndex()
            local password = (self.m_PasswordEdit:getText() ~= "" and md5(self.m_PasswordEdit:getText())) or false;
            local passworded = (password and true) or false

            if (weapon ~= nil and map ~= nil) then
                local instance = DeathmatchEvent:getSingleton()
                instance:closeGUIForm()
                instance:Event_createMatch(type, weapon, map, {passworded, password})

                -- Todo: Improve!
                setTimer(function ()
                    instance:openGUIForm(3)
                end, 500, 1)
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
    self.m_TypeLabel = GUILabel:new(self.m_Width*0.02, self.m_Height*0.1, self.m_Width*0.98, self.m_Height*0.08, _"Spieler in der Lobby:", self.m_Window)
    self.m_Grid = GUIGridList:new(self.m_Width*0.02, self.m_Height*0.18, self.m_Width*0.48, self.m_Height*0.6, self.m_Window)
    self.m_Grid:addColumn(_"Spielername", 0.35)
    self:updateGrid()

    self.m_Button = VRPButton:new(self.m_Width*0.05, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Button", true, self.m_Window):setBarColor(Color.Green)
    self.m_ButtonCancel = VRPButton:new(self.m_Width*0.55, self.m_Height*0.85, self.m_Width*0.4, self.m_Height*0.1, _"Abbrechen", true, self.m_Window):setBarColor(Color.Red)

    self.m_ButtonCancel.onLeftClick = (
        function()
            local instance = DeathmatchEvent:getSingleton()
            instance:removePlayerfromMatch(localPlayer:getMatchID())
            instance:closeGUIForm()
            instance:openGUIForm(1)
        end
    )
    self.m_Button.onLeftClick = (
        function()

        end
    )
end

function LobbyDeathmatchGUI:updateGrid ()
    self.m_Grid:clear()

    local instance = DeathmatchEvent:getSingleton()
    for i, v in ipairs(instance:getMatchData(localPlayer:getMatchID())["players"]) do
        local item = self.m_Grid:addItem(getPlayerName(v))
        item.player = v
        --item.onLeftDoubleClick = function () end
    end
end
