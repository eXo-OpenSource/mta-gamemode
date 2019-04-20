-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/showStateArrestGUI.lua
-- *  PURPOSE:     Arrest GUI class
-- *
-- ****************************************************************************
StateFactionArrestGUI = inherit(GUIForm)
inherit(Singleton, StateFactionArrestGUI)

addRemoteEvents{"showStateFactionArrestGUI"}

function StateFactionArrestGUI:constructor(col)
	GUIForm.constructor(self, screenWidth/2-(300/2), screenHeight/2-(370/2), 300, 370)
	self.m_Window = GUIWindow:new(0,0,300,500,_"Arrest-Menü",true,true,self)

	self.m_List = GUIGridList:new(30, 80, self.m_Width-60, 170, self.m_Window)
	self.m_List:addColumn(_"Name", 0.7)
	self.m_List:addColumn(_"Wanteds", 0.3)


	self.m_mitKaution = GUIButton:new(30, 265, self.m_Width-60, 35,_"mit Kaution einknasten", self.m_Window)
	self.m_mitKaution:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_mitKaution.onLeftClick = bind(self.factionArrestMitKaution,self)

	self.m_ohneKaution = GUIButton:new(30, 310, self.m_Width-60, 35,_"ohne Kaution einknasten", self.m_Window)
	self.m_ohneKaution:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_ohneKaution.onLeftClick = bind(self.factionArrestOhneKaution,self)

	self.m_ArrestCol = col

	self:refreshGrid()
	self.m_RefreshButton = GUIButton:new(self.m_Width-40, 40, 30, 30, FontAwesomeSymbols.Refresh, self.m_Window):setFont(FontAwesome(15))
	self.m_RefreshButton.onLeftClick = function ()
		self:refreshGrid()
	end
end

function StateFactionArrestGUI:onSelectPlayer(player)
	if isElement(player) then
		self.m_SelectedPlayer = player
		self.m_mitKaution:setEnabled(true)
		self.m_ohneKaution:setEnabled(true)
	else
		self.m_SelectedPlayer = nil
		self.m_mitKaution:setEnabled(false)
		self.m_ohneKaution:setEnabled(false)
	end
end

function StateFactionArrestGUI:refreshGrid()
	self.m_List:clear()

	local players = getElementsWithinColShape(self.m_ArrestCol,"player")

	local item
	for key,playeritem in pairs(players) do
		if playeritem:getWanteds() > 0 then
			if playeritem ~= localPlayer then
				item = self.m_List:addItem(getPlayerName(playeritem),playeritem:getWanteds())
				item.Player = playeritem
				item.onLeftClick = function()
					self:onSelectPlayer(playeritem)
				end
			end
		end
	end
end

function StateFactionArrestGUI:hide()
	GUIForm.destructor(self)
	if isTimer(self.m_refreshTimer) then killTimer(self.m_refreshTimer) end
	removeEventHandler("updateStateFactionArrestGUI", root, bind(self.Event_updateStateFactionArrestGUI, self))
end

function StateFactionArrestGUI:factionArrestMitKaution()
	if self.m_SelectedPlayer and isElement(self.m_SelectedPlayer) then
		triggerServerEvent("factionStateArrestPlayer", localPlayer,self.m_SelectedPlayer,true)
		self.m_mitKaution:setEnabled(false)
		self.m_ohneKaution:setEnabled(false)
		self.m_SelectedPlayer = nil
		setTimer(function()
			self:refreshGrid()
		end, 250, 1)
	else
		ErrorBox:new(_"Du hast keinen Spieler ausgewählt!")
	end
end

function StateFactionArrestGUI:factionArrestOhneKaution()
	if self.m_SelectedPlayer and isElement(self.m_SelectedPlayer) then
		triggerServerEvent("factionStateArrestPlayer", localPlayer,self.m_SelectedPlayer, false)
		self.m_mitKaution:setEnabled(false)
		self.m_ohneKaution:setEnabled(false)
		self.m_SelectedPlayer = nil
		setTimer(function()
			self:refreshGrid()
		end, 250, 1)
	else
		ErrorBox:new(_"Du hast keinen Spieler ausgewählt!")
	end
end

addEventHandler("showStateFactionArrestGUI", root,
	function(col)
		StateFactionArrestGUI:new(col)
	end
)
