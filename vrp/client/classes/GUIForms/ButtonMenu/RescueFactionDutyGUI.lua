-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RescueFactionDutyGUI.lua
-- *  PURPOSE:     State Faction Duty GUI
-- *
-- ****************************************************************************
RescueFactionDutyGUI = inherit(GUIButtonMenu)
addRemoteEvents{"showRescueFactionDutyGUI"}

function RescueFactionDutyGUI:constructor(text)
	GUIButtonMenu.constructor(self, text)

	if not localPlayer:getPublicSync("Faction:Duty") then
		self:addItem(_"Medic Dienst starten", Color.Green, bind(self.itemCallback, self, 1))
		self:addItem(_"Feuerwehr Dienst starten", Color.Green, bind(self.itemCallback, self, 2))
	else
		self:addItem(_"Dienst beenden", Color.Green, bind(self.itemCallback, self, 1))
	end
	self:addItem(_"Schließen", Color.Red, bind(self.itemCallback, self))
end

addEventHandler("showRescueFactionDutyGUI", root,
	function()
		RescueFactionDutyGUI:new("Rescue-Team Duty Menü")
	end
)

function RescueFactionDutyGUI:itemCallback(type)
	if type == 1 then -- Duty: Medic
		triggerServerEvent("factionRescueToggleDuty", localPlayer, "medic")
	elseif type == 2 then -- Duty: Fire
		triggerServerEvent("factionRescueToggleDuty", localPlayer, "fire")
	end
	self:close()
end

function RescueFactionDutyGUI:onShow()
	Cursor:show()
end

function RescueFactionDutyGUI:onHide()
	Cursor:hide()
end


function RescueFactionDutyGUI:hide()
	GUIForm.hide(self)
end
