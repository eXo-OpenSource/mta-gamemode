-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/GUIForms/RescueFactionDutyGUI.lua
-- *  PURPOSE:     State Faction Duty GUI
-- *
-- ****************************************************************************
RescueFactionDutyGUI = inherit(GUIButtonMenu)
inherit(Singleton, RescueFactionDutyGUI)
addRemoteEvents{"showRescueFactionDutyGUI"}

function RescueFactionDutyGUI:constructor(text, forceDuty)
	GUIButtonMenu.constructor(self, text)

	if localPlayer:getPublicSync("Faction:Duty") or forceDuty then
		self:addItem(_"Skin wechseln", Color.LightBlue, bind(self.itemCallback, self, 3))
		self:addItem(_"Dienst beenden", Color.Red, bind(self.itemCallback, self, 1))
	else
		self:addItem(_"Medic Dienst starten", Color.Green, bind(self.itemCallback, self, 1))
		self:addItem(_"Feuerwehr Dienst starten", Color.Green, bind(self.itemCallback, self, 2))
	end
	self:addItem(_"Schließen", Color.Red, bind(self.itemCallback, self))
end

addEventHandler("showRescueFactionDutyGUI", root,
	function(forceDuty)
		if RescueFactionDutyGUI:isInstantiated() then
			delete(RescueFactionDutyGUI:getSingleton())
		end
		RescueFactionDutyGUI:new("Rescue-Team Duty Menü", forceDuty)
	end
)

function RescueFactionDutyGUI:itemCallback(type)
	if type == 1 then -- Duty: Medic
		triggerServerEvent("factionRescueToggleDuty", localPlayer, "medic")
	elseif type == 2 then -- Duty: Fire
		triggerServerEvent("factionRescueToggleDuty", localPlayer, "fire")
	elseif type == 3 then -- Change Skin
		triggerServerEvent("factionRescueChangeSkin", localPlayer)
	end
	delete(self)
end
