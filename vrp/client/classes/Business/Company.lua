-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        client/classes/Company/Company.lua
-- *  PURPOSE:     Company Client
-- *
-- ****************************************************************************

CompanyManager = inherit(Singleton)
CompanyManager.Map = {}

function CompanyManager:constructor()
	PublicTransport:new()
	MechanicTow:new()

	triggerServerEvent("getCompanies", localPlayer)
	addRemoteEvents{"loadClientCompany", "companyForceOffduty", "startCompanyRespawnAnnouncement", "stopCompanyRespawnAnnoucement"}
	addEventHandler("loadClientCompany", root, bind(self.loadCompany, self))
	addEventHandler("companyForceOffduty", root, bind(self.companyForceOffduty, self))
	addEventHandler("startCompanyRespawnAnnouncement", localPlayer, bind(self.startRespawnAnnouncement, self))
    addEventHandler("stopCompanyRespawnAnnoucement", localPlayer, bind(self.stopRespawnAnnoucement, self))
end

function CompanyManager:loadCompany(Id, name, name_short, rankNames, color)
	CompanyManager.Map[Id] = Company:new(Id, name, name_short, rankNames, color)
end

function CompanyManager:getFromId(id)
	return CompanyManager.Map[id]
end

function CompanyManager:companyForceOffduty()
	if localPlayer:getPublicSync("Company:Duty") then
		triggerServerEvent("companyToggleDuty", localPlayer, true, false, true)
	end
end

function CompanyManager:startRespawnAnnouncement(announcer)
	if localPlayer:getCompany() then
		localPlayer:getCompany():startRespawnAnnouncement(announcer)
	end
end

function CompanyManager:stopRespawnAnnoucement(stopper)
	if localPlayer:getCompany() then
		localPlayer:getCompany():stopRespawnAnnoucement(stopper)
	end
end

Company = inherit(Object)

function Company:constructor(Id, name, name_short, rankNames, color)
	self.m_Id = Id
	self.m_Name = name
	self.m_NameShort = name_short
	self.m_RankNames = rankNames
	self.m_Color = color
end

function Company:getId()
	return self.m_Id
end

function Company:getName()
	return self.m_Name
end

function Company:getShortName()
	return self.m_NameShort
end

function Company:getColor()
	return self.m_Color
end

function Company:getOnlinePlayers()
	local players = {}
	for _, player in pairs(Element.getAllByType"player") do
		if player:getCompany() and player:getCompany() == self then
			table.insert(players, player)
		end
	end
	return players
end


function Company:startRespawnAnnouncement(announcer)
	local seconds = 15
	local whoAnnouncedText = _("%s einen Respawn angekündigt.", announcer == localPlayer and "Du hast" or _("%s hat", announcer:getName())) 
	local secondsLeftText = _("Alle Fahrzeuge werden in %d Sekunden respawned!", seconds)
	local stopRespawnText = _"Klicke hier, um den Respawn zu stoppen."

	self.m_RespawnAnnouncement = ShortMessage:new(_("%s %s\n %s", whoAnnouncedText, secondsLeftText, stopRespawnText), 
	_"Fahrzeug Respawn", 
	tocolor(self:getColor().r, self:getColor().g, self:getColor().b), 
	15000, function()
		triggerServerEvent("stopCompanyRespawnAnnouncement", localPlayer, self:getId())
	end)

	self.m_RespawnCountdown = setTimer(function() 
		seconds = seconds - 1
		secondsLeftText = _("Alle Fahrzeuge werden in %d Sekunde%s respawned!", seconds, seconds ~= 1 and "n" or "")
		self.m_RespawnAnnouncement:setText(_("%s %s\n%s", whoAnnouncedText, secondsLeftText, stopRespawnText))
	end, 1000, 15)
end

function Company:stopRespawnAnnoucement(stopper)
	local whoStoppedText
	if stopper == localPlayer then
		whoStoppedText = _"Du hast den Respawn gestoppt."
	else
		whoStoppedText = _("%s hat den Respawn gestoppt.", stopper:getName())
	end
	killTimer(self.m_RespawnCountdown)
	self.m_RespawnAnnouncement:delete()
	self.m_RespawnAnnouncement = ShortMessage:new(whoStoppedText, _"Fahrzeug Respawn")
end