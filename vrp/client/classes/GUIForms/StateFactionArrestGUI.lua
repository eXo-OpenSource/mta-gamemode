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

	self.m_List = GUIGridList:new(30, 50, self.m_Width-60, 200, self.m_Window)
	self.m_List:addColumn(_"Name", 0.7)
	self.m_List:addColumn(_"Wanteds", 0.3)


	self.m_mitKaution = GUIButton:new(30, 265, self.m_Width-60, 35,_"mit Kaution einknasten", self.m_Window)
	self.m_mitKaution:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_mitKaution.onLeftClick = bind(self.factionArrestMitKaution,self)

	self.m_ohneKaution = GUIButton:new(30, 310, self.m_Width-60, 35,_"ohne Kaution einknasten", self.m_Window)
	self.m_ohneKaution:setBackgroundColor(Color.Blue):setFont(VRPFont(28)):setFontSize(1)
	self.m_ohneKaution.onLeftClick = bind(self.factionArrestOhneKaution,self)

	self:refreshGrid(col)
	self.m_refreshTimer = setTimer(bind(self.refreshGrid, self),500,0,col)

end

function StateFactionArrestGUI:refreshGrid(col)
	local players = getElementsWithinColShape(col,"player")
	self.m_List:clear()
	local item
	local selectedItem = self.m_List:getSelectedItem()
	if selectedItem and selectedItem.Player then
		self.m_mitKaution:setEnabled(true)
		self.m_ohneKaution:setEnabled(true)
	else
		self.m_mitKaution:setEnabled(false)
		self.m_ohneKaution:setEnabled(false)
	end
	for key,playeritem in pairs(players) do
		if playeritem:getWanteds() > 0 then
			item = self.m_List:addItem(getPlayerName(playeritem),playeritem:getWanteds())
			item.Player = playeritem
			if selectedItem and selectedItem.Player and selectedItem.Player == playeritem then self.m_List:onInternalSelectItem(item)	end
		end
	end



end

addEventHandler("showStateFactionArrestGUI", root,
		function(col)
			StateFactionArrestGUI:new(col)
		end
	)


function StateFactionArrestGUI:hide()
	GUIForm.destructor(self)
	if isTimer(self.m_refreshTimer) then killTimer(self.m_refreshTimer) end
	removeEventHandler("updateStateFactionArrestGUI", root, bind(self.Event_updateStateFactionArrestGUI, self))
end

function StateFactionArrestGUI:factionArrestMitKaution()
	local selectedItem = self.m_List:getSelectedItem()
	if selectedItem and isElement(selectedItem.Player) then
		triggerServerEvent("FactionStateArrestPlayer", localPlayer,selectedItem.Player,true)
	else
		ErrorBox:new(_"Du hast keinen Spieler ausgewählt!")
	end
end

function StateFactionArrestGUI:factionArrestOhneKaution()
	local selectedItem = self.m_List:getSelectedItem()
	if selectedItem and isElement(selectedItem.Player) then
		triggerServerEvent("FactionStateArrestPlayer", localPlayer,selectedItem.Player,false)
	else
		ErrorBox:new(_"Du hast keinen Spieler ausgewählt!")
	end
end
