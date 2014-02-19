-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/GroupManager.lua
-- *  PURPOSE:     Group manager class
-- *
-- ****************************************************************************
GroupManager = inherit(Singleton)
GroupManager.Map = {}
GroupManager.GroupCosts = 10000

function GroupManager:constructor()
	outputServerLog("Loading groups...")
	local result = sql:queryFetch("SELECT Id, Name, Money FROM ??_groups", sql:getPrefix())
	for k, row in ipairs(result) do
		local result2 = sql:queryFetch("SELECT Id, GroupRank FROM ??_character WHERE GroupId = ?", sql:getPrefix(), row.Id)
		local players = {}
		for i, groupRow in ipairs(result2) do
			players[groupRow.Id] = groupRow.GroupRank
		end
		
		local group = Group:new(row.Id, row.Name, row.Money, players)
		GroupManager.Map[row.Id] = group
	end
	
	-- Events
	addRemoteEvents{"groupRequestInfo", "groupCreate", "groupQuit", "groupDelete", "groupDeposit", "groupWithdraw"}
	addEventHandler("groupRequestInfo", root, bind(self.Event_groupRequestInfo, self))
	addEventHandler("groupCreate", root, bind(self.Event_groupCreate, self))
	addEventHandler("groupQuit", root, bind(self.Event_groupQuit, self))
	addEventHandler("groupDelete", root, bind(self.Event_groupDelete, self))
	addEventHandler("groupDeposit", root, bind(self.Event_groupDeposit, self))
	addEventHandler("groupWithdraw", root, bind(self.Event_groupWithdraw, self))
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

function GroupManager:Event_groupRequestInfo()
	local group = client:getGroup()
	
	if group then
		client:triggerEvent("groupRetrieveInfo", group:getName(), group:getPlayerRank(client), group:getMoney(), group:getPlayers())
	else
		client:triggerEvent("groupRetrieveInfo")
	end
end

function GroupManager:Event_groupCreate(name)
	if client:getMoney() < GroupManager.GroupCosts then
		client:sendError(_("Du hast nicht genügend Geld!", client))
		return
	end
	
	-- Create the group and the the client as leader (rank 2)
	local group = Group.create(name)
	group:addPlayer(client, GroupRank.Leader)
	client:sendSuccess(_("Herzlichen Glückwunsch! Du bist nun Leiter der Gruppe %s", client), name)
	client:triggerEvent("groupRetrieveInfo")
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
	client:triggerEvent("groupRetrieveInfo")
end

function GroupManager:Event_groupDelete()
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) ~= GroupRank.Leader then
		client:sendError(_("Du bist nicht berechtigt die Gruppe zu löschen!", client))
		-- Todo: Report possible cheat attempt
		return
	end
	
	-- Distribute group's money
	-- Todo
	
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
	
	client:takeMoney(amount)
	group:giveMoney(amount)
end

function GroupManager:Event_groupWithdraw(amount)
	local group = client:getGroup()
	if not group then return end
	
	if group:getPlayerRank(client) >= GroupRank.Manager then
		client:sendError(_("Du bist nicht berechtigt Geld abzuheben!", client))
		-- Todo: Report possible cheat attempt
		return
	end
	
	if group:getMoney() < amount then
		client:sendError(_("In der Gruppenkasse befindet sich nicht genügend Geld!", client))
		return
	end
	
	group:takeMoney(amount)
	client:giveMoney(amount)
end
