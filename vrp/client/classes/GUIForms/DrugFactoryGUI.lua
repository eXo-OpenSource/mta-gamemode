-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/DrugFactoryGUI.lua
-- *  PURPOSE:     Drug Factory GUI
-- *
-- ****************************************************************************
DrugFactoryGUI = inherit(GUIForm)
inherit(Singleton, DrugFactoryGUI)

addRemoteEvents{"onFactoryDataReceive"}

function DrugFactoryGUI:constructor()
	GUIWindow.updateGrid()	
	self.m_Width = grid("x", 15)
	self.m_Height = grid("y", 11)

	GUIForm.constructor(self, screenWidth/2-self.m_Width/2, screenHeight/2-self.m_Height/2, self.m_Width, self.m_Height, true)
	self.m_Window = GUIWindow:new(0, 0, self.m_Width, self.m_Height, _"Fabriken", true, true, self)
	
	self.m_Headline = GUIGridLabel:new(7, 1, 9, 1, "", self.m_Window):setHeader()
	self.m_OwnerLabel = GUIGridLabel:new(7, 2, 9, 1, "Besitzer:", self.m_Window)
	self.m_ProgressLabel = GUIGridLabel:new(7, 3, 9, 1, "Fortschritt:", self.m_Window)
	self.m_LastAttackLabel = GUIGridLabel:new(7, 4, 9, 1, "Letzter Angriff:", self.m_Window)
	self.m_WorkingStationsLabel = GUIGridLabel:new(7, 5, 9, 1, "Verarbeitungsstellen:", self.m_Window)
	self.m_WorkersLabel = GUIGridLabel:new(7, 6, 9, 1, "Arbeiter:", self.m_Window)
	
	self.m_GridList = GUIGridGridList:new(1, 1, 6, 10, self.m_Window)
    self.m_GridList:addColumn("", 0.95)
    self.m_GridList:addItemNoClick(_"Besetzte Fabriken")
	
	self.m_WorkerButton = GUIGridButton:new(7, 8, 5, 1, _"Arbeiter anwerben", self.m_Window)
	self.m_WorkerButton.onLeftClick = function()
		triggerServerEvent("requestFactoryRecruitWorker", localPlayer, self.m_FactoryID)
	end
	self.m_WorkStationButton = GUIGridButton:new(7, 9, 5, 1, _"Verarbeitungsstelle bauen", self.m_Window)
	self.m_WorkStationButton.onLeftClick = function()
		triggerServerEvent("requestFactoryBuildWorkingStation", localPlayer, self.m_FactoryID)
	end
	self:getFactoryData()
end

function DrugFactoryGUI:destructor()
	GUIForm.destructor(self)
end

function DrugFactoryGUI:getFactoryData()
    triggerServerEvent("requestDrugFactoryData", localPlayer, localPlayer)
    addEventHandler("onFactoryDataReceive", root, bind(self.onFactoryDataReceive, self))
end

function DrugFactoryGUI:onFactoryDataReceive(table)
    if table then
		for key, factory in ipairs(table) do 
			local item = self.m_GridList:addItem(("  %s Fabrik"):format(factory.Type))
			item.onLeftClick = function()
				self.m_FactoryID = factory.ID
				self.m_Headline:setText(("%s Fabrik, %s"):format(factory.Type, factory.Position))
				self.m_OwnerLabel:setText(("Besitzer: %s"):format(factory.Owner))
				self.m_ProgressLabel:setText(("Fortschritt: %s%%"):format(factory.Progress))
				self.m_LastAttackLabel:setText(("Letzter Angriff: %s"):format(factory.LastAttack))
				self.m_WorkingStationsLabel:setText(("Verarbeitungsstellen: %s"):format(factory.WorkingStations))
				self.m_WorkersLabel:setText(("Arbeiter: %s"):format(factory.Workers))
			end
		end
    end
end

function DrugFactoryGUI:addBackButton(callBack)
	if self.m_Window then
		self.m_Window:addBackButton(function () callBack() delete(self) end)
	end
end