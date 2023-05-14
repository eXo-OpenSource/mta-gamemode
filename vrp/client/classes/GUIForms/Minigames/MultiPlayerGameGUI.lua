-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/showStateArrestGUI.lua
-- *  PURPOSE:     Arrest GUI class
-- *
-- ****************************************************************************
MultiPlayerGameGUI = inherit(GUIForm)
inherit(Singleton, MultiPlayerGameGUI)

MultiPlayerGameGUI.Names = {["chess"] = "Schach"}

function MultiPlayerGameGUI:constructor(title, col, callback)
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(370/2), 300, 370)

	self.m_Col = col
	self.m_Callback = callback

	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _("%s", title) ,true, true, self)

	self.m_List = GUIGridList:new(30, 80, self.m_Width-60, 170, self.m_Window)
	self.m_List:addColumn(_"Spieler", 1)

	self.m_PlayButton = GUIButton:new(30, 310, self.m_Width-60, 35,_"Spieler herausfordern", self.m_Window)
	self.m_PlayButton:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_PlayButton.onLeftClick = bind(self.startPlaying,self)

	self:refreshGrid()
	self.m_RefreshButton = GUIButton:new(self.m_Width-40, 40, 30, 30, FontAwesomeSymbols.Refresh, self.m_Window):setFont(FontAwesome(15))
	self.m_RefreshButton.onLeftClick = function ()
		self:refreshGrid()
	end
end

function MultiPlayerGameGUI:onSelectPlayer(player)
	if isElement(player) then
		self.m_SelectedPlayer = player
		self.m_PlayButton:setEnabled(true)
	else
		self.m_SelectedPlayer = nil
		self.m_PlayButton:setEnabled(false)
	end
end

function MultiPlayerGameGUI:refreshGrid()
	self.m_List:clear()

	local players = getElementsWithinColShape(self.m_Col,"player")

	local item
	for key,playeritem in pairs(players) do
		if playeritem ~= localPlayer then
			item = self.m_List:addItem(playeritem:getName())
			item.Player = playeritem
			item.onLeftClick = function()
				self:onSelectPlayer(playeritem)
			end
		end
	end
end

function MultiPlayerGameGUI:startPlaying()
	if self.m_SelectedPlayer and isElement(self.m_SelectedPlayer) then
		self.m_Callback(self.m_SelectedPlayer)
		self.m_PlayButton:setEnabled(false)
		self.m_SelectedPlayer = nil
		delete(self)
	else
		ErrorBox:new(_"Du hast keinen Spieler ausgewählt!")
	end
end

addEvent("openBoxingGUI", true)
addEventHandler("openBoxingGUI", root, function(col)
	MultiPlayerGameGUI:new("Boxkampf", col,
		function(player)
			if player and isElement(player) and player:isWithinColShape(col) then
				ChangerBox:new(_"Einsatz setzen",
				_"Um wie viel Geld (in $) wollt ihr kämpfen?", BOXING_MONEY,
				function (moneyId)
					triggerServerEvent("boxingRequestFight", localPlayer, player, moneyId)
				end)
			else
				ErrorBox:new(_"Der Spieler ist nicht mehr in der Halle!")
			end
		end
	)
end)
