-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupManager.lua
-- *  PURPOSE:     Group manager class
-- *
-- ****************************************************************************
GroupManager = inherit(Singleton)
GroupManager.Map = {}
GroupManager.GroupCosts = 100000
GroupManager.GroupTypes = {[1] = "Gang", [2] = "Firma"}
for i, v in pairs(GroupManager.GroupTypes) do
	GroupManager.GroupTypes[v] = i
end

function GroupManager:constructor()
	self:loadGroups()
	self.m_BankAccountServer = BankServer.get("group")
	GlobalTimer:getSingleton():registerEvent(bind(self.payDay, self), "Group Payday", nil, nil, 00) -- Every Hour

	-- Events
	addRemoteEvents{"groupRequestInfo", "groupCreate", "groupQuit", "groupDelete", "groupDeposit", "groupWithdraw", "groupAddPlayer", "groupDeleteMember", "groupInvitationAccept", "groupInvitationDecline", "groupRankUp", "groupRankDown", "groupChangeName",	"groupSaveRank", "groupConvertVehicle", "groupRemoveVehicle", "groupUpdateVehicleTuning", "groupOpenBankGui", "groupRequestBusinessInfo", "groupChangeType", "groupSetVehicleForSale", "groupBuyVehicle", "groupStopVehicleForSale", "groupToggleLoan"}

	addEventHandler("groupRequestInfo", root, bind(self.Event_RequestInfo, self))
	addEventHandler("groupCreate", root, bind(self.Event_Create, self))
	addEventHandler("groupQuit", root, bind(self.Event_Quit, self))
	addEventHandler("groupDelete", root, bind(self.Event_Delete, self))
	addEventHandler("groupDeposit", root, bind(self.Event_Deposit, self))
	addEventHandler("groupWithdraw", root, bind(self.Event_Withdraw, self))
	addEventHandler("groupAddPlayer", root, bind(self.Event_AddPlayer, self))
	addEventHandler("groupDeleteMember", root, bind(self.Event_DeleteMember, self))
	addEventHandler("groupInvitationAccept", root, bind(self.Event_InvitationAccept, self))
	addEventHandler("groupInvitationDecline", root, bind(self.Event_InvitationDecline, self))
	addEventHandler("groupRankUp", root, bind(self.Event_RankUp, self))
	addEventHandler("groupRankDown", root, bind(self.Event_RankDown, self))
	addEventHandler("groupChangeName", root, bind(self.Event_ChangeName, self))
	addEventHandler("groupSaveRank", root, bind(self.Event_SaveRank, self))
	addEventHandler("groupConvertVehicle", root, bind(self.Event_ConvertVehicle, self))
	addEventHandler("groupRemoveVehicle", root, bind(self.Event_RemoveVehicle, self))
	addEventHandler("groupUpdateVehicleTuning", root, bind(self.Event_UpdateVehicleTuning, self))
	addEventHandler("groupOpenBankGui", root, bind(self.Event_OpenBankGui, self))
	addEventHandler("groupRequestBusinessInfo", root, bind(self.Event_GetShopInfo, self))
	addEventHandler("groupSetVehicleForSale", root, bind(self.Event_SetVehicleForSale, self))
	addEventHandler("groupBuyVehicle", root, bind(self.Event_BuyVehicle, self))
	addEventHandler("groupStopVehicleForSale", root, bind(self.Event_StopVehicleForSale, self))
	addEventHandler("groupChangeType", root, bind(self.Event_ChangeType, self))
	addEventHandler("groupToggleLoan", root, bind(self.Event_ToggleLoan, self))

end

function GroupManager:destructor()
	for k, v in pairs(GroupManager.Map) do
		v:save()
		delete(v)
	end
end

function GroupManager:loadGroups()
	local st, count = getTickCount(), 0
	local result = sql:queryFetch("SELECT Id, Name, Money, Karma, lastNameChange, Type, RankNames, RankLoans, VehicleTuning FROM ??_groups", sql:getPrefix())
	for k, row in ipairs(result) do


		local result2 = sql:queryFetch("SELECT Id, GroupRank, GroupLoanEnabled FROM ??_character WHERE GroupId = ?", sql:getPrefix(), row.Id)
		local players, playerLoans = {}, {}
		for i, groupRow in ipairs(result2) do
			players[groupRow.Id] = groupRow.GroupRank
			playerLoans[groupRow.Id] = groupRow.GroupLoanEnabled
		end

		local group = Group:new(row.Id, row.Name, GroupManager.GroupTypes[row.Type], row.Money, {players, playerLoans}, row.Karma, row.lastNameChange, row.RankNames, row.RankLoans, toboolean(row.VehicleTuning))
		GroupManager.Map[row.Id] = group
		count = count + 1
	end

	if DEBUG_LOAD_SAVE then outputServerLog(("Created %s groups in %sms"):format(count, getTickCount()-st)) end
end

function GroupManager:loadFromId(Id)
	if not GroupManager.Map[Id] then
		local row = sql:queryFetchSingle("SELECT Id, Name, Money, Karma, lastNameChange, Type, RankNames, RankLoans, VehicleTuning FROM ??_groups WHERE Id = ?", sql:getPrefix(), Id)
		if row then
			local result2 = sql:queryFetch("SELECT Id, GroupRank FROM ??_character WHERE GroupId = ?", sql:getPrefix(), row.Id)
			local players = {}
			for i, groupRow in ipairs(result2) do
				players[groupRow.Id] = groupRow.GroupRank
			end
			GroupManager.Map[row.Id] = Group:new(row.Id, row.Name, GroupManager.GroupTypes[row.Type], row.Money, players, row.Karma, row.lastNameChange, row.RankNames, row.RankLoans, toboolean(row.VehicleTuning))
		end
	end
end

function GroupManager:getFromId(Id)
	return GroupManager.Map[Id]
end

function GroupManager:addRef(ref)
	GroupManager.Map[ref:getId()] = ref
end

function GroupManager:removeRef(ref)
	GroupManager.Map[ref:getId()] = nil
end

function GroupManager:getByName(groupName)
	for k, group in pairs(GroupManager.Map) do
		if group:getName() == groupName then
			return group
		end
	end
	return false
end

function GroupManager:sendInfosToClient(player)
	local group = player:getGroup()

	if group then
		local vehicles = {}
		for _, vehicle in pairs(group:getVehicles() or {}) do
			vehicles[vehicle:getId()] = {vehicle, vehicle:getPositionType()}
		end

		player:triggerEvent("groupRetrieveInfo", group:getId(), group:getName(), group:getPlayerRank(player), group:getMoney(), group:getPlayers(), group:getKarma(), group:getType(), group.m_RankNames, group.m_RankLoans, vehicles, group:canVehiclesBeModified())
		VehicleManager:getSingleton():syncVehicleInfo(player)
	else
		player:triggerEvent("groupRetrieveInfo")
	end
end

function GroupManager:Event_RequestInfo()
	self:sendInfosToClient(client)
end

function GroupManager:Event_Create(name, type)
	if client:getMoney() < GroupManager.GroupCosts then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	if client:getGroup() then
		client:sendError(_("Du bist bereits in einer Firma/Gang!", client))
		return
	end

	if string.len(name) < GROUP_NAME_MIN then
		client:sendError(_("Der Name muss mindestens 5 Zeichen lang sein!", client))
		return
	end

	if string.len(name) > GROUP_NAME_MAX then
		client:sendError(_("Dein eingegebener Name ist zu lang! (Max. 24 Zeichen)", client))
		return
	end

	if not name:match(GROUP_NAME_MATCH) then
		client:sendError(_("Name enthält ungültige Zeichen!", client))
		return
	end

	-- Does the group already exist?
	if self:getByName(name) then
		client:sendError(_("Eine Gang oder Firma mit diesem Namen existiert bereits!", client))
		return
	end

	-- Check Group Type
	if not GroupManager.GroupTypes[type] then
		client:sendError(_("Ungültiger Typ!", client))
		return false
	end
	local typeInt = GroupManager.GroupTypes[type]

	-- Create the group and the the client as leader (rank 2)
	local group = Group.create(name, typeInt)
	if group then
		client:giveAchievement(60)

		group:addPlayer(client, GroupRank.Leader)
		client:transferMoney(self.m_BankAccountServer, GroupManager.GroupCosts, "Firmen/Gang Gründung", "Group", "Creation")
		client:sendSuccess(_("Herzlichen Glückwunsch! Du bist nun Leiter der %s %s", client, type, name))
		group:addLog(client, "Gang/Firma", "hat die "..type.." "..name.." erstellt!")
		self:sendInfosToClient(client)
	else
		client:sendError(_("Interner Fehler beim Erstellen der %s", client, type))
	end
end

function GroupManager:Event_Quit()
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) == GroupRank.Leader then
		client:sendWarning(_("Als Leader kannst du nicht die %s verlassen!", client, group:getType()))
		return
	end
	group:sendMessage(_("%s hat soeben eure %s verlassen!", client, getPlayerName(client), group:getType()))
	group:addLog(client, "Gang/Firma", "hat die "..group:getType().." verlassen!")
	group:removePlayer(client)
	client:sendSuccess(_("Du hast die Firma/Gang erfolgreich verlassen!", client))
	self:sendInfosToClient(client)
end

function GroupManager:Event_Delete()
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) ~= GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt die Firma/Gang zu löschen!", client))
		-- Todo: Report possible cheat attempt
		return
  end

	local leaderCount = 0
	for i, playerRank in pairs(group.m_Players) do
		if playerRank == GroupRank.Leader then
			leaderCount = leaderCount + 1
		end
	end

  local money = group:getMoney()
  local leaderAmount = money/(1 + leaderCount)
  money = money - leaderAmount
  local memberAmount = 0
  local groupSize = table.size(group.m_Players)
  if groupSize == leaderAmount then
      leaderAmount = (leaderAmount + money)/leaderCount
  else
      memberAmount = money/(groupSize - leaderCount)
  end

	-- Distribute group's money
  for playerId, playerRank in pairs(group.m_Players) do
	local amount = memberAmount

	if playerRank == GroupRank.Leader then
		amount = leaderAmount
	end

	group:transferMoney({"player", playerId, true}, amount, "Gang/Firmen Auflösung", "Group", "Delete")
  end
  	group:addLog(client, "Gang/Firma", "hat die "..group:getType().." gelöscht!")

	client:sendShortMessage(_("Deine "..group:getType().." wurde soeben gelöscht", client))
	group:purge()
	client:triggerEvent("groupRetrieveInfo")
end

function GroupManager:Event_Deposit(amount)
	local group = client:getGroup()
	if not group then return end
	if not amount then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	client:transferMoney(group, amount, "Firmen/Gang Einzahlung", "Group", "Deposit")
	group:addLog(client, "Kasse", "hat "..toMoneyString(amount).." in die Kasse gelegt!")
	self:sendInfosToClient(client)
	group:refreshBankGui(client)
end

function GroupManager:Event_Withdraw(amount)
	local group = client:getGroup()
	if not group then return end
	if not amount then return end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getMoney() < amount then
		client:sendError(_("In der Firma/Gangkasse befindet sich nicht genügend Geld!", client))
		return
	end

	group:transferMoney(client, amount, "Firmen/Gang Auszahlung", "Group", "Deposit")
	group:addLog(client, "Kasse", "hat "..toMoneyString(amount).." aus der Kasse genommen!")

	self:sendInfosToClient(client)
	group:refreshBankGui(client)
end

function GroupManager:Event_AddPlayer(player)
	if not player then return end
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Firmen/Gang Mitglieder hinzuzufügen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if player:getGroup() then
		client:sendError(_("Dieser Benutzer ist bereits in einer Firma oder Gang!", client))
		return
	end

	if not group:isPlayerMember(player) then
		if not group:hasInvitation(player) then
			group:invitePlayer(player)
			group:addLog(client, "Gang/Firma", "hat den Spieler "..player:getName().." in die "..group:getType().." eingeladen!")
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!", client))
		end
		--group:addPlayer(player)
		--client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers(), group:getKarma())
	else
		client:sendError(_("Dieser Spieler ist bereits in deiner Firma/Gang!", client))
	end
end

function GroupManager:Event_DeleteMember(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getPlayerRank(playerId) == GroupRank.Leader then
		client:sendError(_("Du kannst den Firmen/Gang Leader nicht rauswerfen!", client))
		return
	end

	group:removePlayer(playerId)
	group:addLog(client, "Gang/Firma", "hat den Spieler "..Account.getNameFromId(playerId).." aus der "..group:getType().." geworfen!")

	self:sendInfosToClient(client)
end

function GroupManager:Event_InvitationAccept(groupId)
	local group = self:getFromId(groupId)
	if not group then return end

	if group:hasInvitation(client) then
		group:addPlayer(client)
		group:removeInvitation(client)
		group:sendMessage(_("%s ist soeben der %s beigetreten!", client, getPlayerName(client), group:getType()),200,200,200)
		group:addLog(client, "Gang/Firma", "ist der "..group:getType().." beigetreten!")
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für diese %s", client, group:getType()))
	end
end

function GroupManager:Event_InvitationDecline(groupId)
	local group = self:getFromId(groupId)
	if not group then return end

	if group:hasInvitation(client) then
		group:removeInvitation(client)
		group:sendMessage(_("%s hat die Einladung in die %s abgelehnt", client, getPlayerName(client), group:getType()))
		group:addLog(client, "Gang/Firma", "hat die Einladung abgelehnt!")

	else
		client:sendError(_("Du hast keine Einladung für diese %s", client, group:getType()))
	end
end

function GroupManager:Event_RankUp(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end

	if not group:isPlayerMember(client) or not group:isPlayerMember(playerId) then
		return
	end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getPlayerRank(playerId) < GroupRank.Leader then
		if group:getPlayerRank(playerId) < group:getPlayerRank(client:getId()) then
			group:setPlayerRank(playerId, group:getPlayerRank(playerId) + 1)
			group:addLog(client, "Gang/Firma", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..group:getPlayerRank(playerId).." befördert!")
			local player = DatabasePlayer.getFromId(playerId)
			if player and isElement(player) and player:isActive() then
				player:sendShortMessage(_("Du wurdest von %s auf Rang %d befördert!", player, client:getName(), group:getPlayerRank(playerId)), group:getName())
			end
			self:sendInfosToClient(client)
		else
			client:sendError(_("Du kannst den Spieler nicht up-ranken!", client))
		end
	else
		client:sendError(_("Du kannst Spieler nicht höher als auf Rang 6 setzen!", client))
	end
end

function GroupManager:Event_RankDown(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end

	if not group:isPlayerMember(client) or not group:isPlayerMember(playerId) then
		return
	end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getPlayerRank(playerId)-1 >= GroupRank.Normal then
		if group:getPlayerRank(client:getId()) == GroupRank.Leader or group:getPlayerRank(playerId) < group:getPlayerRank(client:getId()) then
			group:setPlayerRank(playerId, group:getPlayerRank(playerId) - 1)
			group:addLog(client, "Gang/Firma", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..group:getPlayerRank(playerId).." degradiert!")
			local player = DatabasePlayer.getFromId(playerId)
			if player and isElement(player) and player:isActive() then
				player:sendShortMessage(_("Du wurdest von %s auf Rang %d degradiert!", player, client:getName(), group:getPlayerRank(playerId)), group:getName())
			end
			self:sendInfosToClient(client)
		else
			client:sendError(_("Du kannst den Spieler nicht down-ranken!", client))
		end
	end
end

function GroupManager:Event_ChangeName(name)
	if not name then return end
	local group = client:getGroup()
	if not group then return end

	if not group:isPlayerMember(client) then
		return
	end

	if group:getPlayerRank(client) < GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Namen zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if self:getByName(name) then
		client:sendError(_("Es existiert bereits eine Firma/Gang mit diesem Namen!", client))
		return
	end

	if client:getMoney() < GROUP_RENAME_COSTS then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	if name:len() < GROUP_NAME_MIN then
		client:sendError(_("Der Name muss mindestens 5 Zeichen lang sein!", client))
		return
	end

	if name:len() > GROUP_NAME_MAX then
		client:sendError(_("Dein eingegebener Name ist zu lang! (Max. 24 Zeichen)", client))
		return
	end

	if not name:match(GROUP_NAME_MATCH) then
		client:sendError(_("Name enthält ungültige Zeichen!", client))
		return
	end

	if (getRealTime().timestamp - group.m_LastNameChange) < GROUP_RENAME_TIMEOUT then
		client:sendError(_("Du kannst deine %s nur alle %d Tage umbennen!", client, group:getType(), GROUP_RENAME_TIMEOUT/24/60/60))
		return
	end

	if group:setName(name) then
		client:transferMoney(self.m_BankAccountServer, GROUP_RENAME_COSTS, "Firmen/Gang Änderung", "Group", "Rename")
		client:sendSuccess(_("Deine %s heißt nun\n%s!", client, group:getType(), group:getName()))
		group:addLog(client, "Gang/Firma", "hat die "..group:getType().." in "..group:getName().." umbenannt!")

		self:sendInfosToClient(client)
	else
		client:sendError(_("Es ist ein unbekannter Fehler aufgetreten!", client))
	end
end

function GroupManager:Event_SaveRank(rank,name,loan)
	local group = client:getGroup()
	if group and group:getPlayerRank(client) >= GroupRank.Manager then
		group:setRankName(rank, name)
		group:setRankLoan(rank, loan)
		group:saveRankSettings()
		client:sendInfo(_("Die Einstellungen für Rang "..rank.." wurden gespeichert!", client))
		group:addLog(client, "Gang/Firma", "hat die Einstellungen für Rang "..rank.." geändert!")
		self:sendInfosToClient(client)
	end
end

function GroupManager:Event_UpdateVehicleTuning()
	local group = client:getGroup()
	--if true then -- Todo: Tuning Shop needs rework on this
	--	client:sendInfo(_("Derzeit ist dies nicht möglich!", client))
	--	return
	--end
	if group and group:getPlayerRank(client) >= GroupRank.Manager then
	--	if group:getKarma() <= -50 then
			if group:getMoney() >= 3000 then
				group:transferMoney(self.m_BankAccountServer, 3000, "Fahrzeug Tuning", "Group", "VehicleTuning")
				group.m_VehiclesCanBeModified = not group.m_VehiclesCanBeModified
				sql:queryExec("UPDATE ??_groups SET VehicleTuning = ? WHERE Id = ?", sql:getPrefix(), group.m_VehiclesCanBeModified and 1 or 0, group.m_Id)
				if group.m_VehiclesCanBeModified == true then
					client:sendInfo(_("Eure Fahrzeuge können nun getuned werden!", client))
				else
					client:sendInfo(_("Eure Fahrzeuge können nun nicht mehr getuned werden!", client))
				end
				self:sendInfosToClient(client)
			else
				client:sendError(_("Die %s hat zu wenig Geld! (3000$)", client, group:getType()))
			end
		--else
		--	client:sendError(_("Die %s hat zu wenig negatives Karma!", client, group:getType()))
		--end
	end
end

function GroupManager:Event_ConvertVehicle(veh)
	local group = client:getGroup()
	if group then
		if veh then
			if veh:getOwner() == client:getId() then
				local status, newVeh = GroupVehicle.convertVehicle(veh, group)
				if status then
					client:sendInfo(_("Das Fahrzeug ist nun im Besitz der Firma/Gang!", client))
					group:addLog(client, "Fahrzeuge", "hat das Fahrzeug "..newVeh.getNameFromModel(newVeh:getModel()).." hinzugefügt!")
					group.m_VehiclesSpawned = true
					self:sendInfosToClient(client)
				else
					client:sendError(_("Es ist ein Fehler aufgetreten!", client))
				end
			else
				client:sendError(_("Das ist nicht dein Fahrzeug!", client))
			end
		else
			client:sendError(_("Error no Vehicle!", client))
		end
	end
end

function GroupManager:Event_RemoveVehicle(veh)
	local group = client:getGroup()
	if group and veh then
		if group:getPlayerRank(client) < GroupRank.Manager then
			client:sendError(_("Dazu bist du nicht berechtigt!", client))
			return
		end

		if veh:isGroupPremiumVehicle() then
			if veh.m_Premium ~= client:getId() then
				client:sendError(_("Du kannst dieses Premium Fahrzeug nicht entfernen!", client))
				return
			end
		end

		local status, newVeh = PermanentVehicle.convertVehicle(veh, client, group)
		if status then
			client:sendInfo(_("Das Fahrzeug ist nun in deinem Besitz!", client))
			group:addLog(client, "Fahrzeuge", "hat das Fahrzeug "..newVeh.getNameFromModel(newVeh:getModel()).." entfernt!")
			self:sendInfosToClient(client)
		else
			client:sendError(_("Maximaler Fahrzeug-Slot erreicht!", client))
		end
	end
end

function GroupManager:Event_OpenBankGui()
	local group = client:getGroup()
	if group then
		group:openBankGui(client)
	end
end

function GroupManager:Event_GetShopInfo()
	local group = client:getGroup()
	if group then
		local info = {}
		for i, shop in pairs(group:getShops()) do
			table.insert(info, {id = shop:getId(), name = shop:getName(), money = shop:getMoney(), position = {shop.m_Position.x, shop.m_Position.y, shop.m_Position.z}, lastRob = shop.m_LastRob})
		end

		client:triggerEvent("groupRetriveBusinessInfo", info)
	end
end

function GroupManager:Event_SetVehicleForSale(amount)
	local group = client:getGroup()
	if source:getOccupant(0) then
		client:sendError(_("Es sitzt jemand im Fahrzeug!", client))
		return
	end
	if group and group == source:getGroup() and tonumber(amount) > 0 and tonumber(amount) <= 5000000 then
		if group:getPlayerRank(client) < GroupRank.Manager then
			client:sendError(_("Dazu bist du nicht berechtigt!", client))
			return
		end
		if source:isGroupPremiumVehicle() then
			client:sendError(_("Premium-Fahrzeuge können nicht zum Verkauf angeboten werden!", client))
			return
		end
		if getVehicleEngineState(source) then
			source:setEngineState(false)
		end
		group:addLog(client, "Fahrzeugverkauf", "hat das Fahrzeug "..source.getNameFromModel(source:getModel()).." um "..amount.." angeboten!")
		client:sendInfo(_("Du hast das Fahrzeug für %d$ angeboten!", client, amount))
		source:setForSale(true, tonumber(amount))
	end
end

function GroupManager:Event_StopVehicleForSale()
	local group = client:getGroup()
	if group and group == source:getGroup() then
		source:setForSale(false, 0)
	end
end

function GroupManager:Event_BuyVehicle()
	local group = client:getGroup()
	source:buy(client)
end

function GroupManager:Event_ChangeType()
	local group = client:getGroup()
	if group:getPlayerRank(client) < GroupRank.Leader then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end
	if group:getType() == "Firma" then
		if #group:getShops() > 0 then
			client:sendError(_("Deine Firma besitzt noch Geschäfte! Bitte verkaufe diese erst!", client))
			return
		end

		for key, vehicle in pairs(group:getVehicles() or {}) do
			if vehicle.m_ForSale == true then
				client:sendError(_("Du bietest noch Fahrzeuge zum Verkauf an! Beende diese erst!", client))
				return
			end
		end
	end
	--[[
	if #GroupPropertyManager:getSingleton():getPropsForPlayer(client) > 0 then
		client:sendError(_("Deine %s besitzt noch eine Immobilie! Bitte verkaufe diese erst!", client, group:getType()))
		return
	end
	]]

	if group:getMoney() < 20000 then
		client:sendError(_("In der Kasse befindet sich nicht genug Geld! (20.000$)", client))
		return
	end

	local oldType = group:getType()
	local newType = oldType == "Firma" and "Gang" or "Firma"
	group:transferMoney(self.m_BankAccountServer, 20000, "Typ Änderung", "Group", "TypeChange")
	group:setType(newType)
	group:addLog(client, "Gang/Firma", "hat die "..oldType.." in eine "..newType.." umgewandelt!")
	group:sendShortMessage(_("%s hat deine %s in eine %s umgewandelt!", client, client:getName(), oldType, newType))
	self:sendInfosToClient(client)

	local typeInt = GroupManager.GroupTypes[newType]
	sql:queryExec("UPDATE ??_groups SET Type = ? WHERE Id = ?", sql:getPrefix(), typeInt, group.m_Id)
end

function GroupManager:Event_ToggleLoan(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end

	if not group:isPlayerMember(client) or not group:isPlayerMember(playerId) then
		return
	end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Dazu bist du nicht berechtigt!", client))
		return
	end

	local current = group:isPlayerLoanEnabled(playerId)
	group:setPlayerLoanEnabled(playerId, current and 0 or 1)
	self:sendInfosToClient(client)

	group:addLog(client, "Gang/Firma", ("hat das Gehalt von Spieler %s %saktiviert!"):format(Account.getNameFromId(playerId), current and "de" or ""))
end

function GroupManager:payDay()
	local result = sql:queryFetch("SELECT vh.Group AS GroupId, (SELECT Category FROM ??_vehicle_model_data vmd WHERE vmd.Model = vh.Model) AS VCategory, COUNT(Id) AS Amount FROM ??_group_vehicles vh WHERE vh.Premium = 0 GROUP BY vh.`Group`, VCategory", sql:getPrefix(), sql:getPrefix())
	local groups = {}
	for k, row in pairs(result) do
		if not groups[row.GroupId] then groups[row.GroupId] = {} end
		groups[row.GroupId][row.VCategory] = row.Amount
	end

	for groupId, data in pairs(groups) do
		if GroupManager.Map[groupId] then
			GroupManager.Map[groupId]:payDay(data)
		end
	end
end
