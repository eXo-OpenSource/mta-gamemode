-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Events/Deathmatch/DMEvent.lua
-- *  PURPOSE:     Deathmatch event class
-- *
-- ****************************************************************************
DeathmatchEvent = inherit(Singleton)

DeathmatchEvent.Status = {
	{1, "Waiting"};
	{2, "Starting"};
	{3, "Running"};
}
DeathmatchEvent.Types = {
	{1, "1 vs. 1"};
	{2, "2 vs. 2"};
	{3, "3 vs. 3"};
}
DeathmatchEvent.data = {
	Maps = {    -- Name, Position, Int
		{"Deathmatch Area 1", Vector3(0, 0, 0), 0};
		{"Deathmatch Area 2", Vector3(0, 0, 0), 0};
		{"Deathmatch Area 3", Vector3(0, 0, 0), 0};
		{"Deathmatch Area 4", Vector3(0, 0, 0), 0};
		{"Deathmatch Area 5", Vector3(0, 0, 0), 0};
		{"Deathmatch Area 6", Vector3(0, 0, 0), 0};
	};
	Weapons = {
		{"Deagle", 24};
		{"Silenced Pistol", 23};
		{"Pistol", 22};
	}
}

function DeathmatchEvent:constructor ()
	self.m_Matches = {}
	self.m_GUI = false
	self.m_GUIForm = 0

	addRemoteEvents{"DeathmatchEvent.openGUIForm", "DeathmatchEvent.closeGUIForm", "DeathmatchEvent.sendData", "DeathmatchEvent.onHelpColHit", "DeathmatchEvent.onHelpColLeave"}
	addEventHandler("DeathmatchEvent.openGUIForm", root, bind(DeathmatchEvent.openGUIForm, self))
	addEventHandler("DeathmatchEvent.closeGUIForm", root, bind(DeathmatchEvent.closeGUIForm, self))
	addEventHandler("DeathmatchEvent.sendData", root, bind(DeathmatchEvent.fetchMatchData, self))
	addEventHandler("DeathmatchEvent.onHelpColHit", root, self.onHelpColHit)
	addEventHandler("DeathmatchEvent.onHelpColLeave", root, self.onHelpColLeave)

	-- Add to Helpmenu
	HelpTextManager:getSingleton():addText(_"Events", _(HelpTextTitles.Events.Deathmatch):gsub("Event: ", ""), "events.deathmatch")
end

function DeathmatchEvent:openGUIForm (type, ...)
	if not self.m_GUI then
		if type == 1 and self.m_GUIForm ~= 1 then
			self.m_GUI = DeathmatchGUI:new(...)
			self.m_GUIForm = 1
		elseif type == 2 and self.m_GUIForm ~= 2 then -- Todo: Check if the player is allowed to do that. Karma Level, XP or whatever :P
			self.m_GUI = HostDeathmatchGUI:new(...)
			self.m_GUIForm = 2
		elseif type == 3 and self.m_GUIForm ~= 3 then
			self.m_GUI = LobbyDeathmatchGUI:new(...)
			self.m_GUIForm = 3
		end
	end
end

function DeathmatchEvent:closeGUIForm ()
	if self.m_GUI then
		delete(self.m_GUI)
		self.m_GUI = false
		self.m_GUIForm = 0
	end
end

function DeathmatchEvent:fetchMatchData (data)
	self.m_Matches = data

	if self.m_GUI then
		if self.m_GUI.updateData then
			self.m_GUI:updateData()
		end
	end
end

function DeathmatchEvent:Event_createMatch (type, weapon, map, password)
	triggerServerEvent("Deathmatch.newMatch", root, localPlayer, type, password, weapon, map)
end

function DeathmatchEvent:addPlayertoMatch (id)
	outputDebug("Adding "..getPlayerName(localPlayer).." to the Match #"..id.."...")

	-- Todo: Improve!
	localPlayer:setTempMatchID(id)

	triggerServerEvent("Deathmatch.addPlayertoMatch", root, id)
end

function DeathmatchEvent:removePlayerfromMatch (id)
	outputDebug("Removing "..getPlayerName(localPlayer).." from the Match #"..id.."...")

	triggerServerEvent("Deathmatch.removePlayerfromMatch", root, id)
end

function DeathmatchEvent:getMatchData (id)
	return (self.m_Matches[id] ~= nil and self.m_Matches[id]) or false
end

function DeathmatchEvent.onHelpColHit ()
		HelpBar:getSingleton():addText(_(HelpTextTitles.Events.Deathmatch), _(HelpTexts.Events.Deathmatch))
end

function DeathmatchEvent.onHelpColLeave ()
	HelpBar:getSingleton():addText(localPlayer.m_oldHelp.title or _(HelpTextTitles.General.Main), localPlayer.m_oldHelp.text or _(HelpTexts.General.Main), false, localPlayer.m_oldHelp.tutorial or false)
end
