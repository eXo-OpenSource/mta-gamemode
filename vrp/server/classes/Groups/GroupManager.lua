-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupManager.lua
-- *  PURPOSE:     Group manager class
-- *
-- ****************************************************************************
GroupManager = inherit(Singleton)
GroupManager.Map = {}
GroupManager.GroupCosts = 20000
GroupManager.GroupTypes = {[0] = "Gang", [1] = "Firma"}

function GroupManager:constructor()
	outputServerLog("Loading groups...")
	local result = sql:queryFetch("SELECT Id, Name, Money, Karma, lastNameChange, Type, RankNames, RankLoans FROM ??_groups", sql:getPrefix())
	for k, row in ipairs(result) do


		local result2 = sql:queryFetch("SELECT Id, GroupRank FROM ??_character WHERE GroupId = ?", sql:getPrefix(), row.Id)
		local players = {}
		for i, groupRow in ipairs(result2) do
			players[groupRow.Id] = groupRow.GroupRank
		end

		local group = Group:new(row.Id, row.Name, row.Money, players, row.Karma, row.lastNameChange, row.RankNames, row.RankLoans, self.GroupTypes[row.Type])
		GroupManager.Map[row.Id] = group
	end

	-- Events
	addRemoteEvents{"groupRequestInfo", "groupRequestLog", "groupCreate", "groupQuit", "groupDelete", "groupDeposit", "groupWithdraw",
		"groupAddPlayer", "groupDeleteMember", "groupInvitationAccept", "groupInvitationDecline", "groupRankUp", "groupRankDown", "groupChangeName", "groupSaveRank", "groupConvertVehicle"}
	addEventHandler("groupRequestInfo", root, bind(self.Event_groupRequestInfo, self))
	addEventHandler("groupRequestLog", root, bind(self.Event_groupRequestLog, self))
	addEventHandler("groupCreate", root, bind(self.Event_groupCreate, self))
	addEventHandler("groupQuit", root, bind(self.Event_groupQuit, self))
	addEventHandler("groupDelete", root, bind(self.Event_groupDelete, self))
	addEventHandler("groupDeposit", root, bind(self.Event_groupDeposit, self))
	addEventHandler("groupWithdraw", root, bind(self.Event_groupWithdraw, self))
	addEventHandler("groupAddPlayer", root, bind(self.Event_groupAddPlayer, self))
	addEventHandler("groupDeleteMember", root, bind(self.Event_groupDeleteMember, self))
	addEventHandler("groupInvitationAccept", root, bind(self.Event_groupInvitationAccept, self))
	addEventHandler("groupInvitationDecline", root, bind(self.Event_groupInvitationDecline, self))
	addEventHandler("groupRankUp", root, bind(self.Event_groupRankUp, self))
	addEventHandler("groupRankDown", root, bind(self.Event_groupRankDown, self))
	addEventHandler("groupChangeName", root, bind(self.Event_groupChangeName, self))
	addEventHandler("groupSaveRank", root, bind(self.Event_groupSaveRank, self))
	addEventHandler("groupConvertVehicle", root, bind(self.Event_groupConvertVehicle, self))


end

function GroupManager:destructor()
	for k, v in pairs(GroupManager.Map) do
		delete(v)
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

function GroupManager:Event_groupRequestLog()
	local group = client:getGroup()
	if group then
		client:triggerEvent("groupRetrieveLog", group:getPlayers(), group:getLog())
	end
end

function GroupManager:sendInfosToClient(player)
	local group = player:getGroup()

	if group then
		player:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(player), group:getMoney(), group:getPlayers(), group:getKarma(), group:getType(), group.m_RankNames, group.m_RankLoans, group:getVehicles())
		VehicleManager:getSingleton():syncVehicleInfo(player)
	else
		player:triggerEvent("groupRetrieveInfo")
	end
end

function GroupManager:Event_groupRequestInfo()
	self:sendInfosToClient(client)
end

function GroupManager:Event_groupCreate(name,type)
	if client:getMoney() < GroupManager.GroupCosts then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	-- Does the group already exist?
	if self:getByName(name) then
		client:sendError(_("Eine Gang oder Firma mit diesem Namen existiert bereits!", client))
		return
	end

	-- Check Group Type
	for i, v in pairs(GroupManager.GroupTypes) do
		GroupManager.GroupTypes[v] = i
	end
	local typeInt = self.GroupTypes[type]
	if not typeInt then
		client:sendError(_("Ungültiger Typ!", client))
		return false
	end

	-- Create the group and the the client as leader (rank 2)
	local group = Group.create(name,typeInt)
	if group then
		group:addPlayer(client, GroupRank.Leader)
		client:takeMoney(GroupManager.GroupCosts, "Firmen/Gang Gründung")
		client:sendSuccess(_("Herzlichen Glückwunsch! Du bist nun Leiter der %s %s", client, type, name))
		group:addLog(client, "Gang/Firma", "hat die "..self.GroupTypes[type].." "..name.." erstellt!")
		self:sendInfosToClient(client)
	else
		client:sendError(_("Interner Fehler beim Erstellen der %s", client, type))
	end
end

function GroupManager:Event_groupQuit()
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) == GroupRank.Leader then
		client:sendWarning(_("Bitte übertrage den Leiter-Status erst auf ein anderes Mitglied der Gruppe!", client))
		return
	end
	group:removePlayer(client)
	client:sendSuccess(_("Du hast die Gruppe erfolgreich verlassen!", client))
	group:addLog(client, "Gang/Firma", "hat die Gang/Firma verlassen!")
	self:sendInfosToClient(client)
end

function GroupManager:Event_groupDelete()
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) ~= GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt die Gruppe zu löschen!", client))
		-- Todo: Report possible cheat attempt
		return
  end

	local leaderCount = 0
	for i, playerRank in pairs(group.m_Players) do
		if playerRank == GroupRank.Leader then
			leaderCount = leaderCount + 1
		end
	end

  local leaderAmount = group.m_Money/(1 + leaderCount)
  group.m_Money = group.m_Money - leaderAmount
  local memberAmount = 0
  local groupSize = table.size(group.m_Players)
  if groupSize == leaderAmount then
      leaderAmount = (leaderAmount + group.m_Money)/leaderCount
  else
      memberAmount = group.m_Money/(groupSize - leaderCount)
  end

	-- Distribute group's money
  for playerId, playerRank in pairs(group.m_Players) do
      local player, isOffline = DatabasePlayer.get(playerId)
      if playerRank == GroupRank.Leader then
          player:giveMoney(leaderAmount, "Gang/Firmen Auflösung")
      else
          player:giveMoney(memberAmount, "Gang/Firmen Auflösung")
      end

      if isOffline then
          delete(player)
      end
  end
  	group:addLog(client, "Gang/Firma", "hat die Gang/Firma gelöscht!")
	group:purge()
	client:sendShortMessage(_("Deine Gruppe wurde soeben gelöscht", client))

	client:triggerEvent("groupRetrieveInfo")
end

function GroupManager:Event_groupDeposit(amount)
	local group = client:getGroup()
	if not group then return end

	if client:getMoney() < amount then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	client:takeMoney(amount, "Firmen/Gang Einzahlung")
	group:giveMoney(amount, "Firmen/Gang Auszahlung")
	group:addLog(client, "Kasse", "hat "..amount.."$ in die Kasse gelegt!")
	self:sendInfosToClient(client)
end

function GroupManager:Event_groupWithdraw(amount)
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getMoney() < amount then
		client:sendError(_("In der Gruppenkasse befindet sich nicht genügend Geld!", client))
		return
	end

	group:takeMoney(amount, "Firmen/Gang Auszahlung")
	client:giveMoney(amount, "Firmen/Gang Auszahlung")
	group:addLog(client, "Kasse", "hat "..amount.."$ aus der Kasse genommen!")

	self:sendInfosToClient(client)
end

function GroupManager:Event_groupAddPlayer(player)
	if not player then return end
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Gruppenmitglieder hinzuzufügen!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if player:getGroup() then
		client:sendError(_("Dieser Benutzer ist bereits in einer Gruppe!", client))
		return
	end

	if not group:isPlayerMember(player) then
		if not group:hasInvitation(player) then
			group:invitePlayer(player)
			group:addLog(client, "Gang/Firma", "hat den Spieler "..player:getName().." in die Gang/Firma eingeladen!")
		else
			client:sendError(_("Dieser Benutzer hat bereits eine Einladung!", client))
		end
		--group:addPlayer(player)
		--client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers(), group:getKarma())
	else
		client:sendError(_("Dieser Spieler ist bereits in der Gruppe!", client))
	end
end

function GroupManager:Event_groupDeleteMember(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end

	if group:getPlayerRank(client) < GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getPlayerRank(playerId) == GroupRank.Leader then
		client:sendError(_("Du kannst den Gruppenleiter nicht rauswerfen!", client))
		return
	end

	group:removePlayer(playerId)
	group:addLog(client, "Gang/Firma", "hat den Spieler "..Account.getNameFromId(playerId).." aus der Gang/Firma geworfen!")

	self:sendInfosToClient(client)
end

function GroupManager:Event_groupInvitationAccept(groupId)
	local group = self:getFromId(groupId)
	if not group then return end

	if group:hasInvitation(client) then
		group:addPlayer(client)
		group:removeInvitation(client)
		group:sendMessage(_("%s ist soeben der Gruppe beigetreten", client, getPlayerName(client)))
		group:addLog(client, "Gang/Firma", "ist der Gang/Firma beigetreten!")
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du hast keine Einladung für diese Gruppe", client))
	end
end

function GroupManager:Event_groupInvitationDecline(groupId)
	local group = self:getFromId(groupId)
	if not group then return end

	if group:hasInvitation(client) then
		group:removeInvitation(client)
		group:sendMessage(_("%s hat die Gruppeneinladung abgelehnt", client, getPlayerName(client)))
		group:addLog(client, "Gang/Firma", "hat die Einladung abgelehnt!")

	else
		client:sendError(_("Du hast keine Einladung für diese Gruppe", client))
	end
end

function GroupManager:Event_groupRankUp(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end

	if not group:isPlayerMember(client) or not group:isPlayerMember(playerId) then
		return
	end

	if group:getPlayerRank(client) < GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getPlayerRank(playerId) < GroupRank.Manager then
		group:setPlayerRank(playerId, group:getPlayerRank(playerId) + 1)
		group:addLog(client, "Gang/Firma", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..group:getPlayerRank(playerId).." befördert!")
		self:sendInfosToClient(client)
	else
		client:sendError(_("Du kannst Spieler nicht höher als auf Rang 'Manager' setzen!", client))
	end
end

function GroupManager:Event_groupRankDown(playerId)
	if not playerId then return end
	local group = client:getGroup()
	if not group then return end

	if not group:isPlayerMember(client) or not group:isPlayerMember(playerId) then
		return
	end

	if group:getPlayerRank(client) < GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Rang zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if group:getPlayerRank(playerId) == GroupRank.Manager then
		group:setPlayerRank(playerId, group:getPlayerRank(playerId) - 1)
		group:addLog(client, "Gang/Firma", "hat den Spieler "..Account.getNameFromId(playerId).." auf Rang "..group:getPlayerRank(playerId).." degradiert!")
		self:sendInfosToClient(client)
	end
end

function GroupManager:Event_groupChangeName(name)
	if not name then return end
	local group = client:getGroup()
	if not group then return end
	local name = name:gsub(" ", "")

	if not group:isPlayerMember(client) then
		return
	end

	if group:getPlayerRank(client) < GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt den Namen zu verändern!", client))
		-- Todo: Report possible cheat attempt
		return
	end

	if self:getByName(name) then
		client:sendError(_("Es existiert bereits eine Gruppe mit diesem Namen!", client))
		return
	end

	if client:getMoney() < 20000 then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end

	if name:len() < 5 then
		client:sendError(_("Der Name muss mindestens 5 Zeichen lang sein!", client))
		return
	end

	if name:len() > 20 then
		client:sendError(_("Der Name darf nicht länger als 20 Zeichen sein!", client))
		return
	end


	if (getRealTime().timestamp - group.m_LastNameChange) < GROUP_RENAME_TIMEOUT then
		client:sendError(_("Du kannst deine Gruppe nur alle "..(GROUP_RENAME_TIMEOUT/24/60/60).." Tage umbennen!", client))
		return
	end

	if group:setName(name) then
		client:takeMoney(20000, "Firmen/Gang Änderung")
		client:sendSuccess(_("Deine Gruppe heißt nun\n%s!", client, group:getName()))
		group:addLog(client, "Gang/Firma", "hat die Gang Firma in "..group:getName().." umbenannt!")

		self:sendInfosToClient(client)
	else
		client:sendError(_("Es ist ein unbekannter Fehler aufgetreten!", client))
	end
end

function GroupManager:Event_groupSaveRank(rank,name,loan)
	local group = client:getGroup()
	if group then
		group:setRankName(rank,name)
		group:setRankLoan(rank,loan)
		group:saveRankSettings()
		client:sendInfo(_("Die Einstellungen für Rang "..rank.." wurden gespeichert!", client))
		group:addLog(client, "Gang/Firma", "hat die Einstellungen für Rang "..rank.." geändert!")
		self:sendInfosToClient(client)
	end
end

function GroupManager:Event_groupConvertVehicle(veh)
	local group = client:getGroup()
	if group then
		if veh then
			if veh:getOwner() == client:getId() then
				local status, newVeh = GroupVehicle.convertVehicle(veh, group)
				if status then
					client:sendInfo(_("Das Fahrzeug ist nun im Besitz der Firma/Gang!", client))
					group:addLog(client, "Fahrzeuge", "hat das Fahrzeug "..newVeh.getNameFromModel(newVeh:getModel()).." hinzugefügt!")
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
