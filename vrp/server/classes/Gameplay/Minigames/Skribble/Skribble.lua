-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        TODO
-- *  PURPOSE:     TODO
-- *
-- ****************************************************************************
SkribbleLobby = inherit(Object)

function SkribbleLobby:constructor(id, owner, name, password, rounds)
	self.m_Id = id
	self.m_Owner = owner
	self.m_Name = name
	self.m_Password = password
	self.m_Rounds = rounds

	self.m_Players = {}
	self.m_CurrentRound = 1
	self.m_State = "waiting"
	self.m_CurrentDrawing = nil

	self:addPlayer(owner)
end

function SkribbleLobby:destructor()
	SkribbleManager:getSingleton():unlinkLobby(self.m_Id)
end

function SkribbleLobby:getPlayers()
	local players = {}
	for player in pairs(self.m_Players) do
		if isElement(player) then
			table.insert(players, player)
		end
	end
	return players
end

function SkribbleLobby:addPlayer(player)
	self.m_Players[player] = {points = 0}
	self:sendShortMessage(player:getName() .. " is beigetreten!")
	self:syncLobbyInfos()

	player.skribbleLobby = self
end

function SkribbleLobby:removePlayer(player)
	self.m_Players[player] = nil
	player.skribbleLobby = nil

	self:syncLobbyInfos()

	if #self:getPlayers() == 0 then
		delete(self)
	end
end

function SkribbleLobby:syncLobbyInfos()
	for player in pairs(self.m_Players) do
		player:triggerEvent("skribbleSyncLobbyInfos", self.m_Players, self.m_CurrentDrawing, self.m_CurrentRound, self.m_State)
	end
end

function SkribbleLobby:sendShortMessage(text, ...)
	for player in pairs(self.m_Players) do
		player:sendShortMessage(_(text, player), "Skribble", {255, 125, 0}, ...)
	end
end

function SkribbleLobby:onPlayerChat(player, text, type)
	if type ~= 0 then return end

	for player in pairs(self.m_Players) do
		player:outputChat(("[Skribble] %s#E8FCFC: %s"):format(player:getName(), text), 255, 90, 0, true)
	end

	return true
end
