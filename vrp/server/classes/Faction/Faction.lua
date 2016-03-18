-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/Faction/Faction.lua
-- *  PURPOSE:     Base Faction Super Class
-- *
-- ****************************************************************************

Faction = inherit(Object)

-- implement by children

function Faction:constructor(Id, name_short, name, bankAccountId, players, rankLoans, rankSkins, rankWeapons, depotId, factionType)
	self.m_Id = Id
	self.m_Name_Short = name_short
	self.m_Name = name
	self.m_Players = players
	self.m_BankAccount = BankAccount.load(bankAccountId) or BankAccount.create(BankAccountTypes.Faction, self:getId())
	self.m_Invitations = {}
	self.m_RankNames = factionRankNames[Id]
	self.m_Skins = factionSkins[Id]
	self.m_ValidWeapons = factionWeapons[Id]
	self.m_Color = factionColors[Id]
	self.m_WeaponDepotInfo = factionWeaponDepotInfo
	self.m_Vehicles = {}

	if rankLoans == "" then	rankLoans = {} for i=0,6 do rankLoans[i] = 0 end rankLoans = toJSON(rankLoans) outputDebug("Created RankLoans for faction "..Id) end
	if rankSkins == "" then	rankSkins = {} for i=0,6 do rankSkins[i] = self:getRandomSkin() end rankSkins = toJSON(rankSkins) outputDebug("Created RankSkins for faction "..Id) end
	if rankWeapons == "" then rankWeapons = {} for i=0,6 do rankWeapons[i] = {} for wi=0,46 do rankWeapons[i][wi] = 0 end end rankWeapons = toJSON(rankWeapons) outputDebug("Created RankWeapons for faction "..Id) end

	self.m_RankWeapons = fromJSON(rankWeapons)
	self.m_RankLoans = fromJSON(rankLoans)
	self.m_RankSkins = fromJSON(rankSkins)
	self.m_Type = factionType

	self.m_Depot = Depot.load(depotId,Id)

	self.m_PhoneNumber = (PhoneNumber.load(2, self.m_Id) or PhoneNumber.generateNumber(2, self.m_Id))
	self.m_PhoneTakeOff = bind(self.phoneTakeOff, self)

end


function Faction:destructor()
	if self.m_BankAccount then
		delete(self.m_BankAccount)
	end
	self:save()
end

function Faction:save()
	if sql:queryExec("UPDATE ??_factions SET RankLoans = ?, RankSkins = ?, RankWeapons = ?, BankAccount = ? WHERE Id = ?", sql:getPrefix(), toJSON(self.m_RankLoans), toJSON(self.m_RankSkins), toJSON(self.m_RankWeapons), self.m_BankAccount:getId(), self.m_Id) then
		outputDebug(("Saved Faction '%s' (Id: %d)"):format(self:getName(), self:getId()))
	else
		outputDebug(("Failed to save Faction '%s' (Id: %d)"):format(self:getName(), self:getId()))
	end
end

function Faction:isStateFaction()
	if self.m_Type == "State" then
		return true
	end
	return false
end

function Faction:isRescueFaction()
	if self.m_Type == "Rescue" then
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

function Faction:getRandomSkin()
	local i = 1
	local skins = {}
	for skinId,bool in pairs(self.m_Skins) do
		if bool == true then
			skins[i] = skinId
			i = i+1
		end
	end
	return skins[math.random(1,#skins)]
end

function Faction:changeSkin(player)
	local rank = self:getPlayerRank(player)
	player:setModel(self.m_RankSkins[tostring(rank)])
end

function Faction:changeSkin_old(player)
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

function Faction:setRankLoan(rank,amount)
	self.m_RankLoans[tostring(rank)] = amount
end

function Faction:paydayPlayer(player)
	local rank = self.m_Players[player:getId()]
	local loan = tonumber(self.m_RankLoans[tostring(rank)])
	if self.m_BankAccount:getMoney() < loan then loan = self.m_BankAccount:getMoney() end
	self:takeMoney(loan)
	return loan
end

function Faction:setRankSkin(rank,skinId)
	self.m_RankSkins[tostring(rank)] = skinId
end

function Faction:setRankWeapons(rank,weaponsTable)
	self.m_RankWeapons[tostring(rank)] = weaponsTable
end

function Faction:getRankWeapons(rank)
	return self.m_RankWeapons[tostring(rank)]
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

function Faction:sendShortMessage(text, ...)
	for k, player in ipairs(self:getOnlinePlayers()) do
		player:sendShortMessage(("%s:\n%s"):format(self:getName(), _(text, player)), ...)
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

function Faction:respawnVehicles()
	local factionVehicles = VehicleManager:getSingleton():getFactionVehicles(self.m_Id)
	for factionId, vehicle in pairs(factionVehicles) do
		if vehicle:getFaction() == self then
			vehicle:respawn()
		end
	end
end

function Faction:phoneCall(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if not player:getPhonePartner() then
			player:sendShortMessage(_("Der Spieler %s ruft eure Fraktion (%s) an!\nDrücke 'F5' um abzuheben.", player, caller:getName(), self:getName()))
			bindKey(player, "F5", "down", self.m_PhoneTakeOff, caller)
		end
	end
end

function Faction:phoneTakeOff(player, key, state, caller)
	self:sendShortMessage(_("%s hat das Telefonat von %s angenommen!", player, player:getName(), caller:getName()))
	caller:triggerEvent("callAnswer", player, voiceCall)
	player:triggerEvent("callAnswer", caller, voiceCall)
	caller:setPhonePartner(player)
	player:setPhonePartner(caller)
	for k, player in ipairs(self:getOnlinePlayers()) do
		if isKeyBound(player, "F5", "down", self.m_PhoneTakeOff) then
			unbindKey(player, "F5", "down", self.m_PhoneTakeOff)
		end
	end
end

function Faction:addLog(player, category, text)
	StatisticsLogger:getSingleton():addLog(player, "faction", self, category, text)
end
