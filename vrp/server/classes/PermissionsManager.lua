-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/PermissionsManager.lua
-- *  PURPOSE:     permission manager
-- *
-- ****************************************************************************
PermissionsManager = inherit(Singleton)

addRemoteEvents{"requestRankPermissionsList", "requestPlayerPermissionsList", "changeRankPermissions", "changePlayerPermissions", "syncPermissions"}
function PermissionsManager:constructor()
	self.m_Types = {["faction"] = 1, ["company"] = 2, ["group"] = 3}
	self.m_LeaderRank = {["faction"] = 6, ["company"] = 5, ["group"] = 6}

	addEventHandler("requestRankPermissionsList", root, bind(self.Event_requestRankPermissionsList, self))
	addEventHandler("requestPlayerPermissionsList", root, bind(self.Event_requestPlayerPermissionsList, self))
	addEventHandler("changeRankPermissions", root, bind(self.Event_changeRankPermissions, self))
	addEventHandler("changePlayerPermissions", root, bind(self.Event_changePlayerPermissions, self))
	addEventHandler("syncPermissions", root, bind(self.syncPermissions, self))
	setTimer(function() self:checkForNewPermissions() end, 5000, 1)
	setTimer(function() self:checkForNewActions() end, 5000, 1)
end

function PermissionsManager:createRankPermissions(type, id, rank)
	local temp = {}
	local state = false

	if rank == self.m_LeaderRank[type] then
		state = true
	end

	for permission, info in pairs(PERMISSIONS_INFO) do
		if info[1][1] == 0 or (info[1][1] == self.m_Types[type] and table.find(info[1][2], id)) then
			if info[2][type] then
				temp[permission] = state
			end
		end
	end
	return temp 
end

function PermissionsManager:createRankActions(type, id, rank)
	local temp = {}

	for permission, info in pairs(ACTION_PERMISSIONS_INFO) do
		if info[1][1] == 0 or (info[1][1] == self.m_Types[type] and table.find(info[1][2], id)) then
			if info[2][type] then
				temp[permission] = true
			end
		end
	end
	return temp 
end

function PermissionsManager:Event_requestRankPermissionsList(permissionsType, type, sendTo)
	if not client then client = sendTo end
	if not self:getInstance(client, type) then return end
	
	local temp = {}	
	local instance = self:getInstance(client, type)
	
	if permissionsType == "permission" and type then
		if not self:hasPlayerPermissionsTo(client, type, "changePermissions") then 
			client:sendError(_("Du bist nicht berechtigt die Rechte zu verändern!", client))
			return 
		end
		
		temp = instance.m_RankPermissions
	elseif permissionsType == "action" and type then
		if not self:hasPlayerPermissionsTo(client, type, "editActionPermissions") then 
			client:sendError(_("Du bist nicht berechtigt die Aktionsrechte zu verändern!", client))
			return 
		end

		temp = instance.m_RankActions
	end

	client:triggerEvent("showRankPermissionsList", temp, type)
end

function PermissionsManager:Event_requestPlayerPermissionsList(permissionsType, type, playerId, sendTo)
	if not client then client = sendTo end
	if not self:getInstance(client, type) then return end
	
	local temp = {}	
	local instance = self:getInstance(client, type)
	local rank = instance:getPlayerRank(playerId)

	if permissionsType == "permission" and type and rank then
		if not self:hasPlayerPermissionsTo(client, type, "changePermissions") then 
			client:sendError(_("Du bist nicht berechtigt die Rechte zu verändern!", client))
			return 
		end
		if not instance:isPlayerMember(playerId) then return end
		
		local rankPerm = instance.m_RankPermissions[tostring(rank)]
		local playerPerm = instance.m_PlayerPermissions[tonumber(playerId)]
		
		for name, state in pairs(rankPerm) do
			if rank >= PERMISSIONS_INFO[name][2][type] then
				temp[name] = (playerPerm[name] == true and true) or (playerPerm[name] == nil and "default") or false
			end
		end
	elseif permissionsType == "action" and type and rank then
		if not self:hasPlayerPermissionsTo(client, type, "editActionPermissions") then 
			client:sendError(_("Du bist nicht berechtigt die Aktionsrechte zu verändern!", client))
			return 
		end
		if not instance:isPlayerMember(playerId) then return end

		local rankPerm = instance.m_RankActions[tostring(rank)]
		local playerPerm = instance.m_PlayerActionPermissions[tonumber(playerId)]

		for name, state in pairs(rankPerm) do
			if rank >= ACTION_PERMISSIONS_INFO[name][2][type] then
				temp[name] = (playerPerm[name] == true and true) or (playerPerm[name] == nil and "default") or false
			end
		end
	elseif permissionsType == "weapon" and type and rank then
		if not self:hasPlayerPermissionsTo(client, type, "editWeaponPermissions") then 
			client:sendError(_("Du bist nicht berechtigt die Waffenrechte zu verändern!", client))
			return 
		end
		if not instance:isPlayerMember(playerId) then return end
		
		local weapons = table.copy(instance.m_ValidWeapons)

		if instance:isEvilFaction() then
			for i, v in pairs(factionWeaponDepotInfo) do
				if v["Waffe"] ~= 0 then
					weapons[i] = true
				end
			end
		end

		local playerPerm = instance.m_PlayerWeaponPermissions[tonumber(playerId)]
		
		for id, state in pairs(weapons) do
			temp[id] = (playerPerm[tostring(id)] == true and true) or (playerPerm[tostring(id)] == nil and "default") or false
		end
	end

	client:triggerEvent("showPlayerPermissionsList", temp, permissionsType)
end

function PermissionsManager:Event_changeRankPermissions(permissionsType, tbl, type)
	if not self:getInstance(client, type) then return end
	if table.size(tbl) == 0 then return end
	local instance = self:getInstance(client, type)
	local error = false

	if permissionsType == "permission" then
		if not self:hasPlayerPermissionsTo(client, type, "changePermissions") then
			client:sendError(_("Du bist nicht berechtigt die Rechte zu verändern!", client))
			return 
		end

		for rank, info in pairs(tbl) do
			if rank == self.m_LeaderRank[type] or rank > instance:getPlayerRank(client) then 
				client:sendError(_("Du kannst die Rechte von Rang %s nicht verändern.", client, rank))
				error = true
			else
				for name, state in pairs(info) do
					if rank >= PERMISSIONS_INFO[name][2][type] then
						instance.m_RankPermissions[tostring(rank)][name] = state
					else
						error = true
					end
				end
			end
		end
						
		if type == "group" then
			instance:saveRankSettings()
		end
	elseif permissionsType == "action" then
		if not self:hasPlayerPermissionsTo(client, type, "editActionPermissions") then 
			client:sendError(_("Du bist nicht berechtigt die Aktionsrechte zu verändern!", client)) 
			return 
		end

		for rank, info in pairs(tbl) do
			if rank == self.m_LeaderRank[type] or rank > instance:getPlayerRank(client) then 
				client:sendError(_("Du kannst die Aktionsrechte von Rang %s nicht verändern.", client, rank))
				error = true
			else
				for name, state in pairs(info) do
					if rank >= ACTION_PERMISSIONS_INFO[name][2][type] then
						instance.m_RankActions[tostring(rank)][name] = state
					else
						error = true
					end
				end
			end
		end
	end

	for i, player in pairs(instance:getOnlinePlayers()) do
		self:syncPermissions(player, type)
	end

	local text = error and "Einige Rechte konnten nicht geändert werden." or "Rechte erfolgreich geändert."
	client:sendInfo(_("%s", client, text))
	self:addLog(instance, client, permissionsType)

	self:Event_requestRankPermissionsList(permissionsType, type, client)
end

function PermissionsManager:Event_changePlayerPermissions(permissionsType, tbl, type, playerId)
	if not self:getInstance(client, type) then return end
	if table.size(tbl) == 0 then return end
	local instance = self:getInstance(client, type)
	local error = false
	local rank = instance:getPlayerRank(playerId)

	if permissionsType == "permission" then
		if not self:hasPlayerPermissionsTo(client, type, "changePermissions") then
			client:sendError(_("Du bist nicht berechtigt die Rechte zu verändern!", client))
			return 
		end
		if rank == self.m_LeaderRank[type] or rank > instance:getPlayerRank(client) then 
			client:sendError(_("Du kannst die Rechte von dem Spieler nicht verändern.", client))
			return 
		end

		if not instance:isPlayerMember(playerId) then return end
		
		for name, state in pairs(tbl) do
			if rank >= PERMISSIONS_INFO[name][2][type] then
				if state == "default" then state = nil end
				instance.m_PlayerPermissions[tonumber(playerId)][name] = state
			else
				error = true
			end	
		end
	elseif permissionsType == "action" then
		if not self:hasPlayerPermissionsTo(client, type, "editActionPermissions") then 
			client:sendError(_("Du bist nicht berechtigt die Aktionsrechte zu verändern!", client)) 
			return 
		end
		if rank == self.m_LeaderRank[type] or rank > instance:getPlayerRank(client) then 
			client:sendError(_("Du kannst die Aktionsrechte von dem Spieler nicht verändern.", client))
			return
		end
		if not instance:isPlayerMember(playerId) then return end
		
		for name, state in pairs(tbl) do
			if rank >= ACTION_PERMISSIONS_INFO[name][2][type] then
				if self:isPlayerAllowedToStart(client, type, name) then
					if state == "default" then state = nil end
					instance.m_PlayerActionPermissions[tonumber(playerId)][name] = state
				else
					error = true
				end
			end
		end
	elseif permissionsType == "weapon" then
		if not self:hasPlayerPermissionsTo(client, type, "editWeaponPermissions") then
			client:sendError(_("Du bist nicht berechtigt die Waffenrechte zu verändern!", client))
			return
		end
		if rank == self.m_LeaderRank[type] or rank > instance:getPlayerRank(client) then
			client:sendError(_("Du kannst die Waffenberechtigung von dem Spieler nicht verändern.", client))
			return
		end
		if not instance:isPlayerMember(playerId) then return end
		
		for name, state in pairs(tbl) do
			if self:isPlayerAllowedToTake(client, type, name) then
				if state == "default" then state = nil end
				instance.m_PlayerWeaponPermissions[tonumber(playerId)][tostring(name)] = state
			else
				error = true
			end
		end
	end

	instance:savePlayerPermissions(playerId)
	if DatabasePlayer.getFromId(playerId) then
		self:syncPermissions(DatabasePlayer.getFromId(playerId), type)
	end

	local text = error and "Einige Rechte konnten nicht geändert werden." or "Rechte erfolgreich geändert."
	client:sendInfo(_("%s", client, text))
	self:addLog(instance, client, permissionsType, playerId)

	self:Event_requestPlayerPermissionsList(permissionsType, rank, type, playerId, client)
end

function PermissionsManager:hasPlayerPermissionsTo(player, type, permission)	
	if not self:getInstance(player, type) then return false end

	local instance = self:getInstance(player, type)

	if PERMISSIONS_INFO[permission][2][type] > instance:getPlayerRank(player) then
		return false
	elseif instance.m_PlayerPermissions[player:getId()][permission] == true then
		return true
	elseif instance.m_PlayerPermissions[player:getId()][permission] == false then
		return false
	elseif instance.m_RankPermissions[tostring(instance:getPlayerRank(player:getId()))][permission] == true then
		return true
	end

	return false 
end

function PermissionsManager:isPlayerAllowedToStart(player, type, action)
	if not self:getInstance(player, type) then return false end
	
	local instance = self:getInstance(player, type)
	
	if self:hasPlayerPermissionsTo(player, type, "changePermissions") then
		return true 
	elseif instance.m_PlayerActionPermissions[tonumber(player:getId())][action] == true then
		return true
	elseif instance.m_PlayerActionPermissions[tonumber(player:getId())][action] == false then
		return false
	elseif instance.m_RankActions[tostring(instance:getPlayerRank(player))][action] then
		return true
	end

	return false 
end

function PermissionsManager:isPlayerAllowedToTake(player, type, weapon)
	if not self:getInstance(player, type) then return false end
	
	local instance = self:getInstance(player, type)
	
	if self:hasPlayerPermissionsTo(player, type, "changePermissions") then
		return true 
	elseif instance.m_PlayerWeaponPermissions[tonumber(player:getId())][tonumber(weapon)] == true then
		return true
	elseif instance.m_PlayerWeaponPermissions[tonumber(player:getId())][tonumber(weapon)] == false then
		return false
	elseif instance.m_RankWeapons[tostring(instance:getPlayerRank(player))][tostring(weapon)] == 1 then
		return true
	end

	return false
end

function PermissionsManager:syncPermissions(player, type, uninvite)
	local temp = {}

	if not uninvite then
		for i, type in pairs(type == "all" and {"faction", "company", "group"} or {type}) do
			if self:getInstance(player, type) then
				local instance = self:getInstance(player, type)
				temp[type] = {}
				temp[type]["permission"] = instance.m_RankPermissions
				temp[type]["playerPermission"] = instance.m_PlayerPermissions[player:getId()]
				if type == "faction" then
					temp[type]["action"] = instance.m_RankActions
					temp[type]["weapon"] = instance.m_RankWeapons
					temp[type]["playerAction"] = instance.m_PlayerActionPermissions[player:getId()]
					temp[type]["playerWeapon"] = instance.m_PlayerWeaponPermissions[player:getId()]
				end 
			end
		end
	else
		temp[type] = {}
		temp[type]["permission"] = {}
		temp[type]["action"] = {}
		temp[type]["weapon"] = {}
		temp[type]["playerPermission"] = {}
		temp[type]["playerAction"] = {}
		temp[type]["playerWeapon"] = {}
	end
	player:triggerEvent("recievePermissions", temp)
end

function PermissionsManager:onRankChange(changeType, changer, playerId, type)
	if not self:getInstance(changer, type) then return false end
	
	local instance = self:getInstance(changer, type)
	local playerPerm = instance.m_PlayerPermissions[tonumber(playerId)]
	if changeType == "down" then
		for name, state in pairs(playerPerm) do
			if instance:getPlayerRank(playerId) < PERMISSIONS_INFO[name][2][type] then
				playerPerm[name] = nil
			end
		end		
	elseif changeType == "up" then
		if instance:getPlayerRank(playerId) == self.m_LeaderRank[type] then
			for name, state in pairs(playerPerm) do
				playerPerm[name] = nil
			end
		end
	end

	if DatabasePlayer.getFromId(playerId) then
		self:syncPermissions(DatabasePlayer.getFromId(playerId), type)
	end		
end



function PermissionsManager:checkForNewActions()
	for name, info in pairs(ACTION_PERMISSIONS_INFO) do
		for i, faction in pairs(FactionManager:getSingleton():getAllFactions()) do
			if (info[1][1] == 0 or (info[1][1] == 1 and table.find(info[1][2], faction:getId()))) and ACTION_PERMISSIONS_INFO[name][2]["faction"] then
				if not faction.m_RankActions["6"][name] then
					for rank = 0, 6 do
						faction.m_RankActions[tostring(rank)][name] = true
					end
				end
			end
		end
	end
end

function PermissionsManager:checkForNewPermissions()
	for name, info in pairs(PERMISSIONS_INFO) do
		for i, faction in pairs(FactionManager:getSingleton():getAllFactions()) do
			if (info[1][1] == 0 or (info[1][1] == 1 and table.find(info[1][2], faction:getId()))) and PERMISSIONS_INFO[name][2]["faction"] then
				if not faction.m_RankPermissions["6"][name] then
					for rank = 0, 6 do
						if rank ~= 6 then state = false else state = true end
						faction.m_RankPermissions[tostring(rank)][name] = state
					end
				end
			end
		end
		for i, company in pairs(CompanyManager.Map) do
			if (info[1][1] == 0 or (info[1][1] == 2 and table.find(info[1][2], company:getId()))) and PERMISSIONS_INFO[name][2]["company"] then
				if not company.m_RankPermissions["5"][name] then
					for rank = 0, 5 do
						if rank ~= 5 then state = false else state = true end
						company.m_RankPermissions[tostring(rank)][name] = state
					end
				end
			end
		end
		for i, group in pairs(GroupManager.Map) do
			if info[1][1] == 0 and PERMISSIONS_INFO[name][2]["group"] then
				if not group.m_RankPermissions["6"][name] then
					for rank = 0, 6 do
						if rank ~= 6 then state = false else state = true end
						group.m_RankPermissions[tostring(rank)][name] = state
					end
				end
			end
		end
	end
end

function PermissionsManager:getInstance(player, type)
	local instance = false
	if type == "faction" then
		if player:getFaction() then	instance = player:getFaction() end
	elseif type == "company" then
		if player:getCompany() then instance = player:getCompany() end
	elseif type == "group" then
		if player:getGroup() then instance = player:getGroup() end
	end
	return instance
end

function PermissionsManager:addLog(instance, player, type, target)
	local permType = "Rechte"
	if type == "action" then
		permType = "Aktionsrechte"
	elseif type == "weapon" then
		permType = "Waffenrechte"
	end

	if target then
		instance:addLog(player, "Rechte", ("hat die %s von %s geändert"):format(permType, Account.getNameFromId(tonumber(target))))
	else
		instance:addLog(player, "Rechte", ("hat die %s geändert"):format(permType))
	end
end