-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/StateFactionDutyGUI.lua
-- *  PURPOSE:     State Faction Duty GUI
-- *
-- ****************************************************************************
StateFactionDutyGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showStateFactionDutyGUI","updateStateFactionDutyGUI"}

function StateFactionDutyGUI:constructor(duty, swat)
	GUIButtonMenu.constructor(self, "Fraktion Duty Menü")

	self.m_Duty = self:addItem(_"In den Dienst gehen",Color.Green ,
		function()
			triggerServerEvent("factionStateToggleDuty", localPlayer)
		end
	)

	self.m_Rearm = self:addItem(_"Neu ausrüsten",Color.Green ,
		function()
			triggerServerEvent("factionStateRearm", localPlayer)
		end
	)

	self.m_Swat = self:addItem(_"Zum Swat-Modus wechseln",Color.Blue ,
		function()
			triggerServerEvent("factionStateSwat", localPlayer)
		end
	)

	self.m_SkinChange = self:addItem(_"Skin wechseln",Color.Blue ,
		function()
			triggerServerEvent("factionStateChangeSkin", localPlayer)
		end
	)

	addEventHandler("updateStateFactionDutyGUI", root, bind(self.Event_updateStateFactionDutyGUI, self))
end

function StateFactionDutyGUI:Event_updateStateFactionDutyGUI(duty,swat)


	if duty == true then
		self.m_Rearm:setEnabled(true)
		self.m_Swat:setEnabled(true)
		self.m_SkinChange:setEnabled(true)
		self.m_Duty:setBackgroundColor(Color.Red)
		self.m_Duty:setText("Dienst beenden")
	else
		self.m_Rearm:setEnabled(false)
		self.m_Swat:setEnabled(false)
		self.m_SkinChange:setEnabled(false)
		self.m_Duty:setBackgroundColor(Color.Green)
		self.m_Duty:setText("In den Dienst gehen")
	end
	if swat == true then
		self.m_Swat:setText("Swat-Modus beenden")
	else
		self.m_Swat:setText("Zum Swat-Modus wechseln")
	end
end

addEventHandler("showStateFactionDutyGUI", root,
		function()
			StateFactionDutyGUI:new()
		end
	)
