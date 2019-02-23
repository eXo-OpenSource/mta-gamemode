-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ServiceSync.lua
-- *  PURPOSE:     ServiceSync class
-- *
-- ****************************************************************************
ServiceSync = inherit(Singleton)

--[[
	Async.create(function() ServiceSync:getSingleton():syncPlayer(4123) end)()
	Async.create(function() ServiceSync:getSingleton():syncAllUsers() end)()
]]


function ServiceSync:constructor()
	self:load()
	self.m_ForumGroups = {}
	self.m_ForumGroupMembers = {}

	Async.create(function()
		self:loadGroupNames()
		self:syncAllUsers(nil, "premium")
	end)()
end

function ServiceSync:destructor()
end

function ServiceSync:loadGroupNames()
	for _, base in pairs(self.m_Data["forumGroups"]) do
		for _, factionOrCompany in pairs(base) do
			for _, group in pairs(factionOrCompany) do
				self.m_ForumGroups[group] = "Unknown"
				self.m_ForumGroupMembers[group] = {}
			end
		end
	end

	for id, name in pairs(self.m_ForumGroups) do
		Forum:getSingleton():groupGet(id, Async.waitFor(self))
		local result = Async.wait()
		local data = fromJSON(result)

		if data and data.status == 200 then
			self.m_ForumGroups[id] = data.data.groupName
			self.m_ForumGroupMembers[id] = data.data.members
		end
	end
end


--[[
	ALTER TABLE `vrp_factions` ADD COLUMN `ForumGroups` text NULL AFTER `Permissions`;
	ALTER TABLE `vrp_companies` ADD COLUMN `ForumGroups` text NULL AFTER `Permissions`;
]]
function ServiceSync:load()
	self.m_Data = {}

	self.m_Data["faction"] = {}
	self.m_Data["company"] = {}
	self.m_Data["automaticGroups"] = {}
	self.m_Data["automaticGroups"]["forum"] = {}
	self.m_Data["automaticGroups"]["teamspeak"] = {}

	self.m_Data["forumGroups"] = {}
	self.m_Data["forumGroups"]["faction"] = {}
	self.m_Data["forumGroups"]["company"] = {}

	self.m_Data["premiumGroup"] = -1

	if ServerSettings:getSingleton().m_Settings["PremiumGroup"] then
		self.m_Data["premiumGroup"] = tonumber(ServerSettings:getSingleton().m_Settings["PremiumGroup"])
		table.insert(self.m_Data["automaticGroups"]["forum"], self.m_Data["premiumGroup"])
	end

	local result = sql:queryFetch("SELECT Id, 'faction' AS Type, Name, ServiceSync, ForumGroups FROM ??_factions UNION ALL SELECT Id, 'company' AS Type, Name, ServiceSync, ForumGroups FROM ??_companies", sql:getPrefix(), sql:getPrefix())

	for _, v in pairs(result) do
		local permissions = v.ServiceSync and fromJSON(v.ServiceSync) or {}
		local forumGroups = v.ForumGroups and fromJSON(v.ForumGroups) or {}
		self:register(v.Type, v.Id, permissions)

		for _, group in pairs(forumGroups) do
			if not self.m_Data["forumGroups"][v.Type][v.Id] then
				self.m_Data["forumGroups"][v.Type][v.Id] = {}
			end

			table.insert(self.m_Data["forumGroups"][v.Type][v.Id], group)
		end
	end
end

--[[
CREATE VIEW view_AccountGroups AS SELECT
		ac.Id,
		ac.ForumID,
		ch.FactionId,
		ch.FactionRank,
		ch.CompanyId,
		ch.CompanyRank,
		pu.premium_bis
	FROM
		vrp_account ac
	INNER JOIN vrp_character ch ON ch.Id = ac.Id
	INNER JOIN vrp_public_premium.user pu ON pu.UserId = ac.Id;


	SELECT
		ac.Id,
		ac.ForumID,
		ch.FactionId,
		ch.FactionRank,
		ch.CompanyId,
		ch.CompanyRank,
		pu.premium_bis
	FROM
		vrp_account ac
	INNER JOIN vrp_character ch ON ch.Id = ac.Id
	INNER JOIN vrp_public_premium.user pu ON pu.UserId = ac.Id
	WHERE
		ch.FactionId <> 0 OR ch.CompanyId <> 0 OR pu.premium_bis > UNIX_TIMESTAMP(NOW())
]]


--[[
	factionOrCompany - faction or company
	id   - factionId or companyId
	data = {
		forum: {
			rank: {
				[0] = [1, 2],
				[1] = [1, 2],
				[2] = [1, 2],
				[3] = [1, 2],
				[4] = [1, 2],
				[5] = [1, 2],
				[6] = [1, 2]
			},
			onlyRemove: [12, 31]
		},
		teamspeak: {
			TBD
		}
	}

	[ { "forum": { "ranks": { "0": 48, "1": 46, "2": 46, "3": 46, "4": 46, "5": [46, 47], "6": [46, 47] }, "removeOnLeave": 43 }, "teamspeak": { } } ]
]]
function ServiceSync:register(factionOrCompany, id, data)
	if factionOrCompany ~= "faction" and factionOrCompany ~= "company" then
		error("Invalid value for parameter 'factionOrCompany' value " .. factionOrCompany .. " @ ServiceSync:register")
	end

	self.m_Data[factionOrCompany][id] = data

	for k, v in pairs(data) do
		if v["ranks"] then
			for _, groups in pairs(v["ranks"]) do
				local groups = type(groups) == "number" and {groups} or groups
				for _, group in pairs(groups) do
					table.insertUnique(self.m_Data["automaticGroups"][k], group)
				end
			end
		end

		if v["removeOnLeave"] then
			local groups = type(v["removeOnLeave"]) == "number" and {v["removeOnLeave"]} or v["removeOnLeave"]
			for _, group in pairs(groups) do
				table.insertUnique(self.m_Data["automaticGroups"][k], group)
			end
		end
	end
end

function ServiceSync:syncAllUsers(player, syncType, id)
	if syncType then
		if syncType == "premium" then
			sql:queryFetch(Async.waitFor(), "SELECT * FROM view_AccountGroups WHERE premium_bis > UNIX_TIMESTAMP(NOW())")
		elseif syncType == "faction" then
			sql:queryFetch(Async.waitFor(), "SELECT * FROM view_AccountGroups WHERE FactionId = ?", id)
		elseif syncType == "company" then
			sql:queryFetch(Async.waitFor(), "SELECT * FROM view_AccountGroups WHERE CompanyId = ?", id)
		else
			error("Invalid value for parameter 'syncType' value " .. syncType .. " @ ServiceSync:syncAllUsers")
		end
	else
		sql:queryFetch(Async.waitFor(), "SELECT * FROM view_AccountGroups WHERE FactionId <> 0 OR CompanyId <> 0 OR premium_bis > UNIX_TIMESTAMP(NOW())")
	end

	local rows = Async.wait()

	local groups = {}

	for _, user in ipairs(rows) do
		local userGroups = self:checkGroups(user.FactionId, user.FactionRank, user.CompanyId, user.CompanyRank, user.premium_bis > getRealTime().timestamp)

		for _, group in ipairs(userGroups.forum.must) do
			if not groups[group] then groups[group] = { must = {}, can = {} } end
			table.insert(groups[group].must, user.ForumID)
		end

		for _, group in ipairs(userGroups.forum.can) do
			if not groups[group] then groups[group] = { must = {}, can = {} } end
			table.insert(groups[group].can, user.ForumID)
		end
	end

	local groupIds = {}

	if syncType == nil then
		groupIds = self.m_Data["automaticGroups"]["forum"]
	elseif syncType == "premium" then
		groupIds = {self.m_Data["premiumGroup"]}
	elseif syncType == "faction" then
		for _, groups in pairs(self.m_Data["faction"][id]["forum"]["ranks"]) do
			if type(groups) == "table" then
				for _, v in pairs(groups) do
					table.insertUnique(groupIds, v)
				end
			else
				table.insertUnique(groupIds, groups)
			end
		end
	elseif syncType == "company" then
		for _, groups in pairs(self.m_Data["company"][id]["forum"]["ranks"]) do
			if type(groups) == "table" then
				for _, v in pairs(groups) do
					table.insertUnique(groupIds, v)
				end
			else
				table.insertUnique(groupIds, groups)
			end
		end
	end

	local addedCount = 0
	local removedCount = 0

	for _, groupId in ipairs(groupIds) do
		if groups[groupId] then
			Forum:getSingleton():groupGet(groupId, Async.waitFor(self))
			local result = Async.wait()
			local data = fromJSON(result)

			if data and data.status == 200 then
				local currentGroupUsers = {}
				local requiredChanges = {
					add = {},
					remove = {}
				}

				self.m_ForumGroupMembers[groupId] = data.data.members

				for _, member in pairs(data.data.members) do
					table.insert(currentGroupUsers, member.userID)
				end

				-- Check removals
				for _, userId in ipairs(currentGroupUsers) do
					if not table.find(groups[groupId].must, userId) and not table.find(groups[groupId].can,  userId) then
						table.insert(requiredChanges.remove, userId)
					end
				end

				for _, userId in ipairs(groups[groupId].must) do
					if not table.find(currentGroupUsers, userId) then
						table.insert(requiredChanges.add, userId)
					end
				end

				if #requiredChanges.remove > 0 then
					Forum:getSingleton():groupRemoveMember(requiredChanges.remove, groupId, Async.waitFor(self))
					local data = Async.wait()

					if data and data.status == 200 then
						self.m_ForumGroupMembers[groupId] = data.data.members
					end
				end

				if #requiredChanges.add > 0 then
					Forum:getSingleton():groupAddMember(requiredChanges.add, groupId, Async.waitFor(self))
					local data = Async.wait()

					if data and data.status == 200 then
						self.m_ForumGroupMembers[groupId] = data.data.members
					end
				end

				addedCount = addedCount + #requiredChanges.add
				removedCount = removedCount + #requiredChanges.remove
			end
		end
	end


	if player then
		player:sendSuccess(_("Es wurden "..tostring(addedCount).."x eine Gruppe hinzugefügt und "..tostring(removedCount).."x eine Gruppe entfernt!", player))
	end
end

function ServiceSync:syncPlayer(player)
	local player = isElement(player) and playerId.m_Id or player

	local factionId = 0
	local factionRank = 0
	local companyId = 0
	local companyRank = 0
	local premium = false

	sql:queryFetchSingle(Async.waitFor(), "SELECT * FROM view_AccountGroups WHERE Id = ?", player)
	local row = Async.wait()

	if row then -- due to view not getting any results on local databases
		factionId = row.FactionId
		factionRank = row.FactionRank
		companyId = row.CompanyId
		companyRank = row.CompanyRank
		premium = row.premium_bis > getRealTime().timestamp

		return self:syncUser(row.ForumID, factionId, factionRank, companyId, companyRank, premium) ~= false
	end
end

function ServiceSync:calculateChanges(groups, forumGroups, teamspeakGroups)
	local changes = {
		forum = {
			add = {},
			remove = {}
		},
		teamspeak = { -- TODO: How to make it on channel basis?
			add = {},
			remove = {}
		}
	}

	-- Calculate required removals
	for _, group in pairs(self.m_Data["automaticGroups"]["forum"]) do
		if table.find(forumGroups, group) then -- can he have the group?
			if not table.find(groups.forum.must, group) and not table.find(groups.forum.can, group) then
				table.insert(changes.forum.remove, group)
			end
		end
	end

	for _, group in pairs(groups.forum.must) do
		if not table.find(forumGroups, group) then
			table.insert(changes.forum.add, group)
		end
	end

	return changes
end

function ServiceSync:syncUser(forumId, factionId, factionRank, companyId, companyRank, premium)
	local groups = self:checkGroups(factionId, factionRank, companyId, companyRank, premium)

	Forum:getSingleton():userGet(forumId, Async.waitFor(self))
	local result = Async.wait()
	local data = fromJSON(result)

	local forumGroups = {}

	if data and data.status == 200 then
		for _, v in pairs(data.data.groups) do
			table.insert(forumGroups, v.groupID)
		end
	else
		return false
	end

	local teamspeakGroups = {} -- TODO

	local changes = self:calculateChanges(groups, forumGroups, teamspeakGroups)

	for _, groupId in ipairs(changes.forum.remove) do
		Forum:getSingleton():groupRemoveMember(forumId, groupId, Async.waitFor(self))
		local result = Async.wait()
		local data = fromJSON(result)

		if data and data.status == 200 then
			self.m_ForumGroupMembers[groupId] = data.data.members
		end
	end

	for _, groupId in ipairs(changes.forum.add) do
		Forum:getSingleton():groupAddMember(forumId, groupId, Async.waitFor(self))
		local result = Async.wait()
		local data = fromJSON(result)

		if data and data.status == 200 then
			self.m_ForumGroupMembers[groupId] = data.data.members
		end
	end

	return changes
end

function ServiceSync:checkGroups(factionId, factionRank, companyId, companyRank, premium)
	local resultGroups = {
		forum = {
			must = {},
			can = {}
		},
		teamspeak = {
			must = {},
			can = {}
		}
	}

	if factionId ~= 0 then
		if self.m_Data["faction"][factionId] then
			for k, v in pairs(self.m_Data["faction"][factionId]) do
				if v["ranks"] then
					local groups = v["ranks"][tostring(factionRank)]
					groups = type(groups) == "number" and {groups} or groups

					for _, group in ipairs(groups) do
						table.insertUnique(resultGroups[k].must, group)
					end
				end

				if v["removeOnLeave"] then
					local groups = type(v["removeOnLeave"]) == "number" and {v["removeOnLeave"]} or v["removeOnLeave"]
					for _, group in pairs(groups) do
						table.insertUnique(resultGroups[k].can, group)
					end
				end
			end
		end
	end

	if companyId ~= 0 then
		if self.m_Data["company"][companyId] then
			for k, v in pairs(self.m_Data["company"][companyId]) do
				if v["ranks"] then
					local groups = v["ranks"][tostring(companyRank)]
					groups = type(groups) == "number" and {groups} or groups

					for _, group in ipairs(groups) do
						table.insertUnique(resultGroups[k].must, group)
					end
				end

				if v["removeOnLeave"] then
					local groups = type(v["removeOnLeave"]) == "number" and {v["removeOnLeave"]} or v["removeOnLeave"]
					for _, group in pairs(groups) do
						table.insertUnique(resultGroups[k].can, group)
					end
				end
			end
		end
	end

	if premium then
		if self.m_Data["premiumGroup"] > 0 then
			table.insert(resultGroups.forum.must, self.m_Data["premiumGroup"])
		end
	end

	return resultGroups
end
