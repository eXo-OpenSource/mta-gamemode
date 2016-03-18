-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Group.lua
-- *  PURPOSE:     Group class
-- *
-- ****************************************************************************
Group = inherit(Object)

function Group:constructor(Id, name, money, players, karma, lastNameChange, rankNames, rankLoans, type)
	self.m_Id = Id

	self.m_Players = players or {}
	self.m_Name = name
	self.m_Money = money or 0
	self.m_ProfitProportion = 0.5 -- Amount of money for the group fund
	self.m_Invitations = {}
	self.m_Karma = karma or 0
	self.m_LastNameChange = lastNameChange or 0
	self.m_VehiclesCanBeModified = true
	self.m_Type = type
	local saveRanks = false
	if rankNames == "" then	rankNames = {} for i=0,6 do rankNames[i] = "Rang "..i end rankNames = toJSON(rankNames) outputDebug("Created RankNames for group "..Id) saveRanks = true end
	if rankLoans == "" then	rankLoans = {} for i=0,6 do rankLoans[i] = 0 end rankLoans = toJSON(rankLoans) outputDebug("Created RankLoans for group "..Id) saveRanks = true end

	self.m_RankNames = fromJSON(rankNames)
	self.m_RankLoans = fromJSON(rankLoans)
	if saveRanks == true then
		self:saveRankSettings()
	end

	self.m_PhoneNumber = (PhoneNumber.load(4, self.m_Id) or PhoneNumber.generateNumber(4, self.m_Id))
	self.m_PhoneTakeOff = bind(self.phoneTakeOff, self)
end

function Group:destructor()
end

function Group.create(name,type)
	if sql:queryExec("INSERT INTO ??_groups (Name,Type) VALUES(?,?)", sql:getPrefix(), name,type) then
		local group = Group:new(sql:lastInsertId(), name)

		-- Add refernece
		GroupManager:getSingleton():addRef(group)

		return group
	end
	return false
end

function Group:purge()
	if sql:queryExec("DELETE FROM ??_groups WHERE Id = ?", sql:getPrefix(), self.m_Id) then
		-- Remove all players
		for playerId in pairs(self.m_Players) do
			self:removePlayer(playerId)
		end

		-- Remove reference
		GroupManager:getSingleton():removeRef(self)

		-- Free owned gangareas
	--	GangAreaManager:getSingleton():freeAreas()

		return true
	end
	return false
end

function Group:getId()
	return self.m_Id
end

function Group:getType()
	return self.m_Type
end

function Group:getVehicles()
  return VehicleManager:getSingleton():getGroupVehicles(self.m_Id)
end

function Group:canVehiclesBeModified()
  return self.m_VehiclesCanBeModified
end

function Group:setName(name)
	local timestamp = getRealTime().timestamp
	if not sql:queryExec("UPDATE ??_groups SET Name = ?, lastNameChange = ?, RankNames = ?, RankLoans = ? WHERE Id = ?", sql:getPrefix(), name, timestamp, toJSON(self.m_RankNames), toJSON(self.m_RankLoans), self.m_Id) then
		return false
	end
	triggerClientEvent("gangAreaOnGroupNameChange", root, self.m_Name, name)

	self.m_Name = name
	self.m_LastNameChange = timestamp

	for i, player in pairs(self:getOnlinePlayers()) do
		player:setPublicSync("GroupName", self:getName())
	end

	return true
end

function Group:saveRankSettings()
	if not sql:queryExec("UPDATE ??_groups SET RankNames = ?, RankLoans = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_RankNames), toJSON(self.m_RankLoans), self.m_Id) then
		return false
	end
	return true
end

function Group:getName()
	return self.m_Name
end

function Group:getKarma()
	return self.m_Karma
end

function Group:setKarma(karma)
	self.m_Karma = karma

	sql:queryExec("UPDATE ??_groups SET Karma = ? WHERE Id = ?", sql:getPrefix(), self.m_Karma, self.m_Id)
end

function Group:setRankName(rank,name)
	self.m_RankNames[tostring(rank)] = name
end

function Group:setRankLoan(rank,amount)
	self.m_RankLoans[tostring(rank)] = amount
end

function Group:paydayPlayer(player)
	local rank = self.m_Players[player:getId()]
	local loan = tonumber(self.m_RankLoans[tostring(rank)])
	if self:getMoney() < loan then loan = self:getMoney() end
	self:takeMoney(loan)
	return loan
end

function Group:giveKarma(karma)
	self:setKarma(self:getKarma() + karma)
end

function Group:getKarma()
	return self.m_Karma
end

function Group:isEvil()
	return self:getKarma() < 0
end

function Group:addPlayer(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	rank = rank or 0
	self.m_Players[playerId] = rank
	local player = Player.getFromId(playerId)
	if player then
		player:setGroup(self)
	end

	sql:queryExec("UPDATE ??_character SET GroupId = ?, GroupRank = ? WHERE Id = ?", sql:getPrefix(), self.m_Id, rank, playerId)
end

function Group:removePlayer(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = nil
	local player = Player.getFromId(playerId)
	if player then
		player:setGroup(nil)
	end

	sql:queryExec("UPDATE ??_character SET GroupId = 0, GroupRank = 0 WHERE Id = ?", sql:getPrefix(), playerId)
end

function Group:invitePlayer(player)
    client:sendShortMessage(("Du hast %s erfolgreich in deine Gruppe eingeladen."):format(getPlayerName(player)))

	player:triggerEvent("groupInvitationRetrieve", self:getId(), self:getName())

	self.m_Invitations[player] = true
end

function Group:removeInvitation(player)
	self.m_Invitations[player] = nil
end

function Group:hasInvitation(player)
	return self.m_Invitations[player]
end

function Group:isPlayerMember(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId] ~= nil
end


function Group:getPlayerRank(playerId)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	return self.m_Players[playerId]
end

function Group:setPlayerRank(playerId, rank)
	if type(playerId) == "userdata" then
		playerId = playerId:getId()
	end

	self.m_Players[playerId] = rank
	sql:queryExec("UPDATE ??_character SET GroupRank = ? WHERE Id = ?", sql:getPrefix(), rank, playerId)
end

function Group:getMoney()
	return self.m_Money
end

function Group:giveMoney(amount)
	self:setMoney(self.m_Money + amount)
end

function Group:takeMoney(amount)
	self:setMoney(self.m_Money - amount)
end

function Group:setMoney(amount)
	self.m_Money = amount

	sql:queryExec("UPDATE ??_groups SET Money = ? WHERE Id = ?", sql:getPrefix(), self.m_Money, self.m_Id)
end

function Group:getPlayers(getIDsOnly)
	if getIDsOnly then
		return self.m_Players
	end

	local temp = {}
	for playerId, rank in pairs(self.m_Players) do
		temp[playerId] = {name = Account.getNameFromId(playerId), rank = rank}
	end
	return temp
end

function Group:getOnlinePlayers()
	local players = {}
	for playerId in pairs(self.m_Players) do
		local player = Player.getFromId(playerId)
		if player then
			players[#players + 1] = player
		end
	end
	return players
end

function Group:sendMessage(text, r, g, b, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendMessage(text, r, g, b, ...)
	end
end

function Group:sendShortMessage(text, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendShortMessage(("%s:\n%s"):format(self:getName(), text), ...)
	end
end

function Group:distributeMoney(amount)
	local moneyForFund = amount * self.m_ProfitProportion
	self:giveMoney(moneyForFund)

	local moneyForPlayers = amount - moneyForFund
	local onlinePlayers = self:getOnlinePlayers()
	local amountPerPlayer = math.floor(moneyForPlayers / #onlinePlayers)

	for k, player in pairs(onlinePlayers) do
		player:giveMoney(amountPerPlayer)
	end
end

function Group:attachPlayerMarkers()
	self.m_Markers = {}
	for k, player in ipairs(self:getOnlinePlayers()) do
		self.m_Markers[player] = createMarker(player:getPosition(),"arrow",0.4,255,0,0,125)
		self.m_Markers[player]:setDimension(player:getDimension())
		self.m_Markers[player]:setInterior(player:getInterior())
		self.m_Markers[player]:attach(player,0,0,1.5)
		self.m_RefreshAttachedMarker = bind(self.refreshAttachedMarker, self)
		addEventHandler("onElementDimensionChange", player, self.m_RefreshAttachedMarker)
		addEventHandler("onElementInteriorChange", player, self.m_RefreshAttachedMarker)
	end
end

function Group:removePlayerMarkers()
	self.m_Markers = {}
	for k, player in ipairs(self:getOnlinePlayers()) do
		self.m_Markers[player]:destroy()
		removeEventHandler("onElementDimensionChange", self, self.m_RefreshAttachedMarker)
		removeEventHandler("onElementInteriorChange", self, self.m_RefreshAttachedMarker)
	end
end

function Group:refreshAttachedMarker()
	self.m_Markers[source]:setInterior(source:getInterior())
	self.m_Markers[source]:setDimension(source:getDimension())
end


function Group:phoneCall(caller)
	if #self:getOnlinePlayers() > 0 then
		for k, player in ipairs(self:getOnlinePlayers()) do
			if not player:getPhonePartner() then
				player:sendShortMessage(_("Der Spieler %s ruft eure Firma/Gang (%s) an!\nDrücke 'F5' um abzuheben.", player, caller:getName(), self:getName()))
				bindKey(player, "F5", "down", self.m_PhoneTakeOff, caller)
			end
		end
	else
		caller:sendShortMessage(_("Es ist aktuell kein Spieler der Firma/Gang online!", caller))
		caller:triggerEvent("callBusy", caller)
	end
end

function Group:phoneTakeOff(player, key, state, caller)
	self:sendShortMessage(_("%s hat das Telefonat von %s angenommen!", player, player:getName(), caller:getName()))
	caller:triggerEvent("callAnswer", player, false)
	player:triggerEvent("callAnswer", caller, false)
	caller:setPhonePartner(player)
	player:setPhonePartner(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if isKeyBound(player, "F5", "down", self.m_PhoneTakeOff) then
			unbindKey(player, "F5", "down", self.m_PhoneTakeOff)
		end
	end
end
