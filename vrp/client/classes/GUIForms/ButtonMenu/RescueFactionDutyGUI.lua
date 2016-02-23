-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RescueFactionDutyGUI.lua
-- *  PURPOSE:     State Faction Duty GUI
-- *
-- ****************************************************************************
RescueFactionDutyGUI = inherit(GUIButtonMenu)

addRemoteEvents{"showRescueFactionDutyGUI","updateRescueFactionDutyGUI"}

function RescueFactionDutyGUI:constructor(text)
	GUIButtonMenu.constructor(self, text)
	self:addItem(_"Medic Dienst starten",Color.Green ,
		function()
			triggerServerEvent("factionRescueToggleDuty", localPlayer, "medic")
		end
	)

	self:addItem(_"Feuerwehr Dienst starten",Color.Green ,
		function()
			triggerServerEvent("factionRescueToggleDuty", localPlayer, "fire")
		end
	)

	self:addItem(_"Schließen",Color.Red ,
		function()
			self:close()
		end
	)


	--addEventHandler("updateRescueFactionDutyGUI", root, bind(self.Event_updateRescueFactionDutyGUI, self))
	--self:refresh()
end

addEventHandler("showRescueFactionDutyGUI", root,
		function()
			RescueFactionDutyGUI:new("Rescue-Team Duty Menü")
		end
	)


function RescueFactionDutyGUI:onShow()
	Cursor:show()
end

function RescueFactionDutyGUI:onHide()
	Cursor:hide()
end


function RescueFactionDutyGUI:hide()
	GUIForm.hide(self)
end
