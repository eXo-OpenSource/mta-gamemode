-- ****************************************************************************
-- *
-- *  PROJECT:     vRoleplay
-- *  FILE:        server/classes/ForumPermissions.lua
-- *  PURPOSE:     Forum Permissions Class
-- *
-- ****************************************************************************
ForumPermissions = inherit(Singleton)

function ForumPermissions:constructor()
	addRemoteEvents{"forumPermissionsGet", "forumPermissionsSync"}

	addEventHandler("forumPermissionsGet", root, bind(self.Event_GetForumPermissions, self))
	addEventHandler("forumPermissionsSync", root, bind(self.Event_SyncGroups, self))

	self.m_LastSync = {
		faction = {},
		company = {}
	}
	-- TODO: last sync block
end

function ForumPermissions:destructor()

end

function ForumPermissions:Event_GetForumPermissions(factionOrCompany, id)
	Async.create(function()
		self:sendForumPermissions(client, factionOrCompany, id)
	end)(client, factionOrCompany, id)
end


function ForumPermissions:Event_SyncGroups(factionOrCompany, id)
	if factionOrCompany == "faction" or factionOrCompany == "company" then
		if factionOrCompany == "faction" then
			if client:getFaction():getPlayerRank(client) < CompanyRank.Manager then
				client:sendError(_("Du bist nicht berechtigt!", client))
				return
			end
		else
			if client:getCompany():getPlayerRank(client) < FactionRank.Manager then
				client:sendError(_("Du bist nicht berechtigt!", client))
				return
			end
		end

		if not self.m_LastSync[factionOrCompany][id] then
			self.m_LastSync[factionOrCompany][id] = 0
		end

		if self.m_LastSync[factionOrCompany][id] + 5 * 60 * 1000 > getTickCount() then
			client:sendError(_("Es kann nur alle 5 Minuten ein manuelles syncronisieren durchgeführt werden!", client))
			return
		end

		self.m_LastSync[factionOrCompany][id] = getTickCount()
	else
		if player:getRank() < ADMIN_RANK_PERMISSION["syncForum"] then
			client:sendError(_("Du bist nicht berechtigt!", client))
			return
		end
	end

	Async.create(function()
		client:sendSuccess(_("Die synchronisation der Gruppen wurde gestartet und dieser Prozess kann ein paar Minuten in Anspruch nehmen.", client))
		ServiceSync:getSingleton():syncAllUsers(client, factionOrCompany, id)
		self:sendForumPermissions(client, factionOrCompany, id)
	end)(client, factionOrCompany, id)
end

function ForumPermissions:sendForumPermissions(player, factionOrCompany, id)
	if player then
		local result = {}
		if factionOrCompany == "faction" or factionOrCompany == "company" then
			if factionOrCompany == "faction" then
				if player:getFaction():getPlayerRank(player) < CompanyRank.Manager then
					player:sendError(_("Du bist nicht berechtigt!", player))
					return
				end
			else
				if player:getCompany():getPlayerRank(player) < FactionRank.Manager then
					player:sendError(_("Du bist nicht berechtigt!", player))
					return
				end
			end

			local groups = ServiceSync:getSingleton().m_Data["forumGroups"][factionOrCompany][id]
			for _, group in pairs(groups) do
				result[group] = {
					name = ServiceSync:getSingleton().m_ForumGroups[group],
					players = ServiceSync:getSingleton().m_ForumGroupMembers[group]
				}
			end
		else
			if player:getRank() < ADMIN_RANK_PERMISSION["syncForum"] then
				player:sendError(_("Du bist nicht berechtigt!", player))
				return
			end

			for index, group in pairs(ServiceSync:getSingleton().m_ForumGroups) do
				result[index] = {
					name = group,
					players = ServiceSync:getSingleton().m_ForumGroupMembers[index]
				}
			end
		end

		player:triggerEvent("forumPermissionsReceive", result)
	end
end
