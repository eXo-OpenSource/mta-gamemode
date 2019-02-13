-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateEvidenceGUI.lua
-- *  PURPOSE:     StateEvidenceGUI class
-- *
-- ****************************************************************************
StateEvidenceGUI = inherit(GUIForm)
inherit(Singleton, StateEvidenceGUI)

addRemoteEvents{"State:sendEvidenceItems", "State:clearEvidenceItems" }

function StateEvidenceGUI:constructor(evidenceTable, fillState)
	GUIWindow.updateGrid(true)			-- initialise the grid function to use a window
	self.m_Width = grid("x", 13) 	-- width of the window
	self.m_Height = grid("y", 6) 	-- height of the window

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Asservatenkammer", true, true, self)
	self.m_Tabs, self.m_TabPanel = self.m_Window:addTabPanel({"Übersicht", "Details"}) -- fügt Tabs hinzu und gibt ihnen eine füllende Breite
	self.m_TabPanel:updateGrid() -- updated das Grid, weil die nächsten Elemente als parent einen tab haben, der keinen Header besitzt (und somit auch keinen oberen Abstand)
	
	self.m_RowCountLbl = GUIGridLabel:new(1, 1, 4, 1, "1337", self.m_Tabs[1]):setAlign("center", "top"):setHeader()
	self.m_AmountCountLbl = GUIGridLabel:new(5, 1, 4, 1, "42", self.m_Tabs[1]):setAlign("center", "top"):setHeader()
	self.m_PlayerCountLbl = GUIGridLabel:new(9, 1, 4, 1, "69", self.m_Tabs[1]):setAlign("center", "top"):setHeader()
	GUIGridLabel:new(1, 2, 4, 1, "Asservate", self.m_Tabs[1]):setAlign("center", "top")
	GUIGridLabel:new(5, 2, 4, 1, "Objekte insg.", self.m_Tabs[1]):setAlign("center", "top")
	GUIGridLabel:new(9, 2, 4, 1, "beteiligte Beamte", self.m_Tabs[1]):setAlign("center", "top")
	
	--black magic
	GUIImage:new(grid("x", 13)/2 - grid()/2, grid("y",3) - grid()/2, grid(), grid()/2,"files/images/GUI/Triangle.png", self.m_Tabs[1])
	DxRectangle:new(grid("x",1), grid("y",3), grid("w",12), 2, Color.White, self.m_Tabs[1]):setDrawingEnabled(true)
	
	self.m_WeaponCountLbl = GUIGridLabel:new(1, 3, 4, 1, "1337", self.m_Tabs[1]):setAlign("center", "top"):setHeader()
	self.m_MuniCountLbl = GUIGridLabel:new(5, 3, 4, 1, "42", self.m_Tabs[1]):setAlign("center", "top"):setHeader()
	self.m_ItemCountLbl = GUIGridLabel:new(9, 3, 4, 1, "69", self.m_Tabs[1]):setAlign("center", "top"):setHeader()
	GUIGridLabel:new(1, 4, 4, 1, "Waffen", self.m_Tabs[1]):setAlign("center", "top")
	GUIGridLabel:new(5, 4, 4, 1, "Munition", self.m_Tabs[1]):setAlign("center", "top")
	GUIGridLabel:new(9, 4, 4, 1, "Items", self.m_Tabs[1]):setAlign("center", "top")
	
	self.m_Btn = GUIGridButton:new(9, 5, 4, 1, "Truck beladen", self.m_Tabs[1]):setBarEnabled(false) --parent am "ersten" Tab
	self.m_ProgContent = GUIGridProgressBar:new(1,5,8,1,self.m_Tabs[1]):setProgressTextEnabled(true):setText("Lager gefüllt")
	
	self.m_Btn.onLeftClick = function ()
		QuestionBox:new(_"Möchtest du wirklich einen Asservaten Geld-Truck starten?", function()
			triggerServerEvent("State:startEvidenceTruck", localPlayer)
		end)
	end


	--details tab
	self.m_List = GUIGridGridList:new(1,1,12,5,self.m_Tabs[2])
	self.m_List:addColumn(_"#", 0.08)
	self.m_List:addColumn(_"Objekt", 0.3)
	self.m_List:addColumn(_"Von", 0.32)
	self.m_List:addColumn(_"Datum", 0.2)
	self.m_EvidenceTable = evidenceTable
	self.m_FillState = fillState
	self:refreshGrid()
end

function StateEvidenceGUI:clearList()
	self.m_EvidenceTable = {}
	self.m_List:clear()
end

function StateEvidenceGUI:refreshGrid()
	self.m_List:clear()
	local item
	local statistics = {
		rows = 0,
		amount = {total = 0},
		cops = {}
	}

	for i,data in pairs(self.m_EvidenceTable) do
			if data.Type == "Waffe" then data.Object = WEAPON_NAMES[tonumber(data.Object)] or "Unbekannt" end
			if data.Type == "Munition" then data.Object = WEAPON_NAMES[tonumber(data.Object)].."-Muni" or "Unbekannt" end
			item = self.m_List:addItem(data.Amount, data.Object, data.UserName, getOpticalTimestamp(data.Timestamp))
			item.onLeftClick = function() end

			statistics.cops[data.UserName] = true
			if not statistics.amount[data.Type] then statistics.amount[data.Type] = 0 end
			statistics.amount[data.Type] = statistics.amount[data.Type] + data.Amount
			statistics.amount.total = statistics.amount.total + data.Amount
			statistics.rows = statistics.rows + 1
	end

	--refresh statistics
	self.m_RowCountLbl:setText(convertNumber(statistics.rows or 0))
	self.m_AmountCountLbl:setText(convertNumber(statistics.amount.total or 0))
	self.m_PlayerCountLbl:setText(convertNumber(table.size(statistics.cops)))
	
	self.m_WeaponCountLbl:setText(convertNumber(statistics.amount.Waffe or 0))
	self.m_MuniCountLbl:setText(convertNumber(statistics.amount.Munition or 0))
	self.m_ItemCountLbl:setText(convertNumber(statistics.amount.Item or 0))
	self.m_ProgContent:setProgress(math.floor(self.m_FillState/STATE_EVIDENCE_MAX_OBJECTS*100))
	self.m_Btn:setEnabled(self.m_ProgContent:getProgress() > 0)
end

addEventHandler("State:sendEvidenceItems", root,
	function( ev , fillState)
		StateEvidenceGUI:new( ev,fillState )
	end
)