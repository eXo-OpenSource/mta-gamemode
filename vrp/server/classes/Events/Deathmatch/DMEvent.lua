-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Events/Deathmatch/DMEvent.lua
-- *  PURPOSE:     Deathmatch event class
-- *
-- ****************************************************************************
Deathmatch = inherit(Singleton)

Deathmatch.Position = Vector3(2729.59, -1828.13, 10.88)
Deathmatch.Status = {
	{1, "Waiting"};
	{2, "Starting"};
	{3, "Running"};
}
Deathmatch.Types = {
	{1, "1 vs. 1"};
	{2, "2 vs. 2"};
	{3, "3 vs. 3"};
}

function Deathmatch:constructor ()
	self.m_Marker = createMarker(self.Position, "cylinder", 1.3, 125, 0, 0)
	addEventHandler("onMarkerHit", self.m_Marker, function (hitelement, dim)
		if getElementType(hitelement) == "player" and dim then
			local guiID = (hitelement:getMatchID() and hitelement:getMatchID() > 0 and 3 or 1)
			hitelement:triggerEvent("DeathmatchEvent.openGUIForm", guiID)
		end
	end)
	addEventHandler("onMarkerLeave", self.m_Marker, function (hitelement, dim)
		if getElementType(hitelement) == "player" and dim then
			hitelement:triggerEvent("DeathmatchEvent.closeGUIForm")
		end
	end)

	self.m_HelpCol = createColSphere(2729.59, -1828.04, 11.84, 10)
	addEventHandler("onColShapeHit", self.m_HelpCol, function (hitelement, dim)
		if getElementType(hitelement) == "player" and dim then
			hitelement:triggerEvent("DeathmatchEvent.onHelpColHit", guiID)
		end
	end)
	addEventHandler("onColShapeLeave", self.m_HelpCol, function (hitelement, dim)
		if getElementType(hitelement) == "player" and dim then
			hitelement:triggerEvent("DeathmatchEvent.onHelpColLeave")
		end
	end)

	--self.m_Blip = Blip:new("1vs1.png", self.Position.x, self.Position.y, root, 400)
	self.m_Matches = {}

	addRemoteEvents{"Deathmatch.newMatch", "Deathmatch.addPlayertoMatch", "Deathmatch.removePlayerfromMatch", "Deathmatch.setMatchStatus"}
	addEventHandler("Deathmatch.newMatch", root, bind(self.newMatch, self))
	addEventHandler("Deathmatch.addPlayertoMatch", root, bind(self.addPlayertoMatch, self))
	addEventHandler("Deathmatch.removePlayerfromMatch", root, bind(self.removePlayerfromMatch, self))
	addEventHandler("Deathmatch.setMatchStatus", root, bind(self.setMatchStatus, self))
end

function Deathmatch:newMatch (host, ...)
	if host and getPlayerName(host) and (host.m_dmID == nil) then -- Check if the host is online
		local id = #self.m_Matches + 1
		self.m_Matches[id] = new(DMMatch, id, host, ...)
		self:syncData()

		host:setMatchID(id)
		host.m_DMQuit = bind(self.deleteMatch, self, id)
		--host:sendShortMessage(_("Das Match wurde erfolgreich erstellt!", host))
		addEventHandler("onPlayerQuit", host, host.m_DMQuit)

		setTimer(function ()
			host:triggerEvent("DeathmatchEvent.openGUIForm", 3)
		end, 500, 1)
		return self.m_Matches[id]
	end
end

function Deathmatch:deleteMatch (id)
	if self.m_Matches[id] ~= nil then
		local host = self.m_Matches[id]:getMatchData()["host"]
		removeEventHandler("onPlayerQuit", host, host.m_DMQuit)
		host.m_DMQuit = nil
		host:setMatchID(0)
		--host:sendShortMessage(_("Das Match wurde erfolgreich gelöscht!", host))

		delete(self.m_Matches[id])
		table.remove(self.m_Matches, id)
	end

	self:syncData()
end

function Deathmatch:getMatchFromID (id)
	return (self.m_Matches[id] ~= nil and self.m_Matches[id]) or false;
end

function Deathmatch:syncData ()
	local data = {}
	for i, v in pairs(self.m_Matches) do
		data[i] = v:getMatchData()
	end

	for _, v in ipairs(getElementsByType("player")) do
		v:triggerEvent("DeathmatchEvent.sendData", data)
	end
end

-- Match functions
function Deathmatch:addPlayertoMatch (id, ...)
	return self:getMatchFromID(id):addPlayer(client, ...)
end

function Deathmatch:removePlayerfromMatch (id, ...)
	local instance = self:getMatchFromID(id)
	if instance.m_Host == client then
		self:deleteMatch(id)
		return true
	end

	return instance:removePlayer(client, ...)
end

function Deathmatch:setMatchStatus (id, ...)
	local instance = self:getMatchFromID(id)
	if instance then
		if instance.m_Host == client then
			self:getMatchFromID(id):setStatus(...)
		end
	end
end
