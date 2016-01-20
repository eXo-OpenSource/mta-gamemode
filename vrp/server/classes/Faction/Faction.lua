-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Faction.lua
-- *  PURPOSE:     Base Faction Super Class
-- *
-- ****************************************************************************

Faction = inherit(Object)

-- implement by children

function Faction:constructor(id, name_short, name, bankAccountId, players,ranks,colors,skins,depotId,weapons,factionType)
	self.m_Id = id
	self.m_Name_Short = name_short
	self.m_Name = name
	self.m_Players = players
	self.m_BankAccount = BankAccount.load(bankAccountId) or BankAccount.create(BankAccountTypes.Faction, self:getId())
	self.m_Invitations = {}
	self.m_RankNames = ranks
	self.m_Color = colors
	self.m_Skins = skins
	self.m_Type = factionType
	self.m_Weapons = weapons
	self.m_Depot = Depot.load(depotId,id)
end

function Faction:destructor()
	if self.m_BankAccount then
		delete(self.m_BankAccount)
	end
end

function Faction:isStateFaction()
	if self.m_Type == "State" then
		return true
	end
	return false
end

function Faction:isEvilFaction()
	if self.m_Type == "Evil" then
		return true
	end
	return false
end

function Faction:getId()
	return self.m_Id
end

function Faction:getName()
	return self.m_Name
end

function Faction:getShortName()
	return self.m_Name_Short
end

function Faction:changeSkin(player)
	local curskin = getElementModel(player)
	suc = false
	for i = curskin+1, 313 do
		if self.m_Skins[i] then
			suc = true
			player:setSkin(i)
			break
		end
	end
	if suc == false then
		for i = 0, curskin do
			if self.m_Skins[i] then
				suc = true
				player:setSkin(i)
				break
			end
		end
	end	
end

function Faction:rearm(player)
	return self.m_Name
end

function Faction:updateStateFactionDutyGUI(player)
	player:triggerEvent("updateStateFactionDutyGUI", player:isFactionDuty(),player:getPublicSync("Fraktion:Swat"))
end

function Faction:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 1
	self.m_Players[playerId] = rank
	local player = Player.getFromId(playerId)
	if player then
		player:setFaction(self)
	end

	sql:queryExec("UPDATE ??_character SET FactionId = ?, FactionRank = ? WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)
end

function Faction:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setFaction(nil)
	end

	sql:queryExec("UPDATE ??_character SET FactionId = 0, FactionRank = 0 WHERE Id = ?", sql:getPrefix(), playerId)
end

function Faction:invitePlayer(player)
  client:sendShortMessage(("Du hast %s erfolgreich in die Fraktion eingeladen."):format(getPlayerName(player)))
	player:triggerEvent("factionInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = true
end

function Faction:removeInvitation(player)
	self.m_Invitations[player] = nil
end

function Faction:hasInvitation(player)
	return self.m_Invitations[player]
end

function Faction:isPlayerMember(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId] ~= nil
end


function Faction:getPlayerRank(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId]
end

function Faction:setPlayerRank(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = rank
	sql:queryExec("UPDATE ??_character SET FactionRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
end

function Faction:getMoney()
	return self.m_BankAccount:getMoney()
end

function Faction:giveMoney(amount)
	return self.m_BankAccount:addMoney(amount)
end

function Faction:takeMoney(amount)
	return self.m_BankAccount:takeMoney(amount)
end

function Faction:setMoney(amount)
  return self.m_BankAccount:setMoney(amount)
end

function Faction:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end

	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank}
	end
	return temp
end

function Faction:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			players[#players + 1] = player
		end
	end
	return players
end

function Faction:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Faction:sendChatMessage(sourcePlayer,text)
	local playerId = sourcePlayer:getId()
	local rank = self.m_Players[playerId]
	local rankName = self.m_RankNames[rank]
	local r,g,b = self.m_Color["r"],self.m_Color["g"],self.m_Color["b"]
	local text = ("%s %s: %s"):format(rankName,getPlayerName(sourcePlayer), text)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b)
	end
end
