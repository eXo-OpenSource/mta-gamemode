-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateFactionDutyGUI.lua
-- *  PURPOSE:     State Faction Duty GUI
-- *
-- ****************************************************************************
StateFactionDutyGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showStateFactionDutyGUI","updateStateFactionDutyGUI"}

function StateFactionDutyGUI:constructor()
	GUIButtonMenu.constructor(self, "Staatsfraktion Duty Menü")

	-- Add the Items
	self:addItems()

	-- Events
	addEventHandler("updateStateFactionDutyGUI", root, bind(self.Event_updateStateFactionDutyGUI, self))
end

function StateFactionDutyGUI:addItems()
	if localPlayer:getPublicSync("Faction:Duty") then
		self:addItem(_"Dienst beenden", Color.Green, bind(self.itemCallback, self, 1))
		self:addItem(_"Neu ausrüsten", Color.Green, bind(self.itemCallback, self, 2))
		self.m_Swat = self:addItem(_"Zum Swat-Modus wechseln",Color.Blue, bind(self.itemCallback, self, 3))
		--self:addItem(_"Skin wechseln", Color.Blue, bind(self.itemCallback, self, 4))
		self:addItem(_"Waffen einlagern", Color.Red, bind(self.itemCallback, self, 5))
	else
		self:addItem(_"In den Dienst gehen", Color.Green, bind(self.itemCallback, self, 1))
	end
	self:addItem(_"Schließen", Color.Red, bind(self.itemCallback, self))
end

function StateFactionDutyGUI:itemCallback(type)
	if type == 1 then
		triggerServerEvent("factionStateToggleDuty", localPlayer)
	elseif type == 2 then
		triggerServerEvent("factionStateRearm", localPlayer)
	elseif type == 3 then
		triggerServerEvent("factionStateSwat", localPlayer)
	elseif type == 4 then
		triggerServerEvent("factionStateChangeSkin", localPlayer)
	elseif type == 5 then
		triggerServerEvent("factionStateStorageWeapons", localPlayer)
	end
	self:close()
end

function StateFactionDutyGUI:Event_updateStateFactionDutyGUI(duty, swat)
	if self.m_Swat then
		if swat == true then
			self.m_Swat:setText(_"Swat-Modus beenden")
		else
			self.m_Swat:setText(_"Zum Swat-Modus wechseln")
		end
	end
end

addEventHandler("showStateFactionDutyGUI", root,
		function()
			StateFactionDutyGUI:new()
		end
	)
